//
//  DeviceData.swift
//  knock-ios (iOS)
//
//  Created by Andrew Huynh on 4/19/21.
//

import SwiftUI

class DeviceData: Identifiable {
    let id: UUID
    var title: String
    var description: String
    
    init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

extension DeviceData {
    static var data: [DeviceData] {
        [
            DeviceData(
                title: "ESP32 Test",
                description: "Proximity sensor."),
            DeviceData(
                title: "Sensible Pantry",
                description: "Level sensor for your pantry.")
        ]
    }
}

extension DeviceData {
    struct Data {
        var title: String = ""
        var description: String = ""
    }
    
    var data: Data {
        return Data(title: title, description: description)
    }
}
