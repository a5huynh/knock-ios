//
//  ContentView.swift
//  Shared
//
//  Created by Andrew Huynh on 4/19/21.
//

import SwiftUI
import PartialSheet

struct DevicesView: View {
    @Binding public var knownDevices: [Device]
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var partialSheet: PartialSheetManager
    @ObservedObject var scanner = Scanner.sharedInstance
    @State private var discoveredDevice: Device?
    
    let saveAction: () -> Void

    var body: some View {
        List {
            ForEach(knownDevices) { device in
                NavigationLink(destination: DetailView(device: device)
                    // Start scan so we can pull info about this peripheral
                    .onAppear {
                        print("Detail for: \(device.id)")
                        scanner.startScan()
                    }
                    .onDisappear { scanner.stopScan() }
                ) {
                    CardView(device: device)
                }
            }
            .onDelete(perform: { indexSet in
                // remove from known devices list
                for i in indexSet {
                    knownDevices.remove(at: i)
                }
            })
        }
        .navigationTitle("Saved")
        .navigationBarItems(
            trailing:
                Button(action: {
                    scanner.startScan(onDiscover: { device in
                        // Device not known?
                        print("onDiscover: \(device), \(knownDevices.count)")
                        if discoveredDevice == nil && !knownDevices.contains(where: { $0.id == device.id }){
                            discoveredDevice = device
                        }
                    })
                    
                    self.partialSheet.showPartialSheet({
                        discoveredDevice = nil
                        scanner.stopScan()
                    }) {
                        AddDeviceView(device: $discoveredDevice)
                    }
                }) {
                    Label("Add Device", systemImage: "plus")
                }
        )
        .listStyle(PlainListStyle())
        .onChange(of: scenePhase, perform: { phase in
            if phase == .inactive { saveAction() }
        })
        .addPartialSheet()
    }
}

struct DevicesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DevicesView(knownDevices: .constant(Device.data), saveAction: {})
        }
    }
}
