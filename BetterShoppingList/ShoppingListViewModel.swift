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

    @Published var products: Set<ChosenProduct>?

    init(shoppingList: ShoppingList?) {
        _shoppingList = .init(initialValue: shoppingList)
        _isFavorite = .init(initialValue: shoppingList?.isFavorite ?? false)
        _products = .init(initialValue: shoppingList?.products as? Set<ChosenProduct>)
    }

    func removeProduct(_ chosenProduct: ChosenProduct) {
        shoppingList?.removeFromProducts(chosenProduct)
        products = shoppingList?.products as? Set<ChosenProduct>
    }

}
