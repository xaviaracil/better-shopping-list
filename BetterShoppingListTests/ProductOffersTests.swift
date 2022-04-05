//
//  ProductOffersTests.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 5/4/22.
//

import XCTest
import CoreData
@testable import BetterShoppingList
import SwiftUI

class ProductOffersTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        context = PersistenceController(inMemory: true, withTestData: false).container.viewContext
        try loadFixture(into: context)
    }

    override func tearDownWithError() throws {
        try destroyFixture(from: context)
    }

    func testChooseOfferReturnsAChosenProduct() throws {
        // Given some products and offers
        let product1 = mockProduct(name: "Product 1", url: "http://imat.ge", context: context)
        let product2 = mockProduct(name: "Product 2", url: "http://imat.ge", context: context)

        let market1 = mockMarket(name: "Market 1", url: "http://lo.go", context: context)
        let market2 = mockMarket(name: "Market 2", url: "http://lo.go", context: context)

        let offer1 = mockOffer(for: product1, at: market1, with: 1.1, context: context)
        let offer2 = mockOffer(for: product1, at: market2, with: 1.3, context: context)
        let offer3 = mockOffer(for: product2, at: market1, with: 2.0, context: context)
        let offer4 = mockOffer(for: product2, at: market2, with: 1.5, context: context)

        let offers = [offer1, offer2, offer3, offer4]

        // When asking to group together
        let productsOffers = offers.toProductOffers()

        // Then list is well grouped
        XCTAssertEqual(2, productsOffers.count)
        XCTAssertEqual(product1, productsOffers.first?.product)
        XCTAssertEqual(2, productsOffers.first?.offers?.count)
        XCTAssertEqual(offer1, productsOffers.first?.offers?.first)
        XCTAssertEqual(offer2, productsOffers.first?.offers?.last)
        XCTAssertEqual(product2, productsOffers.last?.product)
        XCTAssertEqual(2, productsOffers.last?.offers?.count)
        XCTAssertEqual(offer3, productsOffers.last?.offers?.first)
        XCTAssertEqual(offer4, productsOffers.last?.offers?.last)
    }

}
