//
//  DataFlutterApi.swift
//  Runner
//
//  Created by Nonso Emmanuel Biose on 21/04/2024.
//

import Foundation

class DataFlutterApiImpl {
    
    var flutterApi: DataFlutterApi
    
    init(binaryMessenger: FlutterBinaryMessenger) {
        self.flutterApi = DataFlutterApi(binaryMessenger: binaryMessenger)
    }
    
    func bpmAndSpeed(exerciseLogId: String, setIndex: Int, bpm: Int, speed: Int) {
        flutterApi.bpmAndSpeed(exerciseLogId: exerciseLogId, setIndex: Int64(setIndex), bpm: Int64(bpm), speed: Int64(speed)) { _ in
            // Do nothing
        }
    }
}
