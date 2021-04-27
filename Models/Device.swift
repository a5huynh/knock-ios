//
//  DeviceData.swift
//  knock-ios (iOS)
//
//  Created by Andrew Huynh on 4/19/21.
//

import CoreBluetooth
import SwiftUI

enum DeviceState: String, Codable {
    case disconnected, connecting, connected
}

struct Device: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var deviceState: DeviceState
    
    init(id: UUID = UUID(), title: String, description: String, deviceState: DeviceState = .disconnected) {
        self.id = id
        self.title = title
        self.description = description
        self.deviceState = deviceState
    }
    
    mutating func updateDeviceState(to state: DeviceState) {
        deviceState = state
    }
}

extension Device {
    static var data: [Device] {
        [
            Device(
                title: "ESP32 Test",
                description: "Proximity sensor."),
            Device(
                title: "Sensible Pantry",
                description: "Level sensor for your pantry.")
        ]
    }
}
