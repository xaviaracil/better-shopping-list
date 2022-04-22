//
//  ShoppingListViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 22/4/22.
//

import Foundation

class ShoppingListViewModel: ObservableObject {
    @Published var isFavorite: Bool {
        didSet {
            shoppingList?.isFavorite = isFavorite
        }
    }

    @Published var shoppingList: ShoppingList?

    init(shoppingList: ShoppingList?) {
        _shoppingList = .init(initialValue: shoppingList)
        _isFavorite = .init(initialValue: shoppingList?.isFavorite ?? false)
    }
}
