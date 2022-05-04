//
//  CoreData+Wrapped.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 3/5/22.
//

extension Market {
    var wrappedName: String {
        self.name ?? "N.A"
    }
}

extension ChosenProduct {
    var wrappedName: String {
        self.name ?? "N.A"
    }
}

extension Product {
    var wrappedName: String {
        self.name ?? "N.A"
    }
}

extension ShoppingList {
    var wrappedName: String {
        self.name ?? "N.A"
    }
}
