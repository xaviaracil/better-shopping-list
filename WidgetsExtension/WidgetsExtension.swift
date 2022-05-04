//
//  WidgetsExtension.swift
//  WidgetsExtension
//
//  Created by Xavi Aracil on 4/5/22.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    var persistenceAdapter: PersistenceAdapter

    func placeholder(in context: Context) -> ShoppingListEntry {
        ShoppingListEntry(date: Date(),
                          products: persistenceAdapter.currentList?.chosenProductSet ?? [],
                          earned: 10.0) //persistenceAdapter.currentList?.earned ?? 0.0)
    }

    func getSnapshot(in context: Context, completion: @escaping (ShoppingListEntry) -> Void) {
        let entry = ShoppingListEntry(date: Date(),
                                      products: persistenceAdapter.currentList?.chosenProductSet ?? [],
                                      earned: 10.0) //persistenceAdapter.currentList?.earned ?? 0.0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let entry = ShoppingListEntry(date: Date(),
                                      products: persistenceAdapter.currentList?.chosenProductSet ?? [],
                                      earned: 10.0) //persistenceAdapter.currentList?.earned ?? 0.0)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct ShoppingListEntry: TimelineEntry {
    let date: Date
    let products: Set<ChosenProduct>
    let earned: Double
}

struct WidgetsExtensionEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    var entry: Provider.Entry

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall: SmallView(entry: entry)
        case .systemMedium: MediumView(entry: entry)
        case .systemLarge, .systemExtraLarge: LargeView(entry: entry)
        default: SmallView(entry: entry)
        }
    }
}

@main
struct WidgetsExtension: Widget {
    var body: some WidgetConfiguration {
        let context = PersistenceController.shared.container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: context)
        return StaticConfiguration(kind: WidgetConstants.kind,
                            provider: Provider(persistenceAdapter: persistenceAdapter)) { entry in
            WidgetsExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("BetterShoopingList")
        .description("Show the status of your current list")
    }
}

struct WidgetsExtension_Previews: PreviewProvider {
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

        let entry = ShoppingListEntry(date: Date(), products: products, earned: 10.0)
        return Group {
            WidgetsExtensionEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            WidgetsExtensionEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            WidgetsExtensionEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            WidgetsExtensionEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
        }
    }
}
