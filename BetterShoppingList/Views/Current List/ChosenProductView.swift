//
//  ListDetailProductView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 7/4/22.
//

import SwiftUI

struct ChosenProductView: View {
    @ObservedObject
    private var viewModel: ChosenProductViewModel

    init(chosenProduct: ChosenProduct, shoppingAssistant: ShoppingAssistant) {
        viewModel = ChosenProductViewModel(shoppingAssistant: shoppingAssistant, chosenProduct: chosenProduct)
    }

    var body: some View {
        HStack {
            // swiftlint:disable multiple_closures_with_trailing_closure
            AsyncImage(url: viewModel.product?.imageUrl) { image in
                image.resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 90, height: 90)

            VStack(alignment: .leading) {
                Text(viewModel.product?.name ?? "No Name")
                    .productTitle()
                Text(viewModel.chosenProduct.price.formatted(.currency(code: "eur")))
                    .bestPrice()
                Stepper(value: $viewModel.quantity) {
                    Text("Quantity: \(viewModel.quantity)")
                }
                .font(.subheadline)
            }

            Spacer()

            Button(action: {
            }) {
                Label("Move to", systemImage: "ellipsis.circle")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                    .labelStyle(.iconOnly)

            }
        }

    }
}

struct ListDetailProductView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        // swiftlint:disable line_length
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext,
                                                            coordinator: PersistenceController.preview.container.persistentStoreCoordinator)
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

        return ChosenProductView(chosenProduct: chosenProduct, shoppingAssistant: shoppingAssistant)
    }
}
