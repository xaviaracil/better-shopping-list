//
//  MarketRowViewModelTest.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 6/5/22.
//

import XCTest
@testable import BetterShoppingList
import CoreData

class MarketRowViewModelTest: XCTestCase {

    var shoppingAssistant: ShoppingAssistant!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        shoppingAssistant = ShoppingAssistant(persistenceAdapter: DummyPersistenceAdapter())
        context = PersistenceController(inMemory: true).container.viewContext
    }

    override func tearDownWithError() throws {
        try destroyFixture(from: context)
        shoppingAssistant = nil
        context = nil
    }

    func testGiven_A_Market_When_Created_The_Favorite_Is_Updated() throws {
        // given a market
        let market = mockMarket(name: "Market 1",
                                url: "http://www.apple.com",
                                context: context)
        // when created
        let marketRowViewModel = MarketRowViewModel(market: market, shoppingAssistant: shoppingAssistant)

        XCTAssertFalse(marketRowViewModel.isFavorite)
    }

    func testGiven_A_Favourite_Market_When_Created_The_Favorite_Is_Updated() throws {
        // given a market
        let market = mockMarket(name: "Market 1",
                                url: "http://www.apple.com",
                                context: context)
        _ = mockUserMarket(market: market, favorite: true, context: context)

        // when created
        let marketRowViewModel = MarketRowViewModel(market: market, shoppingAssistant: shoppingAssistant)

        XCTAssertTrue(marketRowViewModel.isFavorite)
    }

    func testGiven_A_Market_When_Updated_The_Favorite_Is_Updated() throws {
        // given a market
        let market = mockMarket(name: "Market 1",
                                url: "http://www.apple.com",
                                context: context)

        // when updated
        let marketRowViewModel = MarketRowViewModel(market: market, shoppingAssistant: shoppingAssistant)
        marketRowViewModel.isFavorite = true

        XCTAssertNotNil(marketRowViewModel.userMarket)
        XCTAssertTrue(marketRowViewModel.userMarket?.isFavorite ?? false)
    }
}
