//
//  Market+usermarkets.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 13/4/22.
//

import Foundation

extension Market {
    var userMarkets: [UserMarket]? {
        value(forKey: "userMarkets") as? [UserMarket]
    }

    var userMarket: UserMarket? {
        return userMarkets?.first
    }
}
