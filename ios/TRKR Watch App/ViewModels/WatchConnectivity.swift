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
        isAnalysing = !isAnalysing
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    #endif
    
    func sendMessage(message: [String:Int]) {
        let watchSession = WCSession.default
        let isAvailable = watchSession.isReachable
        if isAvailable {
            watchSession.sendMessage(["message": message], replyHandler: nil, errorHandler: nil)
            isAnalysing = !isAnalysing
        }
    }
}
