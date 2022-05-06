//
//  PersistenceAdapterTests.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 6/5/22.
//

import XCTest
import CoreData
@testable import BetterShoppingList

class PersistenceAdapterTests: XCTestCase {
    var persistenceAdapter: PersistenceAdapter!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        context = PersistenceController(inMemory: true).container.viewContext
        try loadFixture(into: context)
        persistenceAdapter = CoreDataPersistenceAdapter(viewContext: context)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGiven_A_Name_When_Searched_It_Returns_the_Product() throws {
        // given a name
        let name = "2"

        // when searched
        let fetchRequest = Product.fetchRequest()
        fetchRequest.predicate = persistenceAdapter.productNamePredicate(for: name, in: [])

        let products = try context.fetch(fetchRequest)

        XCTAssertEqual(products.count, 1)
        XCTAssertEqual(products.first?.name ?? "", "Product 2")
    }

    func testGiven_A_Common_Name_When_Searched_It_Returns_the_Products_Containing_That_Name() throws {
        // given a name
        let name = "Product"

        // when searched
        let fetchRequest = Product.fetchRequest()
        fetchRequest.predicate = persistenceAdapter.productNamePredicate(for: name, in: [])

        let products = try context.fetch(fetchRequest)

        XCTAssertEqual(products.count, 10)
        for product in products {
            XCTAssertTrue(product.name?.contains(name) ?? false)
        }
    }

    func testGiven_A_Brand_Name_When_Searched_It_Returns_the_Products_Of_That_Brand() throws {
        // given a brand name
        let name = "COMPANY"

        // when searched
        let fetchRequest = Product.fetchRequest()
        fetchRequest.predicate = persistenceAdapter.productNamePredicate(for: name, in: [])

        let products = try context.fetch(fetchRequest)

        XCTAssertEqual(products.count, 5)
        for product in products {
            XCTAssertTrue(product.brand?.contains(name) ?? false)
        }
    }

    //swiftlint:disable line_length
    func testGiven_A_Brand_Name_And_A_Name_When_Searched_It_Returns_the_Products_Of_That_Company_And_That_Name() throws {
        // given a brand name
        let name = "ANOTHER 3"

        // when searched
        let fetchRequest = Product.fetchRequest()
        fetchRequest.predicate = persistenceAdapter.productNamePredicate(for: name, in: [])

        let products = try context.fetch(fetchRequest)

        XCTAssertEqual(products.count, 1)
        for product in products {
            XCTAssertEqual("ANOTHER", product.brand)
            XCTAssertEqual("Product 3", product.name)
        }
    }
}
