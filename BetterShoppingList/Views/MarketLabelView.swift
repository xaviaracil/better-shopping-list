//
//  MarketLabelView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 6/4/22.
//

import SwiftUI

struct MarketLabelView: View {
    var market: Market?
    var defaultString = "N.A."
    var height = 16.0
    var width = 32.0
    var labelFont: Font = .caption2
    var body: some View {
        HStack {
            // swiftlint:disable multiple_closures_with_trailing_closure
            AsyncImage(url: market?.iconUrl) { logo in
                logo.resizable()
                    .scaledToFit()
            } placeholder: {
                Image(systemName: "cart.circle")
            }
            .frame(width: width, height: height)
            Text(market?.name ?? defaultString)
                .font(labelFont)
        }
    }
}

struct MarketLabelView_Previews: PreviewProvider {
    static var previews: some View {
        MarketLabelView()
            .border(.foreground, width: 30.0)
    }
}
