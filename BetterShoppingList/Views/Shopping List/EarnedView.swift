//
//  EarnedView.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 29/4/22.
//

import SwiftUI

struct EarnedView: View {
    var value: Double?

    var body: some View {
        Label {
            Text(value?.eurosWithoutSign ?? "0.0")
        } icon: {
            Image(systemName: "eurosign.square.fill")
        }
        .labelStyle(EarnedLabelStyle())
        .padding(.bottom)
        .font(.largeTitle)
        .foregroundColor(.accentColor)
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

struct EarnedView_Previews: PreviewProvider {
    static var previews: some View {
        EarnedView(value: 1.20)
    }
}
