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

import ResearchKitUI
private import ResearchKitActiveTask_Private

extension ORKOrderedTask {
    public final class StroopStepFactory {
        public init(){}
        public func welcomeStep(_ intendedUseDescription: String) -> ORKStep {
            let step = ORKInstructionStep(identifier: ORKInstruction0StepIdentifier)
            step.title = ORKLocalizedHiddenString("STROOP_TASK_TITLE")
            step.text = intendedUseDescription
            step.detailText = ORKLocalizedHiddenString("STROOP_TASK_INTRO1_DETAIL_TEXT")
            step.image = UIImage(named: "phonestrooplabel", in: Bundle(for: ORKOrderedTask.self), with: nil)

            step.imageContentMode = .center;
            step.shouldTintImages = true;
            step.shouldAutomaticallyAdjustImageTintColor = true;
            return step
        }

        public var introStep: ORKStep {
            let step = ORKInstructionStep(identifier: ORKInstruction1StepIdentifier)
            step.title = ORKLocalizedHiddenString("STROOP_TASK_TITLE")
            step.detailText = ORKLocalizedHiddenString("STROOP_TASK_INTRO2_DETAIL_TEXT")
            step.image = UIImage(named: "phonestroopbutton", in: Bundle(for: ORKOrderedTask.self), with: nil)
            step.imageContentMode = .center
            step.shouldTintImages = true
            step.shouldAutomaticallyAdjustImageTintColor = true
            return step
        }

        public var countdownStep: ORKStep {
            let step = ORKCountdownStep(identifier: ORKCountdownStepIdentifier)
            step.title = ORKLocalizedHiddenString("STROOP_TASK_TITLE")
            step.stepDuration = 5.0
            return step
        }

        public var completeStep: ORKStep {
            ORKOrderedTask.makeCompletionStep()
        }

        public func stroopStep(identifier: String = "StroopStep", numberOfAttempts: Int = StroopStep.ParamDefaults.trialCount) -> ORKSwiftStroopStep {
            let step = ORKSwiftStroopStep(identifier: identifier)
            step.numberOfAttempts = numberOfAttempts
            return step
        }
    }
}

