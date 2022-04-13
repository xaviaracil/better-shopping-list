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
    private let searchRequest = MKLocalSearch.Request()

    let resultsPublisher =
    PassthroughSubject<[MKMapItem], Never>()

    override init() {
        super.init()
        self.searchRequest.resultTypes = .pointOfInterest
        self.searchRequest.naturalLanguageQuery = "Supermercat"
    }

    func search(region: MKCoordinateRegion) {
        self.searchRequest.region = region
        let localSearch = MKLocalSearch(request: self.searchRequest)
        print("🖥 searching...")
        localSearch.start { [unowned self] (response, error) in
            if let error = error as NSError? {
                print("MKLocalSearch encountered an error: \(error.localizedDescription).")
                return
            }
            if let response = response {
                self.resultsPublisher.send(response.mapItems)
            }
        }
    }
}
