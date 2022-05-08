//
//  Model+utils.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 21/4/22.
//

import Foundation
import CoreData

extension NSManagedObjectContext {

    public func deleteAllObjects() throws {
        guard let entitesByName = persistentStoreCoordinator?.managedObjectModel.entitiesByName else { return }

        for (_, entityDescription) in entitesByName {
            try deleteAllObjects(for: entityDescription)
        }
    }

    func deleteAllObjects(for entity: NSEntityDescription) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity

        let fetchResults = try fetch(fetchRequest)

        if let managedObjects = fetchResults as? [NSManagedObject] {
            for object in managedObjects {
                delete(object)
            }
        }
    }
}

public extension URL {

    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        return fileURL(for: appGroup, name: databaseName, extension: "sqlite")
    }

    static func fileURL(for appGroup: String, name: String, extension ext: String) -> URL {
        // swiftlint:disable line_length
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(name).\(ext)")
    }
}
