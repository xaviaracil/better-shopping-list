//
//  FixtureLoader.swift
//  BetterShoppingListTests
//
//  Created by Xavi Aracil on 1/4/22.
//

import Foundation
import CoreData
import BetterShoppingList

enum Constants {
    static let productNumber = 10
    static let marketNumber = 10
    static let prices = [1.10, 1.20, 1.30, 1.40, 1.50, 1.60, 1.70, 1.80, 1.90, 2.0]
}

func loadFixture(into context: NSManagedObjectContext) throws {
    var markets: [Market] = []

    // load some markets
    for marketIndex in 1...Constants.marketNumber {

        let market = mockMarket(name: "Market \(marketIndex)",
                                url: "http://url.to/market/\(marketIndex)",
                                context: context)
        markets.append(market)
    }

    // load some products and offers
    for productIndex in 1...Constants.productNumber {
        let product = mockProduct(name: "Product \(productIndex)",
                                  url: "http://url.to/product/\(productIndex)",
                                  context: context)

        // load some offers
        for market in markets {
            // prices is based on prices arrays, shifted by market index and product index
            let index = (markets.firstIndex(of: market)! + (productIndex-1)) % Constants.productNumber
            _ = mockOffer(for: product, at: market, with: Constants.prices[index], context: context)
        }
    }

    try context.save()
}

func destroyFixture(from context: NSManagedObjectContext) throws {
    let offerFetchRequest = Offer.fetchRequest()
    offerFetchRequest.includesPropertyValues = false
    let offers = try context.fetch(offerFetchRequest)
    for offer in offers {
        context.delete(offer)
    }

    let productFetchRequest = Product.fetchRequest()
    productFetchRequest.includesPropertyValues = false
    let products = try context.fetch(productFetchRequest)
    for product in products {
        context.delete(product)
    }

    let marketFetchRequest = Market.fetchRequest()
    marketFetchRequest.includesPropertyValues = false
    let markets = try context.fetch(marketFetchRequest)
    for market in markets {
        context.delete(market)
    }

    let listsFetchRequest = ShoppingList.fetchRequest()
    listsFetchRequest.includesPropertyValues = false
    let lists = try context.fetch(marketFetchRequest)
    for list in lists {
        context.delete(list)
    }
    try context.save()
}

func mockList(name: String, current: Bool, context: NSManagedObjectContext) -> ShoppingList {
    let list = ShoppingList(context: context)
    list.timestamp = Date()
    list.name = name
    list.isCurrent = current
    return list
}

func mockMarket(name: String, url: String, context: NSManagedObjectContext) -> Market {
    let market = Market(context: context)
    market.name = name
    market.uuid = UUID()
    market.iconUrl = URL(string: url)
    return market
}

func mockChosenProduct(name: String, price: Double, context: NSManagedObjectContext) -> ChosenProduct {
    let product = ChosenProduct(context: context)
    product.name = name
    product.price = price
    return product
}

func mockChosenProduct(offer: Offer, context: NSManagedObjectContext) -> ChosenProduct {
    let chosenProduct = ChosenProduct(context: context)
    chosenProduct.name = offer.product?.name ?? "N.A."
    chosenProduct.price = offer.price
    chosenProduct.marketUUID = offer.market!.uuid
    chosenProduct.offerUUID = offer.uuid
    return chosenProduct
}

func mockProduct(name: String, url: String, context: NSManagedObjectContext) -> Product {
    let product = Product(context: context)
    product.name = name
    product.imageUrl = URL(string: url)
    return product
}

func mockOffer(for product: Product, at market: Market, with price: Double, context: NSManagedObjectContext) -> Offer {
    let offer = Offer(context: context)
    offer.product = product
    offer.uuid = UUID()
    offer.market = market
    offer.price = price
    return offer
}
