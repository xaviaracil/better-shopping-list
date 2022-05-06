//
//  ChonseProductViewModelTests.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 18/4/22.
//

import XCTest
@testable import BetterShoppingList

class ChosenProductViewModelTests: XCTestCase {
    var shoppingAssistant: ShoppingAssistant!

    override func setUpWithError() throws {
        shoppingAssistant = ShoppingAssistant(persistenceAdapter: DummyPersistenceAdapter())
    }

    override func tearDownWithError() throws {
        shoppingAssistant = nil
    }

    func test_Given_A_ChosenProduct_When_ChangingQuantity_Then_The_Product_Is_Updated() throws {
        // Given a product
        let chosenProduct = ChosenProduct(context: PersistenceController.preview.container.viewContext)
        chosenProduct.quantity = Int16.random(in: 0..<Int16.max)
        let chosenProductViewModel = ChosenProductViewModel(shoppingAssistant: shoppingAssistant,
                                                        chosenProduct: chosenProduct)

        // when changing the quantity
        chosenProductViewModel.quantity = 10

        // then the product is updated
        XCTAssertEqual(10, chosenProduct.quantity)
    }
}
