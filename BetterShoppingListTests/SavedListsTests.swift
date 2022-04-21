//
//  SavedListsTest.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 4/4/22.
//

import XCTest
import CoreData
@testable import BetterShoppingList
import SwiftUI

class SavedListsTests: XCTestCase {

    var context: NSManagedObjectContext!
    var shoppingAssistant: ShoppingAssistant!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let container = PersistenceController(inMemory: true, withTestData: false).container
        context = container.viewContext
        try loadFixture(into: context)
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: context,
                                                            coordinator: container.persistentStoreCoordinator)
        shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try destroyFixture(from: context)
    }

    func test_Given_InitialState_When_Fetched_Then_TheCurrentListIsEmpty() throws {
        // given initial state

        // when asking for saved lists
        let lists = try context.fetch(shoppingAssistant.savedListsFetchRequest)

        // then we get an empty list
        XCTAssertNotNil(lists)
        XCTAssertTrue(lists.isEmpty)
    }

    func test_Given_Lists_When_Fetched_Then_OnlyCompletedListsAreReturned() throws {
        // given some lists
        _ = mockList(name: "Current List", current: true, context: context)
        let list2 = mockList(name: "Another List", current: false, context: context)
        try context.save()

        // when asking for saved lists
        let lists = try context.fetch(shoppingAssistant.savedListsFetchRequest)

        // then we get a list
        XCTAssertNotNil(lists)
        // with the completed lists only
        XCTAssertEqual(1, lists.count)
        XCTAssertEqual(list2.name, lists.first?.name)
        XCTAssertEqual(list2.isCurrent, lists.first?.isCurrent)
    }

    func test_Given_List_When_Selected_Then_ANewListIsCreatedWithSameProducts() throws {
        // given a list with some offers
        let list = mockList(name: "Saved List", current: false, context: context)

        let offers = try context.fetch(Offer.fetchRequest())

        let chosenOffer = offers.first!
        let anotherOffer = offers.filter { offer in
            offer.product != chosenOffer.product && offer.market != chosenOffer.market
        }.first!

        let product = mockChosenProduct(offer: chosenOffer, quantity: 3, context: context)
        let anotherProduct = mockChosenProduct(offer: anotherOffer, quantity: 10, context: context)

        list.addToProducts(product)
        list.addToProducts(anotherProduct)

        // and no current list
        XCTAssertNil(shoppingAssistant.currentList)

        // when selected for current list
        shoppingAssistant.newList(from: list)

        // then a new list is created
        XCTAssertNotNil(shoppingAssistant.currentList)

        // with same products
        XCTAssertEqual(shoppingAssistant.currentList?.products?.count, list.products?.count)
        // swiftlint:disable force_cast
        XCTAssertTrue(((shoppingAssistant.currentList?.products?.contains(where: { chosenProduct in
            (chosenProduct as! ChosenProduct).offer?.product == product
        })) != nil))
        // swiftlint:disable force_cast
        XCTAssertTrue(((shoppingAssistant.currentList?.products?.contains(where: { chosenProduct in
            (chosenProduct as! ChosenProduct).offer?.product == anotherProduct
        })) != nil))

    }

    func test_Given_List_When_Selected_Then_ANewListIsCreatedWithBestOffers() throws {
        // given a list with some offers
        let list = mockList(name: "Saved List", current: false, context: context)

        let offers = try context.fetch(Offer.fetchRequest())

        let chosenOffer = offers.first!
        let anotherOffer = offers.filter { offer in
            offer.product != chosenOffer.product
        }.first!

        let product = mockChosenProduct(offer: chosenOffer, quantity: 3, context: context)
        let anotherProduct = mockChosenProduct(offer: anotherOffer, quantity: 10, context: context)

        list.addToProducts(product)
        list.addToProducts(anotherProduct)

         // and new, better offers
        let betterOfferForProduct = bestOffer(for: chosenOffer.product!, in: offers)
        let betterOfferForAnotherProduct = bestOffer(for: anotherOffer.product!, in: offers)

        // and no current list
        XCTAssertNil(shoppingAssistant.currentList)

        // when selected for current list
        shoppingAssistant.newList(from: list)

        // then the list has best offers for the products
        guard let chosenProducts = shoppingAssistant.currentList?.products else {
            XCTFail("Products must not be empty")
            return
        }
        for chosenProduct in chosenProducts {
            guard let chosenProduct = chosenProduct as? ChosenProduct else {
                XCTFail("ChosenProdcut must be of type ChosenProduct")
                return
            }

            if chosenProduct.offer == betterOfferForProduct {
                XCTAssertEqual(betterOfferForProduct, chosenProduct.offer)
                XCTAssertEqual(betterOfferForProduct.market, chosenProduct.market)
                XCTAssertEqual(betterOfferForProduct.price, chosenProduct.price)
                XCTAssertEqual(product.name, chosenProduct.name)
            } else if chosenProduct.offer == betterOfferForAnotherProduct {
                XCTAssertEqual(betterOfferForAnotherProduct, chosenProduct.offer)
                XCTAssertEqual(betterOfferForAnotherProduct.market, chosenProduct.market)
                XCTAssertEqual(betterOfferForAnotherProduct.price, chosenProduct.price)
                XCTAssertEqual(anotherProduct.name, chosenProduct.name)

            } else {
                XCTFail("ChosenProduct \(chosenProduct) has not the best offer")
            }
        }
    }

    func bestOffer(for product: Product, in offers: [Offer]) -> Offer {
        offers.filter { offer in
            offer.product == product
        }.sorted { lhs, rhs in
            lhs.price < rhs.price
        }.first!
    }
}
