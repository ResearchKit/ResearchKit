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


@main
struct UITestsApp: App {
    @State private var showStroop = false
    @State private var showTrailMarking = false

    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    Button("Show Stroop") {
                        showStroop = true
                    }
                    Button("Show Trail Marking") {
                        showTrailMarking = true
                    }
                }
                .navigationTitle("ResearchKit")
            }
                .sheet(isPresented: $showStroop) {
                    ORKOrderedTaskViewTests(task: .stroopTestTask) { _ in
                    }
                }
                .sheet(isPresented: $showTrailMarking) {
                    ORKOrderedTaskViewTests(task: .trailMarkingTestTask) { _ in
                    }
                }
        }
    }
}
