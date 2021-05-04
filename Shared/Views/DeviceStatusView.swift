//
//  DeviceStatusView.swift
//  knock-ios (iOS)
//
//  Created by Andrew Huynh on 4/28/21.
//

import SwiftUI

enum ConnectionStatus: CaseIterable {
    case connected, connecting, disconnected, notFound, error, unknown
}

struct ConnectionStatusView: View {
    var status: ConnectionStatus
    var icon: String
    
    var body: some View {
        HStack {
            // Already connected?
            switch(status) {
            case .connected:
                Label("Connected", systemImage: icon)
                    .foregroundColor(.green)
            case .connecting:
                Label("Connecting", systemImage: icon)
                    .foregroundColor(.gray)
            case .disconnected:
                Label("Disconnected", systemImage: icon)
                    .foregroundColor(.red)
            case .notFound:
                Label("Scanning...", systemImage: icon)
                    .foregroundColor(.gray)
            case .error:
                Label("Error", systemImage: icon)
                    .foregroundColor(.red)
            case .unknown:
                Label("Unknown", systemImage: icon)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

struct BLEStatusView: View {
    @ObservedObject var scanner = Scanner.sharedInstance
    var device: Device
    
    var bleIcon = "bolt.horizontal.circle"
    
    var body: some View {
        // Already connected?
        if scanner.isConnected(to: device.id) {
            ConnectionStatusView(status: .connected, icon: bleIcon)
        // If not connected, is it within range?
        } else if let peripheral = scanner.peripherals.first(where: { $0.id == device.id }) {
            if peripheral.deviceState == .connecting {
                // In range, connecting
                ConnectionStatusView(status: .connecting, icon: bleIcon)
            } else {
                // In range, not connected
                ConnectionStatusView(status: .disconnected, icon: bleIcon)
            }
        } else {
            // Not in range
            ConnectionStatusView(status: .notFound, icon: bleIcon)
        }
    }
}

struct WiFiStatusView: View {
    @ObservedObject var scanner = Scanner.sharedInstance
    var device: Device
    
    var body: some View {
        // WiFi status on device
        if scanner.isConnected(to: device.id) {
            if scanner.characteristicValues[Scanner.CHAR_WIFI_STATUS] == "CONNECTED" {
                ConnectionStatusView(status: .connected, icon: "wifi")
            } else if scanner.characteristicValues[Scanner.CHAR_WIFI_STATUS] == "CONNECTING" {
                ConnectionStatusView(status: .connecting, icon: "wifi")
            } else {
                ConnectionStatusView(status: .disconnected, icon: "wifi")
            }
        } else {
            ConnectionStatusView(status: .unknown, icon: "wifi")
        }
    }
}

struct DeviceStatusView: View {
    var device: Device
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(device.id.uuidString)
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                BLEStatusView(device: device)
                WiFiStatusView(device: device)
            }
            .padding(.vertical)
        }
        .padding(.horizontal)
    }
}

struct DeviceStatusView_Previews: PreviewProvider {
    static var icon = "bolt.horizontal.circle"
    
    static var previews: some View {
        VStack {
            ForEach(ConnectionStatus.allCases, id: \.self) { status in
                ConnectionStatusView(status: status, icon: icon)
                    .padding()
            }
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Device Statuses")



        DeviceStatusView(device: Device.data[0])
            .previewLayout(.sizeThatFits)
    }
}
