//
//  ContentView.swift
//  DoNotBeEvil
//
//  Created by Yan on 2022/10/17.
//  Copyright © 2022 Yan. All rights reserved.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State
    var title = "Initial Text"
    @State
    private var data = [String]()

    var body: some View {
        NavigationView {
            ZStack {
                //NoDataView()
                CalenderEventView()
                cleanBtnView()
            }
            .navigationBarTitle("日历事件", displayMode: .inline)
        }
    }

    func cleanBtnView() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    print("delete event item")
                    NotificationCenter.default.post(name: Notification.Name("deleteNotification"),
                                                    object: nil,
                                                    userInfo: nil)
                }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.bottom, 32)
        .padding(.trailing, 32)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
