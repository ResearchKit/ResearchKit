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

import ResearchKitActiveTask
import Testing

@Suite(.tags(.serialization))
struct ORKAccuracyStroopResultSerializationTests {
    @Test
    func testORKAccuracyStroopResult() throws {
        let instance = ORKAccuracyStroopResult(identifier: "id")
        
        instance.colorSelected = "green"
        instance.color = "orange"
        instance.userInfo = ["key": "value"]
        instance.text = "text"
        
        let currentDate = Date(timeIntervalSince1970: 1234567)
        let currentDateString = ORKStringFromDateISO8601(currentDate)

        instance.startDate = currentDate
        instance.endDate = currentDate
        
        instance.distanceToClosestCenter = 2.0
        instance.startTime = 2.0
        instance.endTime = 3.0
        instance.timeTakenToSelect = 4.0
        
        let expectation = """
        {
          "_class" : "ORKAccuracyStroopResult",
          "color" : "orange",
          "colorSelected" : "green",
          "didSelectCorrectColor" : false,
          "distanceToClosestCenter" : 2,
          "endDate" : "\(currentDateString)",
          "endTime" : 3,
          "identifier" : "id",
          "startDate" : "\(currentDateString)",
          "startTime" : 2,
          "text" : "text",
          "timeTakenToSelect" : 4,
          "userInfo" : {
            "key" : "value"
          }
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKAccuracyStroopResultWithCorrectSelectedColor() throws {
        let instance = ORKAccuracyStroopResult(identifier: "id")
        
        instance.colorSelected = "green"
        instance.color = "green"
        instance.userInfo = ["key": "value"]
        instance.text = "text"
        
        let currentDate = Date(timeIntervalSince1970: 1234567)
        let currentDateString = ORKStringFromDateISO8601(currentDate)

        instance.startDate = currentDate
        instance.endDate = currentDate
        
        instance.distanceToClosestCenter = 2.0
        instance.startTime = 2.0
        instance.endTime = 3.0
        instance.timeTakenToSelect = 4.0
        
        let expectation = """
        {
          "_class" : "ORKAccuracyStroopResult",
          "color" : "green",
          "colorSelected" : "green",
          "didSelectCorrectColor" : true,
          "distanceToClosestCenter" : 2,
          "endDate" : "\(currentDateString)",
          "endTime" : 3,
          "identifier" : "id",
          "startDate" : "\(currentDateString)",
          "startTime" : 2,
          "text" : "text",
          "timeTakenToSelect" : 4,
          "userInfo" : {
            "key" : "value"
          }
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}
