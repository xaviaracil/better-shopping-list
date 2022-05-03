//
//  Persistence.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 31/3/22.
//

import CoreData
import CloudKit

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        do {

            try viewContext.deleteAllObjects()

            var markets: [Market] = []
            // swiftlint:disable line_length
            for (name, icon) in ["Sorli": "https://www.sorli.com/wp-content/themes/sorli/img/sorli_logo.png",
                         "Carrefour": "https://pbs.twimg.com/profile_images/1501460589612306438/mzRWN7ev_400x400.jpg",
                         "BonPreu Esclat": "https://pbs.twimg.com/profile_images/1103993935419068416/f8FkyYcp_400x400.png"] {
                let market = Market(context: viewContext)
                market.name = name
                market.uuid = UUID()
                market.iconUrl = URL(string: icon)
                markets.append(market)
            }

            // swiftlint:disable line_length
            let products = ["Cervesa Estrella Damm": "https://www.compraonline.bonpreuesclat.cat/images-v3/dcbcfd72-cf23-44a2-8e14-8a38edd645a3/4d4e1ec4-18ec-4982-8267-90b2a6ec90db/300x300.jpg",
                         "Cervesa Moritz 33": "https://www.compraonline.bonpreuesclat.cat/images-v3/dcbcfd72-cf23-44a2-8e14-8a38edd645a3/f39437cc-7536-4355-afd4-4cd266a6ea3e/300x300.jpg",
                         "Llet ATO 1L": "https://static.condisline.com/resize_395x416/images/catalog/large/704005.jpg"]
            var offers: [String: [Offer]] = [:]
            for (name, image) in products {
                let product = Product(context: viewContext)
                product.name = name
                product.imageUrl = URL(string: image)

                var productOffers: [Offer] = []
                // load some offers
                for market in markets {
                    let offer = Offer(context: viewContext)
                    offer.uuid = UUID()
                    offer.product = product
                    offer.market = market
                    offer.isSpecialOffer = false
                    // prices is based on prices arrays, shifted by market index and product index
                    offer.price = Double.random(in: (0.15)...(3.00))
                    productOffers.append(offer)
                    print("🖥 Adding Offer for product \(String(describing: product.name)) in market \(String(describing: market.name)) at price \(String(describing: offer.price))")
                }
                offers[name] = productOffers
            }

            for index in 0..<10 {
                let newList = ShoppingList(context: viewContext)
                newList.isCurrent = false
                newList.timestamp = Date()
                newList.name = "List \(index + 1)"
                newList.isFavorite = Bool.random()
                newList.earning = Double.random(in: 0...(16.0))
                for (name, _) in products {
                    let chosenProduct = ChosenProduct(context: viewContext)
                    let offer = offers[name]?.randomElement()
                    chosenProduct.quantity = Int16.random(in: 1..<10)
                    chosenProduct.name = name
                    chosenProduct.price = offer?.price ?? Double.random(in: 0...(16.0))
                    chosenProduct.isSpecialOffer = offer?.isSpecialOffer ?? false
                    chosenProduct.offerUUID = offer?.uuid
                    chosenProduct.marketUUID = offer?.market?.uuid
                    newList.addToProducts(chosenProduct)
                }

            }

            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Model")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            guard let description = container.persistentStoreDescriptions.first else {
                fatalError("😱 \(#function): Failed to retrieve a persistent store description.")
            }
            description.url = URL.storeURL(for: "group.name.xaviaracil.BetterShoppingList.shared", databaseName: "Model-private")
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            description.configuration = "Local"
            let containerIdentifier = description.cloudKitContainerOptions!.containerIdentifier

            let privateOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
            privateOptions.databaseScope = .private
            description.cloudKitContainerOptions = privateOptions

            // public datababase
            // swiftlint:disable:next line_length
            let publicStoreUrl = URL.storeURL(for: "group.name.xaviaracil.BetterShoppingList.shared", databaseName: "Model-public")

            let publicDescription = NSPersistentStoreDescription(url: publicStoreUrl)
            publicDescription.configuration = "Public"
            publicDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            // swiftlint:disable:next line_length
            publicDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

            let publicOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
            publicOptions.databaseScope = .public

            publicDescription.cloudKitContainerOptions = publicOptions
            container.persistentStoreDescriptions.append(publicDescription)
        }

        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("😱 \(#function): Failed to load persistent stores: \(error)")
        })
        container.viewContext.automaticallyMergesChangesFromParent = true

        // Only initialize the schema when building the app with the
        // Debug build configuration.
        #if DEBUG
        do {
            // Use the container to initialize the development schema.
            try container.initializeCloudKitSchema(options: [])

        } catch {
            // Handle any errors.
            print("Error initializing CloudKit: \(error)")
        }
        #endif
    }
}
