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
        print("🖥 HomeViewModel init \(String(describing: shoppingAssistant.markets?.count))")
        self.shoppingAssistant = shoppingAssistant
        savedListsFetchRequest = FetchRequest(fetchRequest: shoppingAssistant.savedListsFetchRequest,
                                              animation: .default)
    }

    func productQueryPredicate(for text: String) -> NSPredicate? {
        print("🖥 HomeViewModel productQueryPredicate \(String(describing: shoppingAssistant.markets?.count))")
        return shoppingAssistant.productNamePredicate(for: text, in: shoppingAssistant.markets ?? [])
    }
}
