//
//  ContentViewModel.swift
//  WatchBetterShoppingList WatchKit Extension
//
//  Created by Xavi Aracil on 29/4/22.
//

import Foundation
import WatchConnectivity
import CoreData

class ContentViewModel: NSObject, WCSessionDelegate, ObservableObject {
    @Published
    var products: [ChosenProduct] = []
    @Published
    var marketName = ""

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
        if session.isReachable {
            // ask for products
            session.sendMessage(["name": "products"], replyHandler: nil, errorHandler: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("session didReceiveMessage \(message)")
        guard let ids = message["ids"] as? [String],
        let name = message["market"] as? String else {
            return
        }
        let coordinator = PersistenceController.shared.container.persistentStoreCoordinator
        let context = PersistenceController.shared.container.viewContext
        let receivedProducts = ids
            .compactMap { coordinator.managedObjectID(forURIRepresentation: URL(string: $0)!)}
            .compactMap { try? context.existingObject(with: $0) as? ChosenProduct}
        DispatchQueue.main.async {
            self.marketName = name
            self.products = receivedProducts
        }
    }
}
