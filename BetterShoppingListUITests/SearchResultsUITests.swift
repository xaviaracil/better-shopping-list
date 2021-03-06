//
//  SearchResultsUITests.swift
//  BetterShoppingListUITests
//
//  Created by Xavi Aracil on 3/4/22.
//

import XCTest

class SearchResultsUITest: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test.
        app = launchApp()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func testDisplayEmptyResults() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let searchField = app.searchFields.element
        searchField.tap()
        searchField.typeText("intentionally_bad_product_name")

        let emptyResultsMessage = app.staticTexts["Can't find any product with this name."]
        XCTAssertTrue(emptyResultsMessage.waitForExistence(timeout: 5))

        XCTAssertEqual(searchField.placeholderValue, "Search Products Here")
    }

    func testDisplayGoodResults() throws {
        let searchField = app.searchFields.element
        searchField.tap()
        searchField.typeText("Cervesa")

        let estrellaDamm = app.staticTexts["Cervesa Estrella Damm"]
        XCTAssertTrue(estrellaDamm.waitForExistence(timeout: 5))
        let moritz = app.staticTexts["Cervesa Moritz 33"]
        XCTAssertTrue(moritz.waitForExistence(timeout: 5))

    }

    func testSelectingAProductMustAddItToTheCurrentList() throws {
        let searchField = app.searchFields.element
        searchField.tap()
        searchField.typeText("Cervesa")

        sleep(1)

        // When tapping in the add button
        let estrellaDammAddButton = app.buttons["Add to basket"].firstMatch
        estrellaDammAddButton.tap()

        sleep(1)

        // Then search field must be visible
        XCTAssertTrue(searchField.exists)
        // And product listing must not exists
        let estrellaDamm = app.staticTexts["Cervesa Estrella Damm"]
        XCTAssertFalse(estrellaDamm.exists)
        let moritz = app.staticTexts["Cervesa Moritz 33"]
        XCTAssertFalse(moritz.exists)

    }
}
