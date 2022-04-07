//
//  CurrentListViewUITests.swift
//  BetterShoppingListUITests
//
//  Created by Xavi Aracil on 7/4/22.
//

import XCTest

class CurrentListViewUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test.
        app = XCUIApplication()
        app.launch()

        // wait for the splash screen
        sleep(4)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let searchField = app.searchFields.element
        searchField.tap()
        searchField.typeText("Cervesa")

        sleep(1)

        // When tapping in the add button
        let estrellaDammAddButton = app.buttons["Add to basket"].firstMatch
        estrellaDammAddButton.tap()

        sleep(1)

        // Then the current list is shown

        // And market of the product must be visible
        let market1 = app.staticTexts["Products in market Market 1"]
        let market1Number = app.staticTexts["Number of products in market Market 1"]
        XCTAssertTrue(market1.waitForExistence(timeout: 5))
        XCTAssertTrue(market1Number.waitForExistence(timeout: 5))
        XCTAssertEqual(1, market1Number.value as? Int)

    }

}
