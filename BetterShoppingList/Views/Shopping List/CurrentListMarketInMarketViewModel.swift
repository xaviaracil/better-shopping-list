//
//  CurrentListMarketInMarketViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 28/4/22.
//

import Foundation

class CurrentListMarketInMarketViewModel: ObservableObject {
    @Published
    var products: [ChosenProduct]

    init(products: [ChosenProduct]) {
        self.products = products
    }

    func toggleInBasket(_ chosenProduct: ChosenProduct) {
        let newProducts = self.products
        if let index = newProducts.firstIndex(of: chosenProduct) {
            newProducts[index].inBasket.toggle()
        }
        // changing the list forces a refresh of the view
        products = newProducts
    }
}
