//
//  ContentView.swift
//  DoNotBeEvil
//
//  Created by Yan on 2022/10/17.
//  Copyright © 2022 Yan. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CalenderEventView()
                .tabItem {
                    Image(systemName: "trash.fill").imageScale(.large)
                }
        }
        .accentColor(.red)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
