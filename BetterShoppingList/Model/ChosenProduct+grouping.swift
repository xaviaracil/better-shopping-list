//
//  ChosenProduct+grouping.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 5/4/22.
//

import Foundation

extension Collection where Element == ChosenProduct {
    func groupedByMarket(markets: [Market]) -> [Market] {
        let dict = Dictionary(grouping: self) {
            $0.marketUri
        }
        return dict.keys
            .filter { marketUri in
                marketUri != nil
            }
            .compactMap { marketUri in
                return markets.first { market in
                    market.objectID.uriRepresentation() == marketUri
                }
            }
            .sorted {
                $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending
            }
    }

    func ofMarket(market: Market) -> [Element] {
        return self.filter { product in
            product.marketUri == market.objectID.uriRepresentation()
        }
    }
}
