//
//  ListMarketLocationManager.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 29/4/22.
//

import Foundation
import CoreLocation
import Combine
import MapKit

class ListMarketLocationManager: ObservableObject {
    private let locationManager = LocationManager()
    private let marketSearchManager = MarketSearchManager()

    // Current market, updated by MarketSearchManager
    @Published
    var currentMarket: Market? {
        didSet {
            currentMarketPublisher.send(currentMarket)
        }
    }

    let currentMarketPublisher = PassthroughSubject<Market?, Never>()

    // Current location, updated by LocationManager.
    @Published
    var currentLocation: CLLocation? {
        didSet {
            region = MKCoordinateRegion(center: currentLocation!.coordinate,
                                       latitudinalMeters: 50,
                                       longitudinalMeters: 50)
        }
    }

    // Current region. Fires market search when changes
    @Published
    var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.334_900,
                                                                   longitude: -122.009_020),
                                    latitudinalMeters: 750,
                                    longitudinalMeters: 750) {
        didSet {
            regionPublisher.send(region)
        }
    }

    private var cancellableSet: Set<AnyCancellable> = []
    private let regionPublisher =
    PassthroughSubject<MKCoordinateRegion, Never>()

    // list of markets found in region
    @Published
    var items: [MKMapItem] = []

    public var shoppingList: ShoppingList?

    init() {
        // update location in currentLocation
        locationManager.locationPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates(by: lessThan50Meters)
            .assign(to: \.currentLocation, on: self)
            .store(in: &cancellableSet)

        // update search manager results in items
        marketSearchManager.resultsPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { results in
                self.items = results
                self.checkMarkets(results)
            }
            .store(in: &cancellableSet)

        // search for markets when region changes
        regionPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [self] _ in
                Task {
                    // update search
                    await self.marketSearchManager.search(region: region)
                }
            }
            .store(in: &cancellableSet)

    }

    fileprivate func checkMarkets(_ results: [MKMapItem]) {
        // swiftlint:disable line_length
        print("🖥 Some results found \(results.map { String(describing: $0.name) }). Markets: \(String(describing: self.shoppingList?.markets))")
        self.currentMarket = self.shoppingList?.markets?.first(where: { market in
            results.contains { item in
                guard let marketName = market.name else { return false }
                return item.name?.lowercased().localizedStandardContains(marketName.lowercased()) ?? false
            }
        })
    }

    func start() {
        guard shoppingList != nil else {
            return
        }
        self.checkMarkets(items)
        locationManager.start()
    }

    func stop() {
        locationManager.stop()
    }

    private func lessThan50Meters(_ lhs: CLLocation?,
                                  _ rhs: CLLocation?) -> Bool {
        if lhs == nil && rhs == nil {
            return true
        }
        guard let lhr = lhs,
              let rhr = rhs else {
                  return false
              }

        return lhr.distance(from: rhr) < 50
    }

}
