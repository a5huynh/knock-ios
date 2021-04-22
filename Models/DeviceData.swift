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
        return documentsFolder.appendingPathComponent("scrums.data")
    }
    
    @Published var devices: [Device] = []
    
    func load() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let data = try? Data(contentsOf: Self.fileURL) else {
                #if DEBUG
                DispatchQueue.main.async {
                    self?.devices = Device.data
                }
                #endif
                return
            }
            
            guard let devices = try? JSONDecoder().decode([Device].self, from: data) else {
                fatalError("Can't decode saved scrum data.")
            }
            
            DispatchQueue.main.async {
                self?.devices = devices
            }
        }
    }
    
    func save() {
        DispatchQueue.global(qos: .background).async { [weak self] in
           guard let scrums = self?.devices else { fatalError("Self out of scope") }
           guard let data = try? JSONEncoder().encode(scrums) else { fatalError("Error encoding data") }
           do {
               let outfile = Self.fileURL
               try data.write(to: outfile)
           } catch {
               fatalError("Can't write to file")
           }
        }
    }
}
