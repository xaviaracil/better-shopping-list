//
//  AddProductStandardHandler.swift
//  SiriIntents
//
//  Created by Xavi Aracil on 2/5/22.
//

import Foundation
import Intents

class AddProductStandardHandler: AddProductBaseHandler, INAddTasksIntentHandling {

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
        let product = try? addProduct(name: name.spokenPhrase)
        return product?.toINTask()
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
                return .success(with: INSpeakableString(spokenPhrase: products.first!.wrappedName))
            }

            print("🖥 more than one product found with name: \(name)")
            return .disambiguation(with: products.map { INSpeakableString(spokenPhrase: $0.wrappedName) })
        } catch {
            return .unsupported()
        }
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
