//
//  MarketMapViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 13/4/22.
//

import Foundation
import CoreLocation
import Combine
import MapKit

class MarketsMapViewModel: ObservableObject {
    @Published
    private var status: CLAuthorizationStatus = .notDetermined

    @Published
    private var currentLocation: CLLocation? {
        didSet {
            region = MKCoordinateRegion(center: currentLocation!.coordinate,
                                       latitudinalMeters: 750,
                                       longitudinalMeters: 750)
        }
    }

    @Published
    var errorMessage = ""

    @Published
    var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.334_900,
                                                                   longitude: -122.009_020),
                                    latitudinalMeters: 750,
                                    longitudinalMeters: 750) {
        didSet {
            regionPublisher.send(region)
        }
    }

    private let locationManager = LocationManager()
    private let marketSearchManager = MarketSearchManager()

    var thereIsAnError: Bool {
        !errorMessage.isEmpty
    }

    private var cancellableSet: Set<AnyCancellable> = []
    private let regionPublisher =
    PassthroughSubject<MKCoordinateRegion, Never>()

    @Published
    var items: [MKMapItem] = []

    var statusDescription: String {
        switch status {
        case .notDetermined:
            return "notDetermined"
        case .authorizedWhenInUse:
            return "authorizedWhenInUse"
        case .authorizedAlways:
            return "authorizedAlways"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        @unknown default:
            return "unknown"
        }
    }

    func startUpdating() {
        locationManager.start()
    }

    init() {
        locationManager
            .statusPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.rawValue
                }
            } receiveValue: { self.status = $0}
            .store(in: &cancellableSet)

        locationManager.locationPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates(by: lessThan50Meters)
            .assign(to: \.currentLocation, on: self)
            .store(in: &cancellableSet)

        marketSearchManager.resultsPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink {
                self.items.append(contentsOf: $0)
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

extension MKMapItem: Identifiable {
}

