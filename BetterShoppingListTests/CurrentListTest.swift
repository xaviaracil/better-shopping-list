import XCTest
import CoreData
@testable import BetterShoppingList

final class CurrentListTest: XCTestCase {

    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        continueAfterFailure = false
        context = PersistenceController.preview.container.viewContext
        try loadFixture(into: context)
    }

    override func tearDownWithError() throws {
        try destroyFixture(from: context)
    }

    func testEmptyList() throws {
        // given initial state

        // when asking for products of the current list
        let products = try context.fetch(CurrentListQueries.productsFetchRequest)

        // then wh get an empty list
        XCTAssertNotNil(products)
        XCTAssertTrue(products.isEmpty)
    }
}
