//
//  HomeViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 8/4/22.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var productsFetchRequest: FetchRequest<ChosenProduct>
    @Published var savedListsFetchRequest: FetchRequest<ShoppingList>

    var currentList: ShoppingList? {
        shoppingAssistant.currentList
    }

    let shoppingAssistant: ShoppingAssistant

    init(shoppingAssistant: ShoppingAssistant) {
        self.shoppingAssistant = shoppingAssistant
        productsFetchRequest = FetchRequest(fetchRequest: shoppingAssistant.currentProductsFetchRequest,
                                            animation: .default)
        savedListsFetchRequest = FetchRequest(fetchRequest: shoppingAssistant.savedListsFetchRequest,
                                              animation: .default)
    }

    func productQueryPredicate(for text: String) -> NSPredicate? {
        print("🖥 predicate for \(text)")
        return shoppingAssistant.productNamePredicate(for: text)
    }
}
