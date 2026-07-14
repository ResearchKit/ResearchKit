/*
 Copyright (c) 2026, Apple Inc. All rights reserved.

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

// MARK: - Tests

@MainActor
@Suite("ORKFormItemTextFieldCell character count label")
struct ORKFormItemTextFieldCellCharacterCountTests {
    // MARK: - Presence

    @Test(
        """
        Character count label appears when multipleLines is false, maximumLength > 0, 
        and hideCharacterCountLabel is false
        """
    )
    func characterCountLabelIsDisplayedAsExpected() {
        let maxLength = 100
        let formItem = makeFormItem(maximumLength: maxLength, hideCharacterCountLabel: false)
        let inputText = ""

        let cell = configuredCell(formItem: formItem)
        let inputTextCount = inputText.count

        #expect(isLabel(withText: "\(inputTextCount)/\(maxLength)", presentInView: cell.containerView) == true)
    }

    @Test("Character count reflects the character count of a pre-filled answer")
    func characterCountIsAccurate() {
        let maxLength = 100
        let formItem = makeFormItem(maximumLength: maxLength, hideCharacterCountLabel: false)
        let inputText = "hello"

        let cell = configuredCell(formItem: formItem, answer: inputText)
        let inputTextCount = inputText.count
        #expect(isLabel(withText: "\(inputTextCount)/\(maxLength)", presentInView: cell.containerView) == true)
    }

    // MARK: - Absence

    @Test("Character count is absent when hideCharacterCountLabel is true")
    func characterCountLabelIsHiddenAsExpected() {
        let maxLength = 100
        let formItem = makeFormItem(maximumLength: maxLength, hideCharacterCountLabel: true)
        let inputText = ""

        let cell = configuredCell(formItem: formItem)
        let inputTextCount = inputText.count

        #expect(isLabel(withText: "\(inputTextCount)/\(maxLength)", presentInView: cell.containerView) == false)
    }

    @Test("Character count is absent when maximumLength is zero")
    func characterCountIsHiddenWhenMaxLengthIsZero() {
        let maxLength = 0
        let formItem = makeFormItem(maximumLength: maxLength, hideCharacterCountLabel: false)
        let inputText = ""

        let cell = configuredCell(formItem: formItem)
        let inputTextCount = inputText.count

        #expect(isLabel(withText: "\(inputTextCount)/\(maxLength)", presentInView: cell.containerView) == false)
    }

    // MARK: - Reuse

    @Test("Character count is removed after prepareForReuse when the new configuration hides it")
    func characterCountIsRemovedAfterReuseFromHidden() throws {
        let maxLength = 100
        let formItem = makeFormItem(maximumLength: maxLength, hideCharacterCountLabel: false)
        let inputText = ""

        let cell = configuredCell(formItem: formItem)
        let inputTextCount = inputText.count

        try #require(isLabel(withText: "\(inputTextCount)/\(maxLength)", presentInView: cell.containerView) == true)

        cell.prepareForReuse()

        let newFormItem = makeFormItem(maximumLength: maxLength, hideCharacterCountLabel: true)

        cell.configure(
            with: newFormItem,
            answer: Optional<AnyObject>.none as Any,
            maxLabelWidth: 0,
            delegate: delegate
        )

        #expect(isLabel(withText: "\(inputTextCount)/\(maxLength)", presentInView: cell.containerView) == false)
    }
    
    // MARK: - Private
    
    private let delegate = StubFormItemCellDelegate()
}

// MARK: - Private Helpers

private extension ORKFormItemTextFieldCellCharacterCountTests {
    private func makeFormItem(maximumLength: Int, hideCharacterCountLabel: Bool, multipleLines: Bool = false) -> ORKFormItem {
        let answerFormat = ORKTextAnswerFormat(maximumLength: maximumLength)
        answerFormat.hideCharacterCountLabel = hideCharacterCountLabel
        answerFormat.multipleLines = multipleLines
        return ORKFormItem(identifier: "textItem", text: "Label", answerFormat: answerFormat)
    }

    private func configuredCell(formItem: ORKFormItem, answer: String? = nil) -> ORKFormItemTextFieldCell {
        let cell = ORKFormItemTextFieldCell(style: .default, reuseIdentifier: "test")
        cell.configure(with: formItem, answer: answer as Any, maxLabelWidth: 0, delegate: delegate)
        return cell
    }

    private func isLabel(withText text: String, presentInView view: UIView) -> Bool {
        if let label = view as? UILabel, label.text == text {
            return true
        }
        
        for sub in view.subviews {
            if isLabel(withText: text, presentInView: sub) {
                return true
            }
        }
        
        return false
    }
}

// MARK: - Stub delegate

private final class StubFormItemCellDelegate: NSObject, ORKFormItemCellDelegate {
    func formItemCell(_ cell: ORKFormItemCell, answerDidChangeTo answer: Any?) {}
    func formItemCellDidBecomeFirstResponder(_ cell: ORKFormItemCell) {}
    func formItemCellDidResignFirstResponder(_ cell: ORKFormItemCell) {}
    func formItemCell(_ cell: ORKFormItemCell, invalidInputAlertWithMessage input: String) {}
    func formItemCell(_ cell: ORKFormItemCell, invalidInputAlertWithTitle title: String, message: String) {}
    func formItemCellShouldDismissKeyboard(_ cell: ORKFormItemCell) -> Bool { false }
}
