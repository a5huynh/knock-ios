//
//  DetailView.swift
//  knock-ios (iOS)
//
//  Created by Andrew Huynh on 4/19/21.
//

import CoreBluetooth
import SwiftUI

struct DetailView: View {
    @ObservedObject var scanner = Scanner.sharedInstance

    @State var ssid: String = "seriously 2.4"
    @State var password: String = ""
    
    var device: Device

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // Already connected?
                if scanner.isConnected(to: device.id) {
                    Label("Connected", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                // If not connected, can we detect this peripheral?
                } else if let peripheral = scanner.peripherals.first(where: { $0.id == device.id }) {
                    if peripheral.deviceState == .connecting {
                        Label("Connecting", systemImage: "ellipsis.circle.fill")
                    } else {
                        Label("Not Connected", systemImage: "nosign")
                            .foregroundColor(.red)
                    }
                // Not detected & not connected
                } else {
                    Label("Finding Device...", systemImage: "antenna.radiowaves.left.and.right")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            
            if scanner.isConnected(to: device.id) {
                List {
                    Section(header: Text("WiFi Settings")) {
                        TextField("SSID", text: $ssid)
                        SecureField("Password", text: $password)
                        Button("Configure Device", action: {
                            scanner.sendData()
                        })
                    }
                }
                .listStyle(InsetGroupedListStyle())
            } else {
                Text("Connect device to configure")
                    .padding()
                Spacer()
            }
        
        }
        .navigationBarItems(trailing:
            Button("Connect", action: { scanner.connect(identifier: device.id) })
                // Only enable button if we're able to find the device &
                // it's not already connected
                .disabled(
                    !scanner.isNearby(identifier: device.id) ||
                    scanner.isConnected(to: device.id)
                )
        )
        .navigationTitle(device.title)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView(device: Device.data[0])
        }
    }
}
