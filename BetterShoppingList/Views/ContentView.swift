//
//  ContentView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 31/3/22.
//

import SwiftUI
import CoreData

struct ContentView: View {

    @EnvironmentObject
    private var shoppingAssistant: ShoppingAssistant

    @State private var selectedItem: String? = "Current"
    @State private var splashDisplayed = false
    private var hideSplash: Bool

    init(hideSplash: Bool = false) {
        self.hideSplash = hideSplash
    }

    var body: some View {
        if !splashDisplayed && !hideSplash {
            SplashView(displayed: $splashDisplayed)
        } else {
            NavigationView {
                SideBar(shoppingAssistant: shoppingAssistant, selectedItem: $selectedItem)

                HomeView(shoppingAssistant: shoppingAssistant)
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let container = PersistenceController.preview.container
        let viewContext = container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext,
                                                            coordinator: container.persistentStoreCoordinator)
        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)
        Group {
            ContentView(hideSplash: true)
            ContentView(hideSplash: true)
.previewInterfaceOrientation(.landscapeLeft)
        }
        .environmentObject(shoppingAssistant)
    }
}
