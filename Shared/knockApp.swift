//
//  knock_App.swift
//  Shared
//
//  Created by Andrew Huynh on 4/19/21.
//

import SwiftUI
import PartialSheet

@main
struct knockApp: App {
    @ObservedObject private var data = DeviceData()
    @StateObject private var partialSheetManager: PartialSheetManager = PartialSheetManager()
    var scanner = Scanner.sharedInstance
    
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
            .environmentObject(partialSheetManager)
        }
    }
}
