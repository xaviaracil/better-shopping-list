//
//  SidebarViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 8/4/22.
//

import Foundation
import SwiftUI

class SidebarViewModel: ObservableObject {

    @Published
    var marketsFetchRequest: FetchRequest<Market>

    let shoppingAssistant: ShoppingAssistant

    init(shoppingAssistant: ShoppingAssistant) {
        self.shoppingAssistant = shoppingAssistant
        marketsFetchRequest = FetchRequest(fetchRequest: shoppingAssistant.markertsFetchRequest,
                                           animation: .default)
    }

}
