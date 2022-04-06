import Algorithms

struct ProductOffers: Hashable {
    let product: Product
    let offers: [Offer]?

    func chooseOffer(at index: Int, quantity: Int16) -> ChosenProduct {
        var chosenProduct: ChosenProduct
        if let managedObjectContext = product.managedObjectContext {
            chosenProduct = ChosenProduct(context: managedObjectContext)
        } else {
            chosenProduct = ChosenProduct()
        }
        chosenProduct.name = product.name
        if let offers = offers {
            let offer = offers[index]
            chosenProduct.price = offer.price
            chosenProduct.quantity = quantity
            chosenProduct.marketUri = offer.market?.objectID.uriRepresentation()
            chosenProduct.offerUri = offer.objectID.uriRepresentation()
        }
        return chosenProduct
    }
}

extension Collection where Self.Element == Offer {
    func toProductOffers() -> [ProductOffers] {
        let chunked = self.chunked(on: \.product)
        let list = chunked.filter { product, _ in
            product != nil
        }
        .map { product, offers in
            ProductOffers(product: product!, offers: Array(offers))
        }
        return list
    }
}
