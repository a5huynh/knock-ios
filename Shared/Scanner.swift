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
    @Published var connectedPeripheral: CBPeripheral?
    @Published var characteristics: [String: [CBCharacteristic]] = [:]
    @Published var characteristicValues: [CBUUID: String] = [:]
    @Published var services: [CBService] = []
    
    // Should have a 1-to-1 mapping to devices in peripherals
    private var _cbScanned: [CBPeripheral] = []
    private var isScannable: Bool = false
    
    // Characteristics for the currently connected peripheral
    private var _cbCharacteristics: [CBCharacteristic] = []
    // Services for the currently connected periperhal
    private var _cbServices: [CBService] = []
    
    public static var SERVICE_TRANSPORT_DISCOVERY = CBUUID.init(string: "0x1824");
    public static var CHAR_WIFI_SSID = CBUUID.init(string: "beefcafe-36e1-4688-b7f5-000000000001")
    public static var CHAR_WIFI_PASS = CBUUID.init(string: "beefcafe-36e1-4688-b7f5-000000000002")
    public static var CHAR_WIFI_STATUS = CBUUID.init(string: "beefcafe-36e1-4688-b7f5-000000000003")
    public static var CHAR_WIFI_START = CBUUID.init(string: "beefcafe-36e1-4688-b7f5-000000000004")
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
    }
    
    // MARK: - Public funcs
    func startScan(onConnect: @escaping (Device) -> Void = { device in }) {
        if isScannable {
            print("START scanning")
            centralManager.scanForPeripherals(withServices: [Scanner.SERVICE_TRANSPORT_DISCOVERY])
            self.onConnect = onConnect
        }
    }
    
    func stopScan() {
        print("STOP scanning")
        centralManager.stopScan()
        self.onConnect = nil
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
    
    func disconnect() {
        guard let peripheral = self.connectedPeripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func isConnected(to: UUID) -> Bool {
        guard let peripheral = self.connectedPeripheral else { return false }
        return peripheral.identifier == to
    }
    
    func isNearby(identifier: UUID) -> Bool {
        return self.peripherals.contains(where: { $0.id == identifier })
    }
    
    func configureWiFi(ssid: String, password: String) {
        guard let peripheral = self.connectedPeripheral else {
            print("not connected to any device")
            return
        }
        
        guard let data = ssid.data(using: .utf8) else { return }
        if let char = self.characteristics[Scanner.SERVICE_TRANSPORT_DISCOVERY.uuidString]?.first(where: { Scanner.CHAR_WIFI_SSID == $0.uuid }) {
            peripheral.writeValue(data, for: char, type: .withResponse)
        }
        
        guard let data = password.data(using: .utf8) else { return }
        if let char = self.characteristics[Scanner.SERVICE_TRANSPORT_DISCOVERY.uuidString]?.first(where: { Scanner.CHAR_WIFI_PASS == $0.uuid }) {
            peripheral.writeValue(data, for: char, type: .withResponse)
        }
        
        var value = Bool(true)
        let startData = Data(bytes: &value, count: 1)
        if let char = self.characteristics[Scanner.SERVICE_TRANSPORT_DISCOVERY.uuidString]?.first(where: { Scanner.CHAR_WIFI_START == $0.uuid }) {
            peripheral.writeValue(startData, for: char, type: .withResponse)
        }
        
    }
    
    // MARK: - CBCentralManagerDelegate funcs
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.connectedPeripheral = nil
        self.services.removeAll()
        self.characteristics.removeAll()
        self.objectWillChange.send()
    }
        
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[didConnect]: \(peripheral.identifier)")
        guard let deviceIndex = peripherals.firstIndex(where: { $0.id == peripheral.identifier }) else {
            print("unable to find device")
            return
        }
        
        // Update the device status
        print("[didConnect]: Updating device status")
        peripherals[deviceIndex].updateDeviceState(to: .connected)
        // Let any listeners to this class know we've updated the peripherals
        self.objectWillChange.send()

        // Add to list of connected devices
        print("[didConnect]: Set device as connected")
        self.connectedPeripheral = peripheral
        
        // Let scanner delegate know we've connected to a device
        print("[didConnect]: Notifying delegates")
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
        print("[didDiscover]: \(peripheral)")
        if !peripherals.contains(where: { $0.id == peripheral.identifier }) {
            
            if let name = peripheral.name {
                _cbScanned.append(peripheral)
                peripherals.append(
                    Device(
                        id: peripheral.identifier,
                        title: name
                    )
                )
                self.objectWillChange.send()
            }
        }
    }
    
    // MARK: - CBPeriperhalDelegate funcs
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("[didDiscoverServices]: \(peripheral.identifier)")
        if error != nil {
            print("[didDiscoverServices]: error - \(error?.localizedDescription ?? "N/A")")
            return
        }
        
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            self.services.append(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
        self.objectWillChange.send()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            print(characteristic)
            self.characteristics[service.uuid.uuidString] = characteristics
            if characteristic.uuid == Scanner.CHAR_WIFI_STATUS {
                peripheral.setNotifyValue(true, for: characteristic)
            } else {
                peripheral.readValue(for: characteristic)
            }
        }
        
        self.objectWillChange.send()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("[didWriteValueFor]: \(String(describing: error))")
        }
        
        print("[didWriteValueFor]: \(peripheral) | \(characteristic)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let charUUID = characteristic.uuid
        if characteristic.uuid == Scanner.CHAR_WIFI_STATUS {
            guard let value = characteristic.value else { return }
            let oldValue = self.characteristicValues[charUUID]
            
            let byteArray = [UInt8](value)
            if (byteArray[0] == 3) {
                self.characteristicValues[charUUID] = "CONNECTED";
            } else if (byteArray[0] == 6) {
                self.characteristicValues[charUUID] = "CONNECTING"
            } else {
                self.characteristicValues[charUUID] = "DISCONNECTED"
            }
                
            // Print out old & new value for debugging
            if oldValue != nil && oldValue != self.characteristicValues[charUUID] {
                print("[didWriteValueFor]: characteristic \(charUUID) updated from: \(oldValue!) to \(self.characteristicValues[charUUID]!)")
            }
        } else {
            guard let value = characteristic.value else { return }
            self.characteristicValues[charUUID] = String(data: value, encoding: String.Encoding.utf8)
        }
        
        let serviceUUID = characteristic.service.uuid.uuidString 
        guard let charIndex = self.characteristics[serviceUUID]?.firstIndex(where: { $0.uuid == characteristic.uuid }) else {
            return
        }
        
        self.characteristics[serviceUUID]?[charIndex] = characteristic
        self.objectWillChange.send()
    }
}
