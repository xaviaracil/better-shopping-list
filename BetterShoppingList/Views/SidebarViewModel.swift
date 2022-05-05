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

    var shoppingAssistant: ShoppingAssistant

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

    func deleteShoppingLists(lists: [ShoppingList]) {
        lists.forEach(shoppingAssistant.removeList)
    }

    func userMarket(for market: Market) -> UserMarket {
        var userMarket = market.userMarket
        if userMarket == nil {
            userMarket = UserMarket(context: market.managedObjectContext!)
            userMarket?.marketUUID = market.uuid
        }
        return userMarket!
    }

    func includeMarket(_ market: Market) {
        userMarket(for: market).excluded = false
        marketsFetchRequest = FetchRequest(fetchRequest: shoppingAssistant.markertsFetchRequest,
                                           animation: .default)
        shoppingAssistant.save()
    }

    func excludeMarket(_ market: Market) {
        userMarket(for: market).excluded = true
        marketsFetchRequest = FetchRequest(fetchRequest: shoppingAssistant.markertsFetchRequest,
                                           animation: .default)
        shoppingAssistant.save()
    }
}
