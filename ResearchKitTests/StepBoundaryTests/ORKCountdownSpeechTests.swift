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

private func valuesToSpeak(for current: Int) -> [Int] {
    ORKCountdownValuesToSpeak(current).map { $0.intValue }
}

@Suite("ORKCountdownValuesToSpeak")
struct ORKCountdownSpeechTests {
    let lowerBound = 1
    let upperBound = 3

    @Test("values in range [lower bound, upper bound]  are spoken")
    func valuesInRange() {
        #expect(valuesToSpeak(for: lowerBound) == [lowerBound])
        #expect(valuesToSpeak(for: lowerBound + 1) == [lowerBound + 1])
        #expect(valuesToSpeak(for: upperBound) == [upperBound])
    }

    @Test("values above upper bound are not spoken")
    func valuesAboveUpperBound() {
        #expect(valuesToSpeak(for: upperBound + 1) == [])
        #expect(valuesToSpeak(for: upperBound + 2) == [])
    }

    @Test("zero and below are not spoken")
    func zeroAndBelow() {
        #expect(valuesToSpeak(for: lowerBound - 1) == [])
        #expect(valuesToSpeak(for: lowerBound - 2) == [])
    }

    @Test("only in-range values are spoken across a full countdown")
    func fullCountdown() {
        let spoken = stride(from: 10, through: 1, by: -1).flatMap { valuesToSpeak(for: $0) }
        #expect(spoken == (lowerBound...upperBound).reversed().map { $0 })
    }
}
