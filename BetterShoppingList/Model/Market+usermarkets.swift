//
//  Market+usermarkets.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 13/4/22.
//

import Foundation

extension Market {
    var userMarket: UserMarket? {
        let array = value(forKey: "userMarket") as? [UserMarket]
        return array?.first

    }
}
