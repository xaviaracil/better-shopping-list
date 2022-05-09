//
//  Product+sorted.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 30/4/22.
//
import Foundation

extension Product {
    /// sortered array of offers by price
    var sorteredOffers: [Offer]? {
        self.offers?.sortedArray(using: [NSSortDescriptor(keyPath: \Offer.price, ascending: true)]) as? [Offer]
    }
}
