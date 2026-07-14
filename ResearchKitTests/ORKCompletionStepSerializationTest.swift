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
struct ORKCompletionStepStepSerializationTests {
    @Test
    func testORKCompletionStep() throws {
        let instance = ORKCompletionStep(identifier: "id")
        instance.reasonForCompletion = .failed

        instance.centerImageVertically = true
        instance.type = 3

        instance.accessibilityHint = "hint"

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
          "_class" : "ORKCompletionStep",
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
          "centerImageVertically" : true,
          "detailText" : "detailText",
          "footnote" : "footnote",
          "headerTextAlignment" : 2,
          "identifier" : "id",
          "imageContentMode" : 12,
          "optional" : true,
          "allowsBackNavigation" : true,
          "reasonForCompletion" : 3,
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
    
    @Test
    func testORKCompletionStepNoBackNavigation() throws {
        let instance = ORKCompletionStep(identifier: "id")
        instance.reasonForCompletion = .failed

        instance.centerImageVertically = true
        instance.type = 3

        instance.accessibilityHint = "hint"

        instance.useExtendedPadding = true
        instance.useSurveyMode = true
        instance.shouldAutomaticallyAdjustImageTintColor = true
        instance.buildInBodyItems = true
        instance.shouldTintImages = true
        instance.isOptional = true
        instance.allowsBackNavigation = false

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
          "_class" : "ORKCompletionStep",
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
          "centerImageVertically" : true,
          "detailText" : "detailText",
          "footnote" : "footnote",
          "headerTextAlignment" : 2,
          "identifier" : "id",
          "imageContentMode" : 12,
          "optional" : true,
          "allowsBackNavigation" : false,
          "reasonForCompletion" : 3,
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

    @Test
    func testORKCompletionStepWithCustomIconImage() throws {
        let instance = ORKCompletionStep(identifier: "id")
        instance.reasonForCompletion = .completed

        instance.text = "Withdrawal Pending"
        instance.title = "Your withdrawal is pending"
        let iconImage = UIImage(systemName: "exclamationmark.triangle.fill")
        instance.iconImage = iconImage

        // Note: iconImage is not included in the expected JSON because image properties
        // are skipped during serialization (skipSerialization: YES in IMAGEPROPERTY).
        // The modifyingDeserializedObjectBeforeComparison callback restores the iconImage
        // for object equality comparison.
        let expectation = """
        {
          "_class" : "ORKCompletionStep",
          "allowsBackNavigation" : true,
          "bodyItemTextAlignment" : 0,
          "buildInBodyItems" : false,
          "centerImageVertically" : false,
          "headerTextAlignment" : 0,
          "identifier" : "id",
          "imageContentMode" : 0,
          "optional" : false,
          "reasonForCompletion" : 2,
          "shouldAutomaticallyAdjustImageTintColor" : false,
          "shouldTintImages" : false,
          "text" : "Withdrawal Pending",
          "title" : "Your withdrawal is pending",
          "useExtendedPadding" : false,
          "useSurveyMode" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation) { deserializedStep in
            deserializedStep.iconImage = iconImage
            return deserializedStep
        }
    }

    @Test
    func testORKCompletionStepWithCustomIconImageAndTintColor() throws {
        let instance = ORKCompletionStep(identifier: "id")
        instance.reasonForCompletion = .completed

        instance.text = "Withdrawal Pending"
        instance.title = "Your withdrawal is pending"
        let iconImage = UIImage(systemName: "exclamationmark.triangle.fill")
        instance.iconImage = iconImage
        let tintColor = UIColor.systemYellow
        instance.iconImageTintColor = tintColor

        // Note: iconImage is not included in the expected JSON because image properties
        // are skipped during serialization (skipSerialization: YES in IMAGEPROPERTY).
        // iconImageTintColor is now serialized as a named system color, which round-trips
        // correctly as a dynamic color.
        let expectation = """
        {
          "_class" : "ORKCompletionStep",
          "allowsBackNavigation" : true,
          "bodyItemTextAlignment" : 0,
          "buildInBodyItems" : false,
          "centerImageVertically" : false,
          "headerTextAlignment" : 0,
          "iconImageTintColor" : {
            "name" : "systemYellow"
          },
          "identifier" : "id",
          "imageContentMode" : 0,
          "optional" : false,
          "reasonForCompletion" : 2,
          "shouldAutomaticallyAdjustImageTintColor" : false,
          "shouldTintImages" : false,
          "text" : "Withdrawal Pending",
          "title" : "Your withdrawal is pending",
          "useExtendedPadding" : false,
          "useSurveyMode" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation) { deserializedStep in
            deserializedStep.iconImage = iconImage
            return deserializedStep
        }
    }
    
    @Test
    func testORKCompletionStepIconImageDeserializationFromJSON() throws {
        let json = """
        {
          "_class" : "ORKCompletionStep",
          "identifier" : "done",
          "title" : "All Done",
          "iconImage" : {
            "imageName" : "checkmark.circle.fill"
          }
        }
        """

        let step = try #require(try deserializedCompletionStep(from: json))

        #expect(step.identifier == "done")
        #expect(step.title == "All Done")
        #expect(step.iconImage != nil, "iconImage should be resolved from the SF Symbol name in JSON")
    }

    // MARK: - Malformed iconImage JSON

    @Test
    func testORKCompletionStepIconImageWrongType() throws {
        let json = """
        {
          "_class" : "ORKCompletionStep",
          "identifier" : "done",
          "title" : "All Done",
          "iconImage" : "not_a_dictionary"
        }
        """

        let step = try #require(try deserializedCompletionStep(from: json))

        #expect(step.identifier == "done")
        #expect(step.iconImage == nil, "iconImage should be nil when the JSON value is not a dictionary")
    }

    @Test
    func testORKCompletionStepIconImageMissingImageName() throws {
        let json = """
        {
          "_class" : "ORKCompletionStep",
          "identifier" : "done",
          "title" : "All Done",
          "iconImage" : {
            "someOtherKey" : "checkmark.circle.fill"
          }
        }
        """

        let step = try #require(try deserializedCompletionStep(from: json))

        #expect(step.identifier == "done")
        #expect(step.iconImage == nil, "iconImage should be nil when the imageName key is missing")
    }

    @Test
    func testORKCompletionStepIconImageNameWrongType() throws {
        let json = """
        {
          "_class" : "ORKCompletionStep",
          "identifier" : "done",
          "title" : "All Done",
          "iconImage" : {
            "imageName" : 12345
          }
        }
        """

        let step = try #require(try deserializedCompletionStep(from: json))

        #expect(step.identifier == "done")
        #expect(step.iconImage == nil, "iconImage should be nil when imageName is not a string")
    }

    @Test
    func testORKCompletionStepIconImageUnresolvedName() throws {
        let json = """
        {
          "_class" : "ORKCompletionStep",
          "identifier" : "done",
          "title" : "All Done",
          "iconImage" : {
            "imageName" : "this.symbol.does.not.exist.anywhere"
          }
        }
        """

        let step = try #require(try deserializedCompletionStep(from: json))

        #expect(step.identifier == "done")
        #expect(step.iconImage == nil, "iconImage should be nil when the image name cannot be resolved")
    }

    // MARK: - Named system color deserialization

    func testORKCompletionStepNamedColorDeserialization() throws {
        let json = """
        {
          "_class" : "ORKCompletionStep",
          "identifier" : "done",
          "title" : "All Done",
          "iconImageTintColor" : {
            "name" : "systemYellow"
          }
        }
        """

        let step = try #require(try deserializedCompletionStep(from: json))

        #expect(
            step.iconImageTintColor == UIColor.systemYellow,
            "Named color should resolve to the dynamic system color"
        )
    }

    func testORKCompletionStepUnknownNamedColor() throws {
        let json = """
        {
          "_class" : "ORKCompletionStep",
          "identifier" : "done",
          "title" : "All Done",
          "iconImageTintColor" : {
            "name" : "systemMagenta"
          }
        }
        """

        let step = try #require(try deserializedCompletionStep(from: json))

        #expect(
            step.iconImageTintColor == nil,
            "Unknown named color should return nil"
        )
    }

    func testORKCompletionStepRGBAColorDeserialization() throws {
        let json = """
        {
          "_class" : "ORKCompletionStep",
          "identifier" : "done",
          "title" : "All Done",
          "iconImageTintColor" : {
            "r" : 1,
            "g" : 0,
            "b" : 0,
            "a" : 1
          }
        }
        """

        let step = try #require(try deserializedCompletionStep(from: json))

        let color = try #require(step.iconImageTintColor, "RGBA color format should still be supported")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        #expect(color.getRed(&r, green: &g, blue: &b, alpha: &a) == true)
        #expect(r.isApproximatelyEqual(to: 1.0))
        #expect(g.isApproximatelyEqual(to: 0.0))
        #expect(b.isApproximatelyEqual(to: 0.0))
        #expect(a.isApproximatelyEqual(to: 1.0))
    }
}

// MARK: - Helpers

extension ORKCompletionStepStepSerializationTests {
    private func deserializedCompletionStep(from json: String) throws -> ORKCompletionStep? {
        guard let data = json.data(using: .utf8) else { return nil }
        let coreEntryProvider = ORKCoreSerializationEntryProvider()
        let serializer = ORKESerializer(entryProviders: [coreEntryProvider])
        let object = try serializer.object(fromJSONData: data)
        return object as? ORKCompletionStep
    }
}

extension CGFloat {
    func isApproximatelyEqual(to value: CGFloat, tolerance: Double = 0.001) -> Bool {
        abs(self - value) <= tolerance
    }
}
