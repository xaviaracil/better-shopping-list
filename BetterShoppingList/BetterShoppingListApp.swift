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

    var body: some Scene {
        WindowGroup {
            ContentView(hideSplash: false)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
