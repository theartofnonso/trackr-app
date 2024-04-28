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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        print("WCSession activated with state: \(activationState)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        let keys = message.keys
        
        if keys.contains(Constants.SESSION_NAME) {
            DispatchQueue.main.async { [self] in
                sessionName = message[Constants.SESSION_NAME] as! String
            }
        }
        
        if keys.contains(Constants.EXERCISE_LOG_ID) && keys.contains(Constants.SET_INDEX) {
            
            let exerciseLogId = message[Constants.EXERCISE_LOG_ID] as! String
            let setIndex = message[Constants.SET_INDEX] as! Int
            
            accelerometer.stop()
            
            DispatchQueue.main.async { [self] in
                
                replyHandler([Constants.EXERCISE_LOG_ID: exerciseLogId,
                              Constants.SET_INDEX: setIndex,
                              Constants.BPM: 0,
                              Constants.SPEED: Int(accelerometer.speed)])
                
                isAnalysing = false
            }
        }
        
        if keys.contains(Constants.END_SESSION) {
            DispatchQueue.main.async { [self] in
                isAnalysing = false
                sessionName = Constants.NO_SESSION
            }
        }
        
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
#endif
    
    func startAnalysis() {
        accelerometer.start()
        setStartDate = Date.now
    }
    
    func stopAnalysis() {
        accelerometer.stop()
    }
}
