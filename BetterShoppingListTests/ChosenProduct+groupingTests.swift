//
//  ChosenProduct+groupingTests.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 6/5/22.
//

import XCTest
import CoreData
@testable import BetterShoppingList

class ChosenProductGroupingTests: XCTestCase {

    var context: NSManagedObjectContext!
    var shoppingAssistant: ShoppingAssistant!

    override func setUpWithError() throws {
        context = PersistenceController(inMemory: true).container.viewContext
        try loadFixture(into: context)
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: context)
        shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)

    }

    override func tearDownWithError() throws {
        try destroyFixture(from: context)
        context = nil
        shoppingAssistant = nil
    }

    func testGiven_An_Array_When_Grouping_Only_One_Market_For_Each_Is_Returned() throws {
        // given some chosen products
        let offers = try context.fetch(Offer.fetchRequest())

        let offer1 = offers.first!
        let offer2 = offers.filter { offer in
            offer.product != offer1.product && offer.market != offer1.market
        }.first!
        let offer3 = offers.filter { offer in
            offer.product != offer1.product && offer.product != offer2.product && offer.market == offer1.market
        }.first!

        let product1 = mockChosenProduct(offer: offer1, context: context)
        let product2 = mockChosenProduct(offer: offer2, context: context)
        let product3 = mockChosenProduct(offer: offer3, context: context)

        // when grouping
        let markets = [product1, product2, product3].groupedByMarket(markets: [])

        // then only one market for each is returned
        XCTAssertEqual(2, markets.count)
        XCTAssertTrue(markets.contains(product1.market!))
        XCTAssertTrue(markets.contains(product2.market!))
        XCTAssertTrue(markets.contains(product3.market!))
    }

    func testGiven_A_Market_When_Asking_For_Products_Only_Products_Of_Market_Is_returned() throws {
        // given some chosen products
        let offers = try context.fetch(Offer.fetchRequest())

        let offer1 = offers.first!
        let offer2 = offers.filter { offer in
            offer.product != offer1.product && offer.market != offer1.market
        }.first!
        let offer3 = offers.filter { offer in
            offer.product != offer1.product && offer.product != offer2.product && offer.market == offer1.market
        }.first!

        let product1 = mockChosenProduct(offer: offer1, context: context)
        let product2 = mockChosenProduct(offer: offer2, context: context)
        let product3 = mockChosenProduct(offer: offer3, context: context)

        let products = [product1, product2, product3]

        // when asking of products of the market
        let market1Products = products.ofMarket(market: offer1.market!)
        XCTAssertNotNil(market1Products)
        XCTAssertEqual(2, market1Products.count)
        XCTAssertTrue(market1Products.contains(product1))
        XCTAssertTrue(market1Products.contains(product3))

        let market2Products = products.ofMarket(market: offer2.market!)
        XCTAssertNotNil(market2Products)
        XCTAssertEqual(1, market2Products.count)
        XCTAssertTrue(market2Products.contains(product2))

    }
}
