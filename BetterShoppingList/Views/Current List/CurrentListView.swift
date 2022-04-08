//
//  CurrentListView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 6/4/22.
//

import SwiftUI

struct CurrentListView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var shoppingAssistant: ShoppingAssistant

    var products: Set<ChosenProduct>? {
        shoppingAssistant.currentList?.products as? Set<ChosenProduct>
    }

    var body: some View {
        VStack {
            if verticalSizeClass == .compact {
                // landscape
                let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows) {
                        CurrentListMarketListView(products: products, markets: shoppingAssistant.markets)
                    }
                }
            } else {
                // portrait
                let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
                ScrollView {
                    LazyVGrid(columns: columns) {
                        CurrentListMarketListView(products: products, markets: shoppingAssistant.markets)
                    }
                }
            }
            Label {
                Text("Earned")
            } icon: {
                Image(systemName: "eurosign.square.fill")
            }
            .labelStyle(EarnedLabelStyle())
            .font(.largeTitle)
            .foregroundColor(.accentColor)
        }
    }
}

struct EarnedLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

struct CurrentListView_Previews: PreviewProvider {
    static var previews: some View {
        let container = PersistenceController.preview.container
        let viewContext = container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext,
                                                            coordinator: container.persistentStoreCoordinator)
        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)

        let market1 = Market(context: viewContext)
        market1.name = "Market 1"
        market1.iconUrl = URL(string: "https://pbs.twimg.com/profile_images/1103993935419068416/f8FkyYcp_400x400.png")
        //        let market2 = Market(context: viewContext)
        //        market2.name = "Market 2"
        //
        let product = Product(context: viewContext)
        product.name = "Producte 1"
        product.imageUrl = URL(string: "https://static.condisline.com/resize_395x416/images/catalog/large/704005.jpg")
        //
        let offer1 = Offer(context: viewContext)
        offer1.price = 1.10
        offer1.market = market1
        offer1.product = product
        //
        //        let offer2 = Offer(context: viewContext)
        //        offer2.price = 1.30
        //        offer2.market = market2
        //        offer2.product = product
        //
        //        let productOffer = ProductOffers(product: product, offers: [offer1, offer2])
        //
        //        shoppingAssistant.addProductToCurrentList(productOffer.chooseOffer(at: 0))
        let chosenProduct = ChosenProduct(context: viewContext)
        chosenProduct.name = "Producte"
        chosenProduct.price = 1.1
        chosenProduct.offerUri = offer1.objectID.uriRepresentation()
        chosenProduct.marketUri = market1.objectID.uriRepresentation()

        shoppingAssistant.addProductToCurrentList(chosenProduct)

        return CurrentListView()
            .environmentObject(shoppingAssistant)
    }
}