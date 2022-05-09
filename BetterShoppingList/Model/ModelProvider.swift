//
//  ModelProvider.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 9/5/22.
//

import Foundation
import SwiftUI
import CoreData

class ModelProvider: ObservableObject {
    @Published
    var shoppingAssistant: ShoppingAssistant?

    @Published
    var viewContext: NSManagedObjectContext!

    var persistenceController: PersistenceController?

    var persistenceLock: PersistenceLock

    init() {
        persistenceLock = PersistenceLock()
    }

    func save() {
        shoppingAssistant?.save()
    }

    func initModel(testMode: Bool) {
        guard persistenceController == nil, shoppingAssistant == nil else {
            // already init
            return
        }

        persistenceController = testMode ? PersistenceController.preview : PersistenceController.shared
        viewContext = persistenceController!.container.viewContext
        let persistanceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext)

        // save lock file for other extensions in application
        if !persistenceLock.exists {
            persistenceLock.save(testMode: testMode)
        }

        shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistanceAdapter)
    }

    func refresh() {
        // refresh
        persistenceController?.container.viewContext.refreshAllObjects()
        shoppingAssistant?.reloadCurrentList()

        // when active, check if we are near a market in the current list
        shoppingAssistant?.startSearchingForNearMarkets()
    }
}
