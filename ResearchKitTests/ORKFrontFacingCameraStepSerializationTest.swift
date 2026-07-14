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
struct ORKFrontFacingCameraStepSerializationTests {
    @Test
    func testORKFrontFacingCameraStep() throws {
        let instance = ORKFrontFacingCameraStep(identifier: "id")
        instance.maximumRecordingLimit = 5.0
        instance.allowsRetry = true
        instance.allowsReview = true 
        
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
          "_class" : "ORKFrontFacingCameraStep",
          "allowsRetry" : true,
          "allowsReview" : true,
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
          "maximumRecordingLimit" : 5,
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
}
