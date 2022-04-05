import XCTest
import CoreData
@testable import BetterShoppingList

final class CurrentListTests: XCTestCase {

    var context: NSManagedObjectContext!
    var shoppingAssistant: ShoppingAssistant!

    override func setUpWithError() throws {
        context = PersistenceController(inMemory: true).container.viewContext
        try loadFixture(into: context)
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: context)
        shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)

    }

    override func tearDownWithError() throws {
        try destroyFixture(from: context)
    }

    func testEmptyList() throws {
        // given initial state

        // when asking for products of the current list
        let products = try context.fetch(shoppingAssistant.currentProductsFetchRequest)

        // then we get an empty list
        XCTAssertNotNil(products)
        XCTAssertTrue(products.isEmpty)
    }

    func testGivenCurrentListFetchReturnItsProducts() throws {
        // given a current list
        let list = mockList(name: "Current List", current: true, context: context)

        let product = mockChosenProduct(name: "Product 1", price: 1.50, context: context)

        list.addToProducts(product)

        try context.save()

        // when asking for products of the current list
        let products = try context.fetch(shoppingAssistant.currentProductsFetchRequest)

        // then we get a list
        XCTAssertNotNil(products)
        XCTAssertFalse(products.isEmpty)
        XCTAssertEqual(1, products.count)
        XCTAssertEqual(product.price, products.first?.price)
        XCTAssertEqual(product.name, products.first?.name)
        XCTAssertEqual(list.name, products.first?.list?.name)
    }
}
