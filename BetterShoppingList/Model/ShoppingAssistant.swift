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

    let persitenceAdapter: PersistenceAdapter
    init(persistenceAdapter: PersistenceAdapter) {
        self.persitenceAdapter = persistenceAdapter
        currentList = persistenceAdapter.currentList
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

    func addProductToCurrentList(_ product: ChosenProduct) {
        if currentList == nil {
            currentList = newList(isCurrent: true)
        }
        currentList?.addToProducts(product)
    }
}

extension ShoppingList {
    var markets: [URL]? {
        return (self.products as? Set<ChosenProduct>)?.compactMap { $0.marketUri }
    }
}
