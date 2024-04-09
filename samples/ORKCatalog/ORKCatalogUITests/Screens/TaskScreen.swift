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

import Foundation
import XCTest

struct TaskScreen {
    let app = XCUIApplication()
    
    var surveyTasks = [
        "Don't Know Survey",
        "Form Survey Example",
        "Grouped Form Survey Example",
        "Simple Survey Example",
        "Survey With Multiple Options"
    ]
    
    var surveyQuestions = [
        "Boolean Question",
        "Custom Boolean Question",
        "Date Question",
        "Date and Time Question",
        "Date and Time 3 day Limit Question",
        "Health Quantity Question",
        "Height Question",
        "Weight Question",
        "Image Choice Question",
        "Location Question",
        "Numeric Question",
        "Scale Question",
        "Text Question",
        "Text Choice Question",
        "Text Choice Image Question",
        "Time Interval Question",
        "Time of Day Question",
        "Value Picker Choice Question",
        "Validated Text Question",
        "Front Facing Camera Step",
        "Image Capture Step",
        "PDF Viewer Step",
        "Request Permissions Step",
        "Video Capture Step",
        "Video Instruction",
        "Wait Step",
        "Web View"
    ]
    
    var activeTasks: [String] {
        let tasks = [
            "Audio",
            "Amsler Grid",
            "dBHL Tone Audiometry",
            "Fitness Check",
            "Hole Peg Test",
            "Knee Range of Motion",
            "Normalized Reaction Time",
            "PSAT",
            "Reaction Time",
            "Short Walk",
            "Shoulder Range of Motion",
            "Six Minute Walk",
            "Spatial Span Memory",
            "Speech in Noise",
            "Speech Recognition",
            "Environment SPL Meter",
            "Stroop",
            "Tecumseh Cube Test",
            "Timed Walk with Turn Around",
            "Tone Audiometry",
            "Tower of Hanoi",
            "Tremor Test",
            "Two Finger Tapping Interval",
            "Walk Back and Forth",
            // "Trail Making Test"
            ]
        
        return tasks
    }
    
    var mainTaskScreen: XCUIElement {
        app.navigationBars["ORKCatalog"].staticTexts["ORKCatalog"]
    }
    
    func getCurrentTask(task: String) -> XCUIElement? {
        return app.tables.staticTexts[task]
    }
}
