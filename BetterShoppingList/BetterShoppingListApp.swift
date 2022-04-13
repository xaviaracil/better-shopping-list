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
    @Environment(\.scenePhase) var scenePhase

    init() {
        let container = persistenceController.container
        let persistanceAdapter = CoreDataPersistenceAdapter(viewContext: container.viewContext,
                                                            coordinator: container.persistentStoreCoordinator)
        self._shoppingAssitant = StateObject(wrappedValue: ShoppingAssistant(persistenceAdapter: persistanceAdapter))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(shoppingAssitant)
        }.onChange(of: scenePhase) { _ in
            // save when entering background, etc
            try? persistenceController.container.viewContext.save()
        }
    }
}
