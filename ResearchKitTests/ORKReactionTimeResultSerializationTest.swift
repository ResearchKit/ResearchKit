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

import ResearchKitActiveTask_Private
import Testing

@Suite(.tags(.serialization))
struct ORKReactionTimeResultSerializationTests {
    @Test("Instance with no file result")
    func testSerializationSucceedsforTypeWithNoFileResult() throws {
        let testDate = Date(timeIntervalSince1970: 1234567)
        let sutNoFileResult = makeSUT(with: testDate, hasFileResult: false, isSuccessful: true)
        let sutNoFileResultExpectation = makeSerializedSUT(with: testDate, hasFileResult: false, isSuccessful: true)

        try SerializationTestHelper.assertEquality(sutNoFileResult, sutNoFileResultExpectation)
    }

    @Test("Instance with file result")
    func testSerializationSucceedsForTypeWithFileResult() throws {
        let testDate = Date(timeIntervalSince1970: 89101112)
        let sutWithFileResult = makeSUT(with: testDate, hasFileResult: true, isSuccessful: false)
        let sutWithFileResultExpectation = makeSerializedSUT(with: testDate, hasFileResult: true, isSuccessful: false)

        try SerializationTestHelper.assertEquality(sutWithFileResult, sutWithFileResultExpectation)
    }

    @Test("Legacy JSON without isSuccessful deserializes as successful")
    func testLegacyJSONDefaultsToSuccessful() throws {
        let legacyJSON = """
            {
                "_class": "ORKReactionTimeResult",
                "identifier": "id",
                "timestamp": 1234567.0
            }
        """
        let result: ORKReactionTimeResult = try SerializationTestHelper.deserializedFromPrettyPrintedString(legacyJSON)
        #expect(result.isSuccessful == true)
    }
}

// MARK: - Test Helpers

private extension ORKReactionTimeResultSerializationTests {
    func makeSUT(with testDate: Date, hasFileResult: Bool, isSuccessful: Bool) -> ORKReactionTimeResult {
        let result = ORKReactionTimeResult(identifier: "id")
        result.startDate = testDate
        result.endDate = testDate
        result.timestamp = testDate.timeIntervalSince1970
        result.isSuccessful = isSuccessful
        result.userInfo = ["key":"value"]

        if hasFileResult {
            let fileResult = {
                let fileResult: ORKFileResult = .init(identifier: "deviceMotion")
                fileResult.contentType = "application/json"
                fileResult.startDate = testDate
                fileResult.endDate = testDate
                fileResult.fileName = "deviceMotion_B670E90C_85DD_4892_B0C5_0FA8A7EAB73F-20250730190635.json"
                return fileResult
            }()

            result.fileResults = [fileResult]
        }

        return result
    }

    func makeSerializedSUT(with testDate: Date, hasFileResult: Bool, isSuccessful: Bool) -> String {
        let testDateString = ORKStringFromDateISO8601(testDate)

        let serializedSUT = """
            "_class" : "ORKReactionTimeResult",
            "endDate" : "\(testDateString)",
            "identifier" : "id",
            "isSuccessful" : \(isSuccessful ? "true" : "false"),
            "startDate" : "\(testDateString)",
            "timestamp" : \(testDate.timeIntervalSince1970),
            "userInfo" : {
              "key" : "value"
            }
        """

        return if hasFileResult {
            """
                {
                    \(serializedSUT),
                    "fileResults":[
                        {
                            "_class": "ORKFileResult",
                            "contentType":"application/json",
                            "endDate" : "\(testDateString)",
                            "fileName":"deviceMotion_B670E90C_85DD_4892_B0C5_0FA8A7EAB73F-20250730190635.json",
                            "identifier":"deviceMotion",
                            "startDate" : "\(testDateString)"
                        }
                    ]
                }
            """
        } else {
            """
                {
                    \(serializedSUT)
                }
            """
        }
    }
}
