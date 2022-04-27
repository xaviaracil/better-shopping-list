//
//  ListDetailView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 7/4/22.
//

import SwiftUI

struct ListDetailView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var shoppingAssistant: ShoppingAssistant

    var products: [ChosenProduct]
    var name: String

    var body: some View {
        NavigationView {
            Group {
                if verticalSizeClass == .compact {
                    // landscape
                    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(products, id: \.self) { chosenProduct in
                                ChosenProductView(chosenProduct: chosenProduct, shoppingAssistant: shoppingAssistant)
                                    .padding()
                            }
                        }
                    }
                } else {
                    // portrait
                    ScrollView {
                        ForEach(products, id: \.self) { chosenProduct in
                            ChosenProductView(chosenProduct: chosenProduct, shoppingAssistant: shoppingAssistant)
                                .padding()
                        }
                    }
                }
            }
            .navigationBarTitle(Text(name), displayMode: .inline)
            // swiftlint:disable multiple_closures_with_trailing_closure
            .toolbar(content: {
                ToolbarItem(placement: .destructiveAction) {
                    Button(action: { dismiss() }) {
                        Label("Close", systemImage: "xmark")
                            .labelStyle(.iconOnly)
                    }
                }
            })
        }

    }
}

struct ListDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let container = PersistenceController.preview.container
        let viewContext = container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext,
                                                            coordinator: container.persistentStoreCoordinator)
        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)

        ListDetailView(products: [], name: "Some Name")
            .environmentObject(shoppingAssistant)
    }
}
