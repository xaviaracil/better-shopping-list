//
//  ShoppingAssitant.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 4/4/22.
//

import Foundation
import CoreData
import Combine
import Intents
import SwiftUI
import WidgetKit

/// Main Model class for the application
class ShoppingAssistant: ObservableObject, PersistenceAdapter, WatchConnectorDelegate {
    @Published var currentList: ShoppingList? {
        didSet {
            listMarketLocationManager.shoppingList = currentList
        }
    }

    /// Markets the user can search products into
    @Published var markets: [Market]?

    let persistenceAdapter: PersistenceAdapter

    /// market location manager
    let listMarketLocationManager = ListMarketLocationManager()

    /// watch connector for comunicating with watch extension
    let watchConnector = WatchConnector()

    /// flag telling is location query is done by the watch
    public var askedFromWatch = false

    /// market the user is currently in, updated by location manager
    @Published var marketTheUserIsInCurrently: Market? {
        didSet {
            self.userIsinAMarket = !askedFromWatch && self.marketTheUserIsInCurrently != nil
            if self.marketTheUserIsInCurrently != nil {
                // notify watch app
                if let products = self.currentList?.products as? Set<ChosenProduct>,
                   let market = marketTheUserIsInCurrently {
                    let productsInMarket = products.ofMarket(market: market)
                    watchConnector.notifyProducts(productsInMarket, for: market)
                }
            }
            askedFromWatch = false
        }
    }

    /// flag telling if user in current in a market
    @Published var userIsinAMarket = false

    /// flag telling if we have to switch to "in market view"
    @Published var switchToInMarketView = false

    private var cancellableSet: Set<AnyCancellable> = []

    init(persistenceAdapter: PersistenceAdapter) {
        self.persistenceAdapter = persistenceAdapter
        currentList = persistenceAdapter.currentList
        markets = persistenceAdapter.markets?.filter { !$0.isExcluded }

        // subscribe to market search
        listMarketLocationManager.currentMarketPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .assign(to: \.marketTheUserIsInCurrently, on: self)
            .store(in: &cancellableSet)

        // set as watch connector delegate
        watchConnector.delegate = self

        // reload widget timeline
        reloadWidgets()
    }

    ///
    /// Filter offers by active markets
    /// - Parameters:
    ///     - product: The product to get the offers from
    ///
    func activeOffers(for product: Product) -> [Offer]? {
        product.sorteredOffers?.filter(offerIsIncluded)
    }

    ///
    /// Tells if offers is from a included market
    /// - Parameters:
    ///     - offer: The offer to filter
    /// - Returns: true if offer is from an included market, false otherwise
    func offerIsIncluded(_ offer: Offer) -> Bool {
        if markets == nil {
            return true
        }
        guard let market = offer.market,
              let markets = markets else {
            return false
        }
        return markets.contains(market)
    }

    ///
    /// Adds a chosen product to the current list. It's added if it's not already in.
    /// In that case, the existing product is replaced with the given by parameter
    /// - Parameters:
    ///     - product: The chosen product to add to the list
    ///
    func addProductToCurrentList(_ product: ChosenProduct) {
        do {
            let existingProduct = currentList?.chosenProductSet.first(where: { chosenProduct in
                guard let offer = chosenProduct.offer,
                      let productOffer = product.offer else {
                          return false
                      }
                return offer.product == productOffer.product
            })
            // if there's thre product already, remove it
            if let existingProduct = existingProduct {
                persistenceAdapter.removeChosenProduct(existingProduct)
            }

            try persistenceAdapter.addProductToCurrentList(product)
            reloadCurrentList()
            donateIntent(product: product)
            reloadWidgets()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    ///
    /// Creates a new current list from another list. The new list contains the same products than the original list,
    /// with the best offers.
    /// - Parameters:
    ///     - from: The list to copy the products from
    func newList(from list: ShoppingList) {
        let newList = persistenceAdapter.newList(isCurrent: true)
        if let products = list.products {
            // copy offers from list to the new list
            for chosenProduct in products {
                if let chosenProduct = chosenProduct as? ChosenProduct,
                   let product = chosenProduct.offer?.product {
                    // search best offer for product
                    let bestOffer = activeOffers(for: product)?.first ?? chosenProduct.offer!

                    var newChosenProduct: ChosenProduct
                    if let managedObjectContext = chosenProduct.managedObjectContext {
                        newChosenProduct = ChosenProduct(context: managedObjectContext)
                    } else {
                        newChosenProduct = ChosenProduct()
                    }
                    newChosenProduct.name = chosenProduct.name
                    newChosenProduct.price = bestOffer.price
                    newChosenProduct.quantity = chosenProduct.quantity
                    newChosenProduct.isSpecialOffer = bestOffer.isSpecialOffer
                    newChosenProduct.marketUUID = bestOffer.market?.uuid
                    newChosenProduct.offerUUID = bestOffer.uuid
                    newList.addToProducts(newChosenProduct)
                }
            }
        }
        save()
        reloadWidgets()
    }

    ///
    /// Removes a chosen product
    /// - Parameters:
    ///     - the chosen product to remove
    public func removeChosenProduct(_ chosenProduct: ChosenProduct) {
        persistenceAdapter.removeChosenProduct(chosenProduct)
        save()
        reloadWidgets()
    }

    ///
    /// Changes a chosen product to another offer in the current list
    /// - Parameters:
    ///     - the chosen product to remove
    ///     - to: new offer
    ///  - Returns: the new chosen product
    ///
    public func changeChosenProduct(_ chosenProduct: ChosenProduct, to offer: Offer) -> ChosenProduct {
        let newChosenProduct = newChosenProduct(offer: offer, quantity: chosenProduct.quantity)
        addProductToCurrentList(newChosenProduct)
        removeChosenProduct(chosenProduct)
        return newChosenProduct
    }

    ///
    /// Saves the list for further user. The list is no longer the current one
    /// - Parameters:
    ///     - name: The name which of the saved list
    /// - Returns: the saved list
    public func saveList(name: String) -> ShoppingList {
        let newList = currentList!
        newList.isCurrent = false
        newList.isFavorite = false
        newList.name = name
        newList.earning = newList.earned
        save()
        reloadWidgets()
        return newList
    }

    func reloadCurrentList() {
        currentList = persistenceAdapter.currentList
        markets = persistenceAdapter.markets?.filter { !$0.isExcluded }
    }

    // MARK: - PersistenceAdapter methods

    var savedListsFetchRequest: NSFetchRequest<ShoppingList> {
        persistenceAdapter.savedListsFetchRequest
    }

    var currentListFetchRequest: NSFetchRequest<ShoppingList> {
        persistenceAdapter.currentListFetchRequest
    }

    var markertsFetchRequest: NSFetchRequest<Market> {
        persistenceAdapter.markertsFetchRequest
    }

    func newList(isCurrent: Bool) -> ShoppingList {
        persistenceAdapter.newList(isCurrent: isCurrent)
    }

    func newChosenProduct(offer: Offer, quantity: Int16) -> ChosenProduct {
        persistenceAdapter.newChosenProduct(offer: offer, quantity: quantity)
    }


    func offersFetchRequest(productName text: String, in markets: [String] = []) -> NSFetchRequest<Offer> {
        return persistenceAdapter.offersFetchRequest(productName: text, in: markets)
    }

    func productNamePredicate(for text: String, in markets: [Market] = []) -> NSPredicate? {
        return persistenceAdapter.productNamePredicate(for: text, in: markets)
    }

    func removeList(_ list: ShoppingList) {
        persistenceAdapter.removeList(list)
        save()
    }

    ///
    /// Save context in database
    func save() {
        persistenceAdapter.save()
        reloadCurrentList()
    }

    // MARK: - Location
    func startSearchingForNearMarkets() {
        if !(currentList?.markets?.isEmpty ?? true) {
            listMarketLocationManager.start()
        }
    }

    func stopSearchingForNearMarkets() {
        listMarketLocationManager.stop()
    }

    // MARK: - Widgets
    func reloadWidgets() {
        // reload widgets
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetConstants.kind)
    }


    // MARK: - WatchConnector Delegate
    func askForNearbyProducts(in location: CLLocation) {
        askedFromWatch = true
        listMarketLocationManager.currentLocation = location
    }

    // MARK: - Siri
    private func donateIntent(product: ChosenProduct) {
        let intent = AddProductIntent()
        intent.suggestedInvocationPhrase = "Add \(String(describing: product.name))"
        intent.name = product.name
        intent.quantity = NSNumber(value: product.quantity)
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { (error) in
            if error != nil {
                if let error = error as NSError? {
                    print("Interaction donation failed: \(error.description)")
                } else {
                    print("Successfully donated interaction")
                }
            }
        }
    }
}
