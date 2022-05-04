//
//  BetterShoppingListApp.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 31/3/22.
//

import SwiftUI
import Intents

@main
struct BetterShoppingListApp: App {
    let runningInTests = NSClassFromString("XCTestCase") != nil || ProcessInfo().arguments.contains("testMode")

    var persistenceController: PersistenceController!

    @StateObject var shoppingAssitant: ShoppingAssistant
    @Environment(\.scenePhase) var scenePhase
    init() {
        persistenceController = runningInTests ? PersistenceController.preview : PersistenceController.shared
        let context = persistenceController.container.viewContext
        let persistanceAdapter = CoreDataPersistenceAdapter(viewContext: context)
        self._shoppingAssitant = StateObject(wrappedValue: ShoppingAssistant(persistenceAdapter: persistanceAdapter))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(shoppingAssitant)
        }.onChange(of: scenePhase) { phase in
            // ask for siri permission
            INPreferences.requestSiriAuthorization { print($0) }

            // save when entering background, etc
            shoppingAssitant.save()

            if phase == .active {
                // refresh
                persistenceController.container.viewContext.refreshAllObjects()
                shoppingAssitant.reloadCurrentList()

                // when active, check if we are near a market in the current list
                shoppingAssitant.startSearchingForNearMarkets()
            }
        }
    }
}
