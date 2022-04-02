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

        // then we get an empty list
        XCTAssertNotNil(products)
        XCTAssertTrue(products.isEmpty)
    }

    func testGivenCurrentListFetchReturnItsProducts() throws {
        // given a current list
        let list = ShoppingList(context: context)
        list.timestamp = Date()
        list.name = "Current List"
        list.isCurrent = true

        let product = ChosenProduct(context: context)
        product.name = "Product 1"
        product.price = 1.50

        list.addToProducts(product)

        try context.save()

        // when asking for products of the current list
        let products = try context.fetch(CurrentListQueries.productsFetchRequest)

        // then we get a list
        XCTAssertNotNil(products)
        XCTAssertFalse(products.isEmpty)
        XCTAssertEqual(1, products.count)
        XCTAssertEqual(product.price, products.first?.price)
        XCTAssertEqual(product.name, products.first?.name)
        XCTAssertEqual(list.name, products.first?.list?.name)
    }
}
