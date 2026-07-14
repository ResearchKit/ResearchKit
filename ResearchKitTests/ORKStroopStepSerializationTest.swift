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
struct ORKStroopStepSerializationTests {
    @Test
    func testORKStroopStep() throws {
        let instance = ORKStroopStep(identifier: "id")
        instance.numberOfAttempts = 3
        instance.stepDuration = 20.0

        instance.accessibilityHint = "hint"

        instance.finishedSpokenInstruction = "instruction"
        instance.spokenInstruction = "spokenInstruction"
        instance.recorderConfigurations = [
           ORKRecorderConfiguration(identifier: "id")
        ]

        instance.stepDuration = 2.0
        instance.shouldShowDefaultTimer = true
        instance.shouldSpeakCountDown = true
        instance.shouldSpeakRemainingTimeAtHalfway = true
        instance.shouldStartTimerAutomatically = true
        instance.shouldPlaySoundOnStart = true
        instance.shouldPlaySoundOnFinish = true
        instance.shouldVibrateOnStart = true
        instance.shouldVibrateOnFinish = true
        instance.shouldUseNextAsSkipButton = true
        instance.shouldContinueOnFinish = true
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
          "_class" : "ORKStroopStep",
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
          "detailText" : "detailText",
          "finishedSpokenInstruction" : "instruction",
          "footnote" : "footnote",
          "headerTextAlignment" : 2,
          "identifier" : "id",
          "imageContentMode" : 12,
          "numberOfAttempts" : 3,
          "optional" : true,
          "allowsBackNavigation" : false,
          "recorderConfigurations" : [
            {
              "_class" : "ORKRecorderConfiguration",
              "identifier" : "id",
              "rollingFileSizeThreshold" : 0
            }
          ],
          "shouldAutomaticallyAdjustImageTintColor" : true,
          "shouldContinueOnFinish" : true,
          "shouldPlaySoundOnFinish" : true,
          "shouldPlaySoundOnStart" : true,
          "shouldShowDefaultTimer" : true,
          "shouldSpeakCountDown" : true,
          "shouldSpeakRemainingTimeAtHalfway" : true,
          "shouldStartTimerAutomatically" : true,
          "shouldTintImages" : true,
          "shouldUseNextAsSkipButton" : true,
          "shouldVibrateOnFinish" : true,
          "shouldVibrateOnStart" : true,
          "spokenInstruction" : "spokenInstruction",
          "stepDuration" : 2,
          "text" : "text",
          "title" : "title",
          "useExtendedPadding" : true,
          "useSurveyMode" : true
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }

    func testORKSwiftStroopStep() throws {
        let instance = ORKSwiftStroopStep(identifier: "id")
        instance.numberOfAttempts = 15
        instance.colorChoices = [.red, .blue, .green]
        instance.interTrialMaskType = .incorrectFeedback
        instance.congruentFrequency = 0.4
        instance.incongruentFrequency = 0.4
        instance.neutralFrequency = 0.2
        instance.minimumInterTrialDelay = 0.3
        instance.maximumInterTrialDelay = 0.8

        instance.stepDuration = 2.0
        instance.shouldVibrateOnStart = true
        instance.shouldShowDefaultTimer = false
        instance.shouldContinueOnFinish = true

        let expectation = """
        {
          "_class" : "ORKSwiftStroopStep",
          "allowsBackNavigation" : false,
          "bodyItemTextAlignment" : 0,
          "buildInBodyItems" : false,
          "congruentFrequency" : 0.40000000000000002,
          "headerTextAlignment" : 0,
          "identifier" : "id",
          "imageContentMode" : 0,
          "incongruentFrequency" : 0.40000000000000002,
          "maximumInterTrialDelay" : 0.80000000000000004,
          "minimumInterTrialDelay" : 0.29999999999999999,
          "neutralFrequency" : 0.20000000000000001,
          "numberOfAttempts" : 15,
          "optional" : false,
          "recordResults" : true,
          "serializedColorChoices" : [
            "red",
            "blue",
            "green"
          ],
          "serializedInterTrialMaskType" : "incorrectFeedback",
          "shouldAutomaticallyAdjustImageTintColor" : false,
          "shouldContinueOnFinish" : true,
          "shouldPlaySoundOnFinish" : false,
          "shouldPlaySoundOnStart" : false,
          "shouldShowDefaultTimer" : false,
          "shouldSpeakCountDown" : false,
          "shouldSpeakRemainingTimeAtHalfway" : false,
          "shouldStartTimerAutomatically" : false,
          "shouldTintImages" : false,
          "shouldUseNextAsSkipButton" : false,
          "shouldVibrateOnFinish" : false,
          "shouldVibrateOnStart" : true,
          "stepDuration" : 2,
          "useExtendedPadding" : false,
          "useSurveyMode" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }

    func testORKSwiftStroopStepArchiveRoundTrip() throws {
        let instance = ORKSwiftStroopStep(identifier: "id")
        instance.numberOfAttempts = 15
        instance.colorChoices = [.red, .blue, .green]
        instance.interTrialMaskType = .incorrectFeedback
        instance.congruentFrequency = 0.4
        instance.incongruentFrequency = 0.4
        instance.neutralFrequency = 0.2
        instance.minimumInterTrialDelay = 0.3
        instance.maximumInterTrialDelay = 0.8
        instance.recordResults = false

        instance.stepDuration = 2.0
        instance.shouldVibrateOnStart = true
        instance.shouldShowDefaultTimer = false
        instance.shouldContinueOnFinish = true

        let archived = try SerializationTestHelper.archiveAndUnarchive(instance)
        #expect(instance == archived)
    }

    func testORKSwiftStroopStepDefaultValues() throws {
        let instance = ORKSwiftStroopStep(identifier: "defaults")

        let decoded: ORKSwiftStroopStep = try SerializationTestHelper.deserializedFromPrettyPrintedString(
            SerializationTestHelper.serializeToPrettyPrintedString(instance)
        )

        #expect(instance.numberOfAttempts == decoded.numberOfAttempts)
        #expect(instance.colorChoices == decoded.colorChoices)
        #expect(instance.interTrialMaskType == decoded.interTrialMaskType)
        #expect(instance.congruentFrequency == decoded.congruentFrequency)
        #expect(instance.incongruentFrequency == decoded.incongruentFrequency)
        #expect(instance.neutralFrequency == decoded.neutralFrequency)
        #expect(instance.minimumInterTrialDelay == decoded.minimumInterTrialDelay)
        #expect(instance.maximumInterTrialDelay == decoded.maximumInterTrialDelay)
        #expect(instance.recordResults == decoded.recordResults)
        #expect(instance == decoded)
    }

    func testORKSwiftStroopStepRecordResultsFalse() throws {
        let instance = ORKSwiftStroopStep(identifier: "id")
        instance.recordResults = false

        let decoded: ORKSwiftStroopStep = try SerializationTestHelper.deserializedFromPrettyPrintedString(
            SerializationTestHelper.serializeToPrettyPrintedString(instance)
        )
        #expect(decoded.recordResults == false)

        let archived = try SerializationTestHelper.archiveAndUnarchive(instance)
        #expect(archived.recordResults == false)

        #expect(instance == decoded)
        #expect(instance == archived)
    }

    func testORKSwiftStroopStepAllColorChoices() throws {
        let instance = ORKSwiftStroopStep(identifier: "id")
        instance.colorChoices = StroopColor.allCases

        let decoded: ORKSwiftStroopStep = try SerializationTestHelper.deserializedFromPrettyPrintedString(
            SerializationTestHelper.serializeToPrettyPrintedString(instance)
        )
        #expect(instance.colorChoices == decoded.colorChoices)

        let archived = try SerializationTestHelper.archiveAndUnarchive(instance)
        #expect(instance.colorChoices == archived.colorChoices)
    }

    func testORKSwiftStroopStepBackwardsCompatibleDecode() throws {
        let json = """
        {
          "_class" : "ORKSwiftStroopStep",
          "identifier" : "legacy",
          "numberOfAttempts" : 20
        }
        """

        let decoded: ORKSwiftStroopStep = try SerializationTestHelper.deserializedFromPrettyPrintedString(json)

        #expect(decoded.numberOfAttempts == 20)
        #expect(decoded.colorChoices == StroopStep.ParamDefaults.colorChoices)
        #expect(decoded.interTrialMaskType == StroopStep.ParamDefaults.interTrialMaskType)
        #expect(decoded.congruentFrequency == StroopStep.ParamDefaults.congruentFrequency)
        #expect(decoded.incongruentFrequency == StroopStep.ParamDefaults.incongruentFrequency)
        #expect(decoded.neutralFrequency == StroopStep.ParamDefaults.neutralFrequency)
        #expect(decoded.minimumInterTrialDelay == StroopStep.ParamDefaults.minimumInterTrialDelay)
        #expect(decoded.maximumInterTrialDelay == StroopStep.ParamDefaults.maximumInterTrialDelay)
        #expect(decoded.recordResults == StroopStep.ParamDefaults.recordResults)
    }
}

// MARK: - Swift Testing (Parameterized)

@Suite(.tags(.serialization))
struct ORKSwiftStroopStepMaskTypeTests {
    @Test("Mask type round-trips through JSON and archive", arguments: StroopInterTrialMask.allCases)
    func maskTypeRoundTrip(_ maskType: StroopInterTrialMask) throws {
        let instance = ORKSwiftStroopStep(identifier: "id")
        instance.interTrialMaskType = maskType

        let jsonDecoded: ORKSwiftStroopStep = try SerializationTestHelper.deserializedFromPrettyPrintedString(
            SerializationTestHelper.serializeToPrettyPrintedString(instance)
        )
        #expect(maskType == jsonDecoded.interTrialMaskType)

        let archived = try SerializationTestHelper.archiveAndUnarchive(instance)
        #expect(maskType == archived.interTrialMaskType)
    }
}
