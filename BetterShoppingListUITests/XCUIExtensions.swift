//
//  XCUIExtensions.swift
//  BetterShoppingListUITests
//
//  Created by Xavi Aracil on 5/5/22.
//
import XCTest

extension XCUIElement {
    func forceTap() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        }
    }

    func scrollToTop() {
         let topCoordinate = XCUIApplication().screenTopCoordinate
         let elementCoordinate = coordinate(withNormalizedOffset: .zero)

         let delta = topCoordinate.screenPoint.x - elementCoordinate.screenPoint.x
         let deltaVector = CGVector(dx: delta, dy: 0.0)

         elementCoordinate.withOffset(deltaVector).press(forDuration: 0.1, thenDragTo: topCoordinate)
     }
}

extension XCUIApplication {
    private struct Constants {
        // Half way accross the screen and 10% from top
        static let topOffset = CGVector(dx: 0.5, dy: 0.1)

        // Half way accross the screen and 90% from top
        static let bottomOffset = CGVector(dx: 0.5, dy: 0.9)
    }

    var screenTopCoordinate: XCUICoordinate {
        return windows.firstMatch.coordinate(withNormalizedOffset: Constants.topOffset)
    }

    var screenBottomCoordinate: XCUICoordinate {
        return windows.firstMatch.coordinate(withNormalizedOffset: Constants.bottomOffset)
    }

    func scrollDownToElement(element: XCUIElement, maxScrolls: Int = 5) {
        for _ in 0..<maxScrolls {
            if element.exists && element.isHittable { element.scrollToTop(); break }
            scrollDown()
        }
    }

    func scrollUpToElement(element: XCUIElement, maxScrolls: Int = 5) {
        for _ in 0..<maxScrolls {
            if element.exists && element.isHittable { element.scrollToTop(); break }
            scrollUp()
        }
    }

    func scrollDown() {
        screenBottomCoordinate.press(forDuration: 0.1, thenDragTo: screenTopCoordinate)
    }

    func scrollUp() {
        screenTopCoordinate.press(forDuration: 0.1, thenDragTo: screenBottomCoordinate)
    }
}
