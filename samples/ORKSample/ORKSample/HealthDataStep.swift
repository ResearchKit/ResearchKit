/*
Copyright (c) 2015, Apple Inc. All rights reserved.

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

import ResearchKit
import HealthKit

class HealthDataStep: ORKInstructionStep {
    // MARK: Properties
    
    let healthDataItemsToRead: Set<HKObjectType> = [
        HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    ]
    
    let healthDataItemsToWrite: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
        HKObjectType.workoutType()
    ]
    
    // MARK: Initialization
    
    override init(identifier: String) {
        super.init(identifier: identifier)
        
        title = NSLocalizedString("Health Data", comment: "")
        text = NSLocalizedString("On the next screen, you will be prompted to grant access to read and write some of your general and health information, such as height, weight, and steps taken so you don't have to enter it again.", comment: "")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Convenience
    
    func getHealthAuthorization(_ completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            let error = NSError(domain: "com.example.apple-samplecode.ORKSample", code: 2, userInfo: [NSLocalizedDescriptionKey: "Health data is not available on this device."])
            
            completion(false, error)
            
            return
        }
        
        // Get authorization to access the data
        HKHealthStore().requestAuthorization(toShare: healthDataItemsToWrite, read: healthDataItemsToRead) { (success, error) -> Void in
            completion(success, error as NSError?)
        }
    }
}
