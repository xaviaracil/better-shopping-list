//
//  BetterShoppingListApp.swift
//  WatchBetterShoppingList WatchKit Extension
//
//  Created by Xavi Aracil on 29/4/22.
//

import SwiftUI

@main
struct BetterShoppingListApp: App {
    let persistenceController = PersistenceController.shared

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
