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
        VStack {
            CalenderEventView()
                BottomTrashView()
                    .onTapGesture {
                        print("delete event item")
                        NotificationCenter.default.post(name: Notification.Name("deleteNotification"), object: nil, userInfo: nil)
                    }
                    .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct BottomTrashView: View {
    var body: some View {
        Image(systemName: "trash.fill")
            .font(.system(size: 25))
            .foregroundColor(.red)
        Text("垃圾桶")
                .font(.system(size: 10))
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
