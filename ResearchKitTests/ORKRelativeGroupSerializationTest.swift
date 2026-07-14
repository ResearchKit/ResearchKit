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
struct ORKRelativeGroupSerializationTests {
    @Test
    func testORKRelativeGroup() throws {
        let instance = ORKRelativeGroup(
            identifier: "id",
            name: "name",
            sectionTitle: "section",
            sectionDetailText: "detail",
            identifierForCellTitle: "cell",
            maxAllowed: 5,
            formSteps: [
                ORKFormStep(identifier: "id",
                            formItems: [
                                ORKFormItem(
                                    identifier: "id",
                                    text: "text",
                                    answerFormat: ORKBooleanAnswerFormat()
                                )
                            ]
                           )
            ],
            detailTextIdentifiers: [
                "detailText"
            ]
        )

        let expectation = """
        {
          "_class" : "ORKRelativeGroup",
          "detailTextIdentifiers" : [
            "detailText"
          ],
          "formSteps" : [
            {
              "_class" : "ORKFormStep",
              "autoScrollEnabled" : true,
              "bodyItemTextAlignment" : 0,
              "buildInBodyItems" : false,
              "cardViewStyle" : 0,
              "formItems" : [
                {
                  "_class" : "ORKFormItem",
                  "answerFormat" : {
                    "_class" : "ORKBooleanAnswerFormat",
                    "dontKnowButtonStyle" : 1,
                    "showDontKnowButton" : false
                  },
                  "identifier" : "id",
                  "optional" : true,
                  "showsProgress" : true,
                  "text" : "text"
                }
              ],
              "headerTextAlignment" : 0,
              "identifier" : "id",
              "imageContentMode" : 0,
              "optional" : true,
              "allowsBackNavigation" : true,
              "shouldAutomaticallyAdjustImageTintColor" : false,
              "shouldTintImages" : false,
              "useCardView" : true,
              "useExtendedPadding" : false,
              "useSurveyMode" : true
            }
          ],
          "identifier" : "id",
          "identifierForCellTitle" : "cell",
          "maxAllowed" : 5,
          "name" : "name",
          "sectionDetailText" : "detail",
          "sectionTitle" : "section"
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}
