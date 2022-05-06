//
//  CurrentListMarketInMarketViewModelTests.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 6/5/22.
//

import XCTest
@testable import BetterShoppingList
import CoreData

class CurrentListMarketInMarketViewModelTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        context = PersistenceController.preview.container.viewContext
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try destroyFixture(from: context)
        context = nil
    }

    func testGiven_Some_Products_When_Toggle_An_Unexisting_Product_Then_Nothing_Happens() throws {
        // given some products
        let product1 = mockChosenProduct(name: "Product 1", price: 1.0, context: context)
        let product2 = mockChosenProduct(name: "Product 2", price: 1.0, context: context)
        let product3 = mockChosenProduct(name: "Product 3", price: 1.0, context: context)

        let viewModel = CurrentListMarketInMarketViewModel(products: [product1, product2])

        // when toggle
        viewModel.toggleInBasket(product3)

        // then nothing happend
        XCTAssertFalse(product1.inBasket)
        XCTAssertFalse(product2.inBasket)
    }

    func testGiven_Some_Products_When_Toggle_An_Existing_Product_Then_It_Updates() throws {
        // given some products
        let product1 = mockChosenProduct(name: "Product 1", price: 1.0, context: context)
        let product2 = mockChosenProduct(name: "Product 2", price: 1.0, context: context)
        let product3 = mockChosenProduct(name: "Product 3", price: 1.0, context: context)

        let viewModel = CurrentListMarketInMarketViewModel(products: [product1, product2, product3])

        // when toggle
        viewModel.toggleInBasket(product3)

        // then nothing happend
        XCTAssertFalse(product1.inBasket)
        XCTAssertFalse(product2.inBasket)
        XCTAssertTrue(product3.inBasket)
    }}
