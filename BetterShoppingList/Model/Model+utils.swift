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
