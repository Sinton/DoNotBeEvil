//
//  HeaderBar.swift
//  DoNotBeEvil
//
//  Created by Yan on 2023/3/31.
//  Copyright © 2023 Yan. All rights reserved.
//

import SwiftUI

struct HeaderBar: View {
    @Environment(\.colorScheme)
    var currentColorScheme

    var defaultColorScheme: ColorScheme = .dark
    var leftIcon: Image                 = Image(systemName: "magnifyingglass")
    var title: String                   = ""
    var rightIcon: Image                = Image("setting")
    var rightIconWidth: CGFloat         = 0
    var rightIconHeight: CGFloat        = 0

    var body: some View {
        ZStack {
            HStack {
                leftIcon.colorScheme(defaultColorScheme)
                Spacer()
                Text(self.title).colorScheme(defaultColorScheme)
                Spacer()
                rightIcon
                    .resizable()
                    .frame(width: rightIconWidth, height: rightIconHeight)
                    .colorScheme(defaultColorScheme)
            }
            .padding(.top, 40)
            .padding(.bottom)
            .padding(.horizontal)
            
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct HeaderBar_Previews: PreviewProvider {
    static var previews: some View {
        HeaderBar()
    }
}
