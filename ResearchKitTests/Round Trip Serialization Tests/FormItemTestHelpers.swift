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

import ResearchKit
import ResearchKitUI
import Testing

enum FormItemTestHelper {

    /// Stamps volatile fields on the output task result to match the fixture's known values,
    /// making the full JSON comparison deterministic without stripping any fields.
    ///
    /// "Volatile" fields are properties the system populates at runtime with values that
    /// differ between test runs: `taskRunUUID` (generated fresh each time an
    /// ORKTaskViewController is created), and `startDate`/`endDate` (set to the current
    /// time when the pipeline collects results). Because the fixture uses predetermined
    /// values for these fields, we overwrite the pipeline output's volatile fields with
    /// the fixture's values so the two JSONs can be compared directly.
    static func stampVolatileFields(on output: ORKTaskResult, from fixture: ORKTaskResult) {
        output.setTaskRun(fixture.taskRunUUID)
        output.startDate = fixture.startDate
        output.endDate = fixture.endDate

        guard let outputSteps = output.results as? [ORKStepResult],
              let fixtureSteps = fixture.results as? [ORKStepResult] else { return }

        for (outputStep, fixtureStep) in zip(outputSteps, fixtureSteps) {
            outputStep.startDate = fixtureStep.startDate
            outputStep.endDate = fixtureStep.endDate

            guard let outputItems = outputStep.results,
                  let fixtureItems = fixtureStep.results else { continue }
            for (outputItem, fixtureItem) in zip(outputItems, fixtureItems) {
                outputItem.startDate = fixtureItem.startDate
                outputItem.endDate = fixtureItem.endDate
            }
        }
    }

    // MARK: - Cell Materialization Helpers

    /// Attaches the form step VC's view to a temporary UIWindow so the table view
    /// creates real cells (cellForRow returns non-nil).
    static func materializeFormStep(_ formStepVC: ORKFormStepViewController) {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        window.addSubview(formStepVC.view)
        formStepVC.view.frame = window.bounds
        window.isHidden = false
        formStepVC.view.layoutIfNeeded()
        formStepVC.tableView.layoutIfNeeded()
    }

    /// Finds the first ORKFormItemCell in the table view.
    static func findFormItemCell(in tableView: UITableView) -> ORKFormItemCell? {
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                if let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? ORKFormItemCell {
                    return cell
                }
            }
        }
        return nil
    }

    /// Finds the index path of the Nth ORKChoiceViewCell in the table view.
    /// For Boolean: choiceIndex 0 = "Yes" (true), choiceIndex 1 = "No" (false).
    static func findChoiceRowIndexPath(in tableView: UITableView, choiceIndex: Int) -> IndexPath? {
        var count = 0
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                if tableView.cellForRow(at: indexPath) is ORKChoiceViewCell {
                    if count == choiceIndex {
                        return indexPath
                    }
                    count += 1
                }
            }
        }
        return nil
    }
}
