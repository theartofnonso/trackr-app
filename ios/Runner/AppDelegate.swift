import UIKit
import Flutter
import WatchConnectivity

// This extension of Error is required to do use FlutterError in any Swift code.
extension FlutterError: Error {}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, WCSessionDelegate, DataHostApi {
    
    func getHeartRate() throws {
        let watchSession = WCSession.default
        let isAvailable = watchSession.isPaired && watchSession.isReachable
        
        if isAvailable {
            watchSession.sendMessage(["data": "HEARTRATE"], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func getVelocity() throws {
        let watchSession = WCSession.default
        let isAvailable = watchSession.isPaired && watchSession.isReachable
        
        if isAvailable {
            watchSession.sendMessage(["data": "VELOCITY"], replyHandler: nil, errorHandler: nil)
        }
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let message = message["message"] ?? ""
        print("Message contaning heart rate: \(message)")
        DispatchQueue.main.async {
            
            // Get binaryMessenger
            let rootViewController = self.window.rootViewController
            let binaryMessenger = rootViewController as! FlutterBinaryMessenger
            
            DataFlutterWrapperApi(binaryMessenger: binaryMessenger).heartRate(bpm: 0)
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
