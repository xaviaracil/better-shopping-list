//
//  CurrentListView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 6/4/22.
//

import SwiftUI

struct ShoppingListView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var shoppingAssitant: ShoppingAssistant

    @State private var saveListIsPresented = false
    @State private var name = ""

    @StateObject
    var viewModel: ShoppingListViewModel

    var products: Set<ChosenProduct>? {
        viewModel.shoppingList?.products as? Set<ChosenProduct>
    }

    init(shoppingList: ShoppingList?) {
        _viewModel = .init(wrappedValue: ShoppingListViewModel(shoppingList: shoppingList))
    }

    var body: some View {
        VStack {
            if verticalSizeClass == .compact {
                // landscape
                let rows: [GridItem] = Array(repeating: .init(.flexible(minimum: 200.0, maximum: .infinity)), count: 1)
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows) {
                        ForEach(viewModel.shoppingList?.markets ?? []) { market in
                            CurrentListMarketView(market: market, products: products?.ofMarket(market: market) ?? [])
                        }
                    }
                    .padding([.top, .bottom])
                }
            } else if horizontalSizeClass == .regular {
                let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.shoppingList?.markets ?? []) { market in
                            CurrentListMarketView(market: market, products: products?.ofMarket(market: market) ?? [])
                        }
                    }
                }
            } else {
            // portrait
                let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.shoppingList?.markets ?? []) { market in
                            CurrentListMarketView(market: market, products: products?.ofMarket(market: market) ?? [])
                        }
                    }
                }
            }
            Spacer()
            Label {
                Text(viewModel.shoppingList?.earned.formatted(.currency(code: "eur")) ?? "0.0")
            } icon: {
                Image(systemName: "eurosign.square.fill")
            }
            .labelStyle(EarnedLabelStyle())
            .font(.largeTitle)
            .foregroundColor(.accentColor)
            .padding(.bottom)
        }
        .navigationTitle(viewModel.shoppingList?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .primaryAction) {
                if viewModel.shoppingList?.isCurrent ?? false {
                    Button(action: { saveListIsPresented = true }) {
                        Image(systemName: "square.and.arrow.down")
                    }
                } else {
                    FavoriteButton(isOn: $viewModel.isFavorite)
                }
            }
        })
        .sheet(isPresented: $saveListIsPresented) {
            VStack {
                Text("Save List").font(.largeTitle)
                TextField(text: $name, prompt: Text("List name")) {
                    Text("Name")
                }
                .textFieldStyle(.roundedBorder)
                .padding()
                .submitLabel(.done)
                .onSubmit {
                    _ = shoppingAssitant.saveList(name: name)
                    saveListIsPresented = false
                }
            }
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
            ShoppingListView(shoppingList: shoppingAssistant.currentList)
            ShoppingListView(shoppingList: shoppingAssistant.currentList)
                .previewInterfaceOrientation(.landscapeRight)
        }.environmentObject(shoppingAssistant)
    }
}
