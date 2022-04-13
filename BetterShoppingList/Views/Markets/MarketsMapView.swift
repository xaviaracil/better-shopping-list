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

    var body: some View {
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true, userTrackingMode: $userTrackingMode, annotationItems: viewModel.items) { item in
            MapAnnotation(coordinate: item.placemark.location!.coordinate) {
                Image(systemName: "pin.circle.fill").foregroundColor(.accentColor)
                Text(item.name ?? "No Name")
            }
        }
            .task {
                // start updating location
                viewModel.startUpdating()
            }
    }
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
    }}
