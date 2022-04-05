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

    init(text: String, shoppingAssistant: ShoppingAssitant) {
        _results = FetchRequest(fetchRequest: shoppingAssistant.offersFetchRequest(productName: text, in: []),
                                animation: .default)
    }

    func makeProductOfferList() -> [ProductOffers] {
        let productsOffers = results.chunked(on: \.product)
        let list = productsOffers.filter { product, _ in
            product != nil
        }
        .map { product, offers in
            ProductOffers(product: product!, offers: Array(offers))
        }
        return list
    }
    var body: some View {
        VStack {
            if results.isEmpty {
                Label("Can't find any product with this name.", systemImage: "info.circle")
                    .font(.largeTitle)
            } else {
                ScrollView {
                    let list = makeProductOfferList()
                    ForEach(list, id: \.self) { productOffer in
                        ProductOfferView(productOffers: productOffer)
                            .padding()
                    }
                }
            }
        }
    }
}

struct SearchingResultsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext)
        let shoppingAssistant = ShoppingAssitant(persistenceAdapter: persistenceAdapter)

        SearchingResultsView(text: "Cervesa", shoppingAssistant: shoppingAssistant)
    }
}
