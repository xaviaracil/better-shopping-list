//
//  ChosenProduct+grouping.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 5/4/22.
//

import Foundation
import Algorithms
import SwiftUI

extension Collection where Element == ChosenProduct {
    func groupedByMarket(markets: FetchedResults<Market>) -> [Market] {
        self.chunked(on: \.marketUri)
            .filter { marketUri, _ in
                marketUri != nil
            }
            .map { marketUri, _ in
                return markets.first { market in
                    market.objectID.uriRepresentation() == marketUri
                }
            }
            .filter { marketUri in
                marketUri != nil
            }
            .map { $0! }
    }

    func ofMarket(market: Market) -> [Element] {
        return self.filter { product in
            product.marketUri == market.objectID.uriRepresentation()
        }
    }
}
