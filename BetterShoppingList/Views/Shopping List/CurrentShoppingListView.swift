//
//  CurrentListView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 6/4/22.
//

import SwiftUI

struct CurrentShoppingListView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var shoppingAssitant: ShoppingAssistant

    @State private var saveListIsPresented = false
    @State private var name = ""

    @ObservedObject
    var viewModel: CurrentShoppingListViewModel

    init(shoppingList: ShoppingList?) {
        _viewModel = .init(wrappedValue: CurrentShoppingListViewModel(shoppingList: shoppingList))
    }

    var body: some View {
        VStack {
            if verticalSizeClass == .compact {
                // landscape
                let rows: [GridItem] = Array(repeating: .init(.flexible(minimum: 200.0, maximum: .infinity)), count: 1)
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows) {
                        ForEach(viewModel.shoppingList?.markets ?? []) { market in
                            CurrentListMarketView(market: market,
                                                  products: viewModel.products?.ofMarket(market: market) ?? [],
                                                  deleteChosenProducts: deleteChosenProducts,
                                                  changeChosenProduct: changeChosenProduct)
                        }
                    }
                    .padding([.top, .bottom])
                }
            } else if horizontalSizeClass == .regular {
                let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.shoppingList?.markets ?? []) { market in
                            CurrentListMarketView(market: market,
                                                  products: viewModel.products?.ofMarket(market: market) ?? [],
                                                  deleteChosenProducts: deleteChosenProducts,
                                                  changeChosenProduct: changeChosenProduct)
                        }
                    }
                }
            } else {
            // portrait
                let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.shoppingList?.markets ?? []) { market in
                            CurrentListMarketView(market: market,
                                                  products: viewModel.products?.ofMarket(market: market) ?? [],
                                                  deleteChosenProducts: deleteChosenProducts,
                                                  changeChosenProduct: changeChosenProduct)
                        }
                    }
                }
            }
            Spacer()
            EarnedView(value: viewModel.shoppingList?.earned)
        }
        .navigationTitle(viewModel.shoppingList?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .primaryAction) {
                if viewModel.shoppingList?.isCurrent ?? false {
                    Button(action: { saveListIsPresented = true }) {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
        })
        .sheet(isPresented: $saveListIsPresented) {
            VStack {
                Text("Save List").font(.largeTitle)
                Spacer()
                TextField(text: $name, prompt: Text("List name")) {
                    Text("Name")
                }
                .textFieldStyle(.roundedBorder)
                .padding()
                .submitLabel(.done)
                .onSubmit {
                    let newList = shoppingAssitant.saveList(name: name)
                    viewModel.shoppingList = newList
                    saveListIsPresented = false
                }
                Spacer()
            }
        }
    }

    func deleteChosenProducts(products: [ChosenProduct]) {
        withAnimation {
            products.forEach {
                viewModel.removeProduct($0)
                shoppingAssitant.removeChosenProduct($0)
            }

        }
    }

    func changeChosenProduct(chosenProduct: ChosenProduct, offer: Offer) {
        withAnimation {
            let newChosenProduct = shoppingAssitant.changeChosenProduct(chosenProduct, to: offer)
            viewModel.replaceProduct(chosenProduct, with: newChosenProduct)
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
            CurrentShoppingListView(shoppingList: shoppingAssistant.currentList)
            CurrentShoppingListView(shoppingList: shoppingAssistant.currentList)
                .previewInterfaceOrientation(.landscapeRight)
        }.environmentObject(shoppingAssistant)
    }
}
