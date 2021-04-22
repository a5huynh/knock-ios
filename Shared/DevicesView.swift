//
//  ContentView.swift
//  Shared
//
//  Created by Andrew Huynh on 4/19/21.
//

import SwiftUI

struct DevicesView: View {
    @Binding public var knownDevices: [Device]
    @State private var isPresented = false
    var scanner = Scanner.sharedInstance
    
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
                    ScannerView()
                    .navigationBarItems(trailing: Button("Done") {
                        isPresented = false
                    })
                    .onAppear {
                        scanner.startScan()
                    }
                    .onDisappear {
                        scanner.stopScan()
                    }
            }
        }
    }
}

struct DevicesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DevicesView(knownDevices: .constant(Device.data))
        }
    }
}
