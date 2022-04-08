//
//  ShoppingList+Earned.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 8/4/22.
//

import Foundation

extension ShoppingList {

    var markets: [Market]? {
        return (self.products as? Set<ChosenProduct>)?.compactMap { $0.market }
    }

    var earned: Double {
        guard let products = products else {
            return 0.0
        }

        let availableMarkets = markets

        let maxPrices: [Double] = products.compactMap { product in
            guard let chosenProduct = product as? ChosenProduct else {
                return 0.0
            }
            let maxPrice = chosenProduct.offer?.product?.offers?
                .compactMap { $0 as? Offer }
                .filter {$0 != chosenProduct.offer}
                .filter { offer in
                    guard let availableMarkets = availableMarkets else {
                        return true
                    }

                    if availableMarkets.count == 1 {
                        return true
                    }
                    guard let market = offer.market else {
                        return false
                    }
                    return availableMarkets.contains(market)
                }
                .compactMap { $0.price }
                .sorted().last ?? chosenProduct.price
            return (maxPrice - chosenProduct.price) * Double(chosenProduct.quantity)
        }
        return maxPrices.reduce(0.0, +)
    }
}
