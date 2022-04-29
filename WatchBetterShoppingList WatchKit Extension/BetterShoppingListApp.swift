//
//  BetterShoppingListApp.swift
//  WatchBetterShoppingList WatchKit Extension
//
//  Created by Xavi Aracil on 29/4/22.
//

import SwiftUI

@main
struct BetterShoppingListApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
