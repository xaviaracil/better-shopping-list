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
    let marketPredicate = NSPredicate(format: "(identifier = \"Carrefour\") OR (identifier = \"Sorli\") OR (identifier = \"BonPreu Esclat\")")
    let marketLabelPredicate = NSPredicate(format: "(label = \"Carrefour\") OR (label = \"Sorli\") OR (label = \"BonPreu Esclat\")")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test.
        app = launchApp()

        // tap on first list in order to create a current list
        let listButton = app.buttons.matching(NSPredicate(format: "label BEGINSWITH \"List\"")).firstMatch
        app.scrollDownToElement(element: listButton)
        XCTAssertTrue(listButton.exists)
        listButton.forceTap()

        // click on first market
        app.scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.tap()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func testDisplayProducts() throws {
        let marketLabel = app.staticTexts.matching(marketLabelPredicate).firstMatch
        XCTAssertTrue(marketLabel.waitForExistence(timeout: 5))
        let labels = app.staticTexts.allElementsBoundByIndex.map { $0.label }

        // click on in market view
        app.navigationBars[marketLabel.label].buttons["Shop"].tap()

        // market label should not be there
        let marketNewLabel = app.staticTexts.matching(marketLabelPredicate).firstMatch
        XCTAssertFalse(marketNewLabel.waitForExistence(timeout: 5))
        let cells = app.cells.allElementsBoundByIndex
        XCTAssertTrue(cells.allSatisfy { cell in
            !labels.filter { cell.label.contains($0) }.isEmpty
        })
    }

    func testMarkAsCompleted() throws {
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
