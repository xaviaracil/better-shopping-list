//
//  PersistenceAdapter.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 4/4/22.
//

import Foundation
import CoreData
import SwiftUI

protocol PersistenceAdapter {
    var savedListsFetchRequest: NSFetchRequest<ShoppingList> { get }
    var currentListFetchRequest: NSFetchRequest<ShoppingList> { get }
    var markertsFetchRequest: NSFetchRequest<Market> { get }
    var currentList: ShoppingList? { get }
    var markets: [Market]? { get }

    func newList(isCurrent: Bool) -> ShoppingList
    func newChosenProduct(offer: Offer, quantity: Int16) -> ChosenProduct
    func offersFetchRequest(productName text: String, in markets: [String]) -> NSFetchRequest<Offer>
    func productNamePredicate(for text: String) -> NSPredicate?
    func removeChosenProduct(_ chosenProduct: ChosenProduct)
    func save() throws
}

struct CoreDataPersistenceAdapter: PersistenceAdapter {
    let viewContext: NSManagedObjectContext
    let coordinator: NSPersistentStoreCoordinator

    func newList(isCurrent: Bool = false) -> ShoppingList {
        let list = ShoppingList(context: viewContext)
        list.isCurrent = isCurrent
        list.timestamp = Date()
        return list
    }

    func newChosenProduct(offer: Offer, quantity: Int16) -> ChosenProduct {
        let chosenProduct = ChosenProduct(context: viewContext)
        chosenProduct.name = offer.product?.name
        chosenProduct.price = offer.price
        chosenProduct.quantity = quantity
        chosenProduct.isSpecialOffer = offer.isSpecialOffer
        chosenProduct.marketUUID = offer.market?.uuid
        chosenProduct.offerUUID = offer.uuid
        return chosenProduct
    }

    var savedListsFetchRequest: NSFetchRequest<ShoppingList> {
        let fetchRequest = ShoppingList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isCurrent == NO")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ShoppingList.timestamp, ascending: true)]
        return fetchRequest
    }

    var currentList: ShoppingList? {
        let results = try? viewContext.fetch(currentListFetchRequest)
        return results?.first
    }

    var markets: [Market]? {
        try? viewContext.fetch(markertsFetchRequest)
    }

    var currentListFetchRequest: NSFetchRequest<ShoppingList> {
        let fetchRequest = ShoppingList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isCurrent == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ShoppingList.timestamp, ascending: false)]
        fetchRequest.fetchLimit = 1
        return fetchRequest
    }

    var markertsFetchRequest: NSFetchRequest<Market> {
        let fetchRequest = Market.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Market.name, ascending: true)]
        return fetchRequest
    }

    func offersFetchRequest(productName text: String, in markets: [String] = []) -> NSFetchRequest<Offer> {
        let fetchRequest = Offer.fetchRequest()
        fetchRequest.predicate = offersNamePredicate(for: text, markets: markets)
        fetchRequest.relationshipKeyPathsForPrefetching = ["market", "product"]
        fetchRequest.fetchBatchSize = 100
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Offer.product?.name, ascending: true), // by product
            NSSortDescriptor(keyPath: \Offer.price, ascending: true) // then by price
        ]
        return fetchRequest

    }

    func offersNamePredicate(for text: String, markets: [String] = []) -> NSPredicate {
        let words = text.components(separatedBy: " ")
        var textPredicates: [NSPredicate] = []
        for word in words {
            if !word.isEmpty && !(word == " ") {
                let predicate = NSPredicate(format: "product.name CONTAINS[cd] %@", word)
                textPredicates.append(predicate)
            }
        }
        let namePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: textPredicates)

        if !markets.isEmpty {
            let marketsPredicate = NSPredicate(format: "market.name IN %@", markets)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, marketsPredicate])
        }

        return namePredicate
    }

    func productNamePredicate(for text: String) -> NSPredicate? {
        guard !text.isEmpty else {
            return nil
        }
        let words = text.components(separatedBy: " ")
        var textPredicates: [NSPredicate] = []
        for word in words {
            if !word.isEmpty && !(word == " ") {
                let predicate = NSPredicate(format: "name CONTAINS[cd] %@", word)
                textPredicates.append(predicate)
            }
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: textPredicates)
    }

    func removeChosenProduct(_ chosenProduct: ChosenProduct) {
        viewContext.delete(chosenProduct)
    }

    func save() throws {
        try viewContext.save()
    }
}
