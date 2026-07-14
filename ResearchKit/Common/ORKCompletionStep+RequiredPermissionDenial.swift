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


#if !os(watchOS)
@objc extension ORKCompletionStep {

    private static func localizedString(_ key: String) -> String {
        Bundle(for: ORKCompletionStep.self).localizedString(forKey: key, value: "", table: "ResearchKit")
    }

    private static func permissionDeniedCompletionStep(identifier: String, title: String, text: String) -> ORKCompletionStep {
        let completionStep = ORKCompletionStep(identifier: identifier)
        completionStep.title = title
        completionStep.text = text
        completionStep.reasonForCompletion = .failed
        completionStep.iconImage = .init(systemName: "iphone.slash")
        completionStep.allowsBackNavigation = false;

        return completionStep
    }

    /// Returns a pre-configured completion step for when the user denies microphone access.
    ///
    /// Use this step to inform participants that microphone permission is required to continue
    /// the task. The step's `reasonForCompletion` is set to `.failed` and back navigation
    /// is disabled.
    ///
    /// - Returns: An ``ORKCompletionStep`` configured for audio permission denial.
    @objc public static func audioPermissionDeniedCompletionStep() -> ORKCompletionStep {
        permissionDeniedCompletionStep(
            identifier: "com.apple.researchkit.permissionDenied.audio",
            title: localizedString("PERMISSION_DENIED_AUDIO_TITLE"),
            text: localizedString("PERMISSION_DENIED_AUDIO_TEXT"))
    }

    /// Returns a pre-configured completion step for when the user denies Motion & Fitness access.
    ///
    /// Use this step to inform the participant that motion and fitness permission is required to
    /// continue the task. The step's `reasonForCompletion` is set to `.failed` and back navigation
    /// is disabled.
    ///
    /// - Returns: An ``ORKCompletionStep`` configured for motion permission denial.
    @objc public static func motionPermissionDeniedCompletionStep() -> ORKCompletionStep {
        permissionDeniedCompletionStep(
            identifier: "com.apple.researchkit.permissionDenied.motionActivity",
            title: localizedString("PERMISSION_DENIED_MOTION_TITLE"),
            text: localizedString("PERMISSION_DENIED_MOTION_TEXT"))
    }

    /// Returns a pre-configured completion step for when the user denies location access.
    ///
    /// Use this step to inform the participant that location permission is required to continue
    /// the task. The step's `reasonForCompletion` is set to `.failed` and back navigation
    /// is disabled.
    ///
    /// - Returns: An ``ORKCompletionStep`` configured for location permission denial.
    @objc public static func locationPermissionDeniedCompletionStep() -> ORKCompletionStep {
        permissionDeniedCompletionStep(
            identifier: "com.apple.researchkit.permissionDenied.coreLocation",
            title: localizedString("PERMISSION_DENIED_LOCATION_TITLE"),
            text: localizedString("PERMISSION_DENIED_LOCATION_TEXT"))
    }

    /// Returns a pre-configured completion step for when the user denies camera access.
    ///
    /// Use this step to inform the participant that camera permission is required to continue
    /// the task. The step's `reasonForCompletion` is set to `.failed` and back navigation
    /// is disabled.
    ///
    /// - Returns: An ``ORKCompletionStep`` configured for camera permission denial.
    @objc public static func cameraPermissionDeniedCompletionStep() -> ORKCompletionStep {
        permissionDeniedCompletionStep(
            identifier: "com.apple.researchkit.permissionDenied.camera",
            title: localizedString("PERMISSION_DENIED_CAMERA_TITLE"),
            text: localizedString("PERMISSION_DENIED_CAMERA_TEXT"))
    }
}
#endif
