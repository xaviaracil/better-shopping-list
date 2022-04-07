//
//  SwiftUIView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 3/4/22.
//

import SwiftUI
import CoreData

struct SearchingResultsView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @ObservedObject
    private var viewModel: SearchResultsViewModel

    @FetchRequest
    private var results: FetchedResults<Offer>

    init(text: String, shoppingAssistant: ShoppingAssistant, onAdded: @escaping () -> (Void) = {}) {
        let vm = SearchResultsViewModel(text: text, shoppingAssistant: shoppingAssistant, onAdded: onAdded)
        _results = vm.fetchRequest
        viewModel = vm
    }

    var body: some View {
        VStack {
            if results.isEmpty {
                Label("Can't find any product with this name.", systemImage: "info.circle")
                    .font(.largeTitle)
            } else {
                if verticalSizeClass == .compact {
                    // landscape
                    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(results.toProductOffers(), id: \.self) { productOffer in
                                ProductOfferView(productOffers: productOffer, onAdded: viewModel.onAdded)
                                    .padding()
                            }
                        }
                    }
                } else {
                    // portrait
                    ScrollView {
                        ForEach(results.toProductOffers(), id: \.self) { productOffer in
                            ProductOfferView(productOffers: productOffer, onAdded: viewModel.onAdded)
                                .padding()
                        }
                    }
                }
            }
        }
    }
}

struct SearchingResultsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: context)
        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)

        SearchingResultsView(text: "Cervesa", shoppingAssistant: shoppingAssistant) {
            print("product Added")
        }
    }
}
