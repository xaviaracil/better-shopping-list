//
//  ShoppingListView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 28/4/22.
//

import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject var shoppingAssistant: ShoppingAssistant

    @ObservedObject
    var viewModel: CurrentShoppingListViewModel

    init(shoppingList: ShoppingList) {
        _viewModel = .init(wrappedValue: CurrentShoppingListViewModel(shoppingList: shoppingList))
    }

    var body: some View {
        VStack {
            ForEach(viewModel.shoppingList?.markets ?? [], id: \.self) { market in
                VStack(alignment: .leading) {
                    MarketLabelView(market: market)
                    ScrollView(.horizontal) {
                        let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
                        LazyHGrid(rows: rows) {
                            ForEach(viewModel.products?.ofMarket(market: market) ?? [], id: \.self) { chosenProduct in

                                HStack {
                                    ProductImageView(product: chosenProduct.offer?.product,
                                                     isSpecialOffer: chosenProduct.isSpecialOffer)
                                        .frame(width: 90, height: 90)

                                    VStack(alignment: .leading) {
                                        Text(chosenProduct.offer?.product?.name ?? "No Name")
                                            .productTitle()
                                        Text(chosenProduct.price.euros)
                                            .bestPrice()
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }.padding()
            }
            Spacer()
            EarnedView(value: viewModel.shoppingList?.earning)
        }
        .navigationTitle(viewModel.shoppingList?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .primaryAction) {
                FavoriteButton(isOn: $viewModel.isFavorite)
            }
        })
    }

    func deleteChosenProducts(products: [ChosenProduct]) {
        withAnimation {
            products.forEach {
                viewModel.removeProduct($0)
                shoppingAssistant.removeChosenProduct($0)
            }

        }
    }

}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        let container = PersistenceController.preview.container
        let viewContext = container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext,
                                                            coordinator: container.persistentStoreCoordinator)
        let shoppingAssistant = ShoppingAssistant(persistenceAdapter: persistenceAdapter)

        let market1 = Market(context: viewContext)
        market1.name = "Market 1"
        market1.uuid = UUID()
        market1.iconUrl = URL(string: "https://pbs.twimg.com/profile_images/1103993935419068416/f8FkyYcp_400x400.png")

        let product = Product(context: viewContext)
        product.name = "Producte 1"
        product.imageUrl = URL(string: "https://static.condisline.com/resize_395x416/images/catalog/large/704005.jpg")
        let offer1 = Offer(context: viewContext)
        offer1.price = 1.10
        offer1.uuid = UUID()
        offer1.market = market1
        offer1.product = product

        let chosenProduct = ChosenProduct(context: viewContext)
        chosenProduct.name = "Producte"
        chosenProduct.price = 1.1
        chosenProduct.offerUUID = offer1.uuid
        chosenProduct.marketUUID = market1.uuid

        shoppingAssistant.addProductToCurrentList(chosenProduct)

        return Group {
            ShoppingListView(shoppingList: shoppingAssistant.currentList!)
            ShoppingListView(shoppingList: shoppingAssistant.currentList!)
                .previewInterfaceOrientation(.landscapeRight)
        }.environmentObject(shoppingAssistant)
    }
}
