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
    var deleteChosenProducts: (([ChosenProduct]) -> Void)?
    var changeChosenProduct: ((ChosenProduct, Offer) -> Void)?
    var canEdit: Bool
    var canChangeQuantity: Bool

    init(chosenProduct: ChosenProduct,
         shoppingAssistant: ShoppingAssistant,
         deleteChosenProducts: (([ChosenProduct]) -> Void)? = nil,
         changeChosenProduct: ((ChosenProduct, Offer) -> Void)? = nil,
         canEdit: Bool = true,
         canChangeQuantity: Bool = true) {
        viewModel = ChosenProductViewModel(shoppingAssistant: shoppingAssistant,
                                           chosenProduct: chosenProduct)
        self.deleteChosenProducts = deleteChosenProducts
        self.changeChosenProduct = changeChosenProduct
        self.canEdit = canEdit
        self.canChangeQuantity = canChangeQuantity
    }

    private func deleteProduct() {
        guard let deleteChosenProducts = deleteChosenProducts else {
            return
        }

        deleteChosenProducts([viewModel.chosenProduct])
    }

    private func changeOffer(_ offer: Offer) {
        guard let changeChosenProduct = changeChosenProduct else {
            return
        }

        changeChosenProduct(viewModel.chosenProduct, offer)
    }

    var body: some View {
        HStack {
            ProductImageView(product: viewModel.product, isSpecialOffer: viewModel.chosenProduct.isSpecialOffer)
            .frame(width: 90, height: 90)

            VStack(alignment: .leading) {
                Text(viewModel.chosenProduct.wrappedName)
                    .productTitle()
                Text(viewModel.chosenProduct.price.euros)
                    .bestPrice()
                if canChangeQuantity {
                    Stepper(value: $viewModel.quantity) {
                        Text("Quantity: \(viewModel.quantity)")
                            .minimumScaleFactor(0.05)
                    }
                    .font(.subheadline)
                } else {
                    Text("Quantity: \(viewModel.quantity)")
                        .font(.subheadline)
                }
            }

            Spacer()

            Menu {
                if let additionalOffers = viewModel.additionalOffers,
                   canEdit {
                    ForEach(additionalOffers) { offer in
                        Button(action: {
                            changeOffer(offer)
                        }) {
                            Label("\(offer.market?.name ?? "N.A.") (\(offer.price.euros))",
                                  systemImage: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)

                        }
                    }
                    Divider()
                }
                Button(role: .destructive, action: deleteProduct) {
                    Label("Delete", systemImage: "trash.fill")
                }
            } label: {
                Label("Move to", systemImage: "ellipsis.circle")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                    .labelStyle(.iconOnly)
            }
        }
    }
}

struct ChosenProductView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let persistenceAdapter = CoreDataPersistenceAdapter(viewContext: viewContext)
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

        return
            ChosenProductView(chosenProduct: chosenProduct,
                              shoppingAssistant: shoppingAssistant,
                              deleteChosenProducts: nil,
                              changeChosenProduct: nil)
    }
}
