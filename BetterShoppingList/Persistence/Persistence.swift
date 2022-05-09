//
//  Persistence.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 31/3/22.
//

import CoreData
import CloudKit
import Combine

class PersistenceController {
    var lastToken: NSPersistentHistoryToken? = nil {
        didSet {
            guard let token = lastToken,
                let data = try? NSKeyedArchiver.archivedData(
                    withRootObject: token,
                    requiringSecureCoding: true
                ) else { return }
            do {
                try data.write(to: tokenFile)
            } catch {
                let message = "Could not write token data"
                print("###\(#function): \(message): \(error)")
            }
        }
    }

    lazy var tokenFile: URL = {
        let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent(
            "BetterShoppingList",
            isDirectory: true
        )
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(
                    at: url,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                let message = "Could not create persistent container URL"
                print("###\(#function): \(message): \(error)")
            }
        }
        return url.appendingPathComponent("token.data", isDirectory: false)
    }()

    private var cancellableSet: Set<AnyCancellable> = []

    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let lock = PersistenceLock()
        if !lock.exists {
            do {
                try viewContext.deleteAllObjects()

                PersistenceTestData.load(in: viewContext)

                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    static let appGroup = "group.name.xaviaracil.BetterShoppingList.shared"
    static let publicName = "Model-public"

    // swiftlint:disable function_body_length
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Model")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {

            guard let description = container.persistentStoreDescriptions.first else {
                fatalError("😱 \(#function): Failed to retrieve a persistent store description.")
            }

            description.url = URL.storeURL(for: PersistenceController.appGroup, databaseName: "Model-private")
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            description.configuration = "Local"
            let containerIdentifier = description.cloudKitContainerOptions!.containerIdentifier

            let privateOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
            privateOptions.databaseScope = .private
            description.cloudKitContainerOptions = privateOptions

            // public datababase
            // swiftlint:disable:next line_length
            let publicStoreUrl = URL.storeURL(for: PersistenceController.appGroup, databaseName: PersistenceController.publicName)
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

        if !inMemory {
          do {
              try container.viewContext.setQueryGenerationFrom(.current)
          } catch {
              print("Error in setQueryGenerationFrom: \(error)")
          }
        }

        // Only initialize the schema when building the app with the
        // Debug build configuration.
        #if DEBUG
        if !inMemory {
            do {
                // Use the container to initialize the development schema.
                try container.initializeCloudKitSchema(options: [.dryRun])

            } catch {
                // Handle any errors.
                print("Error initializing CloudKit: \(error)")
            }
        }
        #endif

        loadHistoryToken()
        initNotifications(inMemory: inMemory)
    }

    func initNotifications(inMemory: Bool) {
        if !inMemory {
            NotificationCenter.default
              .publisher(for: .NSPersistentStoreRemoteChange)
              .sink {
                  self.processRemoteStoreChange($0)
              }
              .store(in: &cancellableSet)
        } else {
            NotificationCenter.default
                .publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
                .receive(on: RunLoop.main)
                .sink {
                    self.processContainerChanged($0)
                }
                .store(in: &cancellableSet)
        }
    }

    private var historyRequestQueue = DispatchQueue(label: "history")

    private func loadHistoryToken() {
      do {
        let tokenData = try Data(contentsOf: tokenFile)
          lastToken = try NSKeyedUnarchiver
          .unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: tokenData)
      } catch {
        // log any errors
      }
    }

    func processRemoteStoreChange(_ notification: Notification) {
        historyRequestQueue.async {
            let backgroundContext = self.container.newBackgroundContext()
            backgroundContext.performAndWait {
                let request = NSPersistentHistoryChangeRequest
                  .fetchHistory(after: self.lastToken)

            do {
              let result = try backgroundContext.execute(request) as?
                NSPersistentHistoryResult
              guard
                let transactions = result?.result as? [NSPersistentHistoryTransaction],
                !transactions.isEmpty
              else {
                return
              }
                if let newToken = transactions.last?.token {
                    self.lastToken = newToken
                }

                self.mergeChanges(from: transactions)

            } catch {
              // log any errors
            }
          }
        }
    }

    private func mergeChanges(from transactions: [NSPersistentHistoryTransaction]) {
        let context = container.viewContext
        context.perform {
            transactions.forEach { transaction in
                guard let userInfo = transaction.objectIDNotification().userInfo else {
                    return
                }

                NSManagedObjectContext
                    .mergeChanges(fromRemoteContextSave: userInfo, into: [context])

            }
        }
    }

    private func processContainerChanged(_ notification: Notification) {
        // swiftlint:disable line_length
        guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event,
              event.type == .setup else {
            print("wrong type of notification")
                  return
        }

        if !event.succeeded,
           let error = event.error {
            let nsError = error as NSError
            if nsError.code == 134400 {
              // error initializing database: Unable to initialize without an iCloud account (CKAccountStatusNoAccount)
                // since we are here only in inMemory initializations, load test data
                PersistenceTestData.load(in: container.viewContext)
            }
        }
    }
}
