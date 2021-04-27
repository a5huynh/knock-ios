//
//  Scanner.swift
//  knock-ios (iOS)
//
//  Created by Andrew Huynh on 4/20/21.
//

import CoreBluetooth
import SwiftUI

class Scanner: NSObject, CBCentralManagerDelegate, ObservableObject {
    
    static let sharedInstance: Scanner = {
        let instance = Scanner()
        return instance
    }()
    
    var centralManager: CBCentralManager!
    private var onConnect: ((Device) -> ())?
    
    @Published var peripherals: [Device] = []
    
    private var scanned: [CBPeripheral] = []
    private var isScannable: Bool = false
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
    }
    
    // MARK: - Public funcs
    func startScan(onConnect: @escaping (Device) -> Void) {
        if isScannable {
            print("START scanning")
            centralManager.scanForPeripherals(withServices: [CBUUID.init(string: "beefcafe-36e1-4688-b7f5-000000000000")])
            self.onConnect = onConnect
        }
    }
    
    func stopScan() {
        print("STOP scanning")
        centralManager.stopScan()
        self.onConnect = nil
    }
    
    func connect(identifier: UUID, onConnect: () -> () = {}) {
        print("Connecting to \(identifier)")
        guard let peripheral = scanned.first(where: { $0.identifier == identifier }) else {
            print("unable to connect to device")
            return
        }
        
        guard let deviceIndex = peripherals.firstIndex(where: { $0.id == identifier }) else {
            print("unable to find device")
            return
        }
        peripherals[deviceIndex].updateDeviceState(to: .connecting)
        self.objectWillChange.send()
        
        centralManager.connect(peripheral)
    }
    
    // MARK: - CBCentralManagerDelegate funcs
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected to \(peripheral.identifier)")
        guard let deviceIndex = peripherals.firstIndex(where: { $0.id == peripheral.identifier }) else {
            print("unable to find device")
            return
        }
        
        var device = peripherals[deviceIndex];
        // Update the device status
        device.updateDeviceState(to: .connected)
        // Let scanner delegate know we've connected to a device
        self.onConnect?(device)
        // Let any listeners to this class know we've updated the peripherals
        self.objectWillChange.send()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is unknown")
            isScannable = false
        case .resetting:
            print("central.state is resetting")
            isScannable = false
        case .unsupported:
            print("central.state is unsupported")
            isScannable = false
        case .unauthorized:
            print("central.state is unauthorized")
            isScannable = false
        case .poweredOff:
            print("central.state is poweredOff")
            isScannable = false
        case .poweredOn:
            print("central.state is poweredOn")
            isScannable = true
        @unknown default:
            print("unknown value")
            isScannable = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Have we added this already?
        if !peripherals.contains(where: { $0.id == peripheral.identifier }) {
            if let name = peripheral.name {
                scanned.append(peripheral)
                peripherals.append(
                    Device(
                        id: peripheral.identifier,
                        title: name,
                        description: "Device")
                )
                self.objectWillChange.send()
            }
        }
    }
}
