//
//  PeripheralManager.swift
//  Contact_Tracing
//
//  Created by Haider Tariq on 10/24/20.
//

import UIKit
import CoreBluetooth
import os

class PeripheralController: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    
    private var peripheralManager: CBPeripheralManager!
    private var email: String // User's verified email to broadcast
    
    init(email: String) {
        self.email = email
        super.init()
        
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil) // OS calls peripheralManagerDidUpdateState
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown:
            print("Bluetooth Device is UNKNOWN")
        case .unsupported:
            print("Bluetooth Device is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth Device is UNAUTHORIZED")
        case .resetting:
            print("Bluetooth Device is RESETTING")
        case .poweredOff:
            print("Bluetooth Device is POWERED OFF")
            peripheralManager.stopAdvertising()
            os_log("Stopped Advertising")
        case .poweredOn:
            print("Bluetooth Device is POWERED ON")
            setupPeripheral()
        @unknown default:
            print("Unknown State")
        }
    }
    
    private func setupPeripheral() {
        let transferService = CBMutableService(type: TransferService.serviceUUID, primary: true)
        peripheralManager.add(transferService)
        
        peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey: email.prefix(8), CBAdvertisementDataServiceUUIDsKey: [TransferService.serviceUUID]])
        print("Peripheral: Started Advertising", email.prefix(8))
    }
}
