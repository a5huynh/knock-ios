//
//  Scanner.swift
//  knock-ios (iOS)
//
//  Created by Andrew Huynh on 4/19/21.
//

import SwiftUI

struct ScannerView: View {
    @ObservedObject var scanner = Scanner.sharedInstance
    @State var _extraDevices: [Device] = []
    @Binding var knownDevices: [Device]
    
    var body: some View {
        if scanner.peripherals.count > 0 || _extraDevices.count > 0 {
            List {
                ForEach(scanner.peripherals + _extraDevices) { device in
                    if knownDevices.first(where: { $0.id == device.id }) == nil {
                        ScannerCardView(device: binding(for: device))
                    }
                }
            }
            .navigationTitle("Matching Devices")
        } else {
            VStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.largeTitle)
                Text("Scanning for devices...")
            }
        }
    }
    
    private func binding(for device: Device) -> Binding<Device> {
        if let deviceIndex = scanner.peripherals.firstIndex(where: { $0.id == device.id }) {
            return $scanner.peripherals[deviceIndex]
        } else if let deviceIndex = _extraDevices.firstIndex(where: { $0.id == device.id }) {
            return $_extraDevices[deviceIndex]
        } else {
            fatalError("Could not find device")
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScannerView(_extraDevices: Device.data, knownDevices: .constant([]))
                .previewDisplayName("With devices found")
        }
        
        NavigationView {
            ScannerView(knownDevices: .constant([]))
                .previewDisplayName("No devices found / currently scanning")
        }
    }
}
