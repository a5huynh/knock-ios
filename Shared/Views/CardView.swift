//
//  CardView.swift
//  knock-ios (iOS)
//
//  Created by Andrew Huynh on 4/19/21.
//

import SwiftUI

struct CardView: View {
    let device: Device
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(device.title)
                .font(.headline)
            Spacer()
            HStack {
                Label(
                    device.description ?? device.id.uuidString,
                    systemImage: "info.circle.fill"
                )
                Spacer()
            }
            .font(.caption)
        }
        .padding([.vertical])
    }
}

struct CardView_Previews: PreviewProvider {
    static var device = Device.data[0]
    static var previews: some View {
        CardView(device: device)
            .previewLayout(.fixed(width: 400, height: 60))
    }
}
