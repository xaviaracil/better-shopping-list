//
//  Queries.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 1/4/22.
//

import Foundation
import CoreData

struct OfferQueries {
    let context: NSManagedObjectContext

    func query(text: String, markets: [String] = []) throws -> [Offer] {
        let fetchRequest = Offer.fetchRequest()
        fetchRequest.predicate = predicateFor(text: text, markets: markets)
        fetchRequest.relationshipKeyPathsForPrefetching = ["market", "product"]
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Offer.product?.name, ascending: true), // by product
            NSSortDescriptor(keyPath: \Offer.price, ascending: true) // then by price
        ]
        return try context.fetch(fetchRequest)
    }

    private func predicateFor(text: String, markets: [String]) -> NSPredicate {
        let words = text.components(separatedBy: " ")
        var textPredicates: [NSPredicate] = []
        for word in words {
            let predicate = NSPredicate(format: "product.name CONTAINS[cd] %@", word)
            textPredicates.append(predicate)
        }
        let namePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: textPredicates)

        if !markets.isEmpty {
            let marketsPredicate = NSPredicate(format: "market.name IN %@", markets)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, marketsPredicate])
        }

        return namePredicate
    }
}