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

    func query(name: String) throws -> [Offer] {
        let fetchRequest = Offer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "product.name CONTAINS[cd] %@", name)
        fetchRequest.relationshipKeyPathsForPrefetching = ["market", "product"]
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Offer.price, ascending: true)]
        return try context.fetch(fetchRequest)
    }
}
