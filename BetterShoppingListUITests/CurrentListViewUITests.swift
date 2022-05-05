//
//  CurrentListViewUITests.swift
//  BetterShoppingListUITests
//
//  Created by Xavi Aracil on 7/4/22.
//

import XCTest

class CurrentListViewUITests: XCTestCase {
    var app: XCUIApplication!

    var marketPredicate: NSPredicate {
        NSPredicate(format: "(label = \"Carrefour\") OR (label = \"Sorli\") OR (label =\"BonPreu Esclat\")")
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test.
        app = launchApp()

        let searchField = app.searchFields.element
        searchField.tap()
        searchField.typeText("Cervesa Damm")

        sleep(1)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testChooseProduct() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let market = app.staticTexts.matching(marketPredicate).firstMatch
        XCTAssertNotNil(market)
        let label = market.label

        // When tapping in the add button
        let estrellaDammAddButton = app.buttons["Add to basket"].firstMatch
        estrellaDammAddButton.tap()

        sleep(1)

        // Then the current list is shown

        // And market of the product must be visible
//        let market1 = app.staticTexts["Products in market \(String(describing: market.label))"]
        let marketNumber = app.staticTexts["Number of products in market \(label)"]
//        XCTAssertTrue(market1.waitForExistence(timeout: 5))
        XCTAssertTrue(marketNumber.waitForExistence(timeout: 5))
        XCTAssertEqual("1", marketNumber.value as? String)

    }

    func testDisplayList() throws {
        let market = app.staticTexts.matching(marketPredicate).firstMatch
        XCTAssertNotNil(market)
        let label = market.label

        let estrellaDammAddButton = app.buttons["Add to basket"].firstMatch
        estrellaDammAddButton.tap()

        sleep(1)

        let listButton = app.buttons["Products in market \(label)"].firstMatch
        XCTAssertTrue(listButton.waitForExistence(timeout: 5))
        listButton.tap()

        let marketName = app.staticTexts[label].firstMatch
        XCTAssertTrue(marketName.waitForExistence(timeout: 5))

        let productName = app.staticTexts["Cervesa Estrella Damm"].firstMatch
        XCTAssertTrue(productName.waitForExistence(timeout: 5))

    }

}
