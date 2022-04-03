//
//  SwiftUIView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 3/4/22.
//

import SwiftUI
import CoreData
import Collections
import OrderedCollections

struct SearchingResultsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest var results: FetchedResults<Offer>

    init(text: String) {
        _results = FetchRequest<Offer>(fetchRequest: OfferQueries.queryFetchRequest(text: text), animation: .default)
    }

    var body: some View {
        VStack {
            if results.isEmpty {
                Label("Can't find any product with this name.", systemImage: "info.circle")
                    .font(.largeTitle)
            } else {
                let productOffers = OrderedDictionary<String?, [Offer]>(grouping: results, by: { $0.product?.name })
                List(productOffers.keys, id: \.self) { productName in
                    Section(productName ?? "No Name") {
                        if let offers = productOffers[productName] {
                            ForEach(offers) { offer in
                                HStack {
                                    Text(offer.market?.name ?? "No Name")
                                    Text(offer.price.formatted(.currency(code: "eur")))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SearchingResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchingResultsView(text: "Cervesa")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
