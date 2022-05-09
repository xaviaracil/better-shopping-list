//
//  LoadingViewModel.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 9/5/22.
//

import Foundation
import OrderedCollections
import SwiftUI

class LoadingViewModel: ObservableObject {
    var files: OrderedDictionary<URL, URL>

    @Published
    var progress: Progress = Progress()

    var observation: NSKeyValueObservation?

    @Published
    var loaded = false

    @Published
    var modelProvider: ModelProvider

    @Published
    var index = 0

    @Published
    var count = 0

    let testMode: Bool

    init(test: Bool, modelProvider: ModelProvider) {
        self.testMode = test
        self.files = [:]
        self.loaded = test
        self.modelProvider = modelProvider
        if !test {
            for ext in ["sqlite", "sqlite-shm", "sqlite-wal"] {
                // swiftlint:disable line_length
                let destination = URL.fileURL(for: PersistenceController.appGroup, name: PersistenceController.publicName, extension: ext)
                let isReachable = try? destination.checkResourceIsReachable()
                if !(isReachable ?? false) {
                    let url = URL(string: "https://better-shopping-list-assets.s3.eu-west-1.amazonaws.com/seed/\(PersistenceController.publicName).\(ext)")!
                    files[url] = destination
                }
            }
            self.count = files.count
            self.loaded = files.isEmpty
        }
        if self.loaded {
            modelProvider.initModel(testMode: test)
        }
    }

    func load() {
        if index < files.count {
            let (source, destination) = files.elements[index]
            let task = URLSession.shared.downloadTask(with: source) { location, _, error in
                guard let location = location else {
                    print("Couldn't retrieve \(source): \(String(describing: error))")
                    return
                }
                // move file to new location
                do {
                    try FileManager.default.copyItem(at: location, to: destination)
                } catch {
                    print("Couldn't copy \(location) to \(destination): \(error)")
                }
                DispatchQueue.main.async {
                    self.index += 1
                    self.load() // load net file
                }
            }
            self.observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                DispatchQueue.main.async {
                    self.progress = progress
                }
            }
            task.resume()
        } else {
            modelProvider.initModel(testMode: testMode)
            self.loaded = true
        }
    }

}
