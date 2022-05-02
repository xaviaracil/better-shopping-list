//
//  AddProductHandler.swift
//  SiriIntents
//
//  Created by Xavi Aracil on 30/4/22.
//

import Foundation
import CoreData
import Intents

class AddProductHandler: NSObject, AddProductIntentHandling {
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

    func handle(intent: AddProductIntent) async -> AddProductIntentResponse {
        var quantity: Int16 = 1
        if let name = intent.name {
            // get product by name
            let fetchRequest = Product.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)
            fetchRequest.fetchLimit = 1
            do {
                let products = try persistenceController.container.viewContext.fetch(fetchRequest)
                let product = products.first!

                // get best offer
                if let offer = product.sorteredOffers?.first {
                    if let intentQuantity = intent.quantity {
                        quantity = Int16(truncating: intentQuantity)
                    }

                    // add chosen product and save
                    let chosenProduct = persistenceAdapter.newChosenProduct(offer: offer, quantity: quantity)
                    // add chosen product to the current list
                    try persistenceAdapter.addProductToCurrentList(chosenProduct)

                    return .init(code: .success, userActivity: nil)
                } else {
                    return .init(code: .failure, userActivity: nil)
                }
            } catch {
                return .init(code: .failure, userActivity: nil)
            }
        }
        return .init(code: .failure, userActivity: nil)
    }

    func resolveName(for intent: AddProductIntent) async -> INStringResolutionResult {
        if let name = intent.name {
            do {
                // search for name
                let products = try searchProducts(name)

                if products.isEmpty {
                    return .unsupported()
                }

                if products.count == 1 {
                    return .success(with: products.first!.name ?? "N.A.")
                }

                return .disambiguation(with: products.map { $0.name ?? "N.A." })
            } catch {
                return .unsupported()
            }
        } else {
            return .needsValue()
        }
    }

    func resolveQuantity(for intent: AddProductIntent) async -> AddProductQuantityResolutionResult {
        if let quantity = intent.quantity {
            return .success(with: Int(truncating: quantity))
        }
        return .success(with: 1)
    }

    private func searchProducts(_ name: String) throws -> [Product] {
        let fetchRequest = Product.fetchRequest()
        fetchRequest.predicate = persistenceAdapter.productNamePredicate(for: name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Product.name, ascending: true)]
        return try persistenceController.container.viewContext.fetch(fetchRequest)
    }
}
