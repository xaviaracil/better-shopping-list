//
//  ShoppingAssitant.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 4/4/22.
//

import Foundation
import CoreData
// import Algorithms
import Combine

/// Main Model class for the application
class ShoppingAssistant: ObservableObject, PersistenceAdapter, WatchConnectorDelegate {
    @Published var currentList: ShoppingList? {
        didSet {
            listMarketLocationManager.shoppingList = currentList
        }
    }

    @Published var markets: [Market]?

    let persitenceAdapter: PersistenceAdapter

    let listMarketLocationManager = ListMarketLocationManager()
    let watchConnector = WatchConnector()

    @Published var marketTheUserIsInCurrently: Market? {
        didSet {
            self.userIsinAMarket = marketTheUserIsInCurrently != nil
            if self.userIsinAMarket {
                // notify watch app
                if let products = self.currentList?.products as? Set<ChosenProduct> {
                    watchConnector.notifyProducts(products.map {$0.objectID }, for: marketTheUserIsInCurrently!)
                }
            }
        }
    }

    @Published var userIsinAMarket = false

    @Published var switchToInMarketView = false

    private var cancellableSet: Set<AnyCancellable> = []

    init(persistenceAdapter: PersistenceAdapter) {
        self.persitenceAdapter = persistenceAdapter
        currentList = persistenceAdapter.currentList
        markets = persistenceAdapter.markets

        listMarketLocationManager.currentMarketPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .assign(to: \.marketTheUserIsInCurrently, on: self)
            .store(in: &cancellableSet)

        watchConnector.delegate = self
    }

    var savedListsFetchRequest: NSFetchRequest<ShoppingList> {
        persitenceAdapter.savedListsFetchRequest
    }

    var currentListFetchRequest: NSFetchRequest<ShoppingList> {
        persitenceAdapter.currentListFetchRequest
    }

    var markertsFetchRequest: NSFetchRequest<Market> {
        persitenceAdapter.markertsFetchRequest
    }

    func newList(isCurrent: Bool) -> ShoppingList {
        persitenceAdapter.newList(isCurrent: isCurrent)
    }

    func newChosenProduct(offer: Offer, quantity: Int16) -> ChosenProduct {
        persitenceAdapter.newChosenProduct(offer: offer, quantity: quantity)
    }

    ///
    /// Creates a new current list from another list. The new list contains the same products than the original list,
    /// with the best offers.
    /// - Parameters:
    ///     - from: The list to copy the products from
    func newList(from list: ShoppingList) {
        let newList = persitenceAdapter.newList(isCurrent: true)
        if let products = list.products {
            // copy offers from list to the new list
            for chosenProduct in products {
                if let chosenProduct = chosenProduct as? ChosenProduct,
                   let product = chosenProduct.offer?.product {
                    // search best offer for product
                    let bestOffer = product.sorteredOffers?.first ?? chosenProduct.offer!

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
        do {
            try save()
            currentList = persitenceAdapter.currentList
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func offersFetchRequest(productName text: String, in markets: [String] = []) -> NSFetchRequest<Offer> {
        return persitenceAdapter.offersFetchRequest(productName: text, in: markets)
    }

    func productNamePredicate(for text: String) -> NSPredicate? {
        return persitenceAdapter.productNamePredicate(for: text)
    }

    func addProductToCurrentList(_ product: ChosenProduct) {
        do {
            try persitenceAdapter.addProductToCurrentList(product)
            reloadCurrentList()
            donateIntent(product: product)
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    public func toogleFavourite(market: Market) {
        var userMarket = market.userMarket
        if userMarket == nil {
            userMarket = UserMarket(context: market.managedObjectContext!)
            userMarket?.marketUUID = market.uuid
        }
        guard let userMarket = userMarket else {
            return
        }
        userMarket.isFavorite.toggle()
    }

    ///
    /// Removes a chosen product
    /// - Parameters:
    ///     - the chosen product to remove
    public func removeChosenProduct(_ chosenProduct: ChosenProduct) {
        persitenceAdapter.removeChosenProduct(chosenProduct)
        do {
            try save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
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
        do {
            try save()
            currentList = persitenceAdapter.currentList
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return newList
    }

    ///
    /// Save context in database
    func save() throws {
        try persitenceAdapter.save()
    }

    func startSearchingForNearMarkets() {
        listMarketLocationManager.start()
    }

    func stopSearchingForNearMarkets() {
        listMarketLocationManager.stop()
    }

    // MARK: - WatchConnector Delegate
    func askForNearbyProducts() {
        startSearchingForNearMarkets()
    }
}
