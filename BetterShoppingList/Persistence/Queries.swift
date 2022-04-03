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

    static func queryFetchRequest(text: String, markets: [String] = []) -> NSFetchRequest<Offer> {
        let fetchRequest = Offer.fetchRequest()
        fetchRequest.predicate = predicateFor(text: text, markets: markets)
        fetchRequest.relationshipKeyPathsForPrefetching = ["market", "product"]
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Offer.product?.name, ascending: true), // by product
            NSSortDescriptor(keyPath: \Offer.price, ascending: true) // then by price
        ]
        return fetchRequest
    }

    private static func predicateFor(text: String, markets: [String]) -> NSPredicate {
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

struct ShoppingListQueries {
    static var savedListsFetchRequest: NSFetchRequest<ShoppingList> {
        let fetchRequest = ShoppingList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isCurrent = NO")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ShoppingList.timestamp, ascending: true)]
        return fetchRequest
    }
}

struct CurrentListQueries {
    static var productsFetchRequest: NSFetchRequest<ChosenProduct> {
        let fetchRequest = ChosenProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "list.isCurrent = YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ChosenProduct.name, ascending: true)]
        return fetchRequest
    }
}
