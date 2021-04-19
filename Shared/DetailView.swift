//
//  DetailView.swift
//  knock-ios (iOS)
//
//  Created by Andrew Huynh on 4/19/21.
//

import SwiftUI

struct DetailView: View {
    var body: some View {
        List {
            Section(header: Text("Device Info")) {
                HStack {
                    Label("Length", systemImage: "clock")
                    Spacer()
                    Text("10 minutes")
                }

                HStack {
                    Label("Color", systemImage: "paintpalette")
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.init(.red))
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Device Name")
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView()
        }
    }
}
