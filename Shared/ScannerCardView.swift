//
//  ScannedCardView.swift
//  knock-ios (iOS)
//
//  Created by Andrew Huynh on 4/20/21.
//

import SwiftUI

struct ScannerCardView: View {
    @Binding var device: Device
    
    @State var isConnecting: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            CardView(device: device)
            Spacer()
            if device.deviceState == .connecting {
                Image(systemName: "ellipsis.circle.fill")
            } else if device.deviceState == .connected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button(action: {
                    Scanner.sharedInstance.connect(identifier: device.id)
                }, label: {
                    Image(systemName: "plus.circle.fill")
                })
            }
        }
        .padding([.trailing])
    }
}

struct ScannerCardView_Preview: PreviewProvider {
    static var scanner = Scanner()
    static var devices = [
        Device(title: "Proxion Proxo", description: "Proximity Sensor", deviceState: .disconnected),
        Device(title: "Smart Pantry Box", description: "Level Sensor", deviceState: .connecting),
        Device(title: "NewSmellz", description: "CO2 Monitor", deviceState: .connected)
    ]
    
    static var previews: some View {
        ScannerCardView(device: .constant(devices[0]))
            .previewLayout(.fixed(width: 400, height: 60))
            .previewDisplayName("Not connected")
        
        ScannerCardView(device: .constant(devices[1]))
            .previewLayout(.fixed(width: 400, height: 60))
            .previewDisplayName("Connecting")

        ScannerCardView(device: .constant(devices[2]))
            .previewLayout(.fixed(width: 400, height: 60))
            .previewDisplayName("Connected")

    }
}
