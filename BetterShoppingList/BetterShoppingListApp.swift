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

    @StateObject var shoppingAssitant: ShoppingAssitant

    init() {
        let persistanceAdapter = CoreDataPersistenceAdapter(viewContext: persistenceController.container.viewContext)
        self._shoppingAssitant = StateObject(wrappedValue: ShoppingAssitant(persistenceAdapter: persistanceAdapter))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(shoppingAssistant: shoppingAssitant)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
