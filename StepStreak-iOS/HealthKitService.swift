//
//  HealthKitService.swift
//  StepStreak-iOS
//
//  Created by Mohamad Alhaj Rahmoun on 09/07/2023.
//

import Foundation
import HealthKit

class HealthKitService {
    let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let allTypes = Set([HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                            HKObjectType.quantityType(forIdentifier: .stepCount)!])
        
        healthStore.requestAuthorization(toShare: [], read: allTypes) { (success, error) in
            completion(success, error)
        }
    }
    


    func getStepsCount(startTime: Date, endTime: Date, completion: @escaping ([Date: Int32]?, Error?) -> Void) {
        guard let steps = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(nil, nil)
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: endTime, options: .strictStartDate)

        var interval = DateComponents()
        interval.day = 1

        let query = HKStatisticsCollectionQuery(quantityType: steps,
                                                quantitySamplePredicate: predicate,
                                                options: [.cumulativeSum],
                                                anchorDate: startTime,
                                                intervalComponents: interval)

        query.initialResultsHandler = { query, results, error in
            if let error = error {
                completion(nil, error)
            } else if let results = results {
                var stepsByDate = [Date: Int32]()

                results.enumerateStatistics(from: startTime, to: endTime) { statistics, _ in
                    if let quantity = statistics.sumQuantity() {
                        let date = statistics.startDate
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        stepsByDate[date] = Int32(steps)
                    }
                }

                completion(stepsByDate, nil)
            }
        }

        healthStore.execute(query)
    }

    func getCalories(startTime: Date, endTime: Date, completion: @escaping ([Date: Double]?, Error?) -> Void) {
        guard let calories = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(nil, nil)
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: endTime, options: .strictStartDate)

        var interval = DateComponents()
        interval.day = 1

        let query = HKStatisticsCollectionQuery(quantityType: calories,
                                                quantitySamplePredicate: predicate,
                                                options: [.cumulativeSum],
                                                anchorDate: startTime,
                                                intervalComponents: interval)

        query.initialResultsHandler = { query, results, error in
            if let error = error {
                completion(nil, error)
            } else if let results = results {
                var stepsByDate = [Date: Double]()

                results.enumerateStatistics(from: startTime, to: endTime) { statistics, _ in
                    if let quantity = statistics.sumQuantity() {
                        let date = statistics.startDate
                        let steps = quantity.doubleValue(for: HKUnit.kilocalorie())
                        stepsByDate[date] = steps
                    }
                }

                completion(stepsByDate, nil)
            }
        }

        healthStore.execute(query)
    }
        
    func getDistance(startTime: Date, endTime: Date, completion: @escaping ([Date: Double]?, Error?) -> Void) {
        guard let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(nil, nil)
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: endTime, options: .strictStartDate)

        var interval = DateComponents()
        interval.day = 1

        let query = HKStatisticsCollectionQuery(quantityType: distance,
                                                quantitySamplePredicate: predicate,
                                                options: [.cumulativeSum],
                                                anchorDate: startTime,
                                                intervalComponents: interval)

        query.initialResultsHandler = { query, results, error in
            if let error = error {
                completion(nil, error)
            } else if let results = results {
                var stepsByDate = [Date: Double]()

                results.enumerateStatistics(from: startTime, to: endTime) { statistics, _ in
                    if let quantity = statistics.sumQuantity() {
                        let date = statistics.startDate
                        let steps = quantity.doubleValue(for: HKUnit.meter())
                        stepsByDate[date] = steps
                    }
                }

                completion(stepsByDate, nil)
            }
        }

        healthStore.execute(query)
    }
}
