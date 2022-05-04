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

    @SectionedFetchRequest
    private var shoppingLists: SectionedFetchResults<Bool, ShoppingList>

    @StateObject
    private var viewModel: SidebarViewModel

    init(shoppingAssistant: ShoppingAssistant) {
        let auxViewModel = SidebarViewModel(shoppingAssistant: shoppingAssistant)
        _viewModel = .init(wrappedValue: auxViewModel)
        _markets = auxViewModel.marketsFetchRequest
        _shoppingLists = auxViewModel.shoppingListFetchRequest
        print("init!!! \(_viewModel)")
    }

    var body: some View {
        print("Update body \(viewModel)")
        return List {
            if let market = viewModel.shoppingAssistant.marketTheUserIsInCurrently {
                // swiftlint:disable line_length
                NavigationLink(destination:
                    CurrentListMarketInMarketView(name: market.wrappedName,
                                                  products: viewModel.shoppingAssistant.currentList?.chosenProductSet.ofMarket(market: market) ?? [])
                                .navigationBarTitle(market.wrappedName),
                               isActive: $viewModel.shoppingAssistant.switchToInMarketView) {
                    Label(market.wrappedName, systemImage: "cart")
                }
            }

            // swiftlint:disable line_length
            NavigationLink(destination: HomeView(shoppingAssistant: viewModel.shoppingAssistant), tag: "Current", selection: $viewModel.selectedItem) {
                Label("Current List", systemImage: "bag.fill")
            }

            ForEach(shoppingLists) { section in
                Section(header: Label(section.id ? "Favorites" : "All", systemImage: section.id ? "star" : "bag") ) {
                    ForEach(section) { shoppingList in
                        NavigationLink(destination:
                                        ShoppingListView(shoppingList: shoppingList),
                                       tag: shoppingList.wrappedName,
                                       selection: $viewModel.selectedItem) {
                            Text(shoppingList.name ?? "No Name")
                        }
                    }
                    .onDelete(perform: { offsets in
                        withAnimation {
                            viewModel.deleteShoppingLists(lists: offsets.map { section[$0] })
                        }
                    })
                }
            }

            Section(header: Label("Markets", systemImage: "cart")) {
                NavigationLink(destination: MarketsMapView(markets: markets), tag: "Map", selection: $viewModel.selectedItem) {
                    Label("Map", systemImage: "map")
                }

                ForEach(markets, id: \.self) { market in
                    if market.userMarket?.excluded ?? false {
                        EmptyView()
                    } else {
                        NavigationLink(destination: MarketsMapView(markets: [market]), tag: market.uuid?.uuidString ?? "null", selection: $viewModel.selectedItem) {
                            Label {
                                Text(market.wrappedName)
                            } icon: {
                                AsyncImage(url: market.iconUrl) { logo in
                                    logo.resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    Image(systemName: "cart.circle")
                                }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.excludeMarket(market)
                            } label: {
                                Label("Exclude", systemImage: "cart.fill.badge.minus")
                            }
                            .tint(.accentColor)
                        }

                    }
                }
            }
            Section(header: Label("Excluded Markets", systemImage: "cart.badge.minus")) {
                ForEach(markets, id: \.self) { market in
                    if market.userMarket?.excluded ?? false {
                        Label {
                            Text(market.wrappedName)
                        } icon: {
                            AsyncImage(url: market.iconUrl) { logo in
                                logo.resizable()
                                    .scaledToFit()
                            } placeholder: {
                                Image(systemName: "cart.circle")
                            }
                        }
                        .swipeActions {
                            Button {
                                viewModel.includeMarket(market)
                            } label: {
                                Label("Include", systemImage: "cart.fill.badge.plus")
                            }
                            .tint(.accentColor)
                        }
                    } else {
                        EmptyView()
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
        return SideBar(shoppingAssistant: shoppingAssistant)
            .environment(\.managedObjectContext, viewContext)
    }
}
