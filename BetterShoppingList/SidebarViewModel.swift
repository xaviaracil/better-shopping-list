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

    @Published
    var shoppingListFetchRequest: SectionedFetchRequest<Bool, ShoppingList>

    @Published
    var selectedItem: String? = "Current"
    
    let shoppingAssistant: ShoppingAssistant

    init(shoppingAssistant: ShoppingAssistant) {
        print("SidebarViewModel init!!!")
        self.shoppingAssistant = shoppingAssistant
        marketsFetchRequest = FetchRequest(fetchRequest: shoppingAssistant.markertsFetchRequest,
                                           animation: .default)
        let fetchRequest = shoppingAssistant.savedListsFetchRequest
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ShoppingList.isFavorite, ascending: false),
                                        NSSortDescriptor(keyPath: \ShoppingList.timestamp, ascending: false)]
        shoppingListFetchRequest = SectionedFetchRequest(fetchRequest: fetchRequest,
                                                         sectionIdentifier: \.isFavorite,
                                                         animation: .none)
    }
}
