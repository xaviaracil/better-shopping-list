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

    func query(name: String, markets: [String] = []) throws -> [Offer] {
        let fetchRequest = Offer.fetchRequest()
        fetchRequest.predicate = predicateFor(name: name, markets: markets)
        fetchRequest.relationshipKeyPathsForPrefetching = ["market", "product"]
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Offer.price, ascending: true)]
        return try context.fetch(fetchRequest)
    }

    private func predicateFor(name: String, markets: [String]) -> NSPredicate {
        var predicate = "product.name CONTAINS[cd] %@"
        if !markets.isEmpty {
            predicate.append(" AND market.name IN %@")
        }
        return NSPredicate(format: predicate, name, markets)
    }
}
