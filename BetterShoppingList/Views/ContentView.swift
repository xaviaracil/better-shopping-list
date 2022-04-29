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

    @State private var splashDisplayed = false
    @State private var switchToInMarket = false
    private var hideSplash: Bool

    init(hideSplash: Bool = false) {
        self.hideSplash = hideSplash
    }

    var body: some View {
        Group {
            if !splashDisplayed && !hideSplash {
                SplashView(displayed: $splashDisplayed)
            } else {
                NavigationView {
                    SideBar(shoppingAssistant: shoppingAssistant)

                    HomeView(shoppingAssistant: shoppingAssistant)
                }
            }
        }.confirmationDialog("Switch to In Market view?",
                             isPresented: $shoppingAssistant.userIsinAMarket) {
            Button(action: {
                print("Time to switch")
                withAnimation {
                    shoppingAssistant.switchToInMarketView.toggle()
                }

            }) {
                Label("Switch", systemImage: "cart")
            }
        } message: {
            // swiftlint:disable line_length
            Text("Seems you are close to \(shoppingAssistant.marketTheUserIsInCurrently?.name ?? "N.A."). Switch to in market view to view its products in your current list?")
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
