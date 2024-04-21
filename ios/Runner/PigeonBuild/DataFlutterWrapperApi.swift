//
//  DataFlutterApi.swift
//  Runner
//
//  Created by Nonso Emmanuel Biose on 21/04/2024.
//

import Foundation

class DataFlutterWrapperApi {
    
    var flutterApi: DataFlutterApi
    
    init(binaryMessenger: FlutterBinaryMessenger) {
        self.flutterApi = DataFlutterApi(binaryMessenger: binaryMessenger)
    }
    
    func heartRate(bpm: Int64) {
        flutterApi.heartRate(bpm: bpm) {_ in
            // Do nothing
        }
    }
    
    func velocity(speed: Double) {
        flutterApi.velocity(speed: speed) {_ in
            // Do nothing
        }
    }
}
