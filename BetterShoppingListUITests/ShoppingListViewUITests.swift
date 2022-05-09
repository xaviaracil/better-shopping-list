//
//  ShoppingListViewUITests.swift
//  BetterShoppingListUITests
//
//  Created by Xavi Aracil on 5/5/22.
//

import XCTest

class ShoppingListViewUITests: XCTestCase {
    var app: XCUIApplication!

    // swiftlint:disable line_length
    let marketPredicate = NSPredicate(format: "(label = \"Carrefour\") OR (label = \"Sorli\") OR (label =\"BonPreu Esclat\")")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test.
        app = launchApp()

        sleep(1)
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func testDisplayList() throws {
        let sidebarButton = app.buttons["Menu"].firstMatch
        XCTAssertTrue(sidebarButton.waitForExistence(timeout: 5))
        sidebarButton.tap()

        // tap on first list in order to create a current list
        let listButton = app.buttons.matching(NSPredicate(format: "label BEGINSWITH \"List\"")).firstMatch
        XCTAssertTrue(listButton.waitForExistence(timeout: 5))
        app.scrollDownToElement(element: listButton)
        listButton.forceTap()
        let list = listButton.label

        XCTAssertTrue(app.navigationBars[list].waitForExistence(timeout: 5))
        // at least there should be one market
        let market = app.staticTexts.matching(marketPredicate).firstMatch
        XCTAssertNotNil(market)
    }
}
