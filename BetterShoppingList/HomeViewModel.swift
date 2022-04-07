//
//  ContentViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 5/4/22.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var productAdded: Bool = false {
        didSet {
            if productAdded {
                searchText = ""
                productAdded = false
            }
        }
    }
    @Published var splashDisplayed = false
    @Published var searchText = ""
    @Published var hideSplash: Bool
    var displaySlash: Bool {
        !splashDisplayed && !hideSplash
    }

    @Published var productsFetchRequest: FetchRequest<ChosenProduct>
    @Published var savedListsFetchRequest: FetchRequest<ShoppingList>
    @Published var marketsFetchRequest: FetchRequest<Market>

    let shoppingAssistant: ShoppingAssistant

    init(hideSplash: Bool = false, shoppingAssistant: ShoppingAssistant) {
        self.hideSplash = hideSplash
        self.shoppingAssistant = shoppingAssistant
        productsFetchRequest = FetchRequest(fetchRequest: shoppingAssistant.currentProductsFetchRequest, animation: .default)
        savedListsFetchRequest = FetchRequest(fetchRequest: shoppingAssistant.savedListsFetchRequest, animation: .default)
        marketsFetchRequest = FetchRequest(fetchRequest: shoppingAssistant.markertsFetchRequest, animation: .default)
    }
}
