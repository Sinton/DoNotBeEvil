//
//  NoDataView.swift
//  DoNotBeEvil
//
//  Created by Yan on 2023/6/17.
//  Copyright © 2023 Yan. All rights reserved.
//

import SwiftUI

struct NoDataView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "car")
                .resizable()
                .scaledToFit()
                .frame(width: 240)
            Text("无数据")
                .font(.system(size: 17))
                .bold()
                .foregroundColor(.gray)
        }
    }
}

struct NoDataView_Previews: PreviewProvider {
    static var previews: some View {
        NoDataView()
    }
}
