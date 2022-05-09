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

    @StateObject var modelProvider = ModelProvider()

    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            LoadingView(test: runningInTests, modelProvider: modelProvider)
        }.onChange(of: scenePhase) { phase in
            // ask for siri permission
            INPreferences.requestSiriAuthorization { print($0) }

            // save when entering background, etc
            modelProvider.save()

            if phase == .active {
                modelProvider.refresh()
            }
        }
    }
}
