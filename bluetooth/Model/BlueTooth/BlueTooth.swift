//
//  BluetoothServices.swift
//  BlueLightTest
//
//  Created by imac-3282 on 2023/7/31.
//

import Foundation
import CoreBluetooth

class BluetoothServices: NSObject {
    
    // MARK: - Variables
    
    static let shared = BluetoothServices()
    
    var central: CBCentralManager?
    var peripheral: CBPeripheralManager?
    
    var connectedPeripheral: CBPeripheral?
    var rxtxCharacteristic: CBCharacteristic?
    
    var buffer: [Data] = []
    var shouldAutoReconnect = true
    let dataQueue = DispatchQueue(label: "com.bluetooth.dataQueue")
    
    weak var delegate: BluetoothServicesDelegate?
    
    private var blePeripherals: [CBPeripheral] = []
    
    ///  初始化：副線程
    private override init() {
        super.init()
        
        let queue = DispatchQueue.global()
        central = CBCentralManager(delegate: self, queue: queue)
    }
    
    // MARK: - Buffer and Queue Methods

    /// 將數據添加到緩衝區
    /// - Parameter data: 要添加的數據
    func addToBuffer(_ data: Data) {
        dataQueue.async {
            self.buffer.append(data)
        }
    }

    /// 從緩衝區取出數據並發送
    func sendDataFromBuffer() {
        dataQueue.async {
            guard !self.buffer.isEmpty else {
                return
            }
            
            // 從緩衝區取出第一個數據項
            let data = self.buffer.removeFirst()
            
            // 發送數據
            if let characteristic = self.rxtxCharacteristic {
                self.writeCharacteristic(characteristic, value: data)
            }
        }
    }

    /// 寫入特徵值
    /// - Parameters:
    ///   - characteristic: 要寫入的特徵
    ///   - value: 要寫入的數據
    func writeCharacteristic(_ characteristic: CBCharacteristic, value: Data) {
        connectedPeripheral?.writeValue(value, for: characteristic, type: .withResponse)
    }
    
    // MARK: - UI Settings
    
    /// 掃描藍芽裝置
    func startScan() {
        central?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    /// 停止掃描
    func stopScan() {
        central?.stopScan()
    }
    
    /// 連接藍牙週邊設備
    /// - Parameters:
    ///   - peripheral: 要連接的藍牙周邊設備
    func connectPeripheral(peripheral: CBPeripheral) {
        self.connectedPeripheral = peripheral
        
        central?.connect(peripheral, options: nil)
    }
    
    /// 中斷與藍芽週邊設備的連接
    /// - Parameters:
    ///   - peripheral: 要中斷連接的藍牙周邊設備
    func disconnectPeripheral(peripheral: CBPeripheral) {
        central?.cancelPeripheralConnection(peripheral)
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothServices: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            print("poweredOn")
        @unknown default:
            print("藍芽裝置未知狀態")
        }
        
        startScan()
    }
    
    /// 發現裝置
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber,
                        error: Error?) {
        for newPeripheral in blePeripherals {
            if peripheral.name == newPeripheral.name {
                return
            }
        }
        
        if let name = peripheral.name {
            blePeripherals.append(peripheral)
            print(name)
        }
        
        if error == nil {
            print("成功斷開藍牙連線")
        } else {
            print("斷開藍牙連線時發生錯誤: \(error!.localizedDescription)")
        }
        
        delegate?.getBLEPeripherals(peripherals: blePeripherals)
    }
    
    /// 連接裝置
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        delegate?.didUpdateConnectionStatus("Connected")
    }
    
    /// 讀取特徵值
    /// - Parameters:
    ///   - characteristic: 要讀取的特徵
    func readCharacteristic(_ characteristic: CBCharacteristic) {
        connectedPeripheral?.readValue(for: characteristic)
    }

    
}

// MARK: - CBPeripheralDelegate

extension BluetoothServices: CBPeripheralDelegate {
    
    /// 發現服務
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                print(service)
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    /// 服務更改
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
    }
    
    /// 發現對應服務的特徵
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print(characteristic)
                if characteristic.uuid.isEqual(CBUUID(string: "FFE1")) {
                    rxtxCharacteristic = characteristic
                    peripheral.readValue(for: characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                   
                }
            }
        }
    }
    
    /// 寫入操作完成
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed to write for characteristic: \(characteristic), with error: \(error)")
            return
        }
        
        print("Successfully wrote value for characteristic: \(characteristic)")
    }
    
    /// 特徵值變更
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard characteristic == rxtxCharacteristic,
              let characteristicValue = characteristic.value,
              let ASCIIstring = String(data: characteristicValue,
                                       encoding: String.Encoding.utf8) else {
            return
        }
        let characteristicASCIIValue = Character(ASCIIstring)
        
        delegate?.getBlEPeripheralValue(value: characteristicASCIIValue.asciiValue!)
    }
}

// MARK: - CBPeripheralManagerDelegate

extension BluetoothServices: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        guard peripheral.state == .poweredOn else {
            return
        }
        
        switch peripheral.state {
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            print("poweredOn")
        @unknown default:
            print("藍芽裝置未知狀態")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if shouldAutoReconnect {
            print("Connection lost. Attempting to reconnect.")
            connectPeripheral(peripheral: peripheral)
        } else {
            print("Disconnected from peripheral: \(peripheral)")
        }
        
        delegate?.didUpdateConnectionStatus("Disconnected")
    }

}

// MARK: - Protocol

protocol BluetoothServicesDelegate: NSObjectProtocol {
    
    /// 取得藍牙週邊設備
    /// - Parameters:
    ///   - peripherals: 取得的所有藍牙周邊設備
    func getBLEPeripherals(peripherals: [CBPeripheral])
    
    func getBlEPeripheralValue(value: UInt8)
    
    func didUpdateConnectionStatus(_ status: String)
}
