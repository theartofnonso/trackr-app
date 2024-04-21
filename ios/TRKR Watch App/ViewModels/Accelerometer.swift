//
//  Accelerometer.swift
//  TRKRWear Watch App
//
//  Created by Nonso Emmanuel Biose on 18/04/2024.
//

import Foundation
import CoreMotion

class Accelerometer: ObservableObject {
    
    @Published var averageSpeed: Double = 0.0
    
    let motionManager = CMMotionManager()
    
    private var concentricStartTime: Date?
    
    private var speeds: [Double] = []
    
    func startAccelerometers() {
        // Make sure the accelerometer hardware is available.
        if self.motionManager.isAccelerometerAvailable {
            self.motionManager.accelerometerUpdateInterval = 1.0 / 50.0  // 50 Hz
            self.motionManager.startAccelerometerUpdates()
            
            let timer = Timer(fire: Date(), interval: (1.0/50.0), repeats: true, block: { timer in
                // Get the accelerometer data.
                if let data = self.motionManager.accelerometerData {
                    let x = data.acceleration.x
                    let y = data.acceleration.y
                    let z = data.acceleration.z
                    
                    // Use the accelerometer data in your app.
                }
            })
            
            
            // Add the timer to the current run loop.
            RunLoop.current.add(timer, forMode: .default)
        }
    }
    
    private func startAccelerometer() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 1.0 / 50.0 // 50 Hz
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (data, error) in
            guard let self = self, let acceleration = data?.acceleration.z else { return }
            
            self.process(acceleration: acceleration)
        }
    }
    
    private func process(acceleration: Double) {
        // Determine the start and end of the concentric phase
        // This example assumes positive acceleration as the concentric phase
        if acceleration > 0.5 { // Threshold value for starting the concentric phase
            if self.concentricStartTime == nil { // New repetition starting
                self.concentricStartTime = Date()
            }
        } else if acceleration < -0.5 && self.concentricStartTime != nil { // End of concentric phase
            if let start = self.concentricStartTime {
                let duration = Date().timeIntervalSince(start)
                let speed = 1.0 / duration // Speed is inverse of time for one repetition
                speeds.append(speed)
                averageSpeed = speeds.reduce(0, +) / Double(speeds.count)
                self.concentricStartTime = nil
            }
        }
    }
    
    deinit {
        motionManager.stopAccelerometerUpdates()
    }
    
}
