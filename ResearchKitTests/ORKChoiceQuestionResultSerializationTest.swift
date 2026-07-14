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
struct ORKChoiceQuestionResultSerializationTests {
    @Test
    func testORKChoiceQuestionResult() throws {
        let instance = ORKChoiceQuestionResult(identifier: "")
        instance.choiceAnswers = []
        let startDate = Date(timeIntervalSinceReferenceDate: 0)
        let startDateString = ORKResultDateTimeFormatter().string(from: startDate)
        let endDate = Date(timeIntervalSinceReferenceDate: 60 * 60 * 24)
        let endDateString = ORKResultDateTimeFormatter().string(from: endDate)
        instance.startDate = startDate
        instance.endDate = endDate
        let expectation =
        """
        {
          "_class" : "ORKChoiceQuestionResult",
          "choiceAnswers" : [

          ],
          "endDate" : "\(endDateString)",
          "identifier" : "",
          "questionType" : 0,
          "startDate" : "\(startDateString)"
        }
        """


        try SerializationTestHelper.assertEquality(instance, expectation)

    }
    
    @Test
    func testORKBooleanQuestionResultWithDontKnowAnswer() throws {
        let instance = ORKChoiceQuestionResult(identifier: "")
        instance.noAnswerType = ORKDontKnowAnswer.answer()
        let startDate = Date(timeIntervalSinceReferenceDate: 0)
        let startDateString = ORKResultDateTimeFormatter().string(from: startDate)
        let endDate = Date(timeIntervalSinceReferenceDate: 60 * 60 * 24)
        let endDateString = ORKResultDateTimeFormatter().string(from: endDate)
        instance.startDate = startDate
        instance.endDate = endDate

        let expectation =
        """
        {
          "_class" : "ORKChoiceQuestionResult",
          "endDate" : "\(endDateString)",
          "identifier" : "",
          "noAnswerType" : {
            "_class" : "ORKDontKnowAnswer"
          },
          "questionType" : 0,
          "startDate" : "\(startDateString)"
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}
