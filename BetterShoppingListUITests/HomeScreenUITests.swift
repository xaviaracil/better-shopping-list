//
//  BetterShoppingListUITests.swift
//  BetterShoppingListUITests
//
//  Created by Xavi Aracil on 31/3/22.
//

import XCTest

class HomeScreenUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your
        // tests before they run. The setUp method is a good place to do this.

        // UI tests must launch the application that they test.
        app = launchApp()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.terminate()
        app = nil
    }

    func testDisplaySearchBar() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let searchField = app.searchFields.element
        XCTAssert(searchField.waitForExistence(timeout: 5))
        XCTAssertEqual(searchField.placeholderValue, "Search Products Here")
    }

    func testDisplayInitialText() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let predicate = NSPredicate(format: "label BEGINSWITH[c] %@", "Start searching products")
        XCTAssertTrue(app.staticTexts.containing(predicate).element.waitForExistence(timeout: 5))
        if app.staticTexts["OR"].exists ||
            app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "OR")).element.exists {
            XCTAssertTrue(app.scrollViews["Saved Lists"].exists)
        } else {
            XCTAssertFalse(app.scrollViews["Saved Lists"].exists)
        }
    }

    func testSelectASavedList() throws {
        let listButton = app.buttons["List 1"].firstMatch
        app.scrollDownToElement(element: listButton)
        XCTAssert(listButton.exists)
        listButton.forceTap()

        // at least there must be one market
        let predicate = NSPredicate(format: "label BEGINSWITH \"Number of products in market \"")
        let marketText = app.staticTexts.matching(predicate).firstMatch
        XCTAssertTrue(marketText.waitForExistence(timeout: 5))

    }
}
