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
        let products = shoppingAssistant.currentList?.products

        // then we get an empty list
        XCTAssertNil(products)
    }

    func test_Given_CurrentList_When_Fetched_Then_ItsProductsAreReturned() throws {
        // given a current list with products
        let product = mockChosenProduct(name: "Product 1", price: 1.50, context: context)
        shoppingAssistant.addProductToCurrentList(product)

        try context.save()

        // when asking for products of the current list
        let products = shoppingAssistant.currentList?.products

        // then we get a list
        XCTAssertNotNil(products)
        XCTAssertFalse(products!.count == 0)
        XCTAssertEqual(1, products!.count)
        XCTAssertEqual(product.price, (products!.allObjects.first as? ChosenProduct)?.price)
        XCTAssertEqual(product.name, (products!.allObjects.first as? ChosenProduct)?.name)
        XCTAssertEqual(shoppingAssistant.currentList?.name, (products!.allObjects.first as? ChosenProduct)?.list?.name)
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

    // MARK: - save list
    func test_Given_CurrentList_When_Saving_Then_TheListIsSaved() throws {
        // given a current list with some products
        shoppingAssistant.addProductToCurrentList(mockChosenProduct(name: "Product 1", price: 1.50, context: context))
        shoppingAssistant.addProductToCurrentList(mockChosenProduct(name: "Product 2", price: 2.50, context: context))

        let earned = shoppingAssistant.currentList?.earned
        let productCount = shoppingAssistant.currentList?.products?.count

        // when asking for products of the current list
        let savedLists = try context.fetch(shoppingAssistant.savedListsFetchRequest)

        try context.save()

        // when saved
        let savedList = shoppingAssistant.saveList(name: "saved list")

        let newSavedLists = try context.fetch(shoppingAssistant.savedListsFetchRequest)

        // then the list is no longer the current
        XCTAssertEqual(savedList.name, "saved list")
        XCTAssertNotNil(savedList.timestamp)
        XCTAssertFalse(savedList.isCurrent)

        // and the saved list has the offers of the current list
        XCTAssertEqual(savedList.products?.count, productCount)

        // and the list of shopping list has been increased
        XCTAssertEqual(savedList.earning, earned)
        XCTAssertEqual(savedLists.count + 1, newSavedLists.count)

        // and the current list is now empty
        XCTAssertNil(shoppingAssistant.currentList)
    }

    // MARK: - delete chosen product from list
    func test_Given_CurrentList_When_RemovingOneProduct_Then_TheListIsUpdated() throws {
        // given a current list with some products
        let chosenProduct1 = mockChosenProduct(name: "Product 1", price: 1.50, context: context)
        shoppingAssistant.addProductToCurrentList(chosenProduct1)
        let chosenProduct2 = mockChosenProduct(name: "Product 2", price: 2.50, context: context)
        shoppingAssistant.addProductToCurrentList(chosenProduct2)

        // when asking for removing a product
        shoppingAssistant.removeChosenProduct(chosenProduct1)

        // then the list of products is updated
        XCTAssertEqual(shoppingAssistant.currentList?.products?.count ?? 0, 1)
        XCTAssertEqual(chosenProduct2, shoppingAssistant.currentList?.products?.allObjects.first as? ChosenProduct)

    }

    func test_Given_CurrentList_When_ChosingAnotherOfferForAProduct_Then_TheListIsUpdated() throws {
        // given a current list with some products
        let offers = try context.fetch(Offer.fetchRequest())

        let offerForProduct = offers.first!
        let offerForAnotherProduct = offers.first { offer in
            offer.product != offerForProduct.product
        }!

        let chosenProduct1 = mockChosenProduct(offer: offerForProduct, context: context)
        shoppingAssistant.addProductToCurrentList(chosenProduct1)
        let chosenProduct2 = mockChosenProduct(offer: offerForAnotherProduct, context: context)
        shoppingAssistant.addProductToCurrentList(chosenProduct2)

        // and another offer
        let anotherOfferForProduct = offers.last { offer in
            offer.product == offerForProduct.product
        }!

        // when asking for changing the offer of a product
        let newChosenProduct = shoppingAssistant.changeChosenProduct(chosenProduct1, to: anotherOfferForProduct)

        // then the list of products is updated
        XCTAssertEqual(shoppingAssistant.currentList?.products?.count ?? 0, 2)
        XCTAssertEqual(shoppingAssistant.currentList?.products?.contains(chosenProduct2), true)
        XCTAssertEqual(shoppingAssistant.currentList?.products?.contains(chosenProduct1), false)
        XCTAssertEqual(shoppingAssistant.currentList?.products?.contains(newChosenProduct), true)
    }
}
