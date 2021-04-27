//
//  knock_iosApp.swift
//  Shared
//
//  Created by Andrew Huynh on 4/19/21.
//

import SwiftUI

@main
struct knockApp: App {
    @ObservedObject private var data = DeviceData()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                DevicesView(knownDevices: $data.devices) {
                    data.save()
                }
            }
            .onAppear {
                data.load()
            }
        }
    }
}
