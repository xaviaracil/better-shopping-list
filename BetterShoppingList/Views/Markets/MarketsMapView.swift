//
//  MarketsMap.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 13/4/22.
//

import SwiftUI
import MapKit

struct MarketsMapView<Data>: View
where Data: RandomAccessCollection,
      Data.Element: Market {

    /// markets to display
    var markets: Data

    /// view model object
    @StateObject
    var viewModel = MarketsMapViewModel()

    @State
    var userTrackingMode: MapUserTrackingMode = .follow

    @State
    private var displayMode = MapDisplayMode.all

    var body: some View {
        Map(coordinateRegion: $viewModel.region,
            showsUserLocation: true,
            userTrackingMode: $userTrackingMode,
            annotationItems: viewModel.items) { item in
            MapAnnotation(coordinate: item.placemark.location!.coordinate) {
                let name = item.name
                let market = marketWithName(name: name)
                if displayInMap(item: item, market: market) {
                    MarketRowView(market: market, defaultString: name)
                    .padding(4.0)
                    .background(.background)
                    .cornerRadius(10.0)
                } else {
                    EmptyView()
                }
            }
        }
        .toolbar(content: {
            Picker("Mode", selection: $displayMode) {
                ForEach(MapDisplayMode.allCases) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }.pickerStyle(.segmented)
        })
        .navigationBarTitle("Markets", displayMode: .inline)
        .task {
            // start updating location
            viewModel.startUpdating()
        }
    }

    func displayInMap(item: MKMapItem, market: Market?) -> Bool {
        let result = market != nil || (item.pointOfInterestCategory == .foodMarket && displayMode == .all)
        if result {
            print("🖥 displayInMap \(item.name ?? "nil")")
        }
        return result
    }

    func marketWithName(name: String?) -> Market? {
        guard let name = name else {
            return nil
        }

        return markets
            .filter { displayMode == .all || ($0.userMarket?.isFavorite ?? true) }
            .filter {
            guard let marketName = $0.name else { return false }
            return name.lowercased().localizedStandardContains(marketName.lowercased())
        }.first
    }
}

enum MapDisplayMode: String, CaseIterable, Identifiable {
    case all
    case favorites

    // swiftlint:disable identifier_name
    var id: String { self.rawValue }
}

struct MarketsMapView_Previews: PreviewProvider {
    static var previews: some View {
        MarketsMapView(markets: mockMarkets())
    }

    static func mockMarkets() -> [Market] {
        let context = PersistenceController.preview.container.viewContext

        let market1 = Market(context: context)
        market1.name = "Market 1"
        market1.iconUrl = URL(string: "https://pbs.twimg.com/profile_images/1103993935419068416/f8FkyYcp_400x400.png")
        let market2 = Market(context: context)
        market2.name = "Market 2"
        market2.iconUrl = URL(string: "https://pbs.twimg.com/profile_images/1272912771873738753/4mJRDWoR_400x400.png")
        return [market1, market2]
    }
}
