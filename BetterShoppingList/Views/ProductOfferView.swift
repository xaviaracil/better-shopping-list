//
//  OfferView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 3/4/22.
//

import SwiftUI

struct ProductOfferView: View {
    var productOffers: ProductOffers
    @EnvironmentObject var shoppingAssistant: ShoppingAssistant

    var bestOffer: Offer? {
        return productOffers.offers?.first
    }

    var body: some View {
        HStack {
            // swiftlint:disable multiple_closures_with_trailing_closure
            AsyncImage(url: productOffers.product.imageUrl) { image in
                image.resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 90, height: 90)

            VStack(alignment: .leading) {
                Text(productOffers.product.name ?? "No Name")
                    .productTitle()
                Text(bestOffer?.price.formatted(.currency(code: "eur")) ?? "N.A")
                    .bestPrice()
                HStack {
                    AsyncImage(url: bestOffer?.market?.iconUrl) { logo in
                        logo.resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 16.0)
                    Text(bestOffer?.market?.name ?? "N.A")
                        .marketLabel()
                }

            }

            Spacer()

            Button(action: {print("action!")}) {
                Label("Add to basket", systemImage: "cart.circle")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                    .labelStyle(.iconOnly)

            }
        }
    }
}

struct ProductTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .truncationMode(.tail)
            .font(.headline)
    }
}

struct OfferBestPrice: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .foregroundColor(.accentColor)
    }
}

struct MarketLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption2)
    }
}
extension View {
    func productTitle() -> some View {
        modifier(ProductTitle())
    }

    func bestPrice() -> some View {
        modifier(OfferBestPrice())
    }

    func marketLabel() -> some View {
        modifier(MarketLabel())
    }
}

struct ProductOfferView_Previews: PreviewProvider {
    static var previews: some View {
        ProductOfferView(productOffers: mockOffer())
    }

    static func mockOffer() -> ProductOffers {
        let context = PersistenceController.preview.container.viewContext

        let market1 = Market(context: context)
        market1.name = "Market 1"
        market1.iconUrl = URL(string: "https://pbs.twimg.com/profile_images/1103993935419068416/f8FkyYcp_400x400.png")
        let market2 = Market(context: context)
        market2.name = "Market 2"

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

        return ProductOffers(product: product, offers: [offer1, offer2])
    }
}