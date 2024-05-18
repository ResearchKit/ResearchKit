//
// This source file is part of the Stanford Biodesign Digital Health Group open-source organization
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ResearchKit
import ResearchKitSwiftUI
import SwiftUI


struct ORKOrderedTaskViewTests: View {
    private let task: ORKOrderedTask
    private let result: @MainActor (ORKTaskResult) async -> Void

    @Environment(\.dismiss)
    var dismiss


    var body: some View {
        ORKOrderedTaskView(tasks: task) { result in
            dismiss()

            guard case let .completed(taskResult) = result else {
                return // user cancelled or error
            }

            await self.result(taskResult)
        }
    }


    init(task: ORKOrderedTask, result: @escaping @MainActor (ORKTaskResult) async -> Void) {
        self.task = task
        self.result = result
    }
}


extension ORKOrderedTask {
    static var trailMarkingTestTask: ORKOrderedTask {
        .trailmakingTask(
            withIdentifier: "your-trailmaking-task-id",
            intendedUseDescription: "Tests visual attention and task switching",
            trailmakingInstruction: nil,
            trailType: .B,
            options: []
        )
    }

    static var stroopTestTask: ORKOrderedTask {
        .stroopTask(
            withIdentifier: "StroopTask",
            intendedUseDescription: "Tests selective attention capacity and processing speed",
            numberOfAttempts: 10,
            options: [.excludeAudio]
        )
    }
}


#Preview {
    ORKOrderedTaskViewTests(task: .stroopTestTask) { _ in
    }
}
