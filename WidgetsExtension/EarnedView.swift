//
//  EarnedView.swift
//  WidgetsExtensionExtension
//
//  Created by Xavi Aracil on 4/5/22.
//

import SwiftUI

struct EarnedView: View {
    var value: Double
    var body: some View {
        Label {
            Text(value.eurosWithoutSign)
        } icon: {
            Image(systemName: "eurosign.square.fill")
        }
        .labelStyle(EarnedLabelStyle())
        .padding(.bottom)
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
        EarnedView(value: 10.0)
    }
}
