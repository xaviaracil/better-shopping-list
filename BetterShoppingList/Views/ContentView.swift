//
//  ContentView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 31/3/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var splashDisplayed = false
    @State private var searchText = ""
    @Environment(\.isSearching) var isSearching

    let hideSplash: Bool

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        fetchRequest: CurrentListQueries.productsFetchRequest, animation: .default
    )
    private var products: FetchedResults<ChosenProduct>

    private var currentList: ShoppingList? {
        products.first?.list
    }

    @FetchRequest(fetchRequest: ShoppingListQueries.savedListsFetchRequest,
        animation: .default)
    private var savedLists: FetchedResults<ShoppingList>

    var body: some View {
        if !splashDisplayed && !hideSplash {
            SplashView(displayed: $splashDisplayed)
        } else {
            NavigationView {
                ZStack {
                    VStack {
                        if products.isEmpty {
                            EmptyCurrentListView(lists: savedLists)
                                .opacity(searchText.isEmpty ? 1.0 : 0.0)
                        } else {
                            List {
                                ForEach(products) { item in
                                    // swiftlint:disable no_space_in_method_call multiple_closures_with_trailing_closure
                                    NavigationLink {
                                        Text(item.name ?? "No Name")
                                    } label: {
                                        Text(item.name ?? "No Name")
                                    }
                                }
                            }
                        }
                    }
                    if !searchText.isEmpty {
                        SearchingResultsView(text: searchText)
                            .transition(.move(edge: .top))
                    }
                }
                .navigationBarTitle("", displayMode: .inline)

            }
            .searchable(text: $searchText, placement: .automatic, prompt: "Search Products Here")
            .onSubmit(of: .search) {
                // search for products here
                print("search for \(searchText)")
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
        ContentView(hideSplash: true)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
