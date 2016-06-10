/*
Copyright (c) 2015, Apple Inc. All rights reserved.

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

enum Activity: Int {
    case Survey, Microphone, Tapping
    
    static var allValues: [Activity] {
        var idx = 0
        return Array(anyGenerator{ return self.init(rawValue: idx++)})
    }
    
    var title: String {
        switch self {
            case .Survey:
                return "Survey"
            case .Microphone:
                return "Microphone"
            case .Tapping:
                return "Tapping"
        }
    }
    
    var subtitle: String {
        switch self {
            case .Survey:
                return "Answer 6 short questions"
            case .Microphone:
                return "Voice evaluation"
            case .Tapping:
                return "Test tapping speed"
        }
    }
}

class ActivityViewController: UITableViewController {
    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else { return 0 }
        
        return Activity.allValues.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("activityCell", forIndexPath: indexPath)
        
        if let activity = Activity(rawValue: indexPath.row) {
            cell.textLabel?.text = activity.title
            cell.detailTextLabel?.text = activity.subtitle
        }

        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let activity = Activity(rawValue: indexPath.row) else { return }
        
        let taskViewController: ORKTaskViewController
        switch activity {
            case .Survey:
                taskViewController = ORKTaskViewController(task: StudyTasks.surveyTask, taskRunUUID: NSUUID())
            
            case .Microphone:
                taskViewController = ORKTaskViewController(task: StudyTasks.microphoneTask, taskRunUUID: NSUUID())
                
                do {
                    let defaultFileManager = NSFileManager.defaultManager()
                    
                    // Identify the documents directory.
                    let documentsDirectory = try defaultFileManager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
                    
                    // Create a directory based on the `taskRunUUID` to store output from the task.
                    let outputDirectory = documentsDirectory.URLByAppendingPathComponent(taskViewController.taskRunUUID.UUIDString)
                    try defaultFileManager.createDirectoryAtURL(outputDirectory, withIntermediateDirectories: true, attributes: nil)
                    
                    taskViewController.outputDirectory = outputDirectory
                }
                catch let error as NSError {
                    fatalError("The output directory for the task with UUID: \(taskViewController.taskRunUUID.UUIDString) could not be created. Error: \(error.localizedDescription)")
                }
                
            case .Tapping:
                taskViewController = ORKTaskViewController(task: StudyTasks.tappingTask, taskRunUUID: NSUUID())
        }

        taskViewController.delegate = self
        navigationController?.presentViewController(taskViewController, animated: true, completion: nil)
    }
}

extension ActivityViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        // Handle results using taskViewController.result
        taskViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
