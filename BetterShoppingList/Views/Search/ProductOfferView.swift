//
//  OfferView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 3/4/22.
//

import SwiftUI

struct ProductOfferView: View {
    var product: Product
    @EnvironmentObject var shoppingAssistant: ShoppingAssistant

    @State var currentOfferIndex: Int = 0
    @State var quantity: Int16 = 1

    var onAdded: () -> Void = {}

    var chosenOffer: Offer? {
        return product.sorteredOffers?.first// [currentOfferIndex]
    }

    var viewModel = ProductOfferViewModel()

    @Binding
    var added: Bool

    var body: some View {
        HStack {
            ProductImageView(product: product, isSpecialOffer: chosenOffer?.isSpecialOffer ?? false)
            .frame(width: 90, height: 90)

            VStack(alignment: .leading) {
                Text(product.name ?? "No Name")
                    .productTitle()
                Text(chosenOffer?.price.euros ?? "N.A")
                    .bestPrice()
                MarketLabelView(market: chosenOffer?.market)
                Stepper(value: $quantity) {
                    Text("Quantity: \(quantity)")

                }
                .font(.subheadline)
            }

            Spacer()

            Button(action: {
                if let chosenOffer = chosenOffer {
                    let chosenProduct = viewModel.choseProduct(product: product, offer: chosenOffer, quantity: quantity)
                    shoppingAssistant.addProductToCurrentList(chosenProduct)
                    added = true
                }
            }) {
                Label("Add to basket", systemImage: "cart.circle")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                    .labelStyle(.iconOnly)

            }
        }
    }
}

struct ProductOfferView_Previews: PreviewProvider {
    static var previews: some View {
        ProductOfferView(product: mockProduct(), added: .constant(false))
            .border(.foreground, width: 1.0)
    }

    static func mockProduct() -> Product {
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

        let offer1 = Offer(context: context)
        offer1.price = 1.10
        offer1.market = market1
        offer1.product = product

        let offer2 = Offer(context: context)
        offer2.price = 1.30
        offer2.market = market2
        offer2.product = product

        return product
    }
}
