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

import Testing

@Suite(.tags(.serialization))
struct ORKPageResultSerializationTests {
    @Test
    func testORKPageResult() throws {
        let currentDevice = UIDevice.current
        let product = currentDevice.name
        let osVersion = currentDevice.systemVersion
        let osBuild = ""
        let platform = "iOS"
        let frameworkVersion = try #require(
            #bundle.infoDictionary?["CFBundleShortVersionString"] as? String
        )
        let bundleVersion = try #require(
            #bundle.infoDictionary?["CFBundleVersion"] as? String
        )

        let device = ORKDevice(
             product: product,
             osVersion: osVersion,
             osBuild: osBuild,
             platform: platform,
             researchKitVersion: frameworkVersion,
             researchKitBundleVersion: bundleVersion
        )
        
        let id = UUID()

        let instance = ORKPageResult(
            pageStep: ORKPageStep(identifier: "id"),
            stepResult: ORKStepResult(identifier: "id"),
            device: device, 
            uuid: id
        )

        let currentDate = Date(timeIntervalSince1970: 1234567)
        let currentDateString = ORKStringFromDateISO8601(currentDate)

        let result = ORKResult(identifier: "id")
        result.startDate = currentDate
        result.endDate = currentDate

        instance.results = [result]

        instance.userInfo = ["key": "value"]
        instance.startDate = currentDate
        instance.endDate = currentDate

        let expectation = """
        {
          "_class" : "ORKPageResult",
          "device" : {
            "_class" : "ORKDevice",
            "osBuild" : "\(osBuild)",
            "osVersion" : "\(osVersion)",
            "platform" : "\(platform)",
            "product" : "\(product)",
            "researchKitVersion" : "\(frameworkVersion)",
          "researchKitBundleVersion" : "\(bundleVersion)"
          },
          "endDate" : "\(currentDateString)",
          "identifier" : "id",
          "results" : [
            {
              "_class" : "ORKResult",
              "endDate" : "\(currentDateString)",
              "identifier" : "id",
              "startDate" : "\(currentDateString)"
            }
          ],
          "startDate" : "\(currentDateString)",
          "taskRunUUID" : "\(id)",
          "userInfo" : {
            "key" : "value"
          }
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKPageResultWithBasicInit() throws {

        let instance = ORKPageResult(
            pageStep: ORKPageStep(identifier: "id"),
            stepResult: ORKStepResult(identifier: "id")
        )

        let currentDate = Date(timeIntervalSince1970: 1234567)
        let currentDateString = ORKResultDateTimeFormatter().string(from: currentDate)

        let result = ORKResult(identifier: "id")
        result.startDate = currentDate
        result.endDate = currentDate

        instance.results = [result]

        instance.userInfo = ["key": "value"]
        instance.startDate = currentDate
        instance.endDate = currentDate

        let device = ORKDevice.current()
        let osVersion = try #require(device.osVersion)
        let platform = try #require(device.platform)
        let osBuild = device.osBuild ?? ""
        let product = device.product ?? ""

        let expectation = """
        {
          "_class" : "ORKPageResult",
          "device" : {
            "_class" : "ORKDevice",
            "osBuild" : "\(osBuild)",
            "osVersion" : "\(osVersion)",
            "platform" : "\(platform)",
            "product" : "\(product)"
          },
          "endDate" : "\(currentDateString)",
          "identifier" : "id",
          "results" : [
            {
              "_class" : "ORKResult",
              "endDate" : "\(currentDateString)",
              "identifier" : "id",
              "startDate" : "\(currentDateString)"
            }
          ],
          "startDate" : "\(currentDateString)",
          "taskRunUUID" : "\(instance.taskRunUUID)",
          "userInfo" : {
            "key" : "value"
          }
        }
        """
        try SerializationTestHelper.assertEquality(instance, expectation, skipStringComparison: true)
    }
}
