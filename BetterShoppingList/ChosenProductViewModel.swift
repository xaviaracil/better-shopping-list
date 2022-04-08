//
//  ChosenProductViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 7/4/22.
//

import Foundation

class ChosenProductViewModel: ObservableObject {
    @Published var offer: Offer?
    @Published var product: Product?
    @Published var quantity: Int16 {
        didSet {
            chosenProduct.quantity = quantity
            try? shoppingAssitant.save()
        }
    }

    let shoppingAssitant: ShoppingAssistant
    let chosenProduct: ChosenProduct

    init(shoppingAssistant: ShoppingAssistant, chosenProduct: ChosenProduct) {
        self.shoppingAssitant = shoppingAssistant
        self.chosenProduct = chosenProduct
        self.quantity = chosenProduct.quantity

        self.offer = chosenProduct.offer
        self.product = self.offer?.product
    }
}
