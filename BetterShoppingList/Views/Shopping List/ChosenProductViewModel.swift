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
            if quantity <= 0 {
                quantity = 1
            } else {
                chosenProduct.quantity = quantity
                shoppingAssitant.save()
            }
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
            .filter { offer in
                guard let offer = offer as? Offer else {
                    return false
                }

                return shoppingAssistant.offerIsIncluded(offer) && offer != chosenProduct.offer
            }
            .sorted { lhs, rhs in // sort by price
                let lhsPrice = (lhs as? Offer)?.price ?? 0.0
                let rhsPrice = (rhs as? Offer)?.price ?? 0.0
                return lhsPrice < rhsPrice
            } as? [Offer]
    }
}
