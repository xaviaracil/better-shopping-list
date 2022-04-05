//
//  ShoppingAssitantTests.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 5/4/22.
//

import XCTest
@testable import BetterShoppingList
import CoreData

class ShoppingAssitantTests: XCTestCase {

    var shoppingAsistant: ShoppingAssitant!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        context = PersistenceController.preview.container.viewContext
        try loadFixture(into: context)
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: context)
        shoppingAsistant = ShoppingAssitant(persistenceAdapter: persistenceAdapter)
    }

    func testItHasPersistenceAdapter() throws {
        // Given inital

        // When asking for persistence
        let persistenceAdapter = shoppingAsistant.persitenceAdapter

        // Then something is returned
        XCTAssertNotNil(persistenceAdapter)
    }

    func testInitiallyCurrentListIsEmpty() throws {
        // Given inital

        // When asking for currentList
        let currentList = shoppingAsistant.currentList

        // Then nothing is returned
        XCTAssertNil(currentList)
    }

    func testChoosingAProductProducesACurrentList() throws {
        // Given some chosenProduct
        let product = mockChosenProduct(name: "Product 1", price: 1.50, context: context)

        // When adding the product to our list
        shoppingAsistant.addProductToCurrentList(product)

        // Then currentList is created
        let currentList = shoppingAsistant.currentList

        // Then nothing is returned
        XCTAssertNotNil(currentList)
        XCTAssertEqual(1, currentList?.products?.count)

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
