//
//  ShoppingAssitantTests.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 5/4/22.
//

import XCTest
@testable import BetterShoppingList
import CoreData
import Combine

class ShoppingAssitantTests: XCTestCase {

    var shoppingAsistant: ShoppingAssistant!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        context = PersistenceController(inMemory: true).container.viewContext
        try loadFixture(into: context)
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: context)
        shoppingAsistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)
    }

    override func tearDownWithError() throws {
        try destroyFixture(from: context)
    }

    func test_Given_Initial_Then_ItHasPersistenceAdapter() throws {
        // Given inital

        // When asking for persistence
        let persistenceAdapter = shoppingAsistant.persitenceAdapter

        // Then something is returned
        XCTAssertNotNil(persistenceAdapter)
    }

    func test_Given_Initial_Then_CurrentListIsEmpty() throws {
        // Given inital

        // When asking for currentList
        let currentList = shoppingAsistant.currentList

        // Then an empty list is returned
        XCTAssertNil(currentList)
    }

    func test_Given_Initial_When_ChoosingAProduct_Then_ACurrentListIsCreated() throws {
        // Given some chosenProduct
        let product = mockChosenProduct(name: "Product 1", price: 1.50, context: context)

        // When adding the product to our list
        shoppingAsistant.addProductToCurrentList(product)

        // Then currentList is created
        let currentList = shoppingAsistant.currentList
        XCTAssertNotNil(currentList)

        // And it has only one product
        XCTAssertEqual(1, currentList?.products?.count)

    }

    func test_Given_ACurrentList_When_ChoosingAProduct_Then_ItsAddedToTheCurrentList() throws {
        // Given some chosenProduct and a list
        let product = mockChosenProduct(name: "Product 1", price: 1.50, context: context)
        shoppingAsistant.addProductToCurrentList(product)
        let currentList = shoppingAsistant.currentList

        let product2 = mockChosenProduct(name: "Product 2", price: 2.50, context: context)

        // When adding the product to our list
        shoppingAsistant.addProductToCurrentList(product2)

        // Then currentList is created
        let currentListAfter = shoppingAsistant.currentList
        XCTAssertNotNil(currentListAfter)
        XCTAssertEqual(currentList, currentListAfter)

        // And it has all the products
        XCTAssertEqual(2, currentList?.products?.count)

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
