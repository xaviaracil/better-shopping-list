//
//  AddProductHandler.swift
//  SiriIntents
//
//  Created by Xavi Aracil on 30/4/22.
//

import Foundation
import CoreData
import Intents

class AddProductHandler: AddProductBaseHandler, AddProductIntentHandling {
    func handle(intent: AddProductIntent) async -> AddProductIntentResponse {
        var quantity: Int16 = 1
        if let intentQuantity = intent.quantity {
            quantity = Int16(truncating: intentQuantity)
        }

        if let name = intent.name {
            let product = try? addProduct(name: name, quantity: quantity)
            return .init(code: product != nil ? .success : .failure, userActivity: nil)
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
                    return .success(with: products.first!.wrappedName)
                }

                return .disambiguation(with: products.map { $0.wrappedName })
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
}
