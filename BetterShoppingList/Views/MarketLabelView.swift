//
//  MarketLabelView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 6/4/22.
//

import SwiftUI

struct MarketLabelView: View {
    var market: Market?
    var body: some View {
        HStack {
            // swiftlint:disable multiple_closures_with_trailing_closure
            AsyncImage(url: market?.iconUrl) { logo in
                logo.resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(height: 16.0)
            Text(market?.name ?? "N.A")
                .marketLabel()
        }
    }
}

extension View {
    func marketLabel() -> some View {
        modifier(MarketLabel())
    }
}

struct MarketLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption2)
    }
}

struct MarketLabelView_Previews: PreviewProvider {
    static var previews: some View {
        MarketLabelView()
    }
}
