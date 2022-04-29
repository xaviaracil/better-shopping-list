//
//  WatchConnector.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 29/4/22.
//

import Foundation
import WatchConnectivity
import CoreData

protocol WatchConnectorDelegate {
    func askForNearbyProducts()
}

class WatchConnector: NSObject, WCSessionDelegate {
    var delegate: WatchConnectorDelegate?

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

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let operation = message["name"] as? String,
           operation == "products" {
            // launch a new operation
            delegate?.askForNearbyProducts()
        }
    }

    func notifyProducts(_ ids: [NSManagedObjectID], for market: Market) {
        if WCSession.default.isReachable {
            let message: [String: Any] = ["ids": ids.map { $0.uriRepresentation().absoluteString },
                                          "market": market.name ?? "N.A"]
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sendiing message \(error)")
            }
        }
    }
}
