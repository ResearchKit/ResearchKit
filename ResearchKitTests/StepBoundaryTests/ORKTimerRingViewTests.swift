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
 the copyright holders even if such software marks are included in this software.

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

import Testing
@testable import ResearchKitUI

@MainActor
@Suite
struct ORKTimerRingViewTests {
    let view = ORKTimerRingView(duration: TestDuration.default)

    @Test
    func initStoresDurationAndTimeLeft() {
        #expect(view.duration == TestDuration.default)
        #expect(view.timeLeft == TestDuration.default)
    }

    @Test
    func setValidDurationUpdatesValue() {
        // When
        view.duration = TestDuration.biggerThanDefault
        
        // Then
        #expect(view.duration == TestDuration.biggerThanDefault)
    }

    @Test
    func setDurationClampsTimeLeftWhenReduced() {
        // Given
        view.timeLeft = TestDuration.default
        
        // When
        let durationValueInferiorToTimeLeft = view.timeLeft - 1
        view.duration = durationValueInferiorToTimeLeft
        
        // Then
        #expect(view.timeLeft == view.duration)
    }

    @Test
    func setDurationDoesNotChangeTimeLeftWhenIncreased() {
        // Given
        view.timeLeft = TestDuration.default
        
        // When
        let durationValueSuperiorToTimeLeft = view.timeLeft + 1
        view.duration = durationValueSuperiorToTimeLeft
        
        // Then
        #expect(view.timeLeft == TestDuration.default)
    }

    @Test(
        arguments: [
            (TestDuration.smallerThanDefault, TestDuration.smallerThanDefault),
            (TestDuration.negative, TestDuration.zero),
            (TestDuration.biggerThanDefault, TestDuration.default)
        ] as [(TimeInterval, TimeInterval)]
    )
    func setTimeLeftClampsToValidRange(input: TimeInterval, expected: TimeInterval) {
        view.timeLeft = input
        #expect(view.timeLeft == expected)
    }

    // Verifies the tinted arc is actually rendered by comparing a full ring against
    // an empty ring. With timeLeft == duration, percentFilled = 1.0 and the tinted
    // arc overrides the gray background at the top of the ring. With timeLeft == 0,
    // startAngle == stopAngle so no tinted arc is drawn and the top pixel stays gray.
    // If percentFilled were NaN the tinted arc would also be skipped, making the
    // pixels identical and failing the test.
    @Test
    func drawColoredArcDiffersFromEmptyRing() {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let ringBounds = CGRect(x: 0, y: 0, width: 200, height: 250)
        let renderer = UIGraphicsImageRenderer(bounds: ringBounds, format: format)

        let fullView = ORKTimerRingView(duration: TestDuration.default)
        fullView.frame = ringBounds
        let fullImage = renderer.image { _ in fullView.draw(ringBounds) }

        let emptyView = ORKTimerRingView(duration: TestDuration.default)
        emptyView.frame = ringBounds
        emptyView.timeLeft = 0
        let emptyImage = renderer.image { _ in emptyView.draw(ringBounds) }

        let ringTopPoint = CGPoint(x: 100, y: 75) // top of ring within ORKTimerRingStrokeWidth stroke
        #expect(fullImage.pixel(at: ringTopPoint) != emptyImage.pixel(at: ringTopPoint))
    }

    @Test(
        arguments: [
            TestDuration.zero,
            TestDuration.negative,
            Double.infinity,
            Double.nan
        ]
    )
    func initWithInvalidDurationThrows(duration: TimeInterval) throws {
        try StepBoundaryTestHelper.expectInvalidArgumentException { _ = ORKTimerRingView(duration: duration) }
    }

    @Test(
        arguments: [
            TestDuration.zero,
            TestDuration.negative,
            Double.infinity,
            Double.nan
        ]
    )
    func setDurationToInvalidValueThrows(duration: TimeInterval) throws {
        try StepBoundaryTestHelper.expectInvalidArgumentException { view.duration = duration }
    }
}

// MARK: - Helpers

private extension ORKTimerRingViewTests {
    private enum TestDuration {
        static let `default`: TimeInterval = 30
        static let smallerThanDefault: TimeInterval = 15
        static let biggerThanDefault: TimeInterval = 100
        static let negative: TimeInterval = -5
        static let zero: TimeInterval = 0
    }
}

private extension UIImage {
    struct Pixel: Equatable {
        let red, green, blue, alpha: UInt8
    }

    func pixel(at point: CGPoint) -> Pixel {
        guard let cgImage else { return Pixel(red: 0, green: 0, blue: 0, alpha: 0) }
        let x = Int(point.x)
        let y = Int(point.y)
        let width = cgImage.width
        let height = cgImage.height
        guard x >= 0, y >= 0, x < width, y < height else { return Pixel(red: 0, green: 0, blue: 0, alpha: 0) }

        var data = [UInt8](repeating: 0, count: 4 * width * height)
        guard let context = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return Pixel(red: 0, green: 0, blue: 0, alpha: 0) }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        let offset = (y * width + x) * 4
        return Pixel(red: data[offset], green: data[offset + 1], blue: data[offset + 2], alpha: data[offset + 3])
    }
}
