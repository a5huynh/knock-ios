//
//  DeviceData.swift
//  knock-ios (iOS)
//
//  Created by Andrew Huynh on 4/20/21.
//

import Foundation

class DeviceData: ObservableObject {
    private static var documentsFolder: URL {
        do {
            return try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
        } catch {
            fatalError("Can't find documents directory")
        }
    }
    
    private static var fileURL: URL {
        return documentsFolder.appendingPathComponent("devices.data")
    }
    
    @Published var devices: [Device] = []
    
    func load() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            print("Loading saved device data")
            guard let data = try? Data(contentsOf: Self.fileURL) else {
                return
            }
            
            guard let devices = try? JSONDecoder().decode([Device].self, from: data) else {
                fatalError("Can't decode saved device data.")
            }
            
            DispatchQueue.main.async {
                self?.devices = devices
            }
        }
    }
    
    func save() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            print("Saving data")
            guard let devices = self?.devices else { fatalError("Self out of scope") }
            guard let data = try? JSONEncoder().encode(devices) else { fatalError("Error encoding data") }
            do {
                let outfile = Self.fileURL
                try data.write(to: outfile)
            } catch {
                fatalError("Can't write to file")
            }
        }
    }
}
