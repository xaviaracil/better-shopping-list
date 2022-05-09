//
//  WCChosenProduct.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 3/5/22.
//

import Foundation
import CoreData

extension Collection where Element == ChosenProduct {
    func toPropertyList() throws -> Data {
        let encoder = PropertyListEncoder()
        return try encoder.encode(self.map { WCChosenProduct(chosenProduct: $0) })
    }
}

/// Data transfer struct between iOS App and watch extension
struct WCChosenProduct: Codable {
    let name: String
    let price: Double
    let quantity: Int

    init(chosenProduct: ChosenProduct) {
        self.name = chosenProduct.wrappedName
        self.quantity = Int(chosenProduct.quantity)
        self.price = chosenProduct.price
    }

    func toChosenProduct(context: NSManagedObjectContext) -> ChosenProduct {
        let chosenProduct = ChosenProduct(context: context)
        chosenProduct.name = self.name
        chosenProduct.quantity = Int16(self.quantity)
        chosenProduct.price = self.price
        return chosenProduct
    }
}
