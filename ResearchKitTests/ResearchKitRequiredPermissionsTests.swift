/*
 Copyright (c) 2026, Apple Inc. All rights reserved.

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
 the copyright holders even if such software marks are included in this software.

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
import ResearchKitActiveTask
import ResearchKitActiveTask_Private
import Testing

// MARK: - ORKEnvironmentSPLMeterStep

@Suite
struct ORKEnvironmentSPLMeterStepRequiredPermissionsTests {

    let step = ORKEnvironmentSPLMeterStep(identifier: "test", outputDirectory: nil)

    // MARK: - requiredPermissions

    @Test
    func requiredPermissionsIncludesAudioRecording() {
        #expect(step.requiredPermissions() == .audioRecording)
    }
}

@Suite
struct ORKEnvironmentSPLMeterStepRequestedPermissionsTests {

    let step = ORKEnvironmentSPLMeterStep(identifier: "test", outputDirectory: nil)

    // MARK: - requestedPermissions

    @Test
    func requestedPermissionsIncludesAudioRecording() {
        #expect(step.requestedPermissions == .audioRecording)
    }
}

// MARK: - ORKAudioStep

@Suite
struct ORKAudioStepRequiredPermissionsTests {

    let step = ORKAudioStep(identifier: "test")

    // MARK: - requiredPermissions

    @Test
    func requiredPermissionsIncludesAudioRecording() {
        #expect(step.requiredPermissions() == .audioRecording)
    }
}

// MARK: - ORKWalkingTaskStep

@Suite
struct ORKWalkingTaskStepRequiredPermissionsTests {

    let step = ORKWalkingTaskStep(identifier: "test")

    // MARK: - requiredPermissions

    @Test
    func requiredPermissionsIncludesCoreMotionActivity() {
        #expect(step.requiredPermissions() == .coreMotionActivity)
    }
}

// MARK: - ORKNormalizedReactionTimeStep

@Suite
struct ORKNormalizedReactionTimeStepRequiredPermissionsTests {

    let step = ORKNormalizedReactionTimeStep(identifier: "test")

    // MARK: - requiredPermissions

    @Test
    func requiredPermissionsIsEmpty() {
        #expect(step.requiredPermissions() == [])
    }
}

// MARK: - ORKReactionTimeStep

@Suite
struct ORKReactionTimeStepRequiredPermissionsTests {

    let step = ORKReactionTimeStep(identifier: "test")

    // MARK: - requiredPermissions

    @Test
    func requiredPermissionsIsEmpty() {
        #expect(step.requiredPermissions() == [])
    }
}

// MARK: - ORKRangeOfMotionStep

@Suite
struct ORKRangeOfMotionStepRequiredPermissionsTests {

    let step = ORKRangeOfMotionStep(identifier: "test", limbOption: [])

    // MARK: - requiredPermissions

    @Test
    func requiredPermissionsIsEmpty() {
        #expect(step.requiredPermissions() == [])
    }
}

// MARK: - ORKSpeechRecognitionStep

@Suite
struct ORKSpeechRecognitionStepRequiredPermissionsTests {

    let step = ORKSpeechRecognitionStep(identifier: "test", image: nil, text: nil)

    // MARK: - requiredPermissions

    @Test
    func requiredPermissionsIncludesAudioRecording() {
        #expect(step.requiredPermissions() == .audioRecording)
    }
}
