//
//  Scanner.swift
//  knock-ios (iOS)
//
//  Created by Andrew Huynh on 4/20/21.
//

import CoreBluetooth
import SwiftUI

class Scanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    
    static let sharedInstance: Scanner = {
        let instance = Scanner()
        return instance
    }()
    
    var centralManager: CBCentralManager!
    private var onConnect: ((Device) -> ())?
    
    @Published var peripherals: [Device] = []
    @Published var connected: [Device] = []
    
    // Should have a 1-to-1 mapping to devices in peripherals
    private var _cbScanned: [CBPeripheral] = []
    // Should have a 1-to-1 mapping to devices in connected
    private var _cbConnected: [CBPeripheral] = []
    private var isScannable: Bool = false
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
    }
    
    // MARK: - Public funcs
    func startScan(onConnect: @escaping (Device) -> Void = { device in }) {
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
        
        // Clear out lists when we're finished scanning
        self.peripherals.removeAll()
        self._cbScanned.removeAll()
    }
    
    func connect(identifier: UUID, onConnect: () -> () = {}) {
        print("Attempting to connect: \(identifier)")
        guard let peripheral = _cbScanned.first(where: { $0.identifier == identifier }) else {
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
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard let index = self._cbConnected.firstIndex(where: { $0.identifier == peripheral.identifier }) else {
            return
        }
        
        self._cbConnected.remove(at: index)
    }
        
    // MARK: - CBCentralManagerDelegate funcs
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect: \(peripheral.identifier)")
        guard let deviceIndex = peripherals.firstIndex(where: { $0.id == peripheral.identifier }) else {
            print("unable to find device")
            return
        }
        
        // Update the device status
        print("didConnect: Updating device status")
        peripherals[deviceIndex].updateDeviceState(to: .connected)
        // Let any listeners to this class know we've updated the peripherals
        self.objectWillChange.send()

        // Add to list of connected devices
        print("didConnect: Adding to list of connected devices")
        if !self._cbConnected.contains(where: { $0.identifier == peripheral.identifier }) {
            self._cbConnected.append(peripheral)
            self.connected.append(peripherals[deviceIndex])
        }
        
        // Let scanner delegate know we've connected to a device
        print("didConnect: Notifying delegates")
        self.onConnect?(peripherals[deviceIndex])
        
        // Discover services for this peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
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
        print("didDiscover: \(peripheral.identifier)")
        if !peripherals.contains(where: { $0.id == peripheral.identifier }) {
            
            if let name = peripheral.name {
                _cbScanned.append(peripheral)
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
    
    // MARK: - CBPeriperhalDelegate funcs
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
        }
    }
}
