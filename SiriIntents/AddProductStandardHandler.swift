//
//  AddProductStandardHandler.swift
//  SiriIntents
//
//  Created by Xavi Aracil on 2/5/22.
//

import Foundation
import Intents

class AddProductStandardHandler: NSObject, INAddTasksIntentHandling {
    let runningInTests = NSClassFromString("XCTestCase") != nil || ProcessInfo().arguments.contains("testMode")

    var persistenceController: PersistenceController!
    var persistenceAdapter: PersistenceAdapter!

    override init() {
        super.init()
        persistenceController = runningInTests ? PersistenceController.preview : PersistenceController.shared
        let container = persistenceController.container
        persistenceAdapter = CoreDataPersistenceAdapter(viewContext: container.viewContext,
                                                        coordinator: container.persistentStoreCoordinator)
    }

    func handle(intent: INAddTasksIntent) async -> INAddTasksIntentResponse {
        if let names = intent.taskTitles {
            let result = INAddTasksIntentResponse(code: .success, userActivity: nil)
            let tasks = names.compactMap { addProduct(name: $0) }
            result.addedTasks = tasks
            // swiftlint:disable line_length
            let currentTasks = persistenceAdapter.currentList?.products?.allObjects.compactMap { ($0 as? ChosenProduct)?.toINTask() } ?? []
            result.modifiedTaskList = INTaskList(title: INSpeakableString(spokenPhrase: "Current list"),
                                                 tasks: currentTasks,
                                                 groupName: INSpeakableString(spokenPhrase: "BetterShoppingList"),
                                                 createdDateComponents: nil,
                                                 modifiedDateComponents: nil,
                                                 identifier: nil)
            return result
        }
        return .init(code: .failure, userActivity: nil)
    }

    func addProduct(name: INSpeakableString) -> INTask? {
        print("🖥 adding product with name: \(name)")
        // get product by name
        let fetchRequest = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name.spokenPhrase)
        fetchRequest.fetchLimit = 1
        do {
            let products = try persistenceController.container.viewContext.fetch(fetchRequest)
            print("🖥 found product with name: \(name)")
            print("🖥 \(products)")
            let product = products.first!

            // get best offer
            print("🖥 finding best offer")
            if let offer = product.sorteredOffers?.first {
                print("🖥 adding product to the list")
                // add chosen product and save
                let chosenProduct = persistenceAdapter.newChosenProduct(offer: offer, quantity: 1)
                // add chosen product to the current list
                try persistenceAdapter.addProductToCurrentList(chosenProduct)

                print("🖥 returning")
                return chosenProduct.toINTask()
            }
        } catch {
            print("Error adding product \(name): \(error)")
        }
        return nil
    }

    func resolveTaskTitles(for intent: INAddTasksIntent) async -> [INSpeakableStringResolutionResult] {
        if let titles = intent.taskTitles {
            return titles.map { resolveTitle(for: $0) }
        } else {
            return [.needsValue()]
        }
    }

    func resolveTitle(for name: INSpeakableString) -> INSpeakableStringResolutionResult {
        print("🖥 resolveTitle: \(name)")
        do {
            // search for name
            let products = try searchProducts(name.spokenPhrase)

            if products.isEmpty {
                print("🖥 can't find any product with name: \(name)")
                return .unsupported()
            }

            if products.count == 1 {
                print("🖥 only one product found with name: \(name)")
                return .success(with: INSpeakableString(spokenPhrase: products.first!.name ?? "N.A."))
            }

            print("🖥 more than one product found with name: \(name)")
            return .disambiguation(with: products.map { INSpeakableString(spokenPhrase: $0.name ?? "N.A.") })
        } catch {
            return .unsupported()
        }
    }

    private func searchProducts(_ name: String) throws -> [Product] {
        print("🖥 searchProducts: \(name)")
        let fetchRequest = Product.fetchRequest()
        fetchRequest.predicate = persistenceAdapter.productNamePredicate(for: name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Product.name, ascending: true)]
        return try persistenceController.container.viewContext.fetch(fetchRequest)
    }
}

extension ChosenProduct {
    func toINTask() -> INTask {
        INTask(title: INSpeakableString(spokenPhrase: self.name ?? "N.A"),
                      status: .notCompleted,
                      taskType: .completable,
                      spatialEventTrigger: nil,
                      temporalEventTrigger: nil,
                      createdDateComponents: nil,
                      modifiedDateComponents: nil,
                      identifier: self.objectID.uriRepresentation().absoluteString,
                      priority: .notFlagged)
    }
}
