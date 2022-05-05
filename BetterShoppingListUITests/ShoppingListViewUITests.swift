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
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.terminate()
    }

    func testDisplayList() throws {
        let sidebarButton = app.buttons["Menu"].firstMatch
        XCTAssertTrue(sidebarButton.exists)
        sidebarButton.tap()

        // tap on first list in order to create a current list
        let list1Button = app.buttons["List 1"].firstMatch
        XCTAssertTrue(list1Button.exists)
        list1Button.forceTap()

        XCTAssertTrue(app.navigationBars["List 1"].exists)
        // at least there should be one market
        let market = app.staticTexts.matching(marketPredicate).firstMatch
        XCTAssertNotNil(market)
    }
}
