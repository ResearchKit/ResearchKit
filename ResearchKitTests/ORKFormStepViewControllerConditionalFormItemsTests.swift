/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

final class ORKFormStepViewControllerConditionalFormItemsTests: XCTestCase {
        
    func testBasicFormItemsAccessors() throws {
        let formStepViewController = ORKFormStepViewController(step: FormStepTestUtilities.simpleFormStep())
        
        let allFormItems = formStepViewController.allFormItems()
        let visibleFormItems = formStepViewController.visibleFormItems()
        let answerableFormItems = formStepViewController.answerableFormItems()

        XCTAssertEqual(allFormItems, visibleFormItems, "all formItems should be visible")
        XCTAssertEqual(answerableFormItems.count, visibleFormItems.count - 1, "there's one formItem that shouldn't be answerable")
        XCTAssertEqual(visibleFormItems[0].text, FormStepTestUtilities.SectionTitle, "Expected the first visible formItem to be an unanswerable section formItem with text")
        
        // confirm the allFormItems identifiers
        do {
            let identifiers = allFormItems.map({ eachFormItem -> String in
                return eachFormItem.identifier
            })
            XCTAssertEqual(identifiers, [allFormItems[0].identifier, "item1", "item2", "item3"])
        }

        // confirm the visibleFormItems identifiers
        do {
            let identifiers = visibleFormItems.map({ eachFormItem -> String in
                return eachFormItem.identifier
            })
            XCTAssertEqual(identifiers, [allFormItems[0].identifier, "item1", "item2", "item3"])
        }

        // confirm the answerableFormItems identifiers
        do {
            let identifiers = answerableFormItems.map({ eachFormItem -> String in
                return eachFormItem.identifier
            })
            XCTAssertEqual(identifiers, ["item1", "item2", "item3"])
        }
    }
    

    
    func testConditionalFormItemsAccessors() throws {
        let formStepViewController = ORKFormStepViewController(step: FormStepTestUtilities.conditionalFormStep())
        
        let allFormItems = formStepViewController.allFormItems()
        let visibleFormItems = formStepViewController.visibleFormItems()
        let answerableFormItems = formStepViewController.answerableFormItems()

        XCTAssertEqual(answerableFormItems.count, visibleFormItems.count - 1, "there's one formItem that shouldn't be answerable")
        XCTAssertEqual(visibleFormItems[0].text, FormStepTestUtilities.SectionTitle, "Expected the first visible formItem to be an unanswerable section formItem with text")
        
        // confirm the allFormItems identifiers
        do {
            let identifiers = allFormItems.map({ eachFormItem -> String in
                return eachFormItem.identifier
            })
            XCTAssertEqual(identifiers, [allFormItems[0].identifier, "item1", "item2", "item3"])
        }

        // confirm the visibleFormItems identifiers
        do {
            let identifiers = visibleFormItems.map({ eachFormItem -> String in
                return eachFormItem.identifier
            })
            XCTAssertEqual(identifiers, [allFormItems[0].identifier, "item1", "item2"])
        }

        // confirm the answerableFormItems identifiers
        do {
            let identifiers = answerableFormItems.map({ eachFormItem -> String in
                return eachFormItem.identifier
            })
            XCTAssertEqual(identifiers, ["item1", "item2"])
        }
    }

    func testEmptyTaskResult() throws {

        let mainTask = ORKOrderedTask(identifier: "mainTaskIdentifier", steps: [
            FormStepTestUtilities.simpleBooleanFormStep(),
            FormStepTestUtilities.simpleFormStep()
        ])
        let mainTaskVC = ORKTaskViewController(task: mainTask, taskRun: nil)
        
        // go to the first step to generate results
        mainTaskVC.flipToPage(withIdentifier: FormStepTestUtilities.QuestionStepIdentifier, forward: true, animated: false)

        // generate results for the formStep
        mainTaskVC.flipToPage(withIdentifier: FormStepTestUtilities.FormStepIdentifier, forward: true, animated: false)

        // test that the taskViewController.result contains everything, including formStep results
        do {
            let result = mainTaskVC.result
            XCTAssertEqual(result.results?.count, 2)
            
            let simpleQuestionResult = result.results?[0] as? ORKStepResult
            XCTAssertEqual(simpleQuestionResult?.identifier, FormStepTestUtilities.QuestionStepIdentifier)
            
            let formStepResult = result.results?[1] as? ORKStepResult
            XCTAssertEqual(formStepResult?.identifier, FormStepTestUtilities.FormStepIdentifier)
            XCTAssertEqual(formStepResult?.results?.count, 3, "expected to have 3 results in the formStep stepResult")

            // because we forcibly skipped to the viewController without answering, all the answers should be nil
            do {
                let formItemResult = formStepResult?.results?[0] as? ORKBooleanQuestionResult
                XCTAssertEqual(formItemResult?.booleanAnswer, nil)
            }

            do {
                let formItemResult = formStepResult?.results?[1] as? ORKTextQuestionResult
                XCTAssertEqual(formItemResult?.textAnswer, nil)
            }

            do {
                let formItemResult = formStepResult?.results?[2] as? ORKTextQuestionResult
                XCTAssertEqual(formItemResult?.textAnswer, nil)
            }
        }

        // formStepViewController's _ongoingTaskResult provide results for *both* the
        // preceding question step and the current form step
        do {
            let formStepViewController = mainTaskVC.currentStepViewController as? ORKFormStepViewController
            let result = formStepViewController?._ongoingTaskResult()
            XCTAssertEqual(result?.results?.count, 2)
            XCTAssertEqual(result?.results?[0].identifier, FormStepTestUtilities.QuestionStepIdentifier)
            XCTAssertEqual(result?.results?[1].identifier, FormStepTestUtilities.FormStepIdentifier)
        }
    }
    
    func testEvaluatingTaskResultPreviousQuestionStep() throws {
        let mainTask = ORKOrderedTask(identifier: "mainTaskIdentifier", steps: [
            FormStepTestUtilities.simpleBooleanFormStep(),
            FormStepTestUtilities.conditionalFormStep()
        ])
        let mainTaskVC = ORKTaskViewController(task: mainTask, taskRun: nil)
        
        func simulateAnsweringQuestion(with yesOrNo: Bool) {
            let formStepViewController = mainTaskVC.currentStepViewController as! ORKFormStepViewController
            let index = (yesOrNo == true) ? 0 : 1 // index 0 == YES, index 1 == NO
            formStepViewController.simulateSelectingAnswerAtIndex(index)
        }
        
        func questionStepAnswer(in taskResult: ORKTaskResult) -> Bool? {
            let questionStep = taskResult.result(forIdentifier: FormStepTestUtilities.QuestionStepIdentifier) as? ORKStepResult
            let questionResult = questionStep?.firstResult as? ORKQuestionResult
            let result = (questionResult?.answer as? NSNumber)?.boolValue
            return result
        }
        
        // go to the first step so we can drive the UI to simulate a user responding
        mainTaskVC.flipToPage(withIdentifier: mainTask.steps[0].identifier, forward: true, animated: false)

        do {
            simulateAnsweringQuestion(with: true) // our visibilityRule evaluates to true when questionStep's answer is true

            // now move to the formStepViewController to have it generate results.
            // Those results come from visibilityRules on the formItems that can use the
            // questionStep's result in the ongoing task result
            mainTaskVC.flipToPage(withIdentifier: mainTask.steps[1].identifier, forward: true, animated: false)

            // test that the taskViewController.result contains everything, including formStep
            // results, even for the conditional one
            let taskResult = mainTaskVC.result

            // make sure answering the question worked
            XCTAssertEqual(questionStepAnswer(in: taskResult), true, "We tried to set the answer to true, but the result wasn't true")

            let stepResult = taskResult.stepResult(forStepIdentifier: FormStepTestUtilities.ConditionalFormStepIdentifier)
            XCTAssertNotNil(stepResult?.result(forIdentifier: "item1"))
            XCTAssertNotNil(stepResult?.result(forIdentifier: "item2"))
            XCTAssertNotNil(
                stepResult?.result(forIdentifier: "item3"),
                "If the answer to the question step was yes, item3 should be in the result"
            )
        }
        
        // go back to the first step so we can change the answer
        mainTaskVC.flipToPage(withIdentifier: mainTask.steps[0].identifier, forward: false, animated: false)
        
        do {
            simulateAnsweringQuestion(with: false) // our visibilityRule evaluates to false when questionStep's answer is false

            mainTaskVC.flipToPage(withIdentifier: mainTask.steps[1].identifier, forward: true, animated: false)

            // test that the taskViewController.result contains everything, including formStep
            // results *except* for the conditional ones that should evaluate to NO
            let taskResult = mainTaskVC.result

            // make sure answering the question worked
            XCTAssertEqual(questionStepAnswer(in: taskResult), false, "We tried to set the answer to false, but the result wasn't false")

            let stepResult = taskResult.stepResult(forStepIdentifier: FormStepTestUtilities.ConditionalFormStepIdentifier)
            XCTAssertNotNil(stepResult?.result(forIdentifier: "item1"))
            XCTAssertNotNil(stepResult?.result(forIdentifier: "item2"))
            XCTAssertNil(stepResult?.result(forIdentifier: "item3"), "formItems with failing conditions shouldn't be in the result")
        }
    }

    func testEvaluatingTaskResultCurrentStep() throws {
        let mainTask = ORKOrderedTask(identifier: "mainTaskIdentifier", steps: [
            FormStepTestUtilities.selfReferentialConditionalFormStep()
        ])
        let mainTaskVC = ORKTaskViewController(task: mainTask, taskRun: nil)
        
        // go to the first step so we can simulate a user responding
        mainTaskVC.flipToPage(withIdentifier: mainTask.steps[0].identifier, forward: true, animated: false)
        let formStepViewController = mainTaskVC.currentStepViewController as! ORKFormStepViewController

        // make a simulated result
        do {
            // get the current result from the stepViewController, should be nil
            let stepResult = mainTaskVC.currentStepViewController?.result
            let questionResult = stepResult?.result(forIdentifier: "item1") as! ORKQuestionResult
            XCTAssertNil(questionResult.answer)

            // update the question result to unlock the conditional formItem
            formStepViewController.setAnswer(NSNumber(booleanLiteral: true), forIdentifier: questionResult.identifier)
            mainTaskVC.stepViewControllerResultDidChange(formStepViewController)
        }
        
        // now see that the conditional form item is present
        do {
            let stepResult = mainTaskVC.result.stepResult(forStepIdentifier: FormStepTestUtilities.SelfConditionalFormStepIdentifier)
            
            XCTAssertNotNil(stepResult?.result(forIdentifier: "item1"))
            XCTAssertNil((stepResult?.result(forIdentifier: "item2") as? ORKQuestionResult)?.answer)
            XCTAssertNotNil(stepResult?.result(forIdentifier: "item3"), "conditional formItem 'item3' should be unlocked by true answer for 'item1'")
        }
        
        // turn the conditional formItem off again by setting the answer to false
        do {
            // update the question result to unlock the conditional formItem
            formStepViewController.setAnswer(NSNumber(booleanLiteral: false), forIdentifier: "item1")
            mainTaskVC.stepViewControllerResultDidChange(formStepViewController)

            let stepResult = mainTaskVC.result.stepResult(forStepIdentifier: FormStepTestUtilities.SelfConditionalFormStepIdentifier)
            XCTAssertNil(stepResult?.result(forIdentifier: "item3"), "conditional formItem 'item3' should not be visible if item1 is false")
        }
    }

    func testEvaluationLogic() throws {
        let formStep = ORKFormStep(identifier: String(describing: "eligibilityFormStep"))
        formStep.title = NSLocalizedString("Conditional Form Items", comment: "")
        formStep.isOptional = false
        
        // Form items
        let yesNoAnswerFormat = ORKTextChoiceAnswerFormat(
            style: ORKChoiceAnswerStyle.singleChoice,
            textChoices: [
                ORKTextChoice(text: "Yup", value: "Yes" as NSString),
                ORKTextChoice(text: "Nope", value: "No" as NSString),
                ORKTextChoice(text: "hmm", value: "N/A" as NSString)
            ]
        )
        
        let dogsFormItem = ORKFormItem(
            identifier: String(describing: "dogsFormItem"),
            text: "Do you like dogs?",
            answerFormat: ORKTextChoiceAnswerFormat(
                style: ORKChoiceAnswerStyle.singleChoice,
                textChoices: [
                    ORKTextChoice(text: "Yes", value: "Yes" as NSString),
                    ORKTextChoice(text: "No", value: "No" as NSString),
                    ORKTextChoice(text: "N/A", value: "N/A" as NSString)
                ]
            )
        ).optionality(isOptional: false)
        
        let dogsYesFollowupFormItem = ORKFormItem(
            identifier: String(describing: "dogsYesFollowupFormItem"),
            text: "Do you like small dogs?",
            answerFormat: yesNoAnswerFormat
        ).optionality(isOptional: false)
        
        let dogsNoFollowupFormItem = ORKFormItem(
            identifier: String(describing: "dogsNoFollowupFormItem"),
            text: "Do you like cats?",
            answerFormat: yesNoAnswerFormat
        ).optionality(isOptional: false)
        
        let catsFollowupFormItem = ORKFormItem(
            identifier: String(describing: "catsFollowupFormItem"),
            text: "Do you like small cats?",
            answerFormat: yesNoAnswerFormat
        ).optionality(isOptional: false)
        
        let dogsFormItemResultSelector = ORKResultSelector(
            stepIdentifier: String(describing: "eligibilityFormStep"),
            resultIdentifier: String(describing: "dogsFormItem")
        )
        
        let dogsYesPredicate = ORKResultPredicate.predicateForChoiceQuestionResult(
            with: dogsFormItemResultSelector,
            expectedAnswerValue: "Yes" as NSString
        )
        let dogsNoPredicate = ORKResultPredicate.predicateForChoiceQuestionResult(
            with: dogsFormItemResultSelector,
            expectedAnswerValue: "No" as NSString
        )
        
        let catsItemResultSelector = ORKResultSelector(stepIdentifier: String(describing: "eligibilityFormStep"), resultIdentifier: String(describing: "dogsNoFollowupFormItem"))
        
        let catYesPredicate = ORKResultPredicate.predicateForChoiceQuestionResult(with: catsItemResultSelector, expectedAnswerValue: "Yes" as NSString)
        
        dogsYesFollowupFormItem.visibilityRule = ORKPredicateFormItemVisibilityRule(predicateFormat: dogsYesPredicate.predicateFormat)
        dogsNoFollowupFormItem.visibilityRule = ORKPredicateFormItemVisibilityRule(predicateFormat: dogsNoPredicate.predicateFormat)
        catsFollowupFormItem.visibilityRule =  ORKPredicateFormItemVisibilityRule(predicate: catYesPredicate)
        
        let taskResult = ORKTaskResult(taskIdentifier: "TaskIdentifier", taskRun: UUID(), outputDirectory: nil)
        
        formStep.formItems = [
            dogsFormItem,
            dogsYesFollowupFormItem,
            dogsNoFollowupFormItem,
            catsFollowupFormItem,
        ]

        for formItem in formStep.formItems! {
            if let visibilityRule = formItem.visibilityRule {
                XCTAssert(visibilityRule.formItemVisibility(for:taskResult) == false)
            }
        }
        
        checkResult(questionId: "dogsFormItem", answer: ["Yes" as NSString] as NSCopying & NSSecureCoding & NSObjectProtocol, formStep: formStep, formItem: dogsYesFollowupFormItem)
        
        checkResult(questionId: "dogsFormItem", answer: ["No" as NSString] as NSCopying & NSSecureCoding & NSObjectProtocol, formStep: formStep, formItem: dogsNoFollowupFormItem)
        
        checkResult(questionId: "dogsNoFollowupFormItem", answer: ["Yes" as NSString] as NSCopying & NSSecureCoding & NSObjectProtocol, formStep: formStep, formItem: catsFollowupFormItem)
        
    }
    
    func testFormItemForIndexPathSearchPerformance() throws {
        let mainTask = ORKOrderedTask(identifier: "mainTaskIdentifier", steps: [
            FormStepTestUtilities.longFormStep()
        ])
        let mainTaskVC = ORKTaskViewController(task: mainTask, taskRun: nil)
        
        // go to the first step so we can simulate a user responding
        mainTaskVC.flipToPage(withIdentifier: mainTask.steps[0].identifier, forward: true, animated: false)
        let formStepViewController = mainTaskVC.currentStepViewController as! ORKFormStepViewController
        
        self.measure { 
            for i in 0...50 {
                formStepViewController._formItem(for: IndexPath(row: 0, section: i))
            }
        }
    }
    
    // MARK: Utilities -
    
    func checkResult(questionId: String, answer: NSCopying & NSSecureCoding & NSObjectProtocol, formStep: ORKFormStep, formItem: ORKFormItem) {
        let result = ORKTaskResult(taskIdentifier: "TaskIdentifier", taskRun: UUID(), outputDirectory: nil)
        
        let choiceResult =  ORKChoiceQuestionResult(identifier: questionId)
        choiceResult.answer = answer as any NSCopying & NSSecureCoding & NSObjectProtocol
        
        result.results = [ORKStepResult(stepIdentifier: formStep.identifier, results: [choiceResult])]
        
        XCTAssertTrue(formItem.visibilityRule!.formItemVisibility(for: result))
    }
    
    func checkTextResult(questionId: String, answer: NSCopying & NSSecureCoding & NSObjectProtocol, formStep: ORKFormStep, formItem: ORKFormItem) {
        let result = ORKTaskResult(taskIdentifier: "TaskIdentifier", taskRun: UUID(), outputDirectory: nil)
        
        let choiceResult =  ORKTextQuestionResult(identifier: questionId)
        choiceResult.answer = answer as any NSCopying & NSSecureCoding & NSObjectProtocol
        
        result.results = [ORKStepResult(stepIdentifier: formStep.identifier, results: [choiceResult])]
        
        XCTAssertTrue(formItem.visibilityRule!.formItemVisibility(for: result))
    }
    
}

extension ORKFormStep {
    convenience init(identifier: String, formItems: [ORKFormItem]) {
        self.init(identifier: identifier)
        self.formItems = formItems
    }
}

extension ORKFormItem {
    func formItemSettingVisibilityRule(_ predicate: NSPredicate) -> ORKFormItem {
        self.visibilityRule = ORKPredicateFormItemVisibilityRule(predicate: predicate)
        return self
    }
    
    func optionality(isOptional: Bool) -> Self {
        self.isOptional = isOptional
        return self
    }
}

extension ORKFormStepViewController {
    func simulateSelectingAnswerAtIndex(_ index: Int) {
        let answerIndexPath = IndexPath(row: index, section: 0)
        
        _manuallyLoadView()
        _buildDataSourceAndApplySnapshot()
        _manuallyScrollToRow(at: answerIndexPath)
        _manuallySelectCell(at: answerIndexPath)
    }
    
    func _manuallyLoadView() {
        self.loadView()
        self.viewDidLoad()
    }
    
    func _buildDataSourceAndApplySnapshot() {
        let dataSource = tableView.dataSource as! UITableViewDiffableDataSourceReference
        self.build(dataSource)
        dataSource.applySnapshot(dataSource.snapshot(), animatingDifferences: false)
    }
    
    func _manuallyScrollToRow(at indexPath: IndexPath) {
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
    
    func _manuallySelectCell(at indexPath: IndexPath) {
        let tableViewDelegate = self as! UITableViewDelegate
        tableViewDelegate.tableView?(tableView, didSelectRowAt: indexPath)
    }
}

fileprivate struct FormStepTestUtilities {

    static let FormStepIdentifier = "Identifier: Plain old FormStep"
    static let ConditionalFormStepIdentifier = "Identifier: FormStep with conditional form items"
    static let SelfConditionalFormStepIdentifier = "Identifier: FormStep with self-referential conditional form items"
    static let QuestionStepIdentifier = "Identifier: This is a simple question step"

    static let SectionTitle = "Title: This is a Section"

    static func simpleFormStep() -> ORKFormStep {
        let step = ORKFormStep(identifier: FormStepIdentifier, formItems: [
            ORKFormItem(sectionTitle: SectionTitle), // section should not be answerable
            ORKFormItem(identifier: "item1", text:"none", answerFormat: .booleanAnswerFormat(), optional: true),
            ORKFormItem(identifier: "item2", text: "text", answerFormat: ORKTextAnswerFormat()),
            ORKFormItem(identifier: "item3", text: "more text", answerFormat: ORKTextAnswerFormat())
        ])
        return step
    }
    
    // formStep with 50 formItems
    static func longFormStep() -> ORKFormStep {
        let formItems: [ORKFormItem] = [1...50]
            .flatMap({ $0 })
            .compactMap({ index in
                ORKFormItem(identifier: "Item \(index)", text: "Option \(index)", answerFormat: ORKTextAnswerFormat())
            })
        let step = ORKFormStep(identifier: SelfConditionalFormStepIdentifier, formItems: formItems)
        return step
    }
    
    static func simpleFormStepWithTextChoices() -> ORKFormStep {
        let step = ORKFormStep(identifier: FormStepIdentifier, formItems: [
            ORKFormItem(sectionTitle: SectionTitle), // section should not be answerable
            ORKFormItem(identifier: "item1", text:"none", answerFormat: ORKTextChoiceAnswerFormat(
                style: .singleChoice,
                textChoices: [ORKTextChoice(text: "option 1", value:  "option 1" as NSString),
                              ORKTextChoiceOther.choice(withText: "choice 7", detailText: "detail 7", value: "choice 7" as NSString, exclusive: true, textViewPlaceholderText: "enter additional information")
                             ]),
                        optional: true),
        ])
        return step
    }

    // this formStep has a formItem that's conditional on a previous step's results
    static func conditionalFormStep() -> ORKFormStep {
        let step = ORKFormStep(identifier: ConditionalFormStepIdentifier, formItems: [
            ORKFormItem(sectionTitle: SectionTitle), // section should not be answerable
            ORKFormItem(identifier: "item1", text:"none", answerFormat: .booleanAnswerFormat(), optional: true),
            ORKFormItem(identifier: "item2", text: "text", answerFormat: ORKTextAnswerFormat()),
            ORKFormItem(identifier: "item3", text: "more text", answerFormat: ORKTextAnswerFormat())
                .formItemSettingVisibilityRule(
                    ORKResultPredicate.predicateForBooleanQuestionResult(
                        with: ORKResultSelector(
                            stepIdentifier: QuestionStepIdentifier,
                            resultIdentifier: QuestionStepIdentifier
                        ),
                        expectedAnswer: true
                    )
                )
        ])
        return step
    }

    // this formStep has a formItem that's conditional on its own step's results
    static func selfReferentialConditionalFormStep() -> ORKFormStep {
        let step = ORKFormStep(identifier: SelfConditionalFormStepIdentifier, formItems: [
            ORKFormItem(sectionTitle: SectionTitle), // section should not be answerable
            ORKFormItem(identifier: "item1", text:"none", answerFormat: .booleanAnswerFormat(), optional: true),
            ORKFormItem(identifier: "item2", text: "text", answerFormat: ORKTextAnswerFormat()),
            ORKFormItem(identifier: "item3", text: "more text", answerFormat: ORKTextAnswerFormat())
                .formItemSettingVisibilityRule(
                    ORKResultPredicate.predicateForBooleanQuestionResult(
                        with: ORKResultSelector(
                            stepIdentifier: SelfConditionalFormStepIdentifier,
                            resultIdentifier: "item1"
                        ),
                        expectedAnswer: true
                    )
                )
        ])
        return step
    }

    static func simpleBooleanFormStep() -> ORKFormStep {
        let booleanFormItem = ORKFormItem(identifier: QuestionStepIdentifier, text: "none", answerFormat: .booleanAnswerFormat())
        let formStep = ORKFormStep(identifier: QuestionStepIdentifier, formItems: [booleanFormItem])
        
        return formStep
        
    }

}
