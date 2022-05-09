//
//  WatchConnector.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 29/4/22.
//

import Foundation
import WatchConnectivity
import CoreData
import CoreLocation

/// Protocol for comunication between watch extension and the main iOS app
@objc protocol WatchConnectorDelegate {
    /// ask for market search in given location
    /// - Parameters:
    ///     - in: location to search
    func askForNearbyProducts(in location: CLLocation)
}

/// Connector to watch extension.
class WatchConnector: NSObject, WCSessionDelegate {
    weak var delegate: WatchConnectorDelegate?

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let operation = message["name"] as? String,
           let latitude = message["latitude"] as? CLLocationDegrees,
           let longitude = message["longitude"] as? CLLocationDegrees,
           operation == "products" {
            // launch a new operation
            delegate?.askForNearbyProducts(in: CLLocation(latitude: latitude, longitude: longitude))
        }
    }

    /// Notify list of chosen product to the watch extension
    func notifyProducts(_ products: [ChosenProduct], for market: Market) {
        guard WCSession.default.isReachable,
              let data = try? products.toPropertyList() else {
                  print("Can't send message")
                  return
              }
        let message: [String: Any] = ["products": data,
                                      "market": market.wrappedName]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message \(error)")
        }
    }
}
