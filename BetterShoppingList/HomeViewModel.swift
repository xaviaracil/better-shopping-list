//
//  ContentViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 5/4/22.
//

import Foundation

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
    
    let shoppingAssistant: ShoppingAssistant

    init(hideSplash: Bool = false, shoppingAssistant: ShoppingAssistant) {
        self.hideSplash = hideSplash
        self.shoppingAssistant = shoppingAssistant
    }
}
