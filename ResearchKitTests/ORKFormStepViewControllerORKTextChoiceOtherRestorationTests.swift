/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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
import ResearchKit

class ORKFormStepViewControllerORKTextChoiceOtherRestorationTests: XCTestCase {
    var formStepWithSingleTextChoiceOther: ORKFormStep {
        let step = ORKFormStep(
            identifier: "formstep",
            title: "formStep",
            text: nil
        )
        step.formItems = [
            ORKFormItem(
                identifier: "item1",
                text: "item1",
                answerFormat: 
                    ORKTextChoiceAnswerFormat(
                            style:.singleChoice,
                            textChoices: [
                                ORKTextChoice(
                                    text: "option1",
                                    value: 1 as NSNumber
                                ),
                                ORKTextChoiceOther.choice(
                                    withText: "choice 8",
                                    detailText: "",
                                    value: 8 as NSNumber,
                                    exclusive: true,
                                    textViewPlaceholderText: "Tap to write your answer"
                                )
                            ]
                        )
                )
            ]
        return step
    }
    
    var formStepWithMultipleTextChoiceOther: ORKFormStep {
        let step = ORKFormStep(
            identifier: "formstep",
            title: "formStep",
            text: nil
        )
        step.formItems = [
            ORKFormItem(
                identifier: "item1",
                text: "item1",
                answerFormat:
                    ORKTextChoiceAnswerFormat(
                        style: .singleChoice,
                        textChoices: [
                            ORKTextChoice(text: "option1", value: 1 as NSNumber),
                            ORKTextChoiceOther.choice(
                                withText: "choice 8",
                                detailText: "",
                                value: 8 as NSNumber,
                                exclusive: true,
                                textViewPlaceholderText: "Tap to write your answer"
                            ),
                            ORKTextChoiceOther.choice(
                                withText: "choice 9",
                                detailText: "", value: 9 as NSNumber,
                                exclusive: true,
                                textViewPlaceholderText: "Tap to write your answer"
                            )
                        ]
                    )
            )
        ]
        return step
    }
    
    func testORKChoiceRestorationWithSingleTextChoiceOther() {
        let step = formStepWithSingleTextChoiceOther
        let formStepViewController = ORKFormStepViewController(step: step)
        let savedAnswers = ["text"]
        formStepViewController.restoreTextChoiceOtherCellState(
            withSavedAnswer: savedAnswers,
            formItem: step.formItems!.last!,
            choiceOtherViewCell: ORKChoiceOtherViewCell()
        )
        
        checkTextChoiceRestoredCorrectly(
            step: step,
            hasStandardTextChoiceOtherArrangement: true,
            expectedRestoredTextViewText: "text"
        )
    }
    
    func testORKChoiceRestorationWithMultipleTextChoiceOther() {
        let step = formStepWithMultipleTextChoiceOther
        let formStepViewController = ORKFormStepViewController(step: step)
        let savedAnswers = ["text"]
        formStepViewController.restoreTextChoiceOtherCellState(
            withSavedAnswer: savedAnswers,
            formItem: step.formItems!.first!,
            choiceOtherViewCell: ORKChoiceOtherViewCell()
        )
        checkTextChoiceRestoredCorrectly(
            step: step,
            hasStandardTextChoiceOtherArrangement: false,
            expectedRestoredTextViewText: nil
        )
    }
    
    func checkTextChoiceRestoredCorrectly(step: ORKFormStep, hasStandardTextChoiceOtherArrangement: Bool, expectedRestoredTextViewText: String?) {
        guard let formItems = step.formItems else {
            XCTFail("No formItems found")
            return
        }
        
        guard let firstFormItem = formItems.first else {
            XCTFail("No formItems found")
            return
        }
        
        guard let firstFormItemAnswerFormat = firstFormItem.answerFormat else {
            XCTFail("No answerFormat found")
            return
        }
        
        let textChoiceAnswerFormat = firstFormItemAnswerFormat as! ORKTextChoiceAnswerFormat
        XCTAssertEqual(textChoiceAnswerFormat.hasStandardTextChoiceOtherArrangement(), hasStandardTextChoiceOtherArrangement)
        
        guard let lastTextChoiceOther = textChoiceAnswerFormat.textChoices.last as? ORKTextChoiceOther else {
            XCTFail("No textChoiceOthers found")
            return
        }
        
        if let expectedRestoredTextViewText = expectedRestoredTextViewText {
            XCTAssertEqual(lastTextChoiceOther.textViewText, expectedRestoredTextViewText)
        } else {
            XCTAssertEqual(lastTextChoiceOther.textViewText, nil)
        }
    }
}

