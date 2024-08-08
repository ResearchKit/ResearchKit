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

class Helpers: XCTestCase {
    let app = XCUIApplication()
    let commonElements = CommonElements()
    let taskScreen = TaskScreen()
    
    enum SliderTesting {
        case slider1
        case slider2
        case slider3
        case slider4
        case slider5
        case slider6
    }
    enum SwipeDirection {
        case up
        case down
        case left
        case right
        case skip
    }
  
    //Verify existence of any XCUIElement with an option to tap that element
    func verifyElement(_ element: XCUIElement, _ tap: Bool = false) -> Bool {
        if element.exists {
            if tap && element.isEnabled {
                element.tap()
            }
            return true
        }
        XCTFail("Unable to confirm \(element) exists")
        return false
    }
    
    //Verify an element exists based on static text label, option to tap the element after verification
    func verifyElementByText(identifier: String, _ tap: Bool = false) -> Bool {
        let item = app.staticTexts["\(identifier)"]
        if item.exists {
            if tap && item.isEnabled {
                item.tap()
            }
            return true
        }
        XCTFail("Unable to locate Element based on text \(identifier)")
        return false
    }
    
    //Verify an element matching XCUIElement.ElementType exists based on an identifying string existing in the label or value of the element.
    func verifyElementByType(_ elementType: XCUIElement.ElementType, _ identifier: String, _ tap: Bool = false) -> Bool {
        let identifyingOptions = ["label", "value"]
        for option in identifyingOptions {
            let predicate = NSPredicate(format: "\(option) CONTAINS '\(identifier)'")
            let target = app.descendants(matching: elementType).element(matching: predicate)
            if target.exists {
                if tap && target.isEnabled {
                    target.tap()
                }
                return true
            }
        }
        XCTFail("Unable to locate Element based on text \(identifier)")
        return false
    }
    
    //Verify any XCUIElement exists and return that element for assignment, option to tap available
    func verifyAndAssign(_ element: XCUIElement, _ tap: Bool = false) -> XCUIElement? {
        if element.exists {
            if tap && element.isEnabled {
                element.tap()
            }
            return element
        }
        XCTFail("Unable to confirm \(element) exists")
        return nil
    }
    
    //Verify an element exists based on static text label, option to tap the element after verification. Element returned for assignment.
    func verifyAndAssignByText(_ identifier: String, _ tap: Bool = false) -> XCUIElement? {
        let item = app.staticTexts["\(identifier)"]
        if item.exists {
            if tap && item.isEnabled {
                item.tap()
            }
        return item
        }
        XCTFail("Unable to locate Element based on text \(identifier)")
        return nil
    }
    
    //Verify an element matching XCUIElement.ElementType exists based on an identifying string existing in the label or value of the element.
    //Element returned for assignment.
    func verifyAndAssignByType(_ elementType: XCUIElement.ElementType, _ identifier: String, _ tap: Bool = false) -> XCUIElement? {
        let identifyingOptions = ["label", "value"]
        for option in identifyingOptions {
            let predicate = NSPredicate(format: "\(option) CONTAINS '\(identifier)'")
            let target = app.descendants(matching: elementType).element(matching: predicate)
            if target.exists {
                if tap && target.isEnabled {
                    target.tap()
                }
                return target
            }
        }
        XCTFail("Unable to locate Element based on text \(identifier)")
        return nil
    }
    
    //Enter any ORKCatalog task based on the name of the task and leave without taking action
    func launchAndLeave(_ task: String) -> Bool {
        XCTAssert(verifyElement(taskScreen.mainTaskScreen))
        let currentTask = verifyAndAssignByText(task)!
        currentTask.tap()
        
        sleep(1)
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
        
        return verifyElement(taskScreen.mainTaskScreen)
    }
    
    //Deletes the ORKCatalog app from the simulator instance. 
    func deleteORKCatalog() {
        app.terminate()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let icon = springboard.icons["ORKCatalog"]
                if icon.exists {
                    icon.press(forDuration: 1.3)
                    springboard.buttons["Delete App"].tap()
                    sleep(2)
                    springboard.buttons["Delete"].tap()
                }
    }
    
    //Verify that the Navigation bar includes a page count in the form of "pageNumber of pageTotal"
    func verifyPageByCount(_ pageNumber: Int, _ pageTotal: Int) -> Bool {
        let pageCount = app.navigationBars["\(String(pageNumber)) of \(String(pageTotal))"]
        XCTAssert(pageCount.exists)
        return true
    }
    
    //Return an XCUIElement based on page number of the Scale test
    func scaleTitle(_ pageNumber: Int) -> XCUIElement? {
        let titles: [Int: String] = [1: "Discrete Scale", 2: "Continuous Scale", 3: "Discrete Vertical Scale", 4: "Continuous Vertical Scale", 5: "Text Scale", 6: "Text Vertical Scale"]
        return app.scrollViews.otherElements.staticTexts[titles[pageNumber] ?? "Invalid Page Number"]
    }
    
    //Select and interact with sliders in the Scale Question task. Function verifies expected outputs of each slider.
    func sliderValuesCheck(_ sliderScreen:SliderTesting, _ screenNum: Int, _ direction:SwipeDirection) -> Bool {
        let sliderValues: [SliderTesting:String] = [
            .slider1:"8",
            .slider3:"8",
            .slider4:"4.23",
            .slider5:"Above Average",
            .slider6:"Above Average"
        ]
        
        let slider = verifyAndAssignByType(.slider, "Response slider")!
        XCTAssert(slider.waitForExistence(timeout: 2), "Unable to locate slider on page \(screenNum)")
        XCTAssert(verifyPageByCount(screenNum, 6), "Unable to locate \"\(screenNum) of 6\"")
        XCTAssert(scaleTitle(screenNum)!.waitForExistence(timeout: 2), "Unable to locate \(scaleTitle(screenNum)!)")
       
        switch direction {
        case .up:
            slider.swipeUp()
        case .right:
            slider.swipeRight()
        case .left:
            XCTFail("Unexpected Swipe Direction of Left Entered")
        case .down:
            XCTFail("Unexpected Swipe Direction of Down Entered")
        case .skip:
            XCTAssert(commonElements.skipButton!.waitForExistence(timeout: 2))
            commonElements.skipButton!.tap()

        }
        
        if sliderScreen != .slider2 {
            XCTAssert(verifyElementByType(.slider, sliderValues[sliderScreen]!))
            if commonElements.doneButton!.exists {
                commonElements.doneButton!.tap()
                return true
            }
            XCTAssert(commonElements.nextButton!.waitForExistence(timeout: 2))
            commonElements.nextButton!.tap()
            return true
        }
        return true
    }
    
    //Returns true if sliders behave as expected on any given screen in the Scale Question task.
    func sliderScreenCheck(_ sliderScreen:SliderTesting) -> Bool {
        XCTAssert(verifyElement(app.scrollViews.otherElements.staticTexts["Scale"]))
        XCTAssert(verifyElement(app.scrollViews.otherElements.staticTexts["Your question here."]))
        
        switch sliderScreen {
        case .slider1:
            XCTAssert(sliderValuesCheck(sliderScreen, 1, .right), "Slider1 Values Check Failed")
        case .slider2:
            XCTAssert(sliderValuesCheck(sliderScreen, 2, .skip), "Slider2 Values Check Failed")
        case .slider3:
            XCTAssert(sliderValuesCheck(sliderScreen, 3, .up), "Slider3 Values Check Failed")
        case .slider4:
            XCTAssert(sliderValuesCheck(sliderScreen, 4, .up), "Slider4 Values Check Failed")
        case .slider5:
            XCTAssert(sliderValuesCheck(sliderScreen, 5, .right), "Slider5 Values Check Failed")
        case .slider6:
            XCTAssert(sliderValuesCheck(sliderScreen, 6, .up), "Slider6 Values Check Failed")
        }
        return true
    }
    
    //Monitors for any alerts that may appear and interupt the normal flow of the applicaiton.
    func monitorAlerts() {
        addUIInterruptionMonitor(withDescription: "Alert") { element in
            do {
            // Push Notification
                let button = element.buttons["Allow"]
                let title = element.staticTexts["“ORKCatalog” Would Like to Send You Notifications"]
                if title.exists && button.exists {
                    button.tap()
                    return true
                }
            }

            do {
            // Location
                let button = element.buttons["Allow While Using App"]
                if button.exists {
                    button.tap()
                    return true
                }
            }
              
            do {
                // Microphone
                let button = element.buttons["OK"]
                let title = element.staticTexts["“ORKCatalog” Would Like to Access the Microphone"]
                if title.exists && button.exists {
                    button.tap()
                    return true
                }
              }
          return false
        }
    }
    
    func verifyElementByText(_ text: String, _ tap: Bool = false) -> Bool {
        let item = app.staticTexts["\(text)"]
        XCTAssert(item.waitForExistence(timeout: 3))
        if tap && item.isEnabled {
            item.tap()
        }
        return true
    }
}
