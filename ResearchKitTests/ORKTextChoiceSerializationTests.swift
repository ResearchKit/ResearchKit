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
struct ORKTextChoiceSerializationTests {
    @Test
    func testORKTextChoiceMinInit() throws {
        let instance = ORKTextChoice(
            text: "textValue",
            detailText: "detailValue",
            value: 1 as NSNumber,
            exclusive: true
        )
        
        let expectation = """
        {
          "_class" : "ORKTextChoice",
          "detailText" : "detailValue",
          "exclusive" : true,
          "text" : "textValue",
          "value" : 1
        }
        """
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKTextChoiceWithTextInit() throws {
        let instance = ORKTextChoice(text: "textValue", value: 1 as NSNumber)
        let expectation = """
        {
          "_class" : "ORKTextChoice",
          "exclusive" : false,
          "text" : "textValue",
          "value" : 1
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKTextChoiceWithAttributedStrings() throws {
        let primaryTextAttributedString = NSAttributedString(string: "textValue")
        let detailTextAttributedString = NSAttributedString(string: "detailValue")
        
        let instance = ORKTextChoice(
            text: "textValue",
            primaryTextAttributedString: primaryTextAttributedString,
            detailText: "detailValue",
            detailTextAttributedString: detailTextAttributedString,
            value: 1 as NSNumber,
            exclusive: true
        )
        
        let expectation = """
        {
          "_class" : "ORKTextChoice",
          "detailText" : "detailValue",
          "exclusive" : true,
          "text" : "textValue",
          "value" : 1
        }
        """
        try SerializationTestHelper.assertEquality(instance, expectation) { instance in
            return ORKTextChoice(
                text: instance.text,
                primaryTextAttributedString:primaryTextAttributedString,
                detailText: instance.detailText,
                detailTextAttributedString: detailTextAttributedString,
                value: instance.value,
                exclusive: instance.exclusive
            )
        }
    }
    
    @Test
    func testORKTextChoiceWithChoiceTextAndImage() throws {
        let image = try #require(UIImage(systemName: "car"))

        let instance = ORKTextChoice(
            text: "textValue",
            image: image,
            value: 1 as NSNumber
        )
        
        let expectation = """
        {
          "_class" : "ORKTextChoice",
          "exclusive" : false,
          "text" : "textValue",
          "value" : 1
        }
        """
        try SerializationTestHelper.assertEquality(instance, expectation) { instance in
            instance.image = image
            return instance
        }
    }
    
    @Test
    func testORKTextChoiceWithTextAndExclusive() throws {
        let instance = ORKTextChoice(
            text: "textValue",
            detailText: "detailValue",
            value: 1 as NSNumber,
            exclusive: true
        )
        
        let expectation = """
        {
          "_class" : "ORKTextChoice",
          "detailText" : "detailValue",
          "exclusive" : true,
          "text" : "textValue",
          "value" : 1
        }
        """
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
        
    @Test
    func testInvalidORKTextChoiceWithNilText() {
        #expect(
            throws: (any Error).self,
            "The values passed to this initializer are expected to fail"
        ) {
            try NSObject.executeUsingObjCExceptionHandling {
                let _ = ORKTextChoice(
                    text: nil,
                    primaryTextAttributedString: nil,
                    detailText: nil,
                    detailTextAttributedString: nil,
                    value: 1 as NSNumber,
                    exclusive: true
                )
            }
        }
    }

    @Test
    func testInvalidORKTextChoiceWithInvalidValue() {
        #expect(
            throws: (any Error).self,
            "The values passed to this initializer are expected to fail"
        ) {
            try NSObject.executeUsingObjCExceptionHandling {
                let _ = ORKTextChoice(
                    text: "",
                    primaryTextAttributedString: nil,
                    detailText: nil,
                    detailTextAttributedString: nil,
                    value: ["fail": "case"] as NSDictionary,
                    exclusive: true
                )
            }
        }
    }
    
}

@Suite(.tags(.serialization))
struct ORKTextChoiceOtherSerializationTests {    
    @Test
    func testORKTextChoiceOtherFullInit() throws {
        let primaryTextAttributedString = NSAttributedString(string: "textValue")
        let detailTextAttributedString = NSAttributedString(string: "detailValue")
        
        let instance = ORKTextChoiceOther(
            text: "textValue",
            primaryTextAttributedString: primaryTextAttributedString,
            detailText: "detailValue",
            detailTextAttributedString: detailTextAttributedString,
            value: 1 as NSNumber,
            exclusive: true,
            textViewPlaceholderText: "test2",
            textViewInputOptional: false,
            textViewStartsHidden: true
        )
        
        let expectation = """
        {
          "_class" : "ORKTextChoiceOther",
          "detailText" : "detailValue",
          "exclusive" : true,
          "text" : "textValue",
          "textViewInputOptional" : false,
          "textViewPlaceholderText" : "test2",
          "textViewStartsHidden" : true,
          "value" : 1
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation){ instance in
            return ORKTextChoiceOther(
                text: instance.text,
                primaryTextAttributedString: primaryTextAttributedString,
                detailText: instance.detailText,
                detailTextAttributedString: detailTextAttributedString,
                value: instance.value,
                exclusive: instance.exclusive,
                textViewPlaceholderText: instance.textViewPlaceholderText ?? "test2",
                textViewInputOptional: instance.textViewInputOptional,
                textViewStartsHidden: instance.textViewStartsHidden
            )
        }
    }
    
    @Test
    func testORKTextChoiceOtherWithImageInit() throws {
        let image = try #require(UIImage(systemName: "car"))
        let primaryTextAttributedString = NSAttributedString(string: "textValue")
        let detailTextAttributedString = NSAttributedString(string: "detailValue")
        
        let instance = ORKTextChoiceOther(
            text: "textValue",
            primaryTextAttributedString: primaryTextAttributedString,
            detailText: "detailValue",
            detailTextAttributedString: detailTextAttributedString,
            value: 1 as NSNumber,
            exclusive: true,
            textViewPlaceholderText: "test2",
            textViewInputOptional: false,
            textViewStartsHidden: false
        )
        instance.image = image
        
        let expectation = """
        {
          "_class" : "ORKTextChoiceOther",
          "detailText" : "detailValue",
          "exclusive" : true,
          "text" : "textValue",
          "textViewInputOptional" : false,
          "textViewPlaceholderText" : "test2",
          "textViewStartsHidden" : false,
          "value" : 1
        }
        """
        try SerializationTestHelper.assertEquality(instance, expectation) { instance in
            let newInstance = ORKTextChoiceOther(
                text: instance.text,
                primaryTextAttributedString: primaryTextAttributedString,
                detailText: instance.detailText,
                detailTextAttributedString: detailTextAttributedString,
                value: instance.value,
                exclusive: instance.exclusive,
                textViewPlaceholderText: instance.textViewPlaceholderText ?? "test2",
                textViewInputOptional: instance.textViewInputOptional,
                textViewStartsHidden: instance.textViewStartsHidden
            )
            newInstance.image = image
            
            return newInstance
        }
    }
}
