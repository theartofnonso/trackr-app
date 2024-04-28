import UIKit
import WatchConnectivity

// This extension of Error is required to do use FlutterError in any Swift code.
extension FlutterError: Error {}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, WCSessionDelegate, DataHostApi {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func syncSession(sessionName: String) throws {
        let watchSession = WCSession.default
        let isAvailable = watchSession.isPaired && watchSession.isReachable
        
        if isAvailable {
            print("Can send")
            watchSession.sendMessage([Constants.SESSION_NAME: sessionName], replyHandler: { (reply) in
                print("Received reply: \(reply)")
            }, errorHandler: { (error) in
                print("Failed to send message: \(error.localizedDescription)")
            })
        }
    }
    
    func unSyncSession() throws {
        let watchSession = WCSession.default
        let isAvailable = watchSession.isPaired && watchSession.isReachable
        
        if isAvailable {
            watchSession.sendMessage([Constants.END_SESSION: Constants.END_SESSION], replyHandler: { (reply) in
                print("Received reply: \(reply)")
            }, errorHandler: { (error) in
                print("Failed to send message: \(error.localizedDescription)")
            })
        }
    }
    
    func isWatchSynced() throws -> Bool {
        let watchSession = WCSession.default
        let isAvailable = watchSession.isPaired && watchSession.isReachable
        return isAvailable
    }
    
    func getBpmAndSpeed(exerciseLogId: String, setIndex: Int64) throws {
        let watchSession = WCSession.default
        let isAvailable = watchSession.isPaired && watchSession.isReachable
        
        if isAvailable {
            watchSession.sendMessage([Constants.EXERCISE_LOG_ID: exerciseLogId, Constants.SET_INDEX: setIndex]) { message in
                let exerciseLogId = message[Constants.EXERCISE_LOG_ID] as? String ?? ""
                let setIndex = message[Constants.SET_INDEX] as? Int ?? -1
                let bpm = message[Constants.BPM] as? Int ?? 0
                let speed = message[Constants.SPEED] as? Int ?? 0
                
                print(message)
                // Get binaryMessenger
                
                DispatchQueue.main.async { [self] in
                    let rootViewController = self.window.rootViewController
                    let binaryMessenger = rootViewController as! FlutterBinaryMessenger
                    
                    DataFlutterApiImpl(binaryMessenger: binaryMessenger).bpmAndSpeed(exerciseLogId: exerciseLogId, setIndex: setIndex, bpm: bpm, speed: speed)
                }
                
            }
            
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
