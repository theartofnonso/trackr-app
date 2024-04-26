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
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        let keys = message.keys
        
        if keys.contains(Constants.SESSION_NAME) {
            DispatchQueue.main.async {
                self.sessionName = message[Constants.SESSION_NAME] as! String
            }
        }
        
        if keys.contains(Constants.EXERCISE_LOG_ID) && keys.contains(Constants.SET_INDEX) {
            DispatchQueue.main.async {
                self.isAnalysing = !self.isAnalysing
            }
            
            let exerciseLogId = message[Constants.EXERCISE_LOG_ID] as! String
            let setIndex = message[Constants.SET_INDEX] as! Int
            
            // Run HeartRate query and calculate avg velocity from accelerometer
            
            sendBpmAndSpeed(exerciseLogId: exerciseLogId, setIndex: setIndex, bpm: Int.random(in: 50...60), speed: Int.random(in: 1...10))
            
            DispatchQueue.main.async {
                self.isAnalysing = !self.isAnalysing
            }
            
            print("Watch has received request for set intensity index \(setIndex)")
        }
        
        if keys.contains(Constants.END_SESSION) {
            DispatchQueue.main.async {
                self.isAnalysing = false
                self.sessionName = Constants.NO_SESSION
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
            print([Constants.EXERCISE_LOG_ID: exerciseLogId,
                   Constants.SET_INDEX: setIndex,
                   Constants.BPM: bpm,
                   Constants.SPEED: speed])
            watchSession.sendMessage([Constants.EXERCISE_LOG_ID: exerciseLogId,
                                      Constants.SET_INDEX: setIndex,
                                      Constants.BPM: bpm,
                                      Constants.SPEED: speed], replyHandler: nil, errorHandler: nil)
            DispatchQueue.main.async {
                self.isAnalysing = !self.isAnalysing
            }
        }
    }
}
