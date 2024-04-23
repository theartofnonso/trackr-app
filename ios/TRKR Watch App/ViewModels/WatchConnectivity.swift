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
    
    var exerciseLogId: String = ""
    var setIndex: Int = 0
    
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
            exerciseLogId = message[Constants.EXERCISE_LOG_ID] as! String
            setIndex = message[Constants.SET_INDEX] as! Int
        }
        
        DispatchQueue.main.async {
            self.isAnalysing = !self.isAnalysing
        }
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
#endif
    
    func sendBpmAndSpeed(bpm: Int, speed: Int) {
        let watchSession = WCSession.default
        let isAvailable = watchSession.isReachable
        if isAvailable {
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
