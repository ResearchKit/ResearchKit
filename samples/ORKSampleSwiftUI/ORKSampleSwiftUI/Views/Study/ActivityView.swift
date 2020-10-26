/*
Copyright (c) 2020, Helio Tejedor. All rights reserved.

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
import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    var activity: Activity
    var onCompleted: (Bool) -> Void

    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let result: ORKTaskViewController
        switch activity {
        case .survey:
            result = ORKTaskViewController(task: StudyTasks.surveyTask, taskRun: NSUUID() as UUID)
        
        case .microphone:
            result = ORKTaskViewController(task: StudyTasks.microphoneTask, taskRun: NSUUID() as UUID)
            
            do {
                let defaultFileManager = FileManager.default
                
                // Identify the documents directory.
                let documentsDirectory = try defaultFileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                
                // Create a directory based on the `taskRunUUID` to store output from the task.
                let outputDirectory = documentsDirectory.appendingPathComponent(result.taskRunUUID.uuidString)
                try defaultFileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
                
                result.outputDirectory = outputDirectory
            } catch let error as NSError {
                fatalError("The output directory for the task with UUID: \(result.taskRunUUID.uuidString) could not be created. Error: \(error.localizedDescription)")
            }
            
        case .tapping:
            result = ORKTaskViewController(task: StudyTasks.tappingTask, taskRun: NSUUID() as UUID)
        
        case .trailmaking:
            result = ORKTaskViewController(task: StudyTasks.trailmakingTask, taskRun: NSUUID() as UUID)
        }
        result.view.window?.tintColor = UIColor(named: "AccentColor")
        return result
    }
    
    func updateUIViewController(_ uiViewController: ORKTaskViewController, context: Context) {
        uiViewController.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onCompleted: onCompleted)
    }
    
    class Coordinator: NSObject, ORKTaskViewControllerDelegate {
        var onCompleted: (Bool) -> Void

        init(onCompleted: @escaping (Bool) -> Void) {
            self.onCompleted = onCompleted
        }

        public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
            self.onCompleted(reason == .completed)
        }
        
        func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
            return nil
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(activity: .survey) { _ in }
    }
}
