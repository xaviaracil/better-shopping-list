//
//  CurrentListMarketInMarketViewUITests.swift
//  BetterShoppingListUITests
//
//  Created by Xavi Aracil on 5/5/22.
//

import XCTest

class CurrentListMarketInMarketViewUITests: XCTestCase {

    var app: XCUIApplication!

    // swiftlint:disable line_length
    let marketPredicate = NSPredicate(format: "(identifier = \"Carrefour\") OR (identifier = \"Sorli\") OR (identifier =\"BonPreu Esclat\")")

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

    func testDisplayProducts() throws {
        // tap on first list in order to create a current list
        let list1Button = app.buttons["List 1"].firstMatch
        app.scrollDownToElement(element: list1Button)
        XCTAssertTrue(list1Button.exists)
        list1Button.forceTap()

        // click on first market
        app.scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.tap()
        let textsCount = app.staticTexts.count

        // click on in market view
        app.navigationBars.matching(marketPredicate).buttons["Shop"].tap()
        let marketViewTextCount = app.staticTexts.count
        XCTAssertEqual(textsCount - 1, marketViewTextCount) // textCount has one more due to market label
    }

    func testMarkAsCompleted() throws {
        // tap on first list in order to create a current list
        let list1Button = app.buttons["List 1"].firstMatch
        app.scrollDownToElement(element: list1Button)
        XCTAssertTrue(list1Button.exists)
        list1Button.forceTap()

        // click on first market
        app.scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.tap()

        // click on in market view
        app.navigationBars.matching(marketPredicate).buttons["Shop"].tap()
        let addToCartButton = app.buttons["Add to cart"].firstMatch
        XCTAssert(addToCartButton.waitForExistence(timeout: 5))
        app.scrollDownToElement(element: addToCartButton)
        addToCartButton.forceTap()
        let removeFromCartButton = app.buttons["Remove from cart"]
        XCTAssert(removeFromCartButton.waitForExistence(timeout: 5))
    }

}
