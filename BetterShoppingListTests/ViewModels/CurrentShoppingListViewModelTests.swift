//
//  CurrentShoppingListViewModelTests.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 6/5/22.
//

import XCTest
@testable import BetterShoppingList
import CoreData

class CurrentShoppingListViewModelTests: XCTestCase {
    var shoppingAssistant: ShoppingAssistant!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        shoppingAssistant = ShoppingAssistant(persistenceAdapter: DummyPersistenceAdapter())
        context = PersistenceController(inMemory: true).container.viewContext
        try loadFixture(into: context)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        shoppingAssistant = nil
        try destroyFixture(from: context)
        context = nil
    }

    func test_When_Empty_List_Then_All_Is_Empty() throws {
        // when empty
        let viewModel = CurrentShoppingListViewModel(shoppingList: nil)

        // then all is empty
        XCTAssertNil(viewModel.shoppingList)
        XCTAssertFalse(viewModel.isFavorite)
        XCTAssertNil(viewModel.products)
    }

    func test_When_There_Is_A_List_Then_Init_Is_Correct() throws {
        // given a list
        let list = mockList(name: "Current List", current: true, context: context)
        let offers = try context.fetch(Offer.fetchRequest())

        let chosenOffer = offers.first!
        let anotherOffer = offers.filter { offer in
            offer.product != chosenOffer.product && offer.market != chosenOffer.market
        }.first!

        let product = mockChosenProduct(offer: chosenOffer, context: context)
        let anotherProduct = mockChosenProduct(offer: anotherOffer, context: context)

        list.addToProducts(product)
        list.addToProducts(anotherProduct)

        let viewModel = CurrentShoppingListViewModel(shoppingList: list)

        // then all is correct
        XCTAssertNotNil(viewModel.shoppingList)
        XCTAssertEqual(list, viewModel.shoppingList)
        XCTAssertFalse(viewModel.isFavorite)
        XCTAssertNotNil(viewModel.products)
        XCTAssertEqual(2, viewModel.products?.count)
        XCTAssertTrue(viewModel.products?.contains(product) ?? false)
        XCTAssertTrue(viewModel.products?.contains(anotherProduct) ?? false)
    }

    func test_When_There_Is_A_List_Then_Favourite_Is_Backed() throws {
        // given a favourite list
        let list = mockList(name: "Current List", current: true, context: context)
        list.isFavorite = true
        let viewModel = CurrentShoppingListViewModel(shoppingList: list)

        // then all is correct
        XCTAssertTrue(viewModel.isFavorite)

        viewModel.isFavorite.toggle()
        XCTAssertFalse(viewModel.isFavorite)
        XCTAssertFalse(list.isFavorite)
    }

    func test_Given_A_List_When_Removing_A_Product_Then_All_Is_Updated() throws {
        let list = mockList(name: "Current List", current: true, context: context)
        let offers = try context.fetch(Offer.fetchRequest())

        let chosenOffer = offers.first!
        let anotherOffer = offers.filter { offer in
            offer.product != chosenOffer.product && offer.market != chosenOffer.market
        }.first!

        let product = mockChosenProduct(offer: chosenOffer, context: context)
        let anotherProduct = mockChosenProduct(offer: anotherOffer, context: context)

        list.addToProducts(product)
        list.addToProducts(anotherProduct)

        let viewModel = CurrentShoppingListViewModel(shoppingList: list)

        viewModel.removeProduct(anotherProduct)

        // then all is correct
        XCTAssertNotNil(viewModel.shoppingList)
        XCTAssertEqual(list, viewModel.shoppingList)
        XCTAssertFalse(viewModel.isFavorite)
        XCTAssertNotNil(viewModel.products)
        XCTAssertEqual(1, viewModel.products?.count)
        XCTAssertTrue(viewModel.products?.contains(product) ?? false)
        XCTAssertFalse(viewModel.products?.contains(anotherProduct) ?? true)
    }

    func test_Given_A_List_When_Replacing_A_Product_Then_All_Is_Updated() throws {
        let list = mockList(name: "Current List", current: true, context: context)
        let offers = try context.fetch(Offer.fetchRequest())

        let chosenOffer = offers.first!
        let anotherOffer = offers.filter { offer in
            offer.product != chosenOffer.product && offer.market != chosenOffer.market
        }.first!

        let product = mockChosenProduct(offer: chosenOffer, context: context)
        let anotherProduct = mockChosenProduct(offer: anotherOffer, context: context)

        list.addToProducts(product)
        list.addToProducts(anotherProduct)
        let evenOtherProduct = mockChosenProduct(name: "name", price: 1.0, context: context)

        let viewModel = CurrentShoppingListViewModel(shoppingList: list)

        viewModel.replaceProduct(product, with: evenOtherProduct)

        // then all is correct
        XCTAssertNotNil(viewModel.shoppingList)
        XCTAssertEqual(list, viewModel.shoppingList)
        XCTAssertFalse(viewModel.isFavorite)
        XCTAssertNotNil(viewModel.products)
        XCTAssertEqual(2, viewModel.products?.count)
        XCTAssertFalse(viewModel.products?.contains(product) ?? true)
        XCTAssertTrue(viewModel.products?.contains(anotherProduct) ?? false)
        XCTAssertTrue(viewModel.products?.contains(evenOtherProduct) ?? false)
    }
}
