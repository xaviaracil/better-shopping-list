//
//  BetterShoppingListTests.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 31/3/22.
//

import XCTest
@testable import BetterShoppingList
import CoreData

class BetterShoppingListTests: XCTestCase {

    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        context = PersistenceController.preview.container.viewContext
        try loadFixture(into: context)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGivenAProductNameWhenAskingForListThenTheListIsSortedByPrice() throws {
        // given a name
        let name = "9"
        let query = OfferQueries(context: context)

        // when searching
        let offers = try query.query(name: name)

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

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
