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
struct ORKPSATResultSerializationTests {
    @Test
    func testORKPSATResult() throws {
        let instance = ORKPSATResult(identifier: "id")
        instance.presentationMode = .visual
        instance.interStimulusInterval = 2.0
        instance.stimulusDuration = 2.0
        instance.length = 2
        instance.totalCorrect = 2
        instance.totalDyad = 2
        instance.totalTime = 2
        instance.initialDigit = 2
        instance.samples = [
            ORKPSATSample()
        ]

        
        let currentDate = Date(timeIntervalSince1970: 1234567)
        let currentDateString = ORKStringFromDateISO8601(currentDate)

        instance.userInfo = ["key": "value"]
        instance.startDate = currentDate
        instance.endDate = currentDate

        let expectation = """
        {
          "_class" : "ORKPSATResult",
          "endDate" : "\(currentDateString)",
          "identifier" : "id",
          "initialDigit" : 2,
          "interStimulusInterval" : 2,
          "length" : 2,
          "presentationMode" : 2,
          "samples" : [
            {
              "_class" : "ORKPSATSample",
              "answer" : 0,
              "correct" : false,
              "digit" : 0,
              "time" : 0
            }
          ],
          "startDate" : "\(currentDateString)",
          "stimulusDuration" : 2,
          "totalCorrect" : 2,
          "totalDyad" : 2,
          "totalTime" : 2,
          "userInfo" : {
            "key" : "value"
          }
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}
