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
        for index in 0..<10 {
            let newList = ShoppingList(context: viewContext)
            newList.timestamp = Date()
            newList.name = "List \(index + 1)"
        }
        var markets: [Market] = []
        for marketIndex in 1...3 {
            let market = Market(context: viewContext)
            market.name = "Market \(marketIndex)"
            // swiftlint:disable line_length
            market.iconUrl = URL(string: "https://pbs.twimg.com/profile_images/1103993935419068416/f8FkyYcp_400x400.png")
            markets.append(market)
        }

        for name in ["Cervesa Estrella Damm", "Cervesa Moritz 33", "Llet ATO 1L"] {
            let product = Product(context: viewContext)
            product.name = name
            // swiftlint:disable line_length
            product.imageUrl = URL(string: "https://static.condisline.com/resize_395x416/images/catalog/large/704005.jpg")

            // load some offers
            for market in markets {
                let offer = Offer(context: viewContext)
                offer.product = product
                offer.market = market
                offer.isSpecialOffer = false
                // prices is based on prices arrays, shifted by market index and product index
                offer.price = Double.random(in: (0.15)...(3.00))
            }
        }
        do {
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
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            description.configuration = "Local"

            // public datababase
            // swiftlint:disable:next line_length
            let publicStoreUrl = description.url!.deletingLastPathComponent().appendingPathComponent("Model-public.sqlite")
            let containerIdentifier = description.cloudKitContainerOptions!.containerIdentifier

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

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the
                *    device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("😱 \(#function): Unresolved error \(error), \(error.userInfo)")
            }

            print("\(storeDescription.debugDescription) loaded")
        })
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
