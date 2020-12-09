//
//  BLEManager.swift
//  Contact_Tracing
//
//  Created by Haider Tariq on 10/23/20.
//

import Foundation
import CoreBluetooth
import os
import UIKit

class CentralController: NSObject, ObservableObject, CBCentralManagerDelegate {
    
    private var centralManager: CBCentralManager!
    
    private var dbHelper: DBHelper = DBHelper()
    
    private var initTimeMap = [String : Double]()   // Keeps track of when the device was first seen
    private var lastTimeMap = [String : Double]()   // keeps track of when the device was last seen. keeps update for every new seen
    private var distanceMap = [String : Array<Double>]() //keeps track of distances obtained from the subsequent calls to :didDiscover method
    
    // KEEP MIN_EXPOSURE_TIME < DISAPPEAR TIME
    // difference between last seen time and first seen map to get into the database
    private final let MIN_EXPOSURE_TIME = 15.0 //second
    
    //difference between current time and last seen time for the device to be not in the periphery
    private final let DISAPPEAR_TIME = 20.0 //second
    
    // avg. distance to be considered the exposure
    private final let MIN_EXPOSURE_DISTANCE = 6.0 //feet
    
    @Published var isSwitchedOn = false
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
            centralManager.scanForPeripherals(withServices: [TransferService.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]) // Scans until told to stop
            os_log("Central: Started Scanning")
        }
        
        else {
            isSwitchedOn = false
            centralManager.stopScan()
            os_log("Central: Stopped Scanning")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        var removeTokens = Array<String>()
        for (token, lastSeenTime) in lastTimeMap {
            if (Date().timeIntervalSince1970 - lastSeenTime > DISAPPEAR_TIME) {
                print("LOST DEVICE:", token)
                initTimeMap.removeValue(forKey: token)
                distanceMap.removeValue(forKey: token)
                removeTokens.append(token)
            }
        }
        
        for toRemove in removeTokens {
            lastTimeMap.removeValue(forKey: toRemove)
            print("REMOVING:", toRemove)
        }
        
        print("RSSI:", RSSI)
        let distanceInFeet = pow(10, (-56.0 - Double(RSSI.intValue))/(20.0)) * 3.2808
        print("Distance %d in feet", distanceInFeet)
        
        let token = peripheral.name!
        
        let time = Date().timeIntervalSince1970
        print("UnixTime", time)
        
        dbHelper.deleteOldData(currentUnixTime: time) // Use this call to release delete old data.
        
        if (initTimeMap[token] == nil) {
            initTimeMap[token] = time
            print("New token found", token)
            distanceMap[token] = Array(arrayLiteral: distanceInFeet)
        } else {
            lastTimeMap[token] = time
            print("Old token found", token)
            distanceMap[token]!.append(distanceInFeet)
        }
        
        if (initTimeMap[token] != nil && lastTimeMap[token] != nil) {
            let exposureTime = lastTimeMap[token]! - initTimeMap[token]!
            
            print("Exposure Time:",  exposureTime)
            
            let averageDistance = distanceMap[token]!.reduce(0.0) {
                return $0 + $1/Double(distanceMap[token]!.count)
            }
            
            print("Average Distance:",  averageDistance)
            
            if (exposureTime != nil && averageDistance != nil) {
                if (exposureTime > MIN_EXPOSURE_TIME && averageDistance < MIN_EXPOSURE_DISTANCE) {
                    dbHelper.insert(ID: token, startTime: initTimeMap[token]! , endTime: lastTimeMap[token]!, avgDistance: averageDistance)
                }
            }
        }
        
        print("\n")
    }
    
    func getDB() -> DBHelper {
        return self.dbHelper
    }
}
