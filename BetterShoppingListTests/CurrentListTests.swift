import XCTest
import CoreData
@testable import BetterShoppingList

final class CurrentListTests: XCTestCase {

    var context: NSManagedObjectContext!
    var shoppingAssistant: ShoppingAssistant!

    override func setUpWithError() throws {
        let container = PersistenceController(inMemory: true, withTestData: false).container
        context = container.viewContext
        try loadFixture(into: context)
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: context,
                                                            coordinator: container.persistentStoreCoordinator)
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

    func test_Given_CurrentList_When_Fetched_Then_ItsProductsAreReturned() throws {
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

    // MARK: Earned test

    func test_Given_EmptyList_When_AskedForEarned_Then_NothingHasBeenEarnedYet() throws {
        // given a empty list
        let list = mockList(name: "Current List", current: true, context: context)

        // when asking for how many have we earned
        let earned = list.earned

        // then we get 0
        XCTAssertEqual(0, earned)

    }

    func test_Given_CurrentListWithOneProduct_When_AskedForEarned_Then_ReturnsTheMaximumDifference() throws {
        // given a list with one product
        let list = mockList(name: "Current List", current: true, context: context)

        let offers = try context.fetch(Offer.fetchRequest())

        let chosenOffer = offers.first!
        let product = mockChosenProduct(offer: chosenOffer, context: context)

        list.addToProducts(product)

        // when asking for how many have we earned
        let earned = list.earned

        // then we get the maximum difference
        let productOffers = offers.filter { offer in
            offer.product == chosenOffer.product
        }

        let maxPrice: Double? = productOffers.map { $0.price }.sorted().last
        XCTAssertNotNil(maxPrice)
        XCTAssertEqual(maxPrice! - chosenOffer.price, earned)
    }

    // swiftlint:disable line_length
    func test_Given_CurrentListWithTwoProductsOfDifferentMarkets_WhenAskedForEarned_Then_ReturnsTheDifferenceBetweenTwoMarkets() throws {
        // given a list with one product
        let list = mockList(name: "Current List", current: true, context: context)

        let offers = try context.fetch(Offer.fetchRequest())

        let chosenOffer = offers.first!
        let anotherOffer = offers.filter { offer in
            offer.product != chosenOffer.product && offer.market != chosenOffer.market
        }.first!

        let product = mockChosenProduct(offer: chosenOffer, context: context)
        let anotherProduct = mockChosenProduct(offer: anotherOffer, context: context)

        list.addToProducts(product)
        list.addToProducts(anotherProduct)

        // when asking for how many have we earned
        let earned = list.earned

        // then we get the difference between the two markets
        let markets = [chosenOffer.market, anotherOffer.market]
        let products = [chosenOffer.product, anotherOffer.product]
        let productOffers = offers.filter { offer in
            markets.contains(offer.market) && products.contains(offer.product)
        }

        let productAnotherOffer = productOffers.first(where: {$0.product == chosenOffer.product && $0 != chosenOffer })!
        let anoherProductAnotherOffer = productOffers.first(where: {$0.product == anotherOffer.product && $0 != anotherOffer })!

        let earnedProduct = productAnotherOffer.price - chosenOffer.price
        let earnedAnotherProduct = anoherProductAnotherOffer.price - anotherOffer.price
        XCTAssertEqual(earnedProduct + earnedAnotherProduct, earned)
    }

    // swiftlint:disable line_length
    func test_Given_CurrentListWithTwoProductsAndDifferentQuantityOfDifferentMarkets_WhenAskedForEarned_Then_ReturnsTheDifferenceBetweenTwoMarkets() throws {
        // given a list with one product
        let list = mockList(name: "Current List", current: true, context: context)

        let offers = try context.fetch(Offer.fetchRequest())

        let chosenOffer = offers.first!
        let anotherOffer = offers.filter { offer in
            offer.product != chosenOffer.product && offer.market != chosenOffer.market
        }.first!

        let product = mockChosenProduct(offer: chosenOffer, quantity: 3, context: context)
        let anotherProduct = mockChosenProduct(offer: anotherOffer, quantity: 10, context: context)

        list.addToProducts(product)
        list.addToProducts(anotherProduct)

        // when asking for how many have we earned
        let earned = list.earned

        // then we get the difference between the two markets
        let markets = [chosenOffer.market, anotherOffer.market]
        let products = [chosenOffer.product, anotherOffer.product]
        let productOffers = offers.filter { offer in
            markets.contains(offer.market) && products.contains(offer.product)
        }

        let productAnotherOffer = productOffers.first(where: {$0.product == chosenOffer.product && $0 != chosenOffer })!
        let anoherProductAnotherOffer = productOffers.first(where: {$0.product == anotherOffer.product && $0 != anotherOffer })!

        let earnedProduct = (productAnotherOffer.price - chosenOffer.price) * Double(product.quantity)
        let earnedAnotherProduct = (anoherProductAnotherOffer.price - anotherOffer.price) * Double(anotherProduct.quantity)
        XCTAssertEqual(earnedProduct + earnedAnotherProduct, earned)
    }
}
