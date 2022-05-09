//
//  MarketSearchManager.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 13/4/22.
//

import Foundation
import MapKit
import Combine

class MarketSearchManager: NSObject {

    struct Constants {
        static let DISTANCE: CLLocationDistance = 5000.0
    }

    let resultsPublisher =
    PassthroughSubject<[MKMapItem], Never>()

    ///
    /// Search markets in the given region, publishing results in resultsPublisher
    /// Client should subscribe to resultsPublisher in order to get results.
    /// - Parameters:
    ///     - region: region to search markets in
    func search(region: MKCoordinateRegion) async {
        let searchRequest = MKLocalPointsOfInterestRequest(center: region.center, radius: Constants.DISTANCE)
        searchRequest.pointOfInterestFilter = MKPointOfInterestFilter(including: [.foodMarket, .store])
        let localSearch = MKLocalSearch(request: searchRequest)
        print("🖥 searching...")
        do {
            let response = try await localSearch.start()
            self.resultsPublisher.send(response.mapItems)
        } catch {
            print("MKLocalSearch encountered an error: \(error.localizedDescription).")
        }
    }
}
