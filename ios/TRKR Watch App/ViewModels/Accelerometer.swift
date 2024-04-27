//
//  Accelerometer.swift
//  TRKRWear Watch App
//
//  Created by Nonso Emmanuel Biose on 18/04/2024.
//

import Foundation
import CoreMotion

class Accelerometer: ObservableObject {
    
    @Published var primaryAxis: String = "Unknown"
    @Published var speed: Double = 0.0
    
    private var motionManager = CMMotionManager()
    
    private var lastAcceleration: CMAcceleration = CMAcceleration(x: 0, y: 0, z: 0)
    private var lastUpdateTime: TimeInterval = Date().timeIntervalSince1970
    
    func startAccelerometerUpdates() {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let strongSelf = self, let acceleration = data?.acceleration else { return }
            strongSelf.processAcceleration(acceleration)
        }
    }
    
    private func processAcceleration(_ acceleration: CMAcceleration) {
        let currentTime = Date().timeIntervalSince1970
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Calculate speed based on acceleration change and time interval
        let speedX = abs((acceleration.x - lastAcceleration.x) / deltaTime)
        let speedY = abs((acceleration.y - lastAcceleration.y) / deltaTime)
        let speedZ = abs((acceleration.z - lastAcceleration.z) / deltaTime)
        
        // Determine primary axis of movement
        if speedX > speedY && speedX > speedZ {
            primaryAxis = "X"
            speed = speedX
        } else if speedY > speedX && speedY > speedZ {
            primaryAxis = "Y"
            speed = speedY
        } else if speedZ > speedX && speedZ > speedY {
            primaryAxis = "Z"
            speed = speedZ
        }
        
        // Update last acceleration values
        lastAcceleration = acceleration
    }
}
