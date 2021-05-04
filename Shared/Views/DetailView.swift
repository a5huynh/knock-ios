//
//  DetailView.swift
//  knock-ios (iOS)
//
//  Created by Andrew Huynh on 4/19/21.
//

import CoreBluetooth
import SwiftUI

struct ConfigureButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(Color.white)
            .padding()
            .background(Color(.blue))
            .cornerRadius(15.0)
    }
}

struct DetailView: View {
    @ObservedObject var scanner = Scanner.sharedInstance

    @State var ssid: String = ""
    @State var password: String = ""
    
    var device: Device

    var body: some View {
        VStack(alignment: .leading) {
            DeviceStatusView(device: device)
            
            List {
                Section(header: Text("WiFi Settings")) {
                    TextField("SSID", text: $ssid)
                    SecureField("Password", text: $password)
                    Button("Configure Device", action: {
                        scanner.configureWiFi(ssid: ssid, password: password)
                    })
                }
            }
            .listStyle(InsetGroupedListStyle())

        }
        .navigationBarItems(trailing:
            Button(action: {
                if scanner.isConnected(to: device.id) {
                    scanner.disconnect()
                } else {
                    scanner.connect(identifier: device.id)
                }
            }) {
                if scanner.isConnected(to: device.id) {
                    Text("Disconnect")
                } else {
                    Text("Connect")
                }
            }
                .disabled(!scanner.isNearby(identifier: device.id))
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
