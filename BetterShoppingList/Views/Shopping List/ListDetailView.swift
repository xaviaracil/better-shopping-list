//
//  ListDetailView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 7/4/22.
//

import SwiftUI

struct ListDetailView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var shoppingAssistant: ShoppingAssistant

    var products: [ChosenProduct]
    var name: String
    var deleteChosenProducts: (([ChosenProduct]) -> Void)?

    var body: some View {
        NavigationView {
            Group {
                if verticalSizeClass == .compact {
                    // landscape
                    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(products, id: \.self) { chosenProduct in
                                ChosenProductView(chosenProduct: chosenProduct, shoppingAssistant: shoppingAssistant)
                                    .padding()
                            }
                            .onDelete(perform: deleteProducts)
                        }
                    }
                } else {
                    // portrait
                    List {
                        ForEach(products, id: \.self) { chosenProduct in
                            ChosenProductView(chosenProduct: chosenProduct, shoppingAssistant: shoppingAssistant)
                                .padding(.vertical, 4.0)
                        }
                        .onDelete(perform: deleteProducts)
                    }.listStyle(.plain)
                }
            }
            .navigationBarTitle(Text(name), displayMode: .inline)
            // swiftlint:disable multiple_closures_with_trailing_closure
            .toolbar(content: {
                ToolbarItem(placement: .destructiveAction) {
                    Button(action: { dismiss() }) {
                        Label("Close", systemImage: "xmark")
                            .labelStyle(.iconOnly)
                    }
                }
            })
        }
    }

    private func deleteProducts(offsets: IndexSet) {
        guard let deleteChosenProducts = deleteChosenProducts else {
            return
        }

        deleteChosenProducts(offsets.map { products[$0] })
    }

}

struct ListDetailView_Previews: PreviewProvider {
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
        //        let market2 = Market(context: viewContext)
        //        market2.name = "Market 2"
        //
        let product = Product(context: viewContext)
        product.name = "Producte 1"
        product.imageUrl = URL(string: "https://static.condisline.com/resize_395x416/images/catalog/large/704005.jpg")
        //
        let offer1 = Offer(context: viewContext)
        offer1.price = 1.10
        offer1.uuid = UUID()
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
        chosenProduct.isSpecialOffer = true
        chosenProduct.offerUUID = offer1.uuid
        chosenProduct.marketUUID = market1.uuid

        return Group {
            ListDetailView(products: [chosenProduct], name: "Some Name")
                .environmentObject(shoppingAssistant)
            ListDetailView(products: [chosenProduct], name: "Some Name")
                .environmentObject(shoppingAssistant)
.previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
