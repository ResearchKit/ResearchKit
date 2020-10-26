/*
Copyright (c) 2020, Helio Tejedor. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3.  Neither the name of the copyright holder(s) nor the names of any contributors
may be used to endorse or promote products derived from this software without
specific prior written permission. No license is granted to the trademarks of
the copyright holders even if such marks are included in this software.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import Combine
import ResearchKit
import SwiftUI

class SampleService: ObservableObject {
    
    var store = HKHealthStore()
    
    @Published var authorized: Bool = false
    @Published var enrolled: Bool = false
    @Published var hideData: Bool = false
    @Published var askPassword: Bool = false

    @Published var dateOfBirthComponents: DateComponents?
    @Published var height: HKQuantity?
    @Published var bodyMass: HKQuantity?

    let healthDataItemsToShare: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.workoutType()
    ]

    let healthDataItemsToRead: Set<HKObjectType> = [
        HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
        HKObjectType.quantityType(forIdentifier: .height)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
    ]
    
    init() {
        self.enrolled = ORKPasscodeViewController.isPasscodeStoredInKeychain()
        if self.enrolled {
            store.getRequestStatusForAuthorization(toShare: healthDataItemsToShare, read: healthDataItemsToRead) {status, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                switch status {
                case .shouldRequest, .unknown:
                    self.requestAuthorization()
                case .unnecessary:
                    break
                @unknown default:
                    print("Oh - interesting: I received an unexpected new value.")
                }
            }
        }
    }
    
    func requestAuthorization() {
        store.requestAuthorization(toShare: healthDataItemsToShare, read: healthDataItemsToRead) { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.authorized = result
            }
        }
    }

    func updateProfileData() {
        dateOfBirthComponents = try? store.dateOfBirthComponents()
        
        let heightType = HKObjectType.quantityType(forIdentifier: .height)!
        let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass)!

        
        let timeSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let heightQuery = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: [timeSortDescriptor]) { _, samples, _ in
            DispatchQueue.main.async {
                self.height = (samples?.first as? HKQuantitySample)?.quantity
            }
        }
        store.execute(heightQuery)

        let bodyMassQuery = HKSampleQuery(sampleType: bodyMassType, predicate: nil, limit: 1, sortDescriptors: [timeSortDescriptor]) { _, samples, _ in
            DispatchQueue.main.async {
                self.bodyMass = (samples?.first as? HKQuantitySample)?.quantity
            }
        }
        store.execute(bodyMassQuery)
    }

    func scenePhaseChanged(to scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            askPassword = enrolled && hideData
        case .inactive:
            break
        case .background:
            hideData = enrolled
        @unknown default:
            print("Oh - interesting: I received an unexpected new value.")
        }
    }
    
    func enrollStudy() {
        //TODO: Not proud of this solution
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.enrolled = ORKPasscodeViewController.isPasscodeStoredInKeychain() // Just double-check
        }
    }

    func leaveStudy() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.enrolled = false
        }
    }

    func unlock() {
        askPassword = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hideData = false
        }
    }
}
