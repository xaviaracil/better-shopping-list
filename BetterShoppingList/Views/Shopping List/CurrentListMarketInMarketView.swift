//
//  CurrentListMarketInMarketView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 28/4/22.
//

import SwiftUI

struct CurrentListMarketInMarketView: View {
    var name: String
    @ObservedObject
    var viewModel: CurrentListMarketInMarketViewModel

    init(name: String, products: [ChosenProduct]) {
        self.name = name
        _viewModel = .init(wrappedValue: CurrentListMarketInMarketViewModel(products: products))
    }

    var sortedProducts: [ChosenProduct] {
        viewModel.products.sorted { lhs, rhs in
            if !lhs.inBasket && rhs.inBasket {
                return true
            }
            if lhs.inBasket && !rhs.inBasket {
                return false
            }
            return lhs.wrappedName.compare(rhs.wrappedName) == .orderedAscending
        }
    }

    var body: some View {
        List {
            ForEach(sortedProducts, id: \.self) { product in
                HStack {
                    if let offer = product.offer {
                        ProductImageView(product: offer.product, isSpecialOffer: product.isSpecialOffer)
                            .frame(width: 90, height: 90)
                    }

                    VStack(alignment: .leading) {
                        Text(product.name ?? "No Name")
                            .strikethrough(product.inBasket, color: .accentColor)
                            .productTitle()
                        Text(product.price.euros)
                            .strikethrough(product.inBasket, color: .accentColor)
                            .bestPrice()
                        Text("Quantity: \(product.quantity)")
                            .strikethrough(product.inBasket, color: .accentColor)
                            .font(.subheadline)
                            .minimumScaleFactor(0.01)
                    }

                    Spacer()

                    Button(action: {
                        viewModel.toggleInBasket(product)
                    }) {
                        Label(product.inBasket ? "Remove from cart" : "Add to cart",
                              systemImage: product.inBasket ? "checkmark.circle" : "circle")
                            .font(.watchOS ? .largeTitle : .system(size: 48))
                            .foregroundColor(.accentColor)
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                }.opacity(product.inBasket ? 0.7 : 1.0)
            }
        }
        .emptyListPlaceholder(sortedProducts, AnyView(Text("No products found in market")))
        .listStyle(.plain)
    }
}

struct CurrentListMarketInMarketView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
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
        chosenProduct.name = "Llet ATO 1L"
        chosenProduct.price = 1.1
        chosenProduct.quantity = 6
        chosenProduct.isSpecialOffer = true
        chosenProduct.offerUUID = offer1.uuid
        chosenProduct.marketUUID = market1.uuid

        return CurrentListMarketInMarketView(name: "Market 1", products: [chosenProduct])

    }
}
