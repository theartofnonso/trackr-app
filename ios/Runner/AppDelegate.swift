import UIKit
import WatchConnectivity

// This extension of Error is required to do use FlutterError in any Swift code.
extension FlutterError: Error {}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, WCSessionDelegate, DataHostApi {
    
    
    func syncSession(sessionName: String) throws {
        let watchSession = WCSession.default
        let isAvailable = watchSession.isPaired && watchSession.isReachable
        
        if isAvailable {
            watchSession.sendMessage(["sessionName": sessionName], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func getBpmAndSpeed(exerciseLogId: String, setIndex: Int64) throws {
        let watchSession = WCSession.default
        let isAvailable = watchSession.isPaired && watchSession.isReachable
        
        if isAvailable {
            watchSession.sendMessage(["exerciseLogId": exerciseLogId, "setIndex": setIndex], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let exerciseLogId = message["exerciseLogId"] as! String
        let setIndex = message["setIndex"] as! Int
        let bpm = message["bpm"] as! Int
        let speed = message["speed"] as! Int
        
        print("Data contaning heart rate: \(message)")
        
        DispatchQueue.main.async {
            
            // Get binaryMessenger
            let rootViewController = self.window.rootViewController
            let binaryMessenger = rootViewController as! FlutterBinaryMessenger
            
            DataFlutterApiImpl(binaryMessenger: binaryMessenger).bpmAndSpeed(exerciseLogId: exerciseLogId, setIndex: setIndex, bpm: bpm, speed: speed)
        }
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        GeneratedPluginRegistrant.register(with: self)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        
        let rootViewController = window.rootViewController
        
        // Get binaryMessenger
        let binaryMessenger = rootViewController as! FlutterBinaryMessenger
        
        DataHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
