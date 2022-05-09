//
//  TestData.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 6/5/22.
//

import Foundation
import CoreData

struct PersistenceTestData {
    static let markets = ["Sorli": "https://www.sorli.com/wp-content/themes/sorli/img/sorli_logo.png",
                   "Carrefour": "https://pbs.twimg.com/profile_images/1501460589612306438/mzRWN7ev_400x400.jpg",
                   "BonPreu Esclat": "https://pbs.twimg.com/profile_images/1103993935419068416/f8FkyYcp_400x400.png"]
    // swiftlint:disable line_length
    static let products = ["Cervesa Estrella Damm": "https://www.compraonline.bonpreuesclat.cat/images-v3/dcbcfd72-cf23-44a2-8e14-8a38edd645a3/4d4e1ec4-18ec-4982-8267-90b2a6ec90db/300x300.jpg",
                           "Cervesa Moritz 33": "https://www.compraonline.bonpreuesclat.cat/images-v3/dcbcfd72-cf23-44a2-8e14-8a38edd645a3/f39437cc-7536-4355-afd4-4cd266a6ea3e/300x300.jpg",
                           "Llet ATO 1L": "https://static.condisline.com/resize_395x416/images/catalog/large/704005.jpg",
                           "ASTURIANA Llet semidesnatada en cartró": "https://www.compraonline.bonpreuesclat.cat/images-v3/dcbcfd72-cf23-44a2-8e14-8a38edd645a3/9521b38e-57bc-45e2-8660-fd4674c23ce9/500x500.jpg",
                           "MORITZ Cervesa especial en ampolla": "https://www.compraonline.bonpreuesclat.cat/images-v3/dcbcfd72-cf23-44a2-8e14-8a38edd645a3/b910c8eb-8db0-4c3e-a6bf-9aa881389e6f/500x500.jpg",
                           "SERPIS Olives farcides d'anxova": "https://www.compraonline.bonpreuesclat.cat/images-v3/dcbcfd72-cf23-44a2-8e14-8a38edd645a3/b7db78f6-108c-4d45-8adc-eeaf546f5768/500x500.jpg",
                           "COCA-COLA Refresc de cola Zero en llauna": "https://www.compraonline.bonpreuesclat.cat/images-v3/dcbcfd72-cf23-44a2-8e14-8a38edd645a3/166f117c-016e-40b0-ba6e-8cbb2a7d5d5a/500x500.jpg",
                           "COCA-COLA Refresc de cola zero en ampolla": "https://www.compraonline.bonpreuesclat.cat/images-v3/dcbcfd72-cf23-44a2-8e14-8a38edd645a3/bfab909f-842f-40c3-b74e-c39c0da1f19d/500x500.jpg"
    ]

    // swiftlint:disable function_body_length
    static func load(in viewContext: NSManagedObjectContext) {
        var markets: [Market] = []
        for (name, icon) in PersistenceTestData.markets {
            let market = Market(context: viewContext)
            market.name = name
            market.uuid = UUID()
            market.iconUrl = URL(string: icon)
            markets.append(market)
        }

        var offers: [String: [Offer]] = [:]
        for (name, image) in PersistenceTestData.products {
            let product = Product(context: viewContext)
            product.name = name
            product.brand = "Brand"
            product.tokenizedName = "\(product.brand ?? "") \(name)"
            product.imageUrl = URL(string: image)

            var productOffers: [Offer] = []
            // load some offers
            for market in markets {
                let offer = Offer(context: viewContext)
                offer.uuid = UUID()
                offer.product = product
                offer.market = market
                offer.isSpecialOffer = false
                // prices is based on prices arrays, shifted by market index and product index
                offer.price = Double.random(in: (0.15)...(3.00))
                productOffers.append(offer)
                print("""
                      🖥 Adding Offer for product \(String(describing: product.name))
                      in market \(String(describing: market.name))
                      at price \(String(describing: offer.price))
                """)
            }
            offers[name] = productOffers
        }

        for index in 0..<10 {
            let newList = ShoppingList(context: viewContext)
            newList.isCurrent = false
            newList.timestamp = Date()
            newList.name = "List \(index + 1)"
            newList.isFavorite = Bool.random()
            newList.earning = Double.random(in: 0...(16.0))
            for (name, _) in PersistenceTestData.products {
                let chosenProduct = ChosenProduct(context: viewContext)
                let offer = offers[name]?.randomElement()
                chosenProduct.quantity = Int16.random(in: 1..<10)
                chosenProduct.name = name
                chosenProduct.price = offer?.price ?? Double.random(in: 0...(16.0))
                chosenProduct.isSpecialOffer = offer?.isSpecialOffer ?? false
                chosenProduct.offerUUID = offer?.uuid
                chosenProduct.marketUUID = offer?.market?.uuid
                newList.addToProducts(chosenProduct)
            }
        }
    }
}
