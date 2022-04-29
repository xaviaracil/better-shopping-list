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
    let additionalOffers: [Offer]?

    init(shoppingAssistant: ShoppingAssistant, chosenProduct: ChosenProduct) {
        self.shoppingAssitant = shoppingAssistant
        self.chosenProduct = chosenProduct
        self.quantity = chosenProduct.quantity
        self.offer = chosenProduct.offer
        self.product = chosenProduct.offer?.product
        self.additionalOffers = chosenProduct.offer?.product?.offers?
            .filter { $0 as? Offer != chosenProduct.offer }
            .sorted { lhs, rhs in // sort by difference
                let diffLhs = ((lhs as? Offer)?.price ?? 0.0) - chosenProduct.price
                let diffRhs = ((rhs as? Offer)?.price ?? 0.0) - chosenProduct.price
                return diffLhs < diffRhs
            } as? [Offer]
    }
}
