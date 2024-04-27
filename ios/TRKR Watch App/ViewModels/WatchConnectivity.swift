//
//  WatchConnectivityProvider.swift
//  TRKRWear Watch App
//
//  Created by Nonso Emmanuel Biose on 02/04/2024.
//

import Foundation
import WatchConnectivity

class WatchConnectivity: NSObject, ObservableObject, WCSessionDelegate {
    
    @Published var isAnalysing: Bool = false
    
    @Published var sessionName: String = Constants.NO_SESSION
    
    private var setStartDate = Date.now
    
    let heartRateMonitor: HeartRateMonitor = HeartRateMonitor()
    
    private let accelerometer: Accelerometer = Accelerometer()
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
    
    //    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    //
    //        let keys = message.keys
    //
    //        if keys.contains(Constants.SESSION_NAME) {
    //            DispatchQueue.main.async { [self] in
    //                sessionName = message[Constants.SESSION_NAME] as! String
    //            }
    //        }
    //
    //        if keys.contains(Constants.EXERCISE_LOG_ID) && keys.contains(Constants.SET_INDEX) {
    //
    //            let exerciseLogId = message[Constants.EXERCISE_LOG_ID] as! String
    //            let setIndex = message[Constants.SET_INDEX] as! Int
    //
    //            accelerometer.stop()
    //
    //            print("Set start date: \(setStartDate)")
    //
    //            heartRateMonitor.queryHeartRate(from: setStartDate) { bpm in
    //
    //                DispatchQueue.main.async { [self] in
    //
    //                    sendBpmAndSpeed(exerciseLogId: exerciseLogId, setIndex: setIndex, bpm: bpm, speed: Int(accelerometer.speed))
    //
    //                    isAnalysing = false
    //                }
    //            }
    //        }
    //
    //        if keys.contains(Constants.END_SESSION) {
    //            DispatchQueue.main.async { [self] in
    //                isAnalysing = false
    //                sessionName = Constants.NO_SESSION
    //            }
    //        }
    //
    //    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            if let sessionName = message[Constants.SESSION_NAME] as? String {
                strongSelf.sessionName = sessionName
            }
            
            if let exerciseLogId = message[Constants.EXERCISE_LOG_ID] as? String,
               let setIndex = message[Constants.SET_INDEX] as? Int {
                strongSelf.analyseSet(exerciseLogId: exerciseLogId, setIndex: setIndex)
            }
            
            if message.keys.contains(Constants.END_SESSION) {
                strongSelf.isAnalysing = false
                strongSelf.sessionName = Constants.NO_SESSION
            }
        }
    }
    
    private func analyseSet(exerciseLogId: String, setIndex: Int) {
        accelerometer.stop()
        print("Set start date: \(setStartDate)")
        
        heartRateMonitor.queryHeartRate(from: setStartDate) { [weak self] bpm in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                strongSelf.sendBpmAndSpeed(exerciseLogId: exerciseLogId, setIndex: setIndex, bpm: bpm, speed: Int(strongSelf.accelerometer.speed))
                strongSelf.isAnalysing = false
            }
        }
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
#endif
    
    func sendBpmAndSpeed(exerciseLogId: String, setIndex: Int, bpm: Int, speed: Int) {
        let watchSession = WCSession.default
        let isAvailable = watchSession.isReachable
        if isAvailable {
            watchSession.sendMessage([Constants.EXERCISE_LOG_ID: exerciseLogId,
                                      Constants.SET_INDEX: setIndex,
                                      Constants.BPM: bpm,
                                      Constants.SPEED: speed], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func startAnalysis() {
        accelerometer.start()
        setStartDate = Date.now
    }
    
    func stopAnalysis() {
        accelerometer.stop()
    }
}
