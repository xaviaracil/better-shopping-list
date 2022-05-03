//
//  DummyPersistenceAdapter.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 18/4/22.
//

import Foundation
import CoreData
@testable import BetterShoppingList

struct DummyPersistenceAdapter: PersistenceAdapter {
    var savedListsFetchRequest: NSFetchRequest<ShoppingList> {
        NSFetchRequest()
    }

    var currentListFetchRequest: NSFetchRequest<ShoppingList> {
        NSFetchRequest()
    }

    var markertsFetchRequest: NSFetchRequest<Market> {
        NSFetchRequest()
    }

    var currentList: ShoppingList?

    var markets: [Market]?

    func newList(isCurrent: Bool) -> ShoppingList {
        return ShoppingList()
    }

    func newChosenProduct(offer: Offer, quantity: Int16) -> ChosenProduct {
        return ChosenProduct()
    }

    func offersFetchRequest(productName text: String, in markets: [String]) -> NSFetchRequest<Offer> {
        NSFetchRequest()
    }

    func productNamePredicate(for text: String, in markets: [Market]) -> NSPredicate? {
        return nil
    }

    func save() {
        // nothing here
    }

    func removeChosenProduct(_ chosenProduct: ChosenProduct) {
        // nothing here
    }

    func removeList(_ list: ShoppingList) {
        // nothing here
    }

    func addProductToCurrentList(_ product: ChosenProduct) throws {
        // nothing here
    }

}
