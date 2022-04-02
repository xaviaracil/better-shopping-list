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
        sortDescriptors: [],
        predicate: NSPredicate(format: "isCurrent = YES"),
        animation: .default
    )
    private var currentLists: FetchedResults<ShoppingList>

    private var currentList: ShoppingList? {
        currentLists.first
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
                    if let _ = currentList {
                        List {
                            ForEach(currentLists) { item in
                                // swiftlint:disable no_space_in_method_call multiple_closures_with_trailing_closure
                                NavigationLink {
                                    Text(item.name ?? "No Name")
                                } label: {
                                    Text(item.name ?? "No Name")
                                }
                            }
                        }
                    } else {
                        EmptyCurrentListView(lists: savedLists)
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
