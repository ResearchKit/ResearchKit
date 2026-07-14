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

import UIKit
import ResearchKit
import ResearchKit_Private
import ResearchKitUI_Private

/// Configurable auth-denied context for capture steps (video, color, etc.).
///
/// Builds an `ORKCompletionStep` that tells the user camera access is required
/// and offers a link to open Settings.
@objc public class ORKCaptureAccessDeniedContext: NSObject, ORKAuthenticationDeniedContext {

    private let title: String
    private let text: String
    private let settingsLinkText: String
    private let completionStepIdentifier: String
    private let learnMoreStepIdentifier: String
    private let icon: UIImage?

    @objc public init(
        title: String,
        text: String,
        settingsLinkText: String,
        completionStepIdentifier: String,
        learnMoreStepIdentifier: String,
        iconImage: UIImage? = UIImage(systemName: "video.slash")
    ) {
        self.title = title
        self.text = text
        self.settingsLinkText = settingsLinkText
        self.completionStepIdentifier = completionStepIdentifier
        self.learnMoreStepIdentifier = learnMoreStepIdentifier
        self.icon = iconImage
        super.init()
    }

    public func authDeniedCompletionStep() -> ORKCompletionStep {
        let step = ORKCompletionStep(identifier: completionStepIdentifier)
        step.title = title
        step.text = text
        step.reasonForCompletion = .failed
        step.iconImage = icon

        let learnMoreItem = ORKCreateSettingsLearnMoreItem(settingsLinkText, learnMoreStepIdentifier)

        let bodyItem = ORKBodyItem(
            text: nil,
            detailText: nil,
            image: nil,
            learnMoreItem: learnMoreItem,
            bodyItemStyle: .text
        )

        step.bodyItems = [bodyItem]
        return step
    }
}

// MARK: - Audio permission denied recovery

extension ORKCompletionStep {
    @objc
    public static func audioPermissionDeniedCompletionStepWithSettingsLink() -> ORKCompletionStep {
        let step = audioPermissionDeniedCompletionStep()
        step.bodyItems = makeOpenSettingsBodyItems(
            identifier: "com.apple.researchkit.permissionDenied.audio.openSettings"
        )
        return step
    }
}

// MARK: - Motion permission denied recovery

extension ORKCompletionStep {
    @objc
    public static func motionPermissionDeniedCompletionStepWithSettingsLink() -> ORKCompletionStep {
        let step = motionPermissionDeniedCompletionStep()
        step.bodyItems = makeOpenSettingsBodyItems(
            identifier: "com.apple.researchkit.permissionDenied.motionActivity.openSettings"
        )
        return step
    }
}

// MARK: - Shared helpers

private extension ORKCompletionStep {
    static func makeOpenSettingsBodyItems(identifier: String) -> [ORKBodyItem] {
        [
            ORKBodyItem(
                text: nil,
                detailText: nil,
                image: nil,
                learnMoreItem: makeOpenSettingsLearnMoreItem(identifier: identifier),
                bodyItemStyle: .text
            )
        ]
    }

    static func makeOpenSettingsLearnMoreItem(identifier: String) -> ORKLearnMoreItem {
        let linkText = Bundle(for: ORKCompletionStep.self).localizedString(
            forKey: "PERMISSION_DENIED_OPEN_SETTINGS",
            value: "",
            table: "ResearchKit"
        )
        return ORKCreateSettingsLearnMoreItem(linkText, identifier)
    }
}
