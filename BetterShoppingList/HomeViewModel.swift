//
//  HomeViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 8/4/22.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var savedListsFetchRequest: FetchRequest<ShoppingList>

    var currentList: ShoppingList? {
        shoppingAssistant.currentList
    }

    let shoppingAssistant: ShoppingAssistant

    init(shoppingAssistant: ShoppingAssistant) {
        self.shoppingAssistant = shoppingAssistant
        savedListsFetchRequest = FetchRequest(fetchRequest: shoppingAssistant.savedListsFetchRequest,
                                              animation: .default)
    }

    func productQueryPredicate(for text: String) -> NSPredicate? {
        return shoppingAssistant.productNamePredicate(for: text)
    }
}
