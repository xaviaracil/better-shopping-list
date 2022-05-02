//
//  MarketRowViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 2/5/22.
//

import Foundation
import SwiftUI

class MarketRowViewModel: ObservableObject {
    @Published var isFavorite: Bool {
        didSet {
            userMarket?.isFavorite = isFavorite
            shoppingAssistant.save()
        }
    }

    @Published var market: Market?

    var userMarket: UserMarket? {
        guard let market = market else {
            return nil
        }

        var userMarket = market.userMarket
        if userMarket == nil {
            userMarket = UserMarket(context: market.managedObjectContext!)
            userMarket?.marketUUID = market.uuid
        }
        return userMarket
    }

    var shoppingAssistant: ShoppingAssistant

    init(market: Market?, shoppingAssistant: ShoppingAssistant) {
        _market = .init(initialValue: market)
        _isFavorite = .init(initialValue: market?.userMarket?.isFavorite ?? false)
        self.shoppingAssistant = shoppingAssistant
    }

    func reload() {
        isFavorite = market?.userMarket?.isFavorite ?? false
    }
}
