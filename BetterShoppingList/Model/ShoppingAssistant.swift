//
//  ShoppingAssitant.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 4/4/22.
//

import Foundation
import CoreData
import Algorithms

/// Main Model class for the application
class ShoppingAssistant: ObservableObject, PersistenceAdapter {
    @Published var currentList: ShoppingList?
    @Published var markets: [Market]?

    let persitenceAdapter: PersistenceAdapter
    init(persistenceAdapter: PersistenceAdapter) {
        self.persitenceAdapter = persistenceAdapter
        currentList = persistenceAdapter.currentList
        markets = persistenceAdapter.markets
    }

    var savedListsFetchRequest: NSFetchRequest<ShoppingList> {
        persitenceAdapter.savedListsFetchRequest
    }

    var currentProductsFetchRequest: NSFetchRequest<ChosenProduct> {
        persitenceAdapter.currentProductsFetchRequest
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

    func offersFetchRequest(productName text: String, in markets: [String] = []) -> NSFetchRequest<Offer> {
        return persitenceAdapter.offersFetchRequest(productName: text, in: markets)
    }

    func productNamePredicate(for text: String) -> NSPredicate? {
        return persitenceAdapter.productNamePredicate(for: text)
    }

    func addProductToCurrentList(_ product: ChosenProduct) {
        if currentList == nil {
            currentList = newList(isCurrent: true)
        }
        currentList?.addToProducts(product)
        do {
            try save()
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

    public func saveList(name: String) -> ShoppingList {
        let newList = currentList!
        newList.isCurrent = false
        newList.name = name
        do {
            try save()
            currentList = persitenceAdapter.currentList
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return newList
    }

    func save() throws {
        try persitenceAdapter.save()
    }
}
