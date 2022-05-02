//
//  MarketRowView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 13/4/22.
//

import SwiftUI
import CoreData

struct MarketRowView: View {
    var defaultString: String?

    @ObservedObject
    var viewModel: MarketRowViewModel

    init(market: Market?, defaultString: String?, shoppingAssistant: ShoppingAssistant) {
        _viewModel = .init(wrappedValue: MarketRowViewModel(market: market, shoppingAssistant: shoppingAssistant))
        self.defaultString = defaultString
    }

    var body: some View {
        HStack {
            MarketLabelView(market: viewModel.market,
                            defaultString: defaultString ?? "N.A.",
                            height: 20,
                            labelFont: .callout)
            if viewModel.market != nil {
                FavoriteButton(isOn: $viewModel.isFavorite)
                    .labelStyle(.iconOnly)
            }
        }
        .padding(.init(top: 6.0, leading: 4.0, bottom: 6.0, trailing: 4.0))
    }
}

struct MarketRowView_Previews: PreviewProvider {
    static var previews: some View {
        let container = PersistenceController.preview.container
        let viewContext = container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext,
                                                            coordinator: container.persistentStoreCoordinator)
        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)

        MarketRowView(market: mockMarket(), defaultString: "N.A.", shoppingAssistant: shoppingAssistant)
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
