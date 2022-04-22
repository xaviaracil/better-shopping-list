//
//  BetterShoppingListApp.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 31/3/22.
//

import SwiftUI

@main
struct BetterShoppingListApp: App {
    let runningInTests = NSClassFromString("XCTestCase") != nil || ProcessInfo().arguments.contains("testMode")

    var persistenceController: PersistenceController!

    @StateObject var shoppingAssitant: ShoppingAssistant
    @Environment(\.scenePhase) var scenePhase
    init() {
        persistenceController = runningInTests ? PersistenceController.preview : PersistenceController.shared
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
