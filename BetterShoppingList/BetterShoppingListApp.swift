//
//  BetterShoppingListApp.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 31/3/22.
//

import SwiftUI

@main
struct BetterShoppingListApp: App {
    let persistenceController = PersistenceController.shared

    @StateObject var shoppingAssitant: ShoppingAssistant

    init() {
        let persistanceAdapter = CoreDataPersistenceAdapter(viewContext: persistenceController.container.viewContext)
        self._shoppingAssitant = StateObject(wrappedValue: ShoppingAssistant(persistenceAdapter: persistanceAdapter))
    }

    var body: some Scene {
        WindowGroup {
            HomeView(shoppingAssistant: shoppingAssitant)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(shoppingAssitant)
        }
    }
}
