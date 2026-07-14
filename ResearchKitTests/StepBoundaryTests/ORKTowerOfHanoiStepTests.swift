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

import ResearchKitActiveTask_Private
import Testing

@Suite
struct ORKTowerOfHanoiStepTests {

    // MARK: - Invalid values

    @Test("validateParameters throws for numberOfDisks below the minimum")
    func belowMinimumThrows() throws {
        try StepBoundaryTestHelper.expectInvalidArgumentException(for: makeStep(numberOfDisks: 0))
    }

    @Test(
        "validateParameters throws for numberOfDisks above the maximum",
        arguments: [
            ORKTowerOfHanoiStep.maximumNumberOfDisks + 1,
            ORKTowerOfHanoiStep.maximumNumberOfDisks + 100
        ]
    )
    func aboveMaximumThrows(numberOfDisks: UInt) throws {
        try StepBoundaryTestHelper.expectInvalidArgumentException(for: makeStep(numberOfDisks: numberOfDisks))
    }

    // MARK: - Valid boundary values

    @Test(
        "validateParameters accepts boundary values",
        arguments: [
            ORKTowerOfHanoiStep.minimumNumberOfDisks,
            ORKTowerOfHanoiStep.maximumNumberOfDisks
        ]
    )
    func boundaryValuesDoNotThrow(numberOfDisks: UInt) throws {
        try StepBoundaryTestHelper.expectNoException(for: makeStep(numberOfDisks: numberOfDisks))
    }

    // MARK: - Class properties

    @Test("minimumNumberOfDisks class property equals 1")
    func minimumNumberOfDisksClassProperty() {
        #expect(ORKTowerOfHanoiStep.minimumNumberOfDisks == 1)
    }

    @Test("maximumNumberOfDisks class property equals 8")
    func maximumNumberOfDisksClassProperty() {
        #expect(ORKTowerOfHanoiStep.maximumNumberOfDisks == 8)
    }
}

private extension ORKTowerOfHanoiStepTests {
    func makeStep(numberOfDisks: UInt) -> ORKTowerOfHanoiStep {
        let step = ORKTowerOfHanoiStep(identifier: "test")
        step.numberOfDisks = numberOfDisks
        return step
    }
}
