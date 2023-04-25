//
//  AdaptableNavigation.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-25.
//

import SwiftUI

struct AdaptableNavigation<Content>: View where Content: View {
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack(root: content)
        } else {
            NavigationView(content: content)
        }
    }
}

struct AdaptableNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AdaptableNavigation {
            Text("Hello Firebase!")
        }
    }
}
