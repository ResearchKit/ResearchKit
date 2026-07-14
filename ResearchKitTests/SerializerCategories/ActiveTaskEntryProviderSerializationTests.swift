/*
 Copyright (c) 2025, Apple Inc. All rights reserved.
 
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

@Suite(.tags(.serialization))
struct ActiveTaskEntryProviderSerializationTests {

    @Test
    func testActiveTaskObjectFromJSONData() throws {
        let timedWalkStep = getTimeWalkStep()
        let timedWalkStepJSONData = try ORKESerializer.activeTask_JSONData(for: timedWalkStep)
        let decodedTimedWalkStep = try ORKESerializer.activeTask_object(fromJSONData: timedWalkStepJSONData) as? ORKTimedWalkStep
        #expect(timedWalkStep == decodedTimedWalkStep)
    }

    @Test
    func testActiveTaskJSONDataForObject() throws {
        let timedWalkStep = getTimeWalkStep()
        _ = try ORKESerializer.activeTask_JSONData(for: timedWalkStep)
    }

    @Test
    func testActiveTaskJSONObjectForObject() throws {
        let timedWalkStep = getTimeWalkStep()
        _ = try ORKESerializer.activeTask_JSONObject(for: timedWalkStep)
    }

    @Test
    func testActiveTaskJSONObjectForObjectWithContext() throws {
        let timedWalkStep = getTimeWalkStep()
        let serialiazationContext = ORKESerializationContext(localizer: nil, imageProvider: nil, stringInterpolator: nil, propertyInjector: nil)
        _ = try ORKESerializer.activeTask_JSONObject(for: timedWalkStep, context: serialiazationContext)
    }

    @Test
    func testActiveTaskObjectFromJSONObject() throws {
        let timedWalkStep = getTimeWalkStep()
        let timedWalkStepJSON = try ORKESerializer.activeTask_JSONObject(for: timedWalkStep)
        let decodedTimedWalkStep = try ORKESerializer.activeTask_object(fromJSONObject: timedWalkStepJSON) as? ORKTimedWalkStep
        #expect(timedWalkStep == decodedTimedWalkStep)
    }

    @Test
    func testActiveTaskObjectFromJSONObjectWithContext() throws {
        let timedWalkStep = getTimeWalkStep()
        let serialiazationContext = ORKESerializationContext(localizer: nil, imageProvider: nil, stringInterpolator: nil, propertyInjector: nil)
        let timedWalkStepJSON = try ORKESerializer.activeTask_JSONObject(for: timedWalkStep)
        let decodedTimedWalkStep = try ORKESerializer.activeTask_object(fromJSONObject: timedWalkStepJSON, context: serialiazationContext) as? ORKTimedWalkStep
        #expect(timedWalkStep == decodedTimedWalkStep)
    }

    private func getTimeWalkStep() -> ORKTimedWalkStep {
        let timedWalkStep = ORKTimedWalkStep(identifier: "TimedWalkStepIdentifier")
        timedWalkStep.title = "Step Title"
        timedWalkStep.detailText = "Detail Text"
        return timedWalkStep
    }

}
