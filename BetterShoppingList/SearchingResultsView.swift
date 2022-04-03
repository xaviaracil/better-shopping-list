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

    func makeProductOfferList() -> [ProductOffers] {
        let productOffers = OrderedDictionary<String?, [Offer]>(grouping: results, by: { $0.product?.name })
        var list = [ProductOffers]()
        for key in productOffers.keys {
            if let offers = productOffers[key],
            let product = offers.first?.product {
                list.append(ProductOffers(product: product, offers: offers))
            }
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
        SearchingResultsView(text: "Cervesa")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
