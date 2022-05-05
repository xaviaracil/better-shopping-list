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

    enum Field: Hashable {
        case search
    }

    @FocusState private var focusedField: Field?
    @State private var searchResultsDragging = false
    var dragging: Binding<Bool> {
        Binding {
            searchResultsDragging
        } set: { newValue in
            print("dragging: \(newValue)")
            searchResultsDragging = newValue
            if newValue {
                // hide keyboard
                #if canImport(UIKit)
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                #endif
            }
        }
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
                SearchingResultsView(products: products, added: added, isDragging: dragging)

            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .searchable(text: query,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search Products Here")
        .focused($focusedField, equals: .search)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext)
        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)
        return HomeView(shoppingAssistant: shoppingAssistant)
    }
}
