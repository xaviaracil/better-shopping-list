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

    @Published
    var currentMarket: Market? {
        didSet {
            currentMarketPublisher.send(currentMarket)
        }
    }

    let currentMarketPublisher = PassthroughSubject<Market?, Never>()

    @Published
    var currentLocation: CLLocation? {
        didSet {
            region = MKCoordinateRegion(center: currentLocation!.coordinate,
                                       latitudinalMeters: 50,
                                       longitudinalMeters: 50)
        }
    }

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

    @Published
    var items: [MKMapItem] = []

    public var shoppingList: ShoppingList?

    init() {
        locationManager.locationPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates(by: lessThan50Meters)
            .assign(to: \.currentLocation, on: self)
            .store(in: &cancellableSet)

        marketSearchManager.resultsPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { results in
                self.items = results
                self.checkMarkets(results)
            }
            .store(in: &cancellableSet)

        regionPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [self] _ in
                // update search
                self.marketSearchManager.search(region: region)
            }
            .store(in: &cancellableSet)

    }

    fileprivate func checkMarkets(_ results: [MKMapItem]) {
        print("🖥 Some results found \(results.map { String(describing: $0.name) }). Markets: \(String(describing: self.shoppingList?.markets))")
        self.currentMarket = self.shoppingList?.markets?.first(where: { market in
            results.contains { item in
                guard let marketName = market.name else { return false }
                return item.name?.lowercased().localizedStandardContains(marketName.lowercased()) ?? false
            }
        })
    }

    func start() {
        print("🖥 Start searching for markets")
        guard shoppingList != nil else {
            print("🖥 Start cancelled since there isn't any list")
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
