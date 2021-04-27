//
//  DetailView.swift
//  knock-ios (iOS)
//
//  Created by Andrew Huynh on 4/19/21.
//

import SwiftUI

struct DetailView: View {
    @ObservedObject var scanner = Scanner.sharedInstance
    
    var device: Device

    var body: some View {
        VStack {
            HStack {
                if let peripheral = scanner.peripherals.first(where: { $0.id == device.id }) {
                    if peripheral.deviceState == .connecting {
                        Label("Connecting", systemImage: "ellipsis.circle.fill")
                    } else if peripheral.deviceState == .connected {
                        Label("Connected", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Label("Not Connected", systemImage: "nosign")
                            .foregroundColor(.red)
                    }
                } else {
                    Label("Finding Device...", systemImage: "antenna.radiowaves.left.and.right")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            
            List {
                Section(header: Text("Device Info")) {
                    HStack {
                        Label("Length", systemImage: "clock")
                        Spacer()
                        Text("10 minutes")
                    }

                    HStack {
                        Label("Color", systemImage: "paintpalette")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.init(.red))
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarItems(trailing:
            Button("Connect", action: { scanner.connect(identifier: device.id) })
                // Only enable button if we're able to find the device &
                // it's not already connected
                .disabled(
                    !scanner.peripherals.contains(where: { $0.id == device.id }) ||
                    scanner.connected.contains(where: { $0.id == device.id })
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
