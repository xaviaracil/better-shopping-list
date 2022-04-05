//
//  ContentViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 5/4/22.
//

import Foundation

class ContentViewModel: ObservableObject {
    @Published var productAdded: Bool = false {
        didSet {
            if productAdded {
                searchText = ""
                productAdded = false
            }
        }
    }
    @Published var splashDisplayed = false
    @Published var searchText = ""
}
