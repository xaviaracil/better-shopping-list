//
//  File.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 3/5/22.
//

extension ShoppingList {
    public var chosenProductSet: Set<ChosenProduct> {
        products as? Set<ChosenProduct> ?? []
    }
}
