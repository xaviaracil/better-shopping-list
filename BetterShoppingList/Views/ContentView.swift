//
//  ContentView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 31/3/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    let hideSplash: Bool

    let shoppingAssistant: ShoppingAssistant

    @FetchRequest
    private var products: FetchedResults<ChosenProduct>
    @FetchRequest
    private var savedLists: FetchedResults<ShoppingList>
    @FetchRequest
    private var markets: FetchedResults<Market>

    @StateObject private var viewModel = ContentViewModel()

    init(hideSplash: Bool = false, shoppingAssistant: ShoppingAssistant) {
        self.hideSplash = hideSplash
        self.shoppingAssistant = shoppingAssistant
        _products = FetchRequest(fetchRequest: shoppingAssistant.currentProductsFetchRequest, animation: .default)
        _savedLists = FetchRequest(fetchRequest: shoppingAssistant.savedListsFetchRequest, animation: .default)
        _markets = FetchRequest(fetchRequest: shoppingAssistant.markertsFetchRequest, animation: .default)

    }

    var body: some View {
        if !viewModel.splashDisplayed && !hideSplash {
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
                                             viewModel: viewModel,
                                             shoppingAssistant: shoppingAssistant)
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
            ContentView(hideSplash: true, shoppingAssistant: shoppingAssistant)
            ContentView(hideSplash: true, shoppingAssistant: shoppingAssistant)
.previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
