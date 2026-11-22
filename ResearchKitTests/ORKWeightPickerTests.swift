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

// A weight that isn't an exact picker row, such as a HealthKit body mass of 66.68 kg, used to
// reset the picker to its 60 kg default. It should snap to the nearest row (GitHub issue #1451).

@MainActor
@Suite("ORKWeightPicker answer snapping")
struct ORKWeightPickerTests {

    @Test("A metric weight between rows snaps to the nearest row")
    func metricWeightBetweenRowsSnapsToNearestRow() throws {
        let picker = makePicker(format: .init(measurementSystem: .metric), answer: 66.68)

        let answer = try #require(picker.answer as? NSNumber)
        #expect(answer.doubleValue == 66.5)
        // Rows are 0.0, 0.5, 1.0, … kg, after a leading empty row when the question is required.
        #expect(selectedRow(of: picker) == 133 + 1)
    }

    @Test("Setting a weight between rows after creation also snaps to the nearest row")
    func settingWeightBetweenRowsLaterSnapsToNearestRow() throws {
        let picker = makePicker(format: .init(measurementSystem: .metric), answer: nil)

        picker.answer = NSNumber(value: 80.3)

        let answer = try #require(picker.answer as? NSNumber)
        #expect(answer.doubleValue == 80.5)
    }

    @Test("A metric weight that is already a row is kept")
    func metricWeightOnARowIsKept() throws {
        let picker = makePicker(format: .init(measurementSystem: .metric), answer: 70.5)

        let answer = try #require(picker.answer as? NSNumber)
        #expect(answer.doubleValue == 70.5)
    }

    @Test("A weight above the maximum snaps to the last row")
    func weightAboveMaximumSnapsToLastRow() throws {
        let format = ORKWeightAnswerFormat(
            measurementSystem: .metric,
            numericPrecision: .default,
            minimumValue: 40,
            maximumValue: 100,
            defaultValue: ORKDoubleDefaultValue
        )
        let picker = makePicker(format: format, answer: 150)

        // Metric rows step by 0.5 kg and include maximum + 0.5, so the last row is 100.5 kg.
        let answer = try #require(picker.answer as? NSNumber)
        #expect(answer.doubleValue == 100.5)
    }

    @Test("A US customary weight rounds to the nearest whole pound")
    func usCustomaryWeightRoundsToNearestPound() throws {
        // 67.0 kg is 147 lb 11 oz, so the nearest whole pound is 148 lb.
        let picker = makePicker(format: .init(measurementSystem: .USC), answer: 67.0)

        // Rows are 0, 1, 2, … lb, after a leading empty row when the question is required.
        #expect(selectedRow(of: picker) == 148 + 1)
        // 148 lb, stored in kilograms rounded to 0.01 kg.
        let answer = try #require(picker.answer as? NSNumber)
        #expect(answer.doubleValue == 67.13)
    }

    // MARK: - Helpers

    private let delegate = StubPickerDelegate()

    private func makePicker(format: ORKWeightAnswerFormat, answer: Double?) -> ORKWeightPicker {
        ORKWeightPicker(
            answerFormat: format,
            answer: answer.map { NSNumber(value: $0) },
            pickerDelegate: delegate
        )
    }

    private func selectedRow(of picker: ORKWeightPicker) -> Int? {
        (picker.pickerView as? UIPickerView)?.selectedRow(inComponent: 0)
    }
}

// MARK: - Stub delegate

private final class StubPickerDelegate: NSObject, ORKPickerDelegate {
    func picker(_ picker: Any, answerDidChangeTo answer: Any?) {}
    func isOptional() -> Bool { false }
}
