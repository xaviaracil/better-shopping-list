//
//  HomeView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 8/4/22.
//

import SwiftUI

struct HomeView: View {
    @FetchRequest
    private var products: FetchedResults<ChosenProduct>
    @FetchRequest
    private var savedLists: FetchedResults<ShoppingList>

    @ObservedObject
    private var viewModel: HomeViewModel

    init(shoppingAssistant: ShoppingAssistant) {
        let auxViewModel = HomeViewModel(shoppingAssistant: shoppingAssistant)

        _products = auxViewModel.productsFetchRequest
        _savedLists = auxViewModel.savedListsFetchRequest
        viewModel = auxViewModel
    }

    var body: some View {
        ZStack {
            VStack {
                if products.isEmpty {
                    EmptyCurrentListView(lists: savedLists)
                        .opacity(!viewModel.canSearch ? 1.0 : 0.0)
                } else {
                    if !viewModel.canSearch {
                        CurrentListView()
                    }
                }
            }
            if viewModel.canSearch && !viewModel.productAdded {
                SearchingResultsView(text: viewModel.searchText,
                                     shoppingAssistant: viewModel.shoppingAssistant) {
                    viewModel.productAdded = true
                }
                .transition(.move(edge: .top))
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .searchable(text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search Products Here")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let container = PersistenceController.preview.container
        let viewContext = container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext,
                                                            coordinator: container.persistentStoreCoordinator)
        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)
        return HomeView(shoppingAssistant: shoppingAssistant)
    }
}
