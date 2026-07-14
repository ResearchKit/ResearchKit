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
import SwiftUI

/// When ORKTaskViewController or ORKPageStepViewController needs to present a task
/// to the screen, an ORKStepViewController is created that is able to present, interact
/// with, and record results for a specific step. Types that implement
/// ORKViewControllerProviding are intended to work within this context. This protocol is
/// converted from the ObjC written version and is functionally equivalent. Only @objc
/// types should (or are allowed by the compiler) conform to this protocol.
///
@objc
public protocol ORKViewControllerProviding {
    @objc(makeViewControllerWithResult:)
    func makeViewController(with result: ORKResult?) -> ORKStepViewController
}

/// Most ORKStepViewControllers can be created using the default initializer:
/// ORKStepViewController(step:result:). By implementing this protocol, types can
/// simply provide the type (aka. Class in ObjC) that is used in the default
/// implementation of makeViewController(with:) for all ORKStep types.
///
/// For example:
///
/// ```swift
/// //a subclass of `ORKStep`
/// final class ORKRandomCustomStep: ORKStep {...}
///
/// //a custom View Controller that works with `ORKRandomCustomStep`
/// class ORKRandomCustomStepViewController: ORKStepViewController {
///    //by default, inherits init(step: ORKStep, result: ORKResult?)
/// }
///
/// extension ORKRandomCustomStep: ORKStepViewControllerTypeProvider {
///   //by providing only the type, the default `makeViewController(with:)`
///   //implementation will use this type and the default init to
///   //fulfill the protocol requirements.
///   var viewControllerType: ORKStepViewController.Type {
///      ORKRandomCustomStepViewController.self
///   }
/// }
/// ```
///
public protocol ORKStepViewControllerTypeProvider: ORKViewControllerProviding {
    associatedtype ViewController: ORKStepViewController
    var viewControllerType: ViewController.Type { get }
}

/// This is a similar protocol to `ORKViewControllerProviding`, however, there are no
/// @objc types allowed here to allow for Swift-only types.
///
public protocol ORKStepViewControllerProviding {
    associatedtype Step

    @MainActor
    func makeViewController(for step: Step, result: ORKResult?) -> ORKStepViewController
}

/// Defines a function to allow a Swift only type (such as a struct) to provide a
/// corresponding SwiftUI view to present to the screen.
///
public protocol ORKStepViewProvider {
    associatedtype Step
    associatedtype ViewPresentingStep: View
    @MainActor
    func makeView(for step: Step) -> ViewPresentingStep
}

public protocol ORKStepValidatable {
    func validateParameters() throws
}

extension ORKStep: ORKViewControllerProviding {
    open func makeViewController(with result: ORKResult?) -> ORKStepViewController {
        guard let provider = self as? any ORKStepViewControllerTypeProvider else {
            ORKLogDebug(
                "Default implementation of \(#function) on \(self) only creates an ORKStepViewController"
                + " when extending ORKStepViewControllerTypeProvider."
                + " For non-default behavior, a custom implementation of \(#function) must be provided."
            )
            return ORKStepViewController(step: self, result: result)
        }
        return provider.viewControllerType.init(step: self, result: result)
    }
}

extension ORKStepViewControllerProviding where Self: ORKStepViewProvider {
    @MainActor
    public func makeViewController(for step: Step, result: ORKResult?) -> ORKStepViewController {
        ORKHostingStepViewController(
            step: step,
            result: result,
            contentView: { self.makeView(for: $0) }
        )
    }
}

extension ORKStepViewControllerProviding where Self: ORKStepViewProvider, Step: ORKStep {
    @MainActor
    public func makeViewController(for step: Step, result: ORKResult?) -> ORKStepViewController {
        ORKHostingStepViewController(
            step: step,
            result: result,
            contentView: { self.makeView(for: $0) }
        )
    }
}

extension ORKAdapterStep: ORKStepViewProvider where RawStep: ORKStepViewProvider {
    @MainActor
    public func makeView(for step: RawStep.Step) -> some View {
        rawStep.makeView(for: step)
    }
}

extension ORKAdapterStep: ORKStepViewControllerProviding where RawStep: ORKStepViewControllerProviding {
    @MainActor
    public func makeViewController(for step: RawStep.Step, result: ORKResult?) -> ORKStepViewController {
        rawStep.makeViewController(for: step, result: result)
    }
}
