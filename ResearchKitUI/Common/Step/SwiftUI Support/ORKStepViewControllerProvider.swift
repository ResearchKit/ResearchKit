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

import ResearchKit

/// `ORKStepViewControllerProvider` is provided as a common and default implementation of the `ORKStepViewControllerProviding`
/// protocol. This is primarily used in the `ORKTaskViewController` and `ORKPageStepViewController` extensions where
/// those containers are preparing to present a new ORKStepViewController to the screen. The general 
/// flow for `makeViewController(for:result:) is:
///
///  1. Try to get SwiftUI view
///  2. Try to get ORKStepViewController from types conforming to Swift-only protocol
///  3. Fall back to ObjC based lookups via redefined @objc protocol
///
///
@MainActor
struct ORKStepViewControllerProvider: ORKStepViewControllerProviding {
    func makeViewController(for step: ORKStep, result: ORKResult?) -> ORKStepViewController {
        if let provider = step as? any ORKStepViewControllerProviding {
            makeViewController(for: provider, result: result)
        } else if let step = step as? any ORKStepViewProvider {
            makeStepViewController(for: step, result: result)
        } else {
            step.makeViewController(with: result)
        }
    }

    private func makeViewController<S>(for provider: S, result: ORKResult?) -> ORKStepViewController where S: ORKStepViewControllerProviding {
        guard let step = provider as? S.Step else {
            preconditionFailure("Cannot unwrap \(provider) expecting to be of type \(type(of: S.Step.self))")
        }
        return provider.makeViewController(for: step, result: result)
    }

    private func makeStepViewController<Step>(for viewProvidingStep: Step, result: ORKResult?)
        -> ORKStepViewController where Step: ORKStepViewProvider {

        ORKHostingStepViewController(hostableStep: viewProvidingStep, result: result)
    }
}
