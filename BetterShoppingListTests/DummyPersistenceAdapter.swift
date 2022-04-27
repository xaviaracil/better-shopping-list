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

    func offersFetchRequest(productName text: String, in markets: [String]) -> NSFetchRequest<Offer> {
        NSFetchRequest()
    }

    func productNamePredicate(for text: String) -> NSPredicate? {
        return nil
    }

    func save() throws {
        // nothing here
    }

    func removeChosenProduct(_ chosenProduct: ChosenProduct) {
        // nothing here
    }
}
