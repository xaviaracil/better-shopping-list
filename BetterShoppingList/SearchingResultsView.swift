//
//  SwiftUIView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 3/4/22.
//

import SwiftUI
import CoreData

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
                List(results) { offer in
                    Text(offer.product?.name ?? "No Name")
                    Text("\(offer.price)")
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
