//
//  HeartRateMonitor.swift
//  TRKRWear Watch App
//
//  Created by Nonso Emmanuel Biose on 15/04/2024.
//

import Foundation
import HealthKit


class HeartRateMonitor: ObservableObject {
    
    @Published var heartRate: Double = 0.0
    
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) async {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        let heartRateType = HKQuantityType(.heartRate)
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [heartRateType])
            completion(true)
        } catch {
            completion(false)
        }
        
    }
    
    func checkAuthorization(completion: @escaping (Bool) -> Void) async {
        
        if HKHealthStore.isHealthDataAvailable() {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    private func getHeartRatePredicate(from: Date) -> NSPredicate? {
        
        let calendar = NSCalendar.current
        
        let startDateComponents = calendar.dateComponents([.year, .month, .day], from: from)
        guard let startDate = calendar.date(from: startDateComponents) else {
            return nil
        }
        
        let endDateComponents = calendar.dateComponents([.year, .month, .day], from: Date.now)
        guard let endDate = calendar.date(from: endDateComponents) else {
            return nil
        }
        
        return HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
    }
    
    private func createHeartRateQuery(heartRatePredicate: NSPredicate) -> HKStatisticsQuery? {
        
        guard let heartRateQuantity = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            return nil
        }
        
        return HKStatisticsQuery(quantityType: heartRateQuantity, quantitySamplePredicate: heartRatePredicate, options: .discreteMax) { query, statistics, error in
            
            guard let statistics = statistics else {
                return
            }
            
            let maxHeartRate = statistics.maximumQuantity()
            
            self.heartRate = maxHeartRate?.doubleValue(for: .count()) ?? 0.0
        }
    }
    
    func queryHeartRate(from: Date, completion: @escaping () -> Void) {
        
        guard let predicate = getHeartRatePredicate(from: from) else {
            self.heartRate = 0.0
            return
        }
        
        guard let heartRateQuery = createHeartRateQuery(heartRatePredicate: predicate) else {
            self.heartRate = 0.0
            return
        }
        
        healthStore.execute(heartRateQuery)
        
    }
    
}
