//
//  ShoppingListViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 22/4/22.
//

import Foundation

class CurrentShoppingListViewModel: ObservableObject {
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
        _products = .init(initialValue: shoppingList?.chosenProductSet)
    }

    func removeProduct(_ chosenProduct: ChosenProduct) {
        shoppingList?.removeFromProducts(chosenProduct)
        products = shoppingList?.chosenProductSet
    }

    func replaceProduct(_ chosenProduct: ChosenProduct, with newChosenProduct: ChosenProduct) {
        shoppingList?.removeFromProducts(chosenProduct)
        shoppingList?.addToProducts(newChosenProduct)
        products = shoppingList?.chosenProductSet
    }
}
