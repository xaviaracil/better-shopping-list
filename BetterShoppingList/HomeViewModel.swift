//
//  HomeViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 8/4/22.
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
    @Published var searchText = ""
    @Published var productsFetchRequest: FetchRequest<ChosenProduct>
    @Published var savedListsFetchRequest: FetchRequest<ShoppingList>

    let shoppingAssistant: ShoppingAssistant

    var canSearch: Bool {
        searchText.count > 2
    }

    init(shoppingAssistant: ShoppingAssistant) {
        self.shoppingAssistant = shoppingAssistant
        productsFetchRequest = FetchRequest(fetchRequest: shoppingAssistant.currentProductsFetchRequest,
                                            animation: .default)
        savedListsFetchRequest = FetchRequest(fetchRequest: shoppingAssistant.savedListsFetchRequest,
                                              animation: .default)
    }
}
