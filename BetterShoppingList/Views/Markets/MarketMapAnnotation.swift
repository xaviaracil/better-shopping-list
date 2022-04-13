//
//  MarketMapAnnotation.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 13/4/22.
//

import SwiftUI

struct MarketMapAnnotation: View {
    var body: some View {
        let name = item.name
        let market = marketWithName(name: name)
        if displayInMap(item: item, market: market) {
            MarketLabelView(market: market, defaultString: name ?? "N.A.")
                .padding(4.0)
                .background(.background)
                .cornerRadius(10.0)
        } else {
            EmptyView()
        }
    }
}

struct MarketMapAnnotation_Previews: PreviewProvider {
    static var previews: some View {
        MarketMapAnnotation()
    }
}
