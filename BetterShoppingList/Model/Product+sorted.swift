//
//  Product+sorted.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 30/4/22.
//
import Foundation

extension Product {
    var sorteredOffers: [Offer]? {
        self.offers?.sortedArray(using: [NSSortDescriptor(keyPath: \Offer.price, ascending: true)]) as? [Offer]
    }
}
