//
//  TransferService.swift
//  Contact_Tracing
//
//  Created by Haider Tariq on 10/23/20.
//

import Foundation
import CoreBluetooth

struct TransferService {
    // UUID of the bluetooth service the peripheral advertises and central scans for.
    // Android uses same UUID.
    static let serviceUUID = CBUUID(string: "00001234-0000-1000-8000-00805F9B34FB")
} 
