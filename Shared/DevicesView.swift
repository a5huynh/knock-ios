//
//  ContentView.swift
//  Shared
//
//  Created by Andrew Huynh on 4/19/21.
//

import SwiftUI

struct DevicesView: View {
    @Binding var devices: [DeviceData]
    
    var body: some View {
        List {
            ForEach(devices) { device in
                CardView(device: device)
            }
        }
        .navigationTitle("Devices")
        .listStyle(PlainListStyle())
    }
}

struct DevicesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DevicesView(devices: .constant(DeviceData.data))
        }
    }
}
