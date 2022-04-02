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

    let hideSplash: Bool

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        fetchRequest: CurrentListQueries.productsFetchRequest, animation: .default
    )
    private var products: FetchedResults<ChosenProduct>

    private var currentList: ShoppingList? {
        products.first?.list
    }

    @FetchRequest(fetchRequest: ShoppingListQueries.savedListsFetchRequest(),
        animation: .default)
    private var savedLists: FetchedResults<ShoppingList>

    var body: some View {
        if !splashDisplayed && !hideSplash {
            SplashView(displayed: $splashDisplayed)
        } else {
            NavigationView {
                VStack {
                    if products.isEmpty {
                        EmptyCurrentListView(lists: savedLists)
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
                .navigationBarTitle("", displayMode: .inline)

            }
            .searchable(text: $searchText, placement: .automatic, prompt: "Search Products Here")
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
