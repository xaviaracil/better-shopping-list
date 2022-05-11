//
//  PersistenceLock.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 9/5/22.
//

import Foundation

/// Lock structure for persistence. Allows synchornization of PersistenceStore
/// over all extensions of the application
struct PersistenceLock {
    var exists = false
    var testMode = false

    var lockUrl: URL {
        URL.fileURL(for: PersistenceController.appGroup, name: PersistenceController.publicName, extension: "lock")
    }

    init() {
        exists = false
        if let isReachable = try? lockUrl.checkResourceIsReachable() {
            exists = isReachable
            if exists {
                let mode = try? String(contentsOf: lockUrl, encoding: .utf8)
                testMode = "Test" == mode
            }
        }
    }

    mutating func save(testMode: Bool) {
        // save existance of lock file
        do {
            let data = (testMode ? "Test" : "Shared").data(using: .utf8)
            try data!.write(to: lockUrl)
            exists = true
        } catch {
            let message = "Could not write lock data"
            print("###\(#function): \(message): \(error)")
        }
    }
}
