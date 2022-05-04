//
//  LargeView.swift
//  WidgetsExtensionExtension
//
//  Created by Xavi Aracil on 4/5/22.
//

import SwiftUI
import CoreData
import Algorithms
import WidgetKit

struct LargeView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    let numberOfMarketsToShow = 3
    var entry: ShoppingListEntry
    var markets: [Market] {
        entry.products.groupedByMarket(markets: [])
            .uniqued(on: {$0.uuid})
            .sorted { lhs, rhs in
                entry.products.ofMarket(market: lhs).count > entry.products.ofMarket(market: rhs).count
            }
    }

    var numberOfColumns: Int {
        switch family {
        case .systemExtraLarge:
            return 4
        default:
            return 2
        }
    }

    var body: some View {
        ZStack {
            Color("WidgetBackground")
            VStack(alignment: .leading) {
                ForEach(markets.prefix(numberOfMarketsToShow), id: \.self) { market in
                    MarketLabelView(market: market, labelFont: .subheadline)
                    let columns: [GridItem] =
                    Array(repeating: .init(.flexible(), alignment: .leading), count: numberOfColumns)
                    LazyVGrid(columns: columns) {
                        ForEach(entry.products.ofMarket(market: market), id: \.self) { chosenProduct in
                            HStack {
                                ProductImageView(product: chosenProduct.offer?.product,
                                                 isSpecialOffer: chosenProduct.isSpecialOffer)
                                    .frame(width: 48, height: 48)

                                VStack(alignment: .leading) {
                                    Text(chosenProduct.wrappedName)
                                    Text(chosenProduct.price.euros)
                                }
                            }
                            .font(.subheadline)
                        }
                        .padding([.bottom], 2.0)
                        .minimumScaleFactor(0.01)
                    }
                }.padding([.leading, .trailing])

                Spacer()
                HStack(alignment: .center) {
                    Spacer()
                    EarnedView(value: entry.earned)
                        .font(.largeTitle.bold())
                    Spacer()
                }
            }
            .padding(.top)
            .foregroundColor(.white)
        }
    }
}

struct LargeView_Previews: PreviewProvider {
    static func mockMarket(name: String, viewContext: NSManagedObjectContext) -> Market {
        let market = Market(context: viewContext)
        market.name = name
        market.uuid = UUID()
        market.iconUrl = URL(string: "https://pbs.twimg.com/profile_images/1103993935419068416/f8FkyYcp_400x400.png")
        return market
    }

    static func mockChosenProduct(name: String, market: Market, viewContext: NSManagedObjectContext) -> ChosenProduct {
        let chosenProduct = ChosenProduct(context: viewContext)
        chosenProduct.name = name
        chosenProduct.price = Double.random(in: (0.20)..<(99.9))
        chosenProduct.offerUUID = UUID()
        chosenProduct.marketUUID = market.uuid

        return chosenProduct
    }
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext

        let market1 = mockMarket(name: "Market 1", viewContext: viewContext)
        let market2 = mockMarket(name: "Market 2", viewContext: viewContext)
        let market3 = mockMarket(name: "Market 3", viewContext: viewContext)
        let market4 = mockMarket(name: "Market 4", viewContext: viewContext)

        var products: Set<ChosenProduct> = []
        products.insert(mockChosenProduct(name: "Producte 1", market: market1, viewContext: viewContext))
        products.insert(mockChosenProduct(name: "Producte 2", market: market2, viewContext: viewContext))
        products.insert(mockChosenProduct(name: "Producte 3", market: market3, viewContext: viewContext))
        products.insert(mockChosenProduct(name: "Producte 4", market: market3, viewContext: viewContext))
        products.insert(mockChosenProduct(name: "Producte 5", market: market4, viewContext: viewContext))
        products.insert(mockChosenProduct(name: "Producte 6", market: market2, viewContext: viewContext))

        return Group {
            LargeView(entry: ShoppingListEntry(date: Date(),
                                                products: products,
                                                earned: 10.20))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            LargeView(entry: ShoppingListEntry(date: Date(),
                                               products: products,
                                               earned: 10.20))
                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
        }
    }
}
