//
//  AddDeviceView.swift
//  knock-ios (iOS)
//
//  Created by Andrew Huynh on 5/17/21.
//

import SwiftUI

struct AddDeviceView: View {
    @Binding var device: Device?

    var body: some View {
        VStack(alignment: .center) {
            Text("Add Device")
                .font(.headline)
            Divider()
            Spacer()
            if device != nil {
                VStack {
                    Text(device?.title ?? "Device")
                    Text(device?.description ?? "")
                }
                .padding()
                
                Button(action: {}) {
                    Label(
                        "Add Device",
                        systemImage: "plus.circle.fill"
                    )
                }
            } else {
                VStack {
                    ProgressView()
                }
                .scaleEffect(x: 2.0, y: 2.0, anchor: .center)
            }
            Spacer()
        }
        .frame(height: 128)
    }
}

struct AddDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        AddDeviceView(device: .constant(nil))
            .previewLayout(.fixed(width: 400, height: 160))
            .previewDisplayName("Scanning")
        
        AddDeviceView(device: .constant(Device.data[0]))
            .previewLayout(.fixed(width: 400, height: 160))
            .previewDisplayName("Device Found")
    }
}
