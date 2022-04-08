//
//  SideBar.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 8/4/22.
//

import SwiftUI

struct SideBar: View {
    @FetchRequest
    private var markets: FetchedResults<Market>

    @ObservedObject
    private var viewModel: SidebarViewModel

    @Binding var selectedItem: String?

    init(shoppingAssistant: ShoppingAssistant, selectedItem: Binding<String?>) {
        let auxViewModel = SidebarViewModel(shoppingAssistant: shoppingAssistant)
        _markets = auxViewModel.marketsFetchRequest
        viewModel = auxViewModel
        _selectedItem = selectedItem
    }

    var body: some View {
        List {
            // swiftlint:disable line_length
            NavigationLink(destination: HomeView(shoppingAssistant: viewModel.shoppingAssistant), tag: "Current", selection: $selectedItem) {
                Label("Current List", systemImage: "bag.fill")
            }
            Section(header: Label("Markets", systemImage: "cart")) {
                ForEach(markets, id: \.self) { market in
                    NavigationLink(destination: MarketLabelView(market: market)) {
                    Label(market.name ?? "N.A.", systemImage: "info.circle")
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Menu")
    }
}

struct SideBar_Previews: PreviewProvider {
    static var previews: some View {
        let container = PersistenceController.preview.container
        let viewContext = container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext,
                                                            coordinator: container.persistentStoreCoordinator)
        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)
        return SideBar(shoppingAssistant: shoppingAssistant, selectedItem: .constant("Current"))
    }
}
