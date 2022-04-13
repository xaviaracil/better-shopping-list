//
//  ProductOfferViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 13/4/22.
//

import Foundation
class ProductOfferViewModel {
    func choseProduct(product: Product, offer: Offer, quantity: Int16) -> ChosenProduct {
        var chosenProduct: ChosenProduct
        if let managedObjectContext = product.managedObjectContext {
            chosenProduct = ChosenProduct(context: managedObjectContext)
        } else {
            chosenProduct = ChosenProduct()
        }
        chosenProduct.name = product.name
        chosenProduct.price = offer.price
        chosenProduct.quantity = quantity
        chosenProduct.marketUUID = offer.market?.uuid
        chosenProduct.offerUUID = offer.uuid
        return chosenProduct
    }
}
