//
//  ContentView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 31/3/22.
//

import SwiftUI
import CoreData

struct HomeView: View {

    @FetchRequest
    private var products: FetchedResults<ChosenProduct>
    @FetchRequest
    private var savedLists: FetchedResults<ShoppingList>
    @FetchRequest
    private var markets: FetchedResults<Market>

    @ObservedObject
    private var viewModel: HomeViewModel

    init(hideSplash: Bool = false, shoppingAssistant: ShoppingAssistant) {
        let auxViewModel = HomeViewModel(hideSplash: hideSplash, shoppingAssistant: shoppingAssistant)

        _products = auxViewModel.productsFetchRequest
        _savedLists = auxViewModel.savedListsFetchRequest
        _markets = auxViewModel.marketsFetchRequest

        viewModel = auxViewModel
    }

    var body: some View {
        if viewModel.displaySlash {
            SplashView(displayed: $viewModel.splashDisplayed)
        } else {
            NavigationView {
                ZStack {
                    VStack {
                        if products.isEmpty {
                            EmptyCurrentListView(lists: savedLists)
                                .opacity(viewModel.searchText.isEmpty ? 1.0 : 0.0)
                        } else {
                            if viewModel.searchText.isEmpty {
                                CurrentListView()
                            }
                        }
                    }
                    if !viewModel.searchText.isEmpty && !viewModel.productAdded {
                        SearchingResultsView(text: viewModel.searchText,
                                             shoppingAssistant: viewModel.shoppingAssistant) {
                            viewModel.productAdded = true
                        }
                        .transition(.move(edge: .top))
                    }
                }
                .navigationBarTitle("", displayMode: .inline)

            }
            .searchable(text: $viewModel.searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search Products Here")
            .onSubmit(of: .search) {
                // search for products here
                print("search for \(viewModel.searchText)")
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
        let viewContext = PersistenceController.preview.container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext)
        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)
        Group {
            HomeView(hideSplash: true, shoppingAssistant: shoppingAssistant)
            HomeView(hideSplash: true, shoppingAssistant: shoppingAssistant)
.previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
