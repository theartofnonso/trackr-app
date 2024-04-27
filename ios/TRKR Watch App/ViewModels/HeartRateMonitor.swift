//
//  HeartRateMonitor.swift
//  TRKRWear Watch App
//
//  Created by Nonso Emmanuel Biose on 15/04/2024.
//

import Foundation
import HealthKit

class HeartRateMonitor {
    
    private let healthStore = HKHealthStore()
    
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
    
    private func getHeartRatePredicate(from: Date) -> NSPredicate {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: from)
        return HKQuery.predicateForSamples(withStart: startDate, end: Date.now, options: [])
    }
    
    private func createHeartRateQuery(heartRatePredicate: NSPredicate, completion: @escaping (_ bpm: Int) -> Void) -> HKStatisticsQuery? {
        guard let heartRateQuantity = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            return nil
        }
        
        let unit = HKUnit(from: "count/max")
        return HKStatisticsQuery(quantityType: heartRateQuantity, quantitySamplePredicate: heartRatePredicate, options: .mostRecent) { _, statistics, error in
            guard let statistics = statistics, error == nil else {
                completion(0)
                return
            }
            let bpm = statistics.maximumQuantity()?.doubleValue(for: unit) ?? 0
            completion(Int(bpm))
        }
    }
    
    func queryHeartRate(from: Date, completion: @escaping (_ bpm: Int) -> Void) {
        let predicate = getHeartRatePredicate(from: from)
        
        guard let heartRateQuery = createHeartRateQuery(heartRatePredicate: predicate, completion: completion) else {
            return
        }
        
        healthStore.execute(heartRateQuery)
    }
    
    
}
