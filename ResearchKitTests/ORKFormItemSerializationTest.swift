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
struct ORKFormItemSerializationTests {
    @Test
    func testORKFormItem() throws {
        let instance = ORKFormItem(
            identifier: "",
            text: "",
            answerFormat: ORKAnswerFormat()
        )
        instance.tagText = ""
        instance.learnMoreItem = ORKLearnMoreItem()
        instance.detailText = ""
        instance.placeholder = ""

        let expectation =
        """
        {
          "_class" : "ORKFormItem",
          "answerFormat" : {
            "_class" : "ORKAnswerFormat",
            "dontKnowButtonStyle" : 1,
            "showDontKnowButton" : false
          },
          "detailText" : "",
          "identifier" : "",
          "learnMoreItem" : {
            "_class" : "ORKLearnMoreItem"
          },
          "optional" : true,
          "placeholder" : "",
          "showsProgress" : true,
          "tagText" : "",
          "text" : ""
        }
        """
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKFormItemWithOptional() throws {
        let instance = ORKFormItem(
            identifier: "",
            text: "",
            answerFormat: ORKBooleanAnswerFormat(),
            optional: true
        )
        instance.tagText = ""
        instance.learnMoreItem = ORKLearnMoreItem()
        instance.detailText = ""
        instance.placeholder = ""

        let expectation =
        """
        {
          "_class" : "ORKFormItem",
          "answerFormat" : {
            "_class" : "ORKBooleanAnswerFormat",
            "dontKnowButtonStyle" : 1,
            "showDontKnowButton" : false
          },
          "detailText" : "",
          "identifier" : "",
          "learnMoreItem" : {
            "_class" : "ORKLearnMoreItem"
          },
          "optional" : true,
          "placeholder" : "",
          "showsProgress" : true,
          "tagText" : "",
          "text" : ""
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKFormItemWithProgress() throws {
        let instance = ORKFormItem(
            identifier: "",
            text: "",
            detailText: "",
            learnMoreItem: ORKLearnMoreItem(),
            showsProgress: true,
            answerFormat: ORKBooleanAnswerFormat(),
            tagText: "",
            optional: true
        )

        let expectation =
        """
        {
          "_class" : "ORKFormItem",
          "answerFormat" : {
            "_class" : "ORKBooleanAnswerFormat",
            "dontKnowButtonStyle" : 1,
            "showDontKnowButton" : false
          },
          "detailText" : "",
          "identifier" : "",
          "learnMoreItem" : {
            "_class" : "ORKLearnMoreItem"
          },
          "optional" : true,
          "showsProgress" : true,
          "tagText" : "",
          "text" : ""
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKFormItemWithSection() throws {
        let instance = ORKFormItem(sectionTitle: "title")
        instance.tagText = ""
        instance.learnMoreItem = ORKLearnMoreItem()
        instance.detailText = ""
        instance.placeholder = ""

        let expectation =
        """
        {
          "_class" : "ORKFormItem",
          "detailText" : "",
          "identifier" : "\(instance.identifier)",
          "learnMoreItem" : {
            "_class" : "ORKLearnMoreItem"
          },
          "optional" : false,
          "placeholder" : "",
          "showsProgress" : false,
          "tagText" : "",
          "text" : "title"
        }
        """
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKFormItemWithSectionAndDetail() throws {
        let instance = ORKFormItem(
            sectionTitle: "Section",
            detailText: "detail",
            learnMoreItem: ORKLearnMoreItem(),
            showsProgress: true
        )
        instance.tagText = ""
        instance.placeholder = ""

        let expectation =
        """
        {
          "_class" : "ORKFormItem",
          "detailText" : "detail",
          "identifier" : "\(instance.identifier)",
          "learnMoreItem" : {
            "_class" : "ORKLearnMoreItem"
          },
          "optional" : false,
          "placeholder" : "",
          "showsProgress" : true,
          "tagText" : "",
          "text" : "Section"
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKFormItemWithAnswerFormat() throws {
        let instance = ORKFormItem(
            identifier: "",
            text: "",
            answerFormat: ORKBooleanAnswerFormat(),
            optional: false
        )
        instance.tagText = ""
        instance.learnMoreItem = ORKLearnMoreItem()
        instance.detailText = ""
        instance.placeholder = ""

        let expectation =
        """
        {
          "_class" : "ORKFormItem",
          "answerFormat" : {
            "_class" : "ORKBooleanAnswerFormat",
            "dontKnowButtonStyle" : 1,
            "showDontKnowButton" : false
          },
          "detailText" : "",
          "identifier" : "",
          "learnMoreItem" : {
            "_class" : "ORKLearnMoreItem"
          },
          "optional" : false,
          "placeholder" : "",
          "showsProgress" : true,
          "tagText" : "",
          "text" : ""
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}

