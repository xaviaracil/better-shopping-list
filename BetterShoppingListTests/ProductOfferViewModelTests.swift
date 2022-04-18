//
//  ProductOfferViewModelTests.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 18/4/22.
//

import XCTest
@testable import BetterShoppingList

class ProductOfferViewModelTests: XCTestCase {

    var productOfferViewModel: ProductOfferViewModel!
    let context = PersistenceController.preview.container.viewContext

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        productOfferViewModel = ProductOfferViewModel()
    }

    func test_Given_Initial_Data_When_Chosing_A_Product_And_An_Offer_Then_A_ChosenProduct_Is_Returned() throws {
        // given a product and an offer
        let product = Product(context: context)
        product.name =  "Some product name"

        let offer = Offer(context: context)
        offer.price = Double.random(in: 0...(300.0))
        offer.isSpecialOffer = Bool.random()
        offer.uuid = UUID()

        let quantity = Int16.random(in: 0..<Int16.max)

        // when chosing them
        let chosenProduct = productOfferViewModel.choseProduct(product: product, offer: offer, quantity: quantity)

        // then a chosen product is returned
        XCTAssertNotNil(chosenProduct)
        // with product data
        XCTAssertEqual(product.name, chosenProduct.name)
        // and offer data
        XCTAssertEqual(offer.price, chosenProduct.price)
        XCTAssertEqual(offer.isSpecialOffer, chosenProduct.isSpecialOffer)
        XCTAssertEqual(offer.uuid, chosenProduct.offerUUID)
    }
}
