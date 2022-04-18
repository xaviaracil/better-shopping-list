//
//  CurrentListMarketListView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 7/4/22.
//

import SwiftUI

struct CurrentListMarketListView: View {
    var products: Set<ChosenProduct>?
    var markets: [Market]?

    var body: some View {
        if let products = products,
           let markets = markets {
            ForEach(markets) { market in
                CurrentListMarketView(market: market, products: products.ofMarket(market: market))
            }
        } else {
            Spacer()
        }
    }
}

struct CurrentListMarketListView_Previews: PreviewProvider {
    static var previews: some View {
        let container = PersistenceController.preview.container
        let viewContext = container.viewContext
        let market1 = Market(context: viewContext)
        market1.name = "Market 1"
        market1.iconUrl = URL(string: "https://pbs.twimg.com/profile_images/1103993935419068416/f8FkyYcp_400x400.png")

        let market2 = Market(context: viewContext)
        market2.name = "Market 2"
        market2.iconUrl = URL(string: "https://pbs.twimg.com/profile_images/1103993935419068416/f8FkyYcp_400x400.png")

        return CurrentListMarketListView(products: nil, markets: [market1, market2])
    }
}
