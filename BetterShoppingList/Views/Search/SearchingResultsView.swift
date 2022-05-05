//
//  SwiftUIView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 3/4/22.
//

import SwiftUI
import CoreData

struct SearchingResultsView<Data>: View
where Data: RandomAccessCollection,
      Data.Element: Product {

    @Environment(\.verticalSizeClass) var verticalSizeClass

    /// products to display
    var products: Data

    /// boolean telling if a product has been added or not
    @Binding
    var added: Bool

    @Binding
    var isDragging: Bool {
        didSet {
            print("isDragging: \(isDragging)")
        }
    }

    var body: some View {
        VStack {
            if products.isEmpty {
                Label("Can't find any product with this name.", systemImage: "info.circle")
                    .font(.largeTitle)
                    .padding()
            } else {
                if verticalSizeClass == .compact {
                    // landscape
                    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(products) { product in
                                ProductOfferView(product: product, added: $added)
                                    .padding()
                            }
                        }
                    }.simultaneousGesture(DragGesture()
                                            .onChanged { _ in
                        isDragging = true
                    })
                } else {
                    // portrait
                    ScrollView {
                        LazyVStack {
                            ForEach(products) { product in
                                ProductOfferView(product: product, added: $added)
                            }
                        }
                    }.simultaneousGesture(DragGesture()
                                            .onChanged { _ in
                        isDragging = true
                    })
                }
            }
        }
    }
}

struct SearchingResultsView_Previews: PreviewProvider {
    static var previews: some View {
        let products =  mockProducts()

        return SearchingResultsView(products: products, added: .constant(false), isDragging: .constant(false))
    }

    static func mockProducts() -> [Product] {
        let context = PersistenceController.preview.container.viewContext

        let market1 = Market(context: context)
        market1.name = "Market 1"
        market1.iconUrl = URL(string: "https://pbs.twimg.com/profile_images/1103993935419068416/f8FkyYcp_400x400.png")
        let market2 = Market(context: context)
        market2.name = "Market 2"
        market2.iconUrl = URL(string: "https://pbs.twimg.com/profile_images/1272912771873738753/4mJRDWoR_400x400.png")

        let product = Product(context: context)
        product.name = "Producte 1"
        product.imageUrl = URL(string: "https://static.condisline.com/resize_395x416/images/catalog/large/704005.jpg")

        let product2 = Product(context: context)
        product.name = "Producte 2"
        product.imageUrl = URL(string: "https://static.condisline.com/resize_395x416/images/catalog/large/704005.jpg")

        let offer1 = Offer(context: context)
        offer1.price = 1.10
        offer1.market = market1
        offer1.product = product

        let offer2 = Offer(context: context)
        offer2.price = 1.30
        offer2.market = market2
        offer2.product = product

        let offer3 = Offer(context: context)
        offer3.price = 2.10
        offer3.market = market1
        offer3.product = product2

        let offer4 = Offer(context: context)
        offer4.price = 2.30
        offer4.market = market2
        offer4.product = product2

        return [product, product2]
    }
}
