//
// This source file is part of the Stanford Biodesign Digital Health Group open-source organization
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


class ORKOrderedTaskViewTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
    }
    

    @MainActor
    func testStroopTest() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssert(app.staticTexts["ResearchKit"].waitForExistence(timeout: 5.0))

        XCTAssert(app.buttons["Show Stroop"].exists)
        app.buttons["Show Stroop"].tap()

        XCTAssert(app.staticTexts["Stroop"].waitForExistence(timeout: 2.0))
        XCTAssert(app.staticTexts["Tests selective attention capacity and processing speed"].exists)

        XCTAssert(app.buttons["Next"].exists)
        app.buttons["Next"].tap()

        XCTAssert(app.staticTexts["1 of 3"].waitForExistence(timeout: 2.0))
        XCTAssert(app.buttons["Get Started"].exists)
        app.buttons["Get Started"].tap()

        XCTAssert(app.staticTexts["2 of 3"].waitForExistence(timeout: 2.0))

        // There is a 5 second countdown before that
        XCTAssert(app.staticTexts["Select the first letter of the name of the COLOR that is shown."].waitForExistence(timeout: 10))
        XCTAssert(app.staticTexts["3 of 3"].exists)

        XCTAssert(app.buttons["R"].exists)
        XCTAssert(app.buttons["G"].exists)
        XCTAssert(app.buttons["B"].exists)
        XCTAssert(app.buttons["Y"].exists)


        XCTAssert(app.buttons["Cancel"].exists)
        app.buttons["Cancel"].tap()

        XCTAssert(app.buttons["End Task"].waitForExistence(timeout: 2.0))
        app.buttons["End Task"].tap()

        sleep(1)
    }
}
