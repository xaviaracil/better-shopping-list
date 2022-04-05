//
//  SwiftUIView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 3/4/22.
//

import SwiftUI
import CoreData
import Algorithms

struct SearchingResultsView: View {
    @FetchRequest
    private var results: FetchedResults<Offer>

    @ObservedObject var viewModel: ContentViewModel

    init(text: String, viewModel: ContentViewModel, shoppingAssistant: ShoppingAssistant) {
        _results = FetchRequest(fetchRequest: shoppingAssistant.offersFetchRequest(productName: text),
                                animation: .default)
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if results.isEmpty {
                Label("Can't find any product with this name.", systemImage: "info.circle")
                    .font(.largeTitle)
            } else {
                ScrollView {
                    ForEach(results.toProductOffers(), id: \.self) { productOffer in
                        ProductOfferView(productOffers: productOffer, productAdded: $viewModel.productAdded)
                            .padding()
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

        SearchingResultsView(text: "Cervesa", viewModel: ContentViewModel(), shoppingAssistant: shoppingAssistant)
    }
}
