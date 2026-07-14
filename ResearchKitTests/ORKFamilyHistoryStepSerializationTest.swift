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
struct ORKFamilyHistoryStepSerializationTests {
    @Test
    func testORKFamilyHistoryStep() throws {
        let instance = ORKFamilyHistoryStep(identifier: "id")
        instance.relativeGroups = [
            ORKRelativeGroup(
                identifier: "id",
                name: "group1",
                sectionTitle: "group",
                sectionDetailText: "details",
                identifierForCellTitle: "id2",
                maxAllowed: 3,
                formSteps: [
                    ORKFormStep(
                        identifier: "id3",
                        title: "title",
                        text: "text"
                    )
                ],
                detailTextIdentifiers: ["detail"]
            )
        ]
        
        instance.conditionStepConfiguration = ORKConditionStepConfiguration(
            stepIdentifier: "step",
            conditionsFormItemIdentifier: "id",
            conditions: [
                ORKHealthCondition(
                    identifier: "id2",
                    displayName: "knee",
                    value: 3 as NSNumber
                )
            ],
            formItems: [
                ORKFormItem(
                    identifier: "id",
                    text: "text",
                    answerFormat: ORKBooleanAnswerFormat()
                )
            ]
        )

        instance.useExtendedPadding = true
        instance.useSurveyMode = true
        instance.shouldAutomaticallyAdjustImageTintColor = true
        instance.buildInBodyItems = true
        instance.shouldTintImages = true
        instance.isOptional = true

        instance.text = "text"
        instance.title = "title"
        instance.detailText = "detailText"
        instance.bodyItems = [
          ORKBodyItem(
              text: "text",
              detailText: nil,
              image: nil,
              learnMoreItem: nil,
              bodyItemStyle: .bulletPoint
          )
        ]
        instance.footnote = "footnote"
        instance.bodyItemTextAlignment = .justified
        instance.headerTextAlignment = .right
        instance.imageContentMode = .bottomRight

        let expectation = """
        {
          "_class" : "ORKFamilyHistoryStep",
          "bodyItems" : [
            {
              "_class" : "ORKBodyItem",
              "alignImageToTop" : false,
              "bodyItemStyle" : 1,
              "text" : "text",
              "useCardStyle" : false,
              "useSecondaryColor" : false
            }
          ],
          "bodyItemTextAlignment" : 3,
          "buildInBodyItems" : true,
          "conditionStepConfiguration" : {
            "_class" : "ORKConditionStepConfiguration",
            "conditions" : [
              {
                "_class" : "ORKHealthCondition",
                "displayName" : "knee",
                "identifier" : "id2",
                "value" : 3
              }
            ],
            "conditionsFormItemIdentifier" : "id",
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
            "stepIdentifier" : "step"
          },
          "detailText" : "detailText",
          "footnote" : "footnote",
          "headerTextAlignment" : 2,
          "identifier" : "id",
          "imageContentMode" : 12,
          "optional" : true,
          "allowsBackNavigation" : true,
          "relativeGroups" : [
            {
              "_class" : "ORKRelativeGroup",
              "detailTextIdentifiers" : [
                "detail"
              ],
              "formSteps" : [
                {
                  "_class" : "ORKFormStep",
                  "autoScrollEnabled" : true,
                  "bodyItemTextAlignment" : 0,
                  "buildInBodyItems" : false,
                  "cardViewStyle" : 0,
                  "headerTextAlignment" : 4,
                  "identifier" : "id3",
                  "imageContentMode" : 0,
                  "optional" : true,
                  "allowsBackNavigation" : true,
                  "shouldAutomaticallyAdjustImageTintColor" : false,
                  "shouldTintImages" : false,
                  "text" : "text",
                  "title" : "title",
                  "useCardView" : true,
                  "useExtendedPadding" : false,
                  "useSurveyMode" : true
                }
              ],
              "identifier" : "id",
              "identifierForCellTitle" : "id2",
              "maxAllowed" : 3,
              "name" : "group1",
              "sectionDetailText" : "details",
              "sectionTitle" : "group"
            }
          ],
          "shouldAutomaticallyAdjustImageTintColor" : true,
          "shouldTintImages" : true,
          "text" : "text",
          "title" : "title",
          "useExtendedPadding" : true,
          "useSurveyMode" : true
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}
