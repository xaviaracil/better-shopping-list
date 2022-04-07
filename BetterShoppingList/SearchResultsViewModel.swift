//
//  SearchResultsViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 7/4/22.
//

import Foundation
import SwiftUI

class SearchResultsViewModel: ObservableObject {
    @Published var fetchRequest: FetchRequest<Offer>
    var onAdded: () -> Void

    init(text: String, shoppingAssistant: ShoppingAssistant, onAdded: @escaping () -> Void = {}) {
        fetchRequest = FetchRequest(fetchRequest: shoppingAssistant.offersFetchRequest(productName: text),
                                    animation: .default)
        self.onAdded = onAdded
    }
}
