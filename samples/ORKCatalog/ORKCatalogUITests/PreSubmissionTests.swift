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

import XCTest

class PreSubmissionTests: XCTestCase {
    let app = XCUIApplication()
    let commonElements = CommonElements()
    let allowScreens = AllowScreens()
    let helpers = Helpers()
    let taskScreen = TaskScreen()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        helpers.monitorAlerts()
        app.launch()

    }

    override func tearDownWithError() throws {

    }
    
    func testAccessSurveyTasks() throws {
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        
        for task in taskScreen.surveyTasks {
            XCTAssert(helpers.launchAndLeave(task))
        }
    }
    
    func testAccessSurveyQuestions() throws {
        XCTAssert(allowScreens.triggerAllowScreens())
        
        for task in taskScreen.surveyQuestions {
            XCTAssert(helpers.launchAndLeave(task))
        }
        
        return
    }
    
    func testAccessActiveTasks() throws {
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        
        for task in taskScreen.activeTasks {
            XCTAssert(helpers.launchAndLeave(task))
        }
        
        return
    }

    func testWrittenMultipleChoice() throws {
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        let options = ["Choice 1", "Choice 2", "Choice 3", "Other"]
        let required = ["Text Choice", "Additional text can go here.", "Your question here."]
        
        XCTAssert(helpers.verifyElementByText("Text Choice Question", true))
        
        for item in required {
            XCTAssert(app.tables.staticTexts[item].exists, "Unable to locate the \(item) element.")
        }
        
        XCTAssert(helpers.verifyElementByText(options.randomElement()!, true))
        
        XCTAssert(helpers.verifyElementByType(.button, "Done", true))
        return
    }
    
    func testImageMultipleChoice() throws {
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        XCTAssert(helpers.verifyElementByText("Image Choice Question", true))
        
        let required = ["Image Choice", "Additional text can go here."]
        for item in required {
            XCTAssert(helpers.verifyElementByText(item))
        }
        
        let square = helpers.verifyAndAssignByType(.button, "Square Shape")!
        let circle = helpers.verifyAndAssignByType(.button, "Round Shape")!
    
        square.tap()
        
        XCTAssert(helpers.verifyElementByType(.button, "Next", true))
        XCTAssert(helpers.verifyPageByCount(2, 2))
        XCTAssert(helpers.verifyElementByType(.button, "Back", true))
        XCTAssert(helpers.verifyPageByCount(1, 2))
        square.tap()
        circle.tap()
        
        XCTAssert(helpers.verifyElementByType(.button, "Next", true))
        XCTAssert(helpers.verifyPageByCount(2, 2))
        circle.tap()
        
        XCTAssert(helpers.verifyElementByType(.button, "Done", true))
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        return
    }
    
    func testSQPickerWheel() throws {
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        
        let dt = helpers.verifyAndAssignByText("Date and Time Question")!
        let elementsQuery = app.scrollViews.otherElements.staticTexts
        
        dt.tap()
        XCTAssert(elementsQuery["Date and Time"].exists)
        XCTAssert(elementsQuery["Additional text can go here."].exists)
        XCTAssert(elementsQuery["Your question here."].exists)
        
        let skip = helpers.verifyAndAssignByText("Skip")!
        XCTAssert(skip.isEnabled)
        
        let done = helpers.verifyAndAssignByType(.button, "Done")!
        XCTAssert(done.isEnabled)
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("a")
        let datetime = formatter.string(from: now)
        formatter.setLocalizedDateFormatFromTemplate("MMM dd")
        let newDate = Calendar.current.date(byAdding: .day, value: 5, to: now)
        let newDateString = formatter.string(from: newDate!)
        
        let firstPredicate = NSPredicate(format: "value BEGINSWITH 'Today'")
        let firstPicker = app.pickerWheels.element(matching: firstPredicate)
        XCTAssert(firstPicker.isEnabled)
        firstPicker.adjust(toPickerWheelValue: newDateString)
        
        let secondPicker = helpers.verifyAndAssignByType(.pickerWheel, "clock")!
        XCTAssert((secondPicker.isEnabled))
        secondPicker.adjust(toPickerWheelValue: "5")
        
        let thirdPicker = helpers.verifyAndAssignByType(.pickerWheel, "minute")!
        XCTAssert(thirdPicker.isEnabled)
        thirdPicker.adjust(toPickerWheelValue: "23")
        let fourthPredicate = NSPredicate(format: "value CONTAINS '\(datetime)'")
        let fourthPicker = app.pickerWheels.element(matching: fourthPredicate)
        XCTAssert(fourthPicker.isEnabled)
        datetime == "AM" ? fourthPicker.adjust(toPickerWheelValue: "PM") : fourthPicker.adjust(toPickerWheelValue: "AM")
        
        XCTAssert(done.isEnabled)
        done.tap()
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        
        dt.tap()
        skip.tap()
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
    
        return
    }
    
    func testSQSliders() throws {
        XCTAssert(helpers.verifyElementByText("Scale Question", true))
        
        XCTAssert(helpers.sliderScreenCheck(.slider1))
        XCTAssert(helpers.sliderScreenCheck(.slider2))
        XCTAssert(helpers.sliderScreenCheck(.slider3))
        XCTAssert(helpers.sliderScreenCheck(.slider4))
        XCTAssert(helpers.sliderScreenCheck(.slider5))
        XCTAssert(helpers.sliderScreenCheck(.slider6))
        
        XCTAssert(helpers.sliderScreenCheck(.slider1))
        XCTAssert(helpers.sliderScreenCheck(.slider2))
        XCTAssert(helpers.sliderScreenCheck(.slider3))
        XCTAssert(helpers.sliderScreenCheck(.slider4))
        XCTAssert(helpers.sliderScreenCheck(.slider5))
        XCTAssert(helpers.sliderScreenCheck(.slider6))
        
        XCTAssert(taskScreen.mainTaskScreen.waitForExistence(timeout: 5))
        return
    }
    
    func testSQTextEntry() throws {
        let testString = "The wonderful thing about tiggers is tiggers are wonderful things! Their tops are made out of rubber, their bottoms are made out of springs!"
        
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        XCTAssert(helpers.verifyElementByText("Text Question", true))
        guard let done = commonElements.doneButton else {
            XCTFail("Unable to locate done button")
            return
        }
        XCTAssertFalse(done.isEnabled)
        XCTAssert(helpers.verifyElementByText("Text"))
        XCTAssert(helpers.verifyElementByText("Additional text can go here."))
        
        let textView = app.textViews.element(boundBy: 0)
        XCTAssert(textView.waitForExistence(timeout: 5))
        textView.tap()
        
        app.typeText(testString)
        XCTAssert(helpers.verifyElementByText("140/280"))
        
        let clear = app.buttons["Clear"]
        XCTAssert(clear.waitForExistence(timeout: 3))
        clear.tap()
        
        XCTAssert(helpers.verifyElementByText("0/280"))
        app.typeText(testString)
        
        XCTAssert(commonElements.doneButton!.firstMatch.exists)
        commonElements.doneButton!.firstMatch.tap()
        
        done.tap()
        
        XCTAssert(helpers.verifyElement(taskScreen.mainTaskScreen))
        
        return
    }

}
