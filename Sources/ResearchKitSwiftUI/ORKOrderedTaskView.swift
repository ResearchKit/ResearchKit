//
// This source file is part of the Stanford Biodesign Digital Health Group open-source organization
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ResearchKit
import SwiftUI


/// Present an `ORKOrderedTask`.
///
/// This view allows you to present a ResearchKit `ORKOrderedTask` to the user.
///
/// This view makes the `ORKTaskViewController` available as a reusable SwiftUI view.
/// 
/// - Tip: For more information refer to the documentation of ResearchKit.
///
/// Here is small code example that displays a [Trail Making Test](https://researchkit.org/docs/docs/ActiveTasks/ActiveTasks.html#trail).
///
/// ```swift
/// import ResearchKit
/// import ResearchKitSwiftUI
///
///
/// struct TrailMakingTask: View {
///     var trailMarkingTask: ORKOrderedTask {
///         .trailmakingTask(
///             withIdentifier: "your-trailmaking-task-id",
///             intendedUseDescription: "Tests visual attention and task switching",
///             trailmakingInstruction: nil,
///             trailType: .B,
///             options: []
///         )
///     }
///
///     var body: some View {
///         ORKOrderedTaskView(tasks: trailMarkingTask) { result in
///             guard case let .completed(taskResult) = result else {
///                 return // user cancelled or task failed
///             }
///
///             // store your result ...
///         }
///     }
/// }
/// ```
///
/// - Tip: The `ORKOrderedTaskView` automatically creates a temporary output directory for active tasks that provide results as a file.
///     You can check the results of a `taskResult` if it contains an object of type `ORKFileResult` and save its corresponding content.
///     After your async closure returns the temporary directory will be automatically deleted otherwise.
public struct ORKOrderedTaskView: UIViewControllerRepresentable {
    public class Coordinator: NSObject, ORKTaskViewControllerDelegate {
        fileprivate var result: @MainActor (TaskResult) async -> Void
        fileprivate var cancelBehavior: CancelBehavior

        fileprivate var stepWillAppear: ((ORKTaskViewController, ORKStepViewController) -> Void)?
        fileprivate var stepWillDisappear: ((ORKTaskViewController, ORKStepViewController, ORKStepViewControllerNavigationDirection) -> Void)?
        fileprivate var shouldPresentStep: ((ORKTaskViewController, ORKStep) -> Bool)?


        init(
            result: @escaping @MainActor (TaskResult) async -> Void,
            cancelBehavior: CancelBehavior
        ) {
            self.result = result
            self.cancelBehavior = cancelBehavior
        }

        public func taskViewControllerShouldConfirmCancel(_ taskViewController: ORKTaskViewController) -> Bool {
            cancelBehavior == .shouldConfirmCancel
        }
        
        public func taskViewController(
            _ taskViewController: ORKTaskViewController,
            stepViewControllerWillAppear stepViewController: ORKStepViewController
        ) {
            if cancelBehavior == .disabled {
                stepViewController.cancelButtonItem = nil
            }

            stepWillAppear?(taskViewController, stepViewController)
        }

        public func taskViewController(
            _ taskViewController: ORKTaskViewController,
            stepViewControllerWillDisappear stepViewController: ORKStepViewController,
            navigationDirection direction: ORKStepViewControllerNavigationDirection
        ) {
            stepWillDisappear?(taskViewController, stepViewController, direction)
        }

        public func taskViewControllerSupportsSaveAndRestore(_ taskViewController: ORKTaskViewController) -> Bool {
            false
        }

        public func taskViewController(
            _ taskViewController: ORKTaskViewController,
            didFinishWith reason: ORKTaskFinishReason,
            error: Error?
        ) {
            let taskResult = taskViewController.result

            _Concurrency.Task { @MainActor in
                switch reason {
                case .completed:
                    await result(.completed(taskResult))
                case .discarded, .earlyTermination:
                    await result(.cancelled)
                case .failed:
                    guard let error else {
                        preconditionFailure("ResearchKit broke API contract. Didn't supply error when indicating task failure.")
                    }
                    await result(.failed(error))
                case .saved:
                    break // we don't support that currently
                @unknown default:
                    break
                }

                if let outputDirectory = taskViewController.outputDirectory {
                    do {
                        try FileManager.default.removeItem(at: outputDirectory)
                    } catch {
                        logger.error("Failed to delete the temporary output directory: \(error)")
                    }
                }
            }
        }

        public func taskViewController(_ taskViewController: ORKTaskViewController, shouldPresent step: ORKStep) -> Bool {
            shouldPresentStep?(taskViewController, step) ?? true
        }
    }

    
    private static let logger = Logger(subsystem: "edu.stanford.spezi.researchkit", category: "ORKOrderedTaskView")


    private let taskId: UUID
    private let tasks: ORKOrderedTask
    private let tintColor: Color
    private let cancelBehavior: CancelBehavior

    private let result: @MainActor (TaskResult) async -> Void


    @Environment(\.onStepWillAppear)
    private var onStepWillAppear
    @Environment(\.onStepWillDisappear)
    private var onStepWillDisappear
    @Environment(\.shouldPresentStep)
    private var shouldPresentStep


    private var outputDirectory: URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("edu.stanford.spezi.researchkit-task-\(taskId.uuidString)")

        if !FileManager.default.fileExists(atPath: directory.path) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                ORKOrderedTaskView.logger.error("Failed to create the temporary output directory: \(error)")
            }
        }

        return directory
    }


    /// Create a new `ORKOrderedTaskView`.
    ///
    /// - Parameters:
    ///   - tasks: The `ORKOrderedTask` that should be displayed by the underlying `ORKTaskViewController`.
    ///   - tintColor: The tint color to use with ResearchKit views.
    ///   - shouldConfirmCancel: Specifies the behavior of the "Cancel" button if it should ask for confirmation. The button is always presented.
    ///   - result: A closure receiving the ``TaskResult`` for the task view.
    @available(*, deprecated, message: "Use init(tasks:tintColor:cancelBehavior:result:) instead")
    public init( // swiftlint:disable:this function_default_parameter_at_end
        tasks: ORKOrderedTask,
        tintColor: Color = Color(UIColor(named: "AccentColor") ?? .systemBlue),
        shouldConfirmCancel: Bool,
        result: @escaping @MainActor (TaskResult) async -> Void
    ) {
        self.init(
            tasks: tasks,
            tintColor: tintColor,
            cancelBehavior: shouldConfirmCancel ? .shouldConfirmCancel : .cancel,
            result: result
        )
    }
    
    /// Create a new `ORKOrderedTaskView`.
    ///
    /// - Parameters:
    ///   - tasks: The `ORKOrderedTask` that should be displayed by the underlying `ORKTaskViewController`.
    ///   - tintColor: The tint color to use with ResearchKit views.
    ///   - cancelBehavior: Specifies the behavior of the "Cancel" button.
    ///   - result: A closure receiving the ``TaskResult`` for the task view.
    public init(
        tasks: ORKOrderedTask,
        tintColor: Color = Color(UIColor(named: "AccentColor") ?? .systemBlue),
        cancelBehavior: CancelBehavior = .shouldConfirmCancel,
        result: @escaping @MainActor (TaskResult) async -> Void
    ) {
        self.taskId = UUID()
        self.tasks = tasks
        self.tintColor = tintColor
        self.cancelBehavior = cancelBehavior
        self.result = result
    }


    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(result: result, cancelBehavior: cancelBehavior)
        updateClosures(for: coordinator)
        return coordinator
    }

    public func updateUIViewController(_ uiViewController: ORKTaskViewController, context: Context) {
        uiViewController.view.tintColor = UIColor(tintColor)
        uiViewController.delegate = context.coordinator

        context.coordinator.result = result
        context.coordinator.cancelBehavior = cancelBehavior
        updateClosures(for: context.coordinator)
    }

    public func makeUIViewController(context: Context) -> ORKTaskViewController {
        // Create a new instance of the view controller and pass in the assigned delegate.
        let viewController = ORKTaskViewController(task: tasks, taskRun: taskId)
        viewController.view.tintColor = UIColor(tintColor)
        viewController.delegate = context.coordinator
        viewController.outputDirectory = outputDirectory
        return viewController
    }

    private func updateClosures(for coordinator: Coordinator) {
        coordinator.stepWillAppear = onStepWillAppear
        coordinator.stepWillDisappear = onStepWillDisappear
        coordinator.shouldPresentStep = shouldPresentStep
    }
}
