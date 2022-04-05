//
//  BetterShoppingListTests.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 31/3/22.
//

import XCTest
import CoreData
@testable import BetterShoppingList

final class BetterShoppingListTests: XCTestCase {

    var context: NSManagedObjectContext!
    var shoppingAssistant: ShoppingAssistant!

    override func setUpWithError() throws {
        context = PersistenceController(inMemory: true, withTestData: false).container.viewContext
        try loadFixture(into: context)
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: context)
        shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)
    }

    override func tearDownWithError() throws {
        try destroyFixture(from: context)
    }

    func testGivenAProductNameWhenAskingForListThenTheListIsSortedByPrice() throws {
        // given a name
        let name = "9"

        // when searching
        let offers = try context.fetch(shoppingAssistant.offersFetchRequest(productName: name))

        // then we got some only one product
        XCTAssertNotNil(offers)
        XCTAssertEqual(10, offers.count)

        // and offers are sorted
        for index in 0..<offers.count - 1 {
            // swiftlint:disable line_length
            XCTAssertTrue(offers[index].price <= offers[index+1].price,
                          "List should be ordered: \(offers[index].price)  is more expensive than \(offers[index+1].price)")
        }
        XCTAssertEqual(offers.map { $0.price }, Constants.prices)
        XCTAssertEqual(offers.map { $0.market?.name }, ["Market 3", "Market 4", "Market 5", "Market 6", "Market 7", "Market 8", "Market 9", "Market 10", "Market 1", "Market 2"])
    }

    func testGivenAProductNameAndMarketListWhenAskingForListThenTheListContainsOnlyMarketOffers() throws {
        // given a name and market list
        let name = "9"
        let markets = ["Market 3", "Market 8"]

        // when searching
        let offers = try context.fetch(shoppingAssistant.offersFetchRequest(productName: name, in: markets))

        // then we got some only one product
        XCTAssertNotNil(offers)
        XCTAssertEqual(markets.count, offers.count)

        // and offers are sorted
        for index in 0..<offers.count - 1 {
            // swiftlint:disable line_length
            XCTAssertTrue(offers[index].price <= offers[index+1].price,
                          "List should be ordered: \(offers[index].price)  is more expensive than \(offers[index+1].price)")
        }
        XCTAssertEqual(offers.map { $0.price }, [1.1, 1.6]) // sorted price of product 9 in markets 3 and 8
        XCTAssertEqual(offers.map { $0.market?.name }, markets)
    }

    func testGivenAMultipleNameWhenAskingForListThenTheListIsSortedByNameAndPrice() throws {
        // given a name
        let name = "Pro 1"

        // when searching
        let offers = try context.fetch(shoppingAssistant.offersFetchRequest(productName: name))

        // then we got some only one product
        XCTAssertNotNil(offers)
        XCTAssertEqual(20, offers.count)

        // and offers are sorted by name
        let productsOffers = offers.toProductOffers()
        for productOffer in productsOffers {
            if let fetchedOffers = productOffer.offers {
                for index in 0..<fetchedOffers.count - 1 {
                    XCTAssertTrue(fetchedOffers[index].price <= fetchedOffers[index+1].price,
                                  """
                                  List should be ordered: \(fetchedOffers[index].price)
                                  is more expensive than \(fetchedOffers[index+1].price)
                                  """)
                }
            }
        }

        XCTAssertEqual(offers.map { $0.price }, Constants.prices + Constants.prices)
        let productNames = Set(offers.map { $0.product?.name})
        XCTAssertEqual(productNames.count, 2)
        XCTAssertTrue(productNames.contains("Product 1"))
        XCTAssertTrue(productNames.contains("Product 10"))
        XCTAssertEqual(offers.map { $0.market?.name }, ["Market 1", "Market 2", "Market 3", "Market 4", "Market 5",
                                                        "Market 6", "Market 7", "Market 8", "Market 9", "Market 10",
                                                        "Market 2", "Market 3", "Market 4", "Market 5", "Market 6",
                                                        "Market 7", "Market 8", "Market 9", "Market 10", "Market 1"]
        )
    }
}
