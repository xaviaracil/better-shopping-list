//
//  CurrentListMarketView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 7/4/22.
//

import SwiftUI

struct CurrentListMarketView: View {
    var market: Market
    var products: [ChosenProduct]
    @State private var isPresented = false
    var deleteChosenProducts: (([ChosenProduct]) -> Void)?
    var changeChosenProduct: ((ChosenProduct, Offer) -> Void)?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                Label {
                    MarketLabelView(market: market)
                } icon: {
                    Image(systemName: "cart")
                }
                .labelStyle(ShoppingListLabelStyle())
                .padding(EdgeInsets(top: 20.0, leading: 10.0, bottom: 10.0, trailing: 10.0))
            }
            .accessibility(label: Text("Products in market \(market.name ?? "N.A.")"))
            .accessibility(hint: Text("Display products"))
            .accessibility(addTraits: .isButton)
            .addBorder(.foreground, width: 1, cornerRadius: 10)
            .padding(10)
            .onTapGesture {
                isPresented = true
            }

            Circle()
                .fill(.red)
                .frame(width: 36, height: 36, alignment: .center)
                .overlay(
                    Text("\(products.count)")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                )
                .accessibilityLabel(Text("Number of products in market \(market.name ?? "N.A.")"))
                .accessibilityValue(Text("\(products.ofMarket(market: market).count)"))
        }.sheet(isPresented: $isPresented) {
            ListDetailView(products: products,
                           name: market.name ?? "N. A.",
                           deleteChosenProducts: deleteChosenProducts,
                           changeChosenProduct: changeChosenProduct)
        }
    }
}

struct CurrentListMarketView_Previews: PreviewProvider {
    static var previews: some View {
        let container = PersistenceController.preview.container
        let viewContext = container.viewContext
        let market1 = Market(context: viewContext)
        market1.name = "Market 1"
        market1.iconUrl = URL(string: "https://pbs.twimg.com/profile_images/1103993935419068416/f8FkyYcp_400x400.png")

        return CurrentListMarketView(market: market1, products: [])
    }
}
