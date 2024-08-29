//
// This source file is part of the Stanford Biodesign Digital Health Group open-source organization
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ResearchKit
import SwiftUI

// swiftlint:disable file_types_order


private struct ORKWillAppearMethod: EnvironmentKey {
    static var defaultValue: ((ORKTaskViewController, ORKStepViewController) -> Void)? {
        nil
    }
}

private struct ORKWillDisappearMethod: EnvironmentKey {
    static var defaultValue: ((ORKTaskViewController, ORKStepViewController, ORKStepViewControllerNavigationDirection) -> Void)? {
        nil
    }
}

private struct ORKShouldPresentMethod: EnvironmentKey {
    static var defaultValue: ((ORKTaskViewController, ORKStep) -> Bool)? {
        nil
    }
}


extension EnvironmentValues {
    var onStepWillAppear: ((ORKTaskViewController, ORKStepViewController) -> Void)? {
        get {
            self[ORKWillAppearMethod.self]
        }
        set {
            self[ORKWillAppearMethod.self] = newValue
        }
    }

    var onStepWillDisappear: ((ORKTaskViewController, ORKStepViewController, ORKStepViewControllerNavigationDirection) -> Void)? {
        get {
            self[ORKWillDisappearMethod.self]
        }
        set {
            self[ORKWillDisappearMethod.self] = newValue
        }
    }

    var shouldPresentStep: ((ORKTaskViewController, ORKStep) -> Bool)? {
        get {
            self[ORKShouldPresentMethod.self]
        }
        set {
            self[ORKShouldPresentMethod.self] = newValue
        }
    }
}


extension View {
    /// Add an action every time a step appears.
    ///
    /// This method adds a closure that is called by the underlying `ORKTaskViewController` once a new step is about to be displayed.
    ///
    /// - Note: This method bridges the [`taskViewController:stepViewControllerWillAppear:`](https://researchkit.org/docs/Protocols/ORKTaskViewControllerDelegate.html#//api/name/taskViewController:stepViewControllerWillAppear:)
    /// of the underlying `ORKTaskViewControllerDelegate` to the SwiftUI environment.
    /// - Parameter perform: The closure to be executed before the step is presented.
    /// - Returns: The modified view.
    @_spi(ORK)
    public func onStepWillAppear(
        perform closure: @escaping (ORKTaskViewController, ORKStepViewController) -> Void
    ) -> some View {
        environment(\.onStepWillAppear, closure)
    }

    /// Adds an action every time a step disappears.
    ///
    /// Add an action every time a step appears.
    ///
    /// This method adds a closure that is called by the underlying `ORKTaskViewController` once a step is about to disappear.
    ///
    /// - Note: This method bridges the [`taskViewController:stepViewControllerWillDisappear:navigationDirection:`](https://researchkit.org/docs/Protocols/ORKTaskViewControllerDelegate.html#//api/name/taskViewController:stepViewControllerWillDisappear:navigationDirection:)
    /// of the underlying `ORKTaskViewControllerDelegate` to the SwiftUI environment.
    /// - Parameter perform: The closure to be executed before the step disappears.
    /// - Returns: The modified view.
    @_spi(ORK)
    public func onStepWillDisappear(
        perform closure: @escaping (ORKTaskViewController, ORKStepViewController, ORKStepViewControllerNavigationDirection) -> Void
    ) -> some View {
        environment(\.onStepWillDisappear, closure)
    }


    /// Adds a predicate to decide if a given step should be presented.
    ///
    /// Add a predicate that is called to determine if a step should be presented.
    /// This is called once the `Continue` button of a previous step is called (or before the first step is shown). When returning `false` nothing happens,
    /// otherwise the respective view controller for the given step will be shown.
    ///
    /// - Note: This method bridges the [`taskViewController:shouldPresentStep:`](https://researchkit.org/docs/Protocols/ORKTaskViewControllerDelegate.html#//api/name/taskViewController:shouldPresentStep:)
    /// of the underlying `ORKTaskViewControllerDelegate` to the SwiftUI environment.
    /// - Parameter predicate: The closure to be executed to determine if the next step should be presented.
    /// - Returns: The modified view.
    @_spi(ORK)
    public func shouldPresentStep(predicate: @escaping (ORKTaskViewController, ORKStep) -> Bool) -> some View {
        environment(\.shouldPresentStep, predicate)
    }
}
