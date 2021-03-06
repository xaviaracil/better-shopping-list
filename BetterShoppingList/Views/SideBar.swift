//
//  SideBar.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 8/4/22.
//

import SwiftUI
import CoreData

struct SideBar: View {
    @FetchRequest
    private var markets: FetchedResults<Market>

    @SectionedFetchRequest
    private var shoppingLists: SectionedFetchResults<Bool, ShoppingList>

    @FetchRequest
    private var products: FetchedResults<Product>

    @FetchRequest
    private var offers: FetchedResults<Offer>

    @StateObject
    private var viewModel: SidebarViewModel

    init(shoppingAssistant: ShoppingAssistant) {
        let auxViewModel = SidebarViewModel(shoppingAssistant: shoppingAssistant)
        _viewModel = .init(wrappedValue: auxViewModel)
        _markets = auxViewModel.marketsFetchRequest
        _shoppingLists = auxViewModel.shoppingListFetchRequest
        _products = auxViewModel.productsFetchRequest
        _offers = auxViewModel.offersFetchRequest
        print("init!!! \(_viewModel)")
    }

    var body: some View {
        print("Update body \(viewModel)")
        return VStack {
            List {
                // in market view
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

                // current list
            // swiftlint:disable line_length
            NavigationLink(destination: HomeView(shoppingAssistant: viewModel.shoppingAssistant),
                           tag: "Current",
                           selection: $viewModel.selectedItem) {
                Label("Current List", systemImage: "bag.fill")
            }

                // saved lists
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
                // map view
                NavigationLink(destination: MarketsMapView(markets: markets), tag: "Map", selection: $viewModel.selectedItem) {
                    Label("Map", systemImage: "map")
                }

                // included markets
                ForEach(markets, id: \.self) { market in
                    if market.userMarket?.excluded ?? false {
                        EmptyView()
                    } else {
                        NavigationLink(destination: MarketsMapView(markets: [market], onlyGivenMarkets: true), tag: market.uuid?.uuidString ?? "null", selection: $viewModel.selectedItem) {
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
                Text("Products: \(products.count). Offers: \(offers.count)")
                    .font(.footnote)
        }
        .navigationTitle("Menu")
    }
}

struct SideBar_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext)
        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)
        return SideBar(shoppingAssistant: shoppingAssistant)
            .environment(\.managedObjectContext, viewContext)
    }
}
