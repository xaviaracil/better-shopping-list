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

    @State private var switchToInMarket = false

    @State private var alreadyDisplayedInMarketView = false

    var switchDialogPresented: Binding<Bool> {
        Binding {
            !alreadyDisplayedInMarketView && shoppingAssistant.userIsinAMarket
        } set: { newValue in
            alreadyDisplayedInMarketView = !newValue
        }
    }

    var body: some View {
        NavigationView {
            SideBar(shoppingAssistant: shoppingAssistant)

            HomeView(shoppingAssistant: shoppingAssistant)
        }
        .confirmationDialog("Switch to In Market view?",
                             isPresented: switchDialogPresented) {
            Button(action: {
                print("Time to switch")
                withAnimation {
                    shoppingAssistant.stopSearchingForNearMarkets()
                    shoppingAssistant.switchToInMarketView.toggle()
                    alreadyDisplayedInMarketView = true
                }

            }) {
                Label("Switch", systemImage: "cart")
            }

            Button("Cancel", role: .cancel) {
                shoppingAssistant.stopSearchingForNearMarkets()
                alreadyDisplayedInMarketView = true
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
        let viewContext = PersistenceController.preview.container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext)
        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)
        Group {
            ContentView()
            ContentView()
.previewInterfaceOrientation(.landscapeLeft)
        }
        .environmentObject(shoppingAssistant)
    }
}
