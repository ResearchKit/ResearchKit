/*
 Copyright (c) 2024, Apple Inc. All rights reserved.
 
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
import Testing

@Suite(.tags(.serialization))
struct ORKFamilyHistoryResultSerializationTests {
    @Test
    func testORKFamilyHistoryResult() throws {
        let instance = ORKFamilyHistoryResult(identifier: "id")
        instance.displayedConditions = [
            "condition"
        ]
        
        let frameworkVersion = try #require(#bundle.infoDictionary?["CFBundleShortVersionString"] as? String)
        let bundleVersion = try #require(#bundle.infoDictionary?["CFBundleVersion"] as? String)
        
        let device = ORKDevice(
            product: "ORK",
            osVersion: "17.0",
            osBuild: "1.0",
            platform: "iOS",
            researchKitVersion: frameworkVersion,
            researchKitBundleVersion: bundleVersion
        )

        let id = UUID()
        let result = ORKTaskResult(
            taskIdentifier: "id",
            taskRun: id,
            outputDirectory: nil,
            device: device
        )
        
        let currentDate = Date(timeIntervalSince1970: 1234567)
        let currentDateString = ORKStringFromDateISO8601(currentDate)

        result.startDate = currentDate
        result.endDate = currentDate

        instance.userInfo = ["key": "value"]
        instance.startDate = currentDate
        instance.endDate = currentDate
        
        instance.relatedPersons = [
            ORKRelatedPerson(
                identifier: "id",
                groupIdentifier: "group",
                identifierForCellTitle: "cell",
                taskResult: result
            )
        ]
        
        let expectation = """
        {
          "_class" : "ORKFamilyHistoryResult",
          "displayedConditions" : [
            "condition"
          ],
          "endDate" : "\(currentDateString)",
          "identifier" : "id",
          "relatedPersons" : [
            {
              "_class" : "ORKRelatedPerson",
              "groupIdentifier" : "group",
              "identifier" : "id",
              "identifierForCellTitle" : "cell",
              "taskResult" : {
                "_class" : "ORKTaskResult",
                "device" : {
                  "_class" : "ORKDevice",
                  "osBuild" : "1.0",
                  "osVersion" : "17.0",
                  "platform" : "iOS",
                  "product" : "ORK",
                  "researchKitVersion" : "\(frameworkVersion)",
                  "researchKitBundleVersion" : "\(bundleVersion)"
                },
                "endDate" : "\(currentDateString)",
                "identifier" : "id",
                "results" : [

                ],
                "startDate" : "\(currentDateString)",
                "taskRunUUID" : "\(id)"
              }
            }
          ],
          "startDate" : "\(currentDateString)",
          "userInfo" : {
            "key" : "value"
          }
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}
