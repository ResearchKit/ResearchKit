/*
 Copyright (c) 2026, Snehal Mehta.

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
 the copyright holders even if such software includes software developed by the
 copyright holders.

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
import Testing
import UIKit

// The decimal and number pads have no minus key on iPhone. Numeric questions whose answer
// format allows negative values need a keyboard that includes one (GitHub issue #1423).

@MainActor
@Suite("Numeric answer keyboard type")
struct ORKNumericAnswerKeyboardTypeTests {

    // MARK: - Form step cell

    @Test("Form decimal item with a negative minimum uses a keyboard with a minus key")
    func formDecimalWithNegativeMinimum() {
        let cell = formCell(style: .decimal, minimum: -100, maximum: 100)
        #expect(textField(of: cell)?.keyboardType == .numbersAndPunctuation)
    }

    @Test("Form integer item with a negative minimum uses a keyboard with a minus key")
    func formIntegerWithNegativeMinimum() {
        let cell = formCell(style: .integer, minimum: -5, maximum: 5)
        #expect(textField(of: cell)?.keyboardType == .numbersAndPunctuation)
    }

    @Test("Form items that can't be negative keep the number and decimal pads")
    func formItemsWithoutNegativeMinimum() {
        #expect(textField(of: formCell(style: .decimal, minimum: nil, maximum: nil))?.keyboardType == .decimalPad)
        #expect(textField(of: formCell(style: .decimal, minimum: 0, maximum: 10))?.keyboardType == .decimalPad)
        #expect(textField(of: formCell(style: .integer, minimum: nil, maximum: nil))?.keyboardType == .numberPad)
        #expect(textField(of: formCell(style: .integer, minimum: 1, maximum: 10))?.keyboardType == .numberPad)
    }

    @Test("Form decimal item accepts a typed negative answer")
    func formDecimalAcceptsNegativeAnswer() throws {
        let delegate = RecordingFormItemCellDelegate()
        let cell = formCell(style: .decimal, minimum: -100, maximum: 100, delegate: delegate)

        try type("-12", into: cell)

        let answer = try #require(delegate.lastAnswer as? NSNumber)
        #expect(answer.doubleValue == -12)
    }

    // MARK: - Question step cell

    @Test("Question decimal step with a negative minimum uses a keyboard with a minus key")
    func questionDecimalWithNegativeMinimum() {
        let cell = questionCell(style: .decimal, minimum: -100, maximum: 100)
        #expect(textField(of: cell)?.keyboardType == .numbersAndPunctuation)
    }

    @Test("Question integer step with a negative minimum uses a keyboard with a minus key")
    func questionIntegerWithNegativeMinimum() {
        let cell = questionCell(style: .integer, minimum: -5, maximum: 5)
        #expect(textField(of: cell)?.keyboardType == .numbersAndPunctuation)
    }

    @Test("Question steps that can't be negative keep the number and decimal pads")
    func questionStepsWithoutNegativeMinimum() {
        #expect(textField(of: questionCell(style: .decimal, minimum: nil, maximum: nil))?.keyboardType == .decimalPad)
        #expect(textField(of: questionCell(style: .decimal, minimum: 0, maximum: 10))?.keyboardType == .decimalPad)
        #expect(textField(of: questionCell(style: .integer, minimum: nil, maximum: nil))?.keyboardType == .numberPad)
        #expect(textField(of: questionCell(style: .integer, minimum: 1, maximum: 10))?.keyboardType == .numberPad)
    }

    @Test("Question decimal step accepts a typed negative answer")
    func questionDecimalAcceptsNegativeAnswer() throws {
        let delegate = RecordingSurveyAnswerCellDelegate()
        // The cell holds its step weakly, as the step view controller owns it in the app.
        let step = questionStep(style: .decimal, minimum: -100, maximum: 100)
        let cell = questionCell(step: step, delegate: delegate)

        try withExtendedLifetime(step) {
            try type("-12", into: cell)
        }

        let answer = try #require(delegate.lastAnswer as? NSNumber)
        #expect(answer.doubleValue == -12)
    }

    // MARK: - Helpers

    private let formDelegate = RecordingFormItemCellDelegate()
    private let questionDelegate = RecordingSurveyAnswerCellDelegate()

    private func answerFormat(
        style: ORKNumericAnswerStyle,
        minimum: NSNumber?,
        maximum: NSNumber?
    ) -> ORKNumericAnswerFormat {
        ORKNumericAnswerFormat(style: style, unit: nil, minimum: minimum, maximum: maximum)
    }

    private func formCell(
        style: ORKNumericAnswerStyle,
        minimum: NSNumber?,
        maximum: NSNumber?,
        delegate: RecordingFormItemCellDelegate? = nil
    ) -> ORKFormItemNumericCell {
        let formItem = ORKFormItem(
            identifier: "numberItem",
            text: "Number",
            answerFormat: answerFormat(style: style, minimum: minimum, maximum: maximum)
        )
        let cell = ORKFormItemNumericCell(style: .default, reuseIdentifier: "test")
        cell.configure(with: formItem, answer: NSNull(), maxLabelWidth: 0, delegate: delegate ?? formDelegate)
        return cell
    }

    private func questionStep(style: ORKNumericAnswerStyle, minimum: NSNumber?, maximum: NSNumber?) -> ORKQuestionStep {
        ORKQuestionStep(
            identifier: "numberStep",
            title: nil,
            question: "Number",
            answer: answerFormat(style: style, minimum: minimum, maximum: maximum)
        )
    }

    private func questionCell(
        step: ORKQuestionStep,
        delegate: RecordingSurveyAnswerCellDelegate? = nil
    ) -> ORKSurveyAnswerCellForNumber {
        ORKSurveyAnswerCellForNumber(
            style: .default,
            reuseIdentifier: "test",
            step: step,
            answer: NSNull(),
            delegate: delegate ?? questionDelegate
        )
    }

    /// The keyboard type is set when the cell is created, so the step only needs to live that long.
    private func questionCell(
        style: ORKNumericAnswerStyle,
        minimum: NSNumber?,
        maximum: NSNumber?
    ) -> ORKSurveyAnswerCellForNumber {
        questionCell(step: questionStep(style: style, minimum: minimum, maximum: maximum))
    }

    private func textField(of cell: UITableViewCell) -> UITextField? {
        cell.value(forKey: "textField") as? UITextField
    }

    /// Enters text the way the keyboard does. `sendActions(for:)` doesn't reach the cell's
    /// editing-changed handler outside a window, so the handler is called directly.
    private func type(_ text: String, into cell: UITableViewCell) throws {
        let field = try #require(textField(of: cell))
        field.text = text
        cell.perform(NSSelectorFromString("valueFieldDidChange:"), with: field)
    }
}

// MARK: - Stub delegates

private final class RecordingFormItemCellDelegate: NSObject, ORKFormItemCellDelegate {
    var lastAnswer: Any?

    func formItemCell(_ cell: ORKFormItemCell, answerDidChangeTo answer: Any?) { lastAnswer = answer }
    func formItemCellDidBecomeFirstResponder(_ cell: ORKFormItemCell) {}
    func formItemCellDidResignFirstResponder(_ cell: ORKFormItemCell) {}
    func formItemCell(_ cell: ORKFormItemCell, invalidInputAlertWithMessage input: String) {}
    func formItemCell(_ cell: ORKFormItemCell, invalidInputAlertWithTitle title: String, message: String) {}
    func formItemCellShouldDismissKeyboard(_ cell: ORKFormItemCell) -> Bool { false }
}

private final class RecordingSurveyAnswerCellDelegate: NSObject, ORKSurveyAnswerCellDelegate {
    var lastAnswer: Any?

    func answerCell(_ cell: ORKSurveyAnswerCell, answerDidChangeTo answer: Any, dueUserAction: Bool) {
        lastAnswer = answer
    }
    func answerCell(_ cell: ORKSurveyAnswerCell, invalidInputAlertWithMessage input: String) {}
    func answerCell(_ cell: ORKSurveyAnswerCell, invalidInputAlertWithTitle title: String, message: String) {}
}
