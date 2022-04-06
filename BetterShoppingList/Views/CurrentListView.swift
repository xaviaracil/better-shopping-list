//
//  CurrentListView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 6/4/22.
//

import SwiftUI

struct CurrentListView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var shoppingAssistant: ShoppingAssistant

    var products: Set<ChosenProduct>? {
        shoppingAssistant.currentList?.products as? Set<ChosenProduct>
    }

    var body: some View {
        if verticalSizeClass == .compact {
            // landscape
            let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
            ScrollView(.horizontal) {
                LazyHGrid(rows: rows) {
                    MarketListView(products: products, markets: shoppingAssistant.markets)
                }
            }
        } else {
            // portrait
            let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
            ScrollView {
                LazyVGrid(columns: columns) {
                    MarketListView(products: products, markets: shoppingAssistant.markets)
                }
            }
        }
    }
}

struct MarketListView: View {
    var products: Set<ChosenProduct>?
    var markets: [Market]?

    var body: some View {
        if let products = products,
           let markets = markets {
            let sortedMarkets = products.groupedByMarket(markets: markets)
                .sorted {
                    $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") ?? .orderedDescending == .orderedAscending
                }

            ForEach(sortedMarkets) { market in
                ZStack(alignment: .topTrailing) {
                Group {
                    // swiftlint:disable no_space_in_method_call multiple_closures_with_trailing_closure
                    Label {
                        MarketLabelView(market: market)
                    } icon: {
                        Image(systemName: "cart")
                    }
                    .labelStyle(ShoppingListLabelStyle())
                    .padding(EdgeInsets(top: 20.0, leading: 10.0, bottom: 10.0, trailing: 10.0))
                }
                .addBorder(.foreground, width: 1, cornerRadius: 10)
                .padding(10)
                Circle()
                    .fill(.red)
                    .frame(width: 40, height: 40, alignment: .center)
                    .overlay(
                        Text("\(products.ofMarket(market: market).count)")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                    )
                }
            }
        } else {
            Spacer()
        }
    }
}
struct CurrentListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext)
        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)

        let market1 = Market(context: viewContext)
        market1.name = "Market 1"
        market1.iconUrl = URL(string: "https://pbs.twimg.com/profile_images/1103993935419068416/f8FkyYcp_400x400.png")
//        let market2 = Market(context: viewContext)
//        market2.name = "Market 2"
//
        let product = Product(context: viewContext)
        product.name = "Producte 1"
        product.imageUrl = URL(string: "https://static.condisline.com/resize_395x416/images/catalog/large/704005.jpg")
//
        let offer1 = Offer(context: viewContext)
        offer1.price = 1.10
        offer1.market = market1
        offer1.product = product
//
//        let offer2 = Offer(context: viewContext)
//        offer2.price = 1.30
//        offer2.market = market2
//        offer2.product = product
//
//        let productOffer = ProductOffers(product: product, offers: [offer1, offer2])
//
//        shoppingAssistant.addProductToCurrentList(productOffer.chooseOffer(at: 0))
        let chosenProduct = ChosenProduct(context: viewContext)
        chosenProduct.name = "Producte"
        chosenProduct.price = 1.1
        chosenProduct.offerUri = offer1.objectID.uriRepresentation()
        chosenProduct.marketUri = market1.objectID.uriRepresentation()

        shoppingAssistant.addProductToCurrentList(chosenProduct)

        return CurrentListView()
            .environmentObject(shoppingAssistant)
    }
}
