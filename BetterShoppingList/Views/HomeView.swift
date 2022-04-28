//
//  HomeView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 8/4/22.
//

import SwiftUI

struct HomeView: View {
    @FetchRequest
    private var savedLists: FetchedResults<ShoppingList>

    @FetchRequest(sortDescriptors: [SortDescriptor(\Product.name)])
    private var products: FetchedResults<Product>

    @ObservedObject
    private var viewModel: HomeViewModel

    var canSearch: Bool {
        return searchText.count > 2
    }

    @State private var searchText = ""
    var query: Binding<String> {
        Binding {
            searchText
        } set: { newValue in
            searchText = newValue
            productAdded = false
            products.nsPredicate = viewModel.productQueryPredicate(for: newValue)
        }
    }

    @State private var productAdded = false
    var added: Binding<Bool> {
        Binding {
            productAdded
        } set: { newValue in
            if newValue {
                searchText = ""
            }
        }
    }

    init(shoppingAssistant: ShoppingAssistant) {
        let auxViewModel = HomeViewModel(shoppingAssistant: shoppingAssistant)
        _savedLists = auxViewModel.savedListsFetchRequest
        viewModel = auxViewModel
    }

    var body: some View {
        ZStack {
            VStack {
                if viewModel.currentList?.products?.count ?? 0 == 0 {
                    EmptyCurrentListView(lists: savedLists)
                        .opacity(!canSearch ? 1.0 : 0.0)
                } else {
                    if !canSearch {
                        CurrentShoppingListView(shoppingList: viewModel.currentList)
                    }
                }
            }
            if canSearch {
                SearchingResultsView(products: products, added: added)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .searchable(text: query,
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
