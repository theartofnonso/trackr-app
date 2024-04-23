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
    
    @Published var sessionName: String = "No session"
    
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
        
        if keys.contains("sessionName") {
            sessionName = message["sessionName"] as! String
        }
        
        if keys.contains("exerciseLogId") && keys.contains("setIndex") {
            exerciseLogId = message["exerciseLogId"] as! String
            setIndex = message["setIndex"] as! Int
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
            watchSession.sendMessage(["exerciseLogId": exerciseLogId, "setIndex": setIndex, "bpm": bpm, "speed": speed], replyHandler: nil, errorHandler: nil)
            DispatchQueue.main.async {
                self.isAnalysing = !self.isAnalysing
            }
        }
    }
}
