//
//  ChosenProduct+fetchers.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 7/4/22.
//

import Foundation

extension ChosenProduct {
    var offer: Offer {
        let fethcRequest = Offer.fetchRequest()
        fethcRequest.predicate = NSPredicate(format: "(objectId = %@)", self.offerUri)
    }
}
