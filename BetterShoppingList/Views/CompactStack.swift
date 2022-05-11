//
//  CompactStack.swift
//  BetterShoppingList
//
//  Created by Xavi Aracil on 9/5/22.
//

import SwiftUI

struct CompactStack<Content>: View where Content: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    let content: Content

    var verticalAlignment: HorizontalAlignment = .leading

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        if verticalSizeClass == .compact {
            HStack(alignment: .firstTextBaseline) { content }
        } else {
            VStack(alignment: verticalAlignment) { content }
        }
    }
}

struct CompactStack_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CompactStack {
                Text("Hello vertical")
                Text("There")
            }
            CompactStack {
                Text("Hello")
                Text("There")
            }
.previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
