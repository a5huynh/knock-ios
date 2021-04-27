//
//  ContentView.swift
//  Shared
//
//  Created by Andrew Huynh on 4/19/21.
//

import SwiftUI

struct DevicesView: View {
    @Binding public var knownDevices: [Device]
    @Environment(\.scenePhase) private var scenePhase
    @State private var isPresented = false
    var scanner = Scanner.sharedInstance
    let saveAction: () -> Void

    var body: some View {
        List {
            ForEach(knownDevices) { device in
                NavigationLink(destination: DetailView()) {
                    CardView(device: device)
                }
            }
        }
        .navigationTitle("Devices")
        .navigationBarItems(trailing: Button(action: { isPresented = true }) {
            Label("Add Device", systemImage: "plus")
        })
        .listStyle(PlainListStyle())
        .sheet(isPresented: $isPresented) {
         	   NavigationView {
                    ScannerView(knownDevices: $knownDevices)
                    .navigationBarItems(trailing: Button("Done") {
                        isPresented = false
                    })
                    .onAppear {
                        scanner.startScan(onConnect: { device in
                            // Device not known?
                            if knownDevices.first(where: { $0.id == device.id }) == nil {
                                knownDevices.append(device)
                            }
                        })
                    }
                    .onDisappear {
                        scanner.stopScan()
                    }
            }
        }
        .onChange(of: scenePhase, perform: { phase in
            if phase == .inactive { saveAction() }
        })
    }
}

struct DevicesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DevicesView(knownDevices: .constant(Device.data), saveAction: {})
        }
    }
}
