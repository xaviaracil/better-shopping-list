//
//  ChosenProduct+grouping.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 5/4/22.
//

import Foundation

extension ChosenProduct {
    var offer: Offer? {
        let array = value(forKey: "offer") as? [Offer]
        return array?.first
    }

    var market: Market? {
        let array = value(forKey: "market") as? [Market]
        return array?.first

    }
}

extension Collection where Element == ChosenProduct {
    func groupedByMarket(markets: [Market]) -> [Market] {
        return self
            .compactMap { $0.market }
            .uniqued()
            .sorted {
                $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending
            }
    }

    func ofMarket(market: Market) -> [Element] {
        return self.filter { product in
            product.market == market
        }.sorted { lhs, rhs in
            lhs.wrappedName < rhs.wrappedName
        }
    }
}
