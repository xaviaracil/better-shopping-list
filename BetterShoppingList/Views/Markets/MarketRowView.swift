//
//  MarketRowView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 13/4/22.
//

import SwiftUI

struct MarketRowView: View {
    var market: Market?
    var defaultString: String?

    @EnvironmentObject
    private var shoppingAssitant: ShoppingAssistant

    var body: some View {
        HStack {
            MarketLabelView(market: market, defaultString: defaultString ?? "N.A.")
            if let market = market {
                Image(systemName: "star")
                    .symbolVariant(market.userMarket?.isFavorite ?? false ? .fill : .none)
            }
        }
        .padding([.horizontal, .vertical], 4.0)
        .onTapGesture {
            if let market = market {
                shoppingAssitant.toogleFavourite(market: market)
            }
        }
    }
}

struct MarketRowView_Previews: PreviewProvider {
    static var previews: some View {
        let container = PersistenceController.preview.container
        let viewContext = container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext,
                                                            coordinator: container.persistentStoreCoordinator)
        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)

        MarketRowView(market: mockMarket())
            .environmentObject(shoppingAssistant)
            .border(.foreground, width: 1.0)
    }

    static func mockMarket() -> Market {
        let context = PersistenceController.preview.container.viewContext

        let market = Market(context: context)
        market.name = "Market 1"
        market.iconUrl = URL(string: "https://pbs.twimg.com/profile_images/1103993935419068416/f8FkyYcp_400x400.png")
        return market
    }
}
