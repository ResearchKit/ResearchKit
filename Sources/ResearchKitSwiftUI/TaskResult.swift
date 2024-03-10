//
// This source file is part of the Stanford Biodesign Digital Health Group open-source organization
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ResearchKit


/// The result of a `ORKOrderedTask` presented using `ORKOrderedTaskView`.
public enum TaskResult {
    /// The task was successfully completed with the provided `ORKTaskResult`.
    case completed(_ result: ORKTaskResult)
    /// The task was cancelled by the user.
    case cancelled
    /// An error occurred while completing the task.
    case failed(_ error: Error)
}
