//
//  ShoppingAssitant.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 4/4/22.
//

import Foundation
import CoreData

/// Main Model class for the application
class ShoppingAssitant: ObservableObject, PersistenceAdapter {
    @Published var currentList: ShoppingList?

    let persitenceAdapter: PersistenceAdapter
    init(persistenceAdapter: PersistenceAdapter) {
        self.persitenceAdapter = persistenceAdapter
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
