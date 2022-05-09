//
//  AddProductBaseHandler.swift
//  SiriIntents
//
//  Created by Xavi Aracil on 3/5/22.
//

import Foundation

class AddProductBaseHandler: NSObject {
    let runningInTests = NSClassFromString("XCTestCase") != nil || ProcessInfo().arguments.contains("testMode")

    var persistenceController: PersistenceController!
    var persistenceAdapter: PersistenceAdapter!

    override init() {
        super.init()

        let persistenceLock = PersistenceLock()
        if persistenceLock.exists {
            // swiftlint:disable line_length
            persistenceController = persistenceLock.testMode ? PersistenceController.preview : PersistenceController.shared
            let context = persistenceController.container.viewContext
            persistenceAdapter = CoreDataPersistenceAdapter(viewContext: context)
        }
    }

    func searchProducts(_ name: String) throws -> [Product] {
        print("🖥 searchProducts: \(name)")
        let markets = try getMarkets()
        print("🖥 markets: \(markets)")
        let fetchRequest = Product.fetchRequest()
        fetchRequest.predicate = persistenceAdapter.productNamePredicate(for: name, in: markets)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Product.name, ascending: true)]
        return try persistenceController.container.viewContext.fetch(fetchRequest)
    }

    private func getMarkets() throws -> [Market] {
        let fetchRequest = Market.fetchRequest()
        let markets = try persistenceController.container.viewContext.fetch(fetchRequest)
        return markets.filter { !$0.isExcluded }
    }

    func addProduct(name: String, quantity: Int16 = 1) throws -> ChosenProduct? {
        // get product by name
        let fetchRequest = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1
        do {
            let products = try persistenceController.container.viewContext.fetch(fetchRequest)
            let product = products.first!

            // get best offer
            if let offer = product.sorteredOffers?.first {
                // add chosen product and save
                let chosenProduct = persistenceAdapter.newChosenProduct(offer: offer, quantity: quantity)
                // add chosen product to the current list
                try persistenceAdapter.addProductToCurrentList(chosenProduct)

                return chosenProduct
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }

}
