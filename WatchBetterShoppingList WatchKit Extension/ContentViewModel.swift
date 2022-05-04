//
//  ContentViewModel.swift
//  WatchBetterShoppingList WatchKit Extension
//
//  Created by Xavi Aracil on 29/4/22.
//

import Foundation
import WatchConnectivity
import CoreData
import CoreLocation
import Combine

class ContentViewModel: NSObject, WCSessionDelegate, ObservableObject {
    @Published
    var products: [ChosenProduct] = []
    @Published
    var marketName = ""
    @Published
    var askedForProducts = false

    var session: WCSession?

    @Published
    private var currentLocation: CLLocation? {
        didSet {
            askForProducts()
        }
    }

    let locationManager = LocationManager()
    let persistenceController = PersistenceController.shared
    private var cancellableSet: Set<AnyCancellable> = []

    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
        }
        locationManager.locationPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates(by: lessThan50Meters)
            .assign(to: \.currentLocation, on: self)
            .store(in: &cancellableSet)
        askedForProducts = true
        locationManager.start()
    }

    deinit {
        locationManager.stop()
    }

    func askForProducts() {
        guard let session = session,
              let currentLocation = currentLocation else {
            return
        }

        print("🖥 askForProducts in location \(currentLocation)")
        if session.isReachable {
            // ask for products
            session.sendMessage(["name": "products",
                                 "latitude": currentLocation.coordinate.latitude,
                                 "longitude": currentLocation.coordinate.longitude],
                                replyHandler: nil) { print("\($0)") }
            DispatchQueue.main.async {
                self.askedForProducts = true
            }
        }
    }

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("🖥 session didReceiveMessage \(message)")
        guard let encodedProducts = message["products"] as? Data,
        let name = message["market"] as? String else {
            return
        }
        locationManager.stop()

        let context = persistenceController.container.viewContext
        let decoder = PropertyListDecoder()
        var chosenProducts: [ChosenProduct] = []
        do {
            let products = try decoder.decode([WCChosenProduct].self, from: encodedProducts)
            chosenProducts = products.map { $0.toChosenProduct(context: context)}
        } catch {
            print("🖥 Error decoding products: \(error)")
        }

        DispatchQueue.main.async {
            self.askedForProducts = false
            self.marketName = name
            self.products = chosenProducts
        }
    }

    func identifierForStore() -> String? {
        return persistenceController.container.persistentStoreCoordinator.persistentStores.first?.identifier
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
