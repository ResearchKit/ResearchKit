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

struct AllowScreens {
    let app = XCUIApplication()
    let commonElements = CommonElements()
    let taskScreen = TaskScreen()
    
    var healthAccessScreen: XCUIElement {
        app.navigationBars.staticTexts["Health Access"]
    }
    
    var locationAccessAlert: XCUIElement {
        app.alerts["Allow “ORKCatalog” to use your location?"]
    }
    
    func allowHealthAccess() {
        if healthAccessScreen.exists {
            app.tables.staticTexts["Turn All Categories On"].tap()
            sleep(1)
            app.navigationBars["Health Access"].buttons["Allow"].tap()
        }
    }
    
    func allowLocationServices() {
        if locationAccessAlert.exists {
            locationAccessAlert.scrollViews.otherElements.buttons["Allow While Using App"].tap()
        }
    }
    
    func triggerAllowScreens() -> Bool {
        let healthTriggers = ["Height Question", "Weight Question"]
        XCTAssert(commonElements.verifyElement(taskScreen.mainTaskScreen))

        for task in healthTriggers {
            let healthTask = app.tables.staticTexts[task]
            healthTask.tap()
            
            sleep(3)
            allowHealthAccess()
            
            sleep(2)
            guard let cancelButton = commonElements.cancelButton else {
                XCTFail("Unable to locate Cancel Button")
                return false
            }
            cancelButton.tap()
            
            sleep(1)
            guard let exitButton = commonElements.getExitButton() else {
                XCTFail("Unable to locate End Task or Discard Results button")
                return false
            }
            exitButton.tap()
            
            XCTAssert(taskScreen.mainTaskScreen.exists)
        }
        
        return true
    }
}
