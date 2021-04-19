//
//  knock_iosApp.swift
//  Shared
//
//  Created by Andrew Huynh on 4/19/21.
//

import SwiftUI

@main
struct knockApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                DevicesView(devices: .constant(DeviceData.data))
            }
        }
    }
}
