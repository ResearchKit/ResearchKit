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

import Testing

@Suite(.tags(.serialization))
struct CoreEntryProviderSerializationTests {

    @Test
    func testCoreObjectFromJSONData() throws {
        let instructionStep = getInstructionStepExample()
        let instructionStepJSONData = try ORKESerializer.core_JSONData(for: instructionStep)
        let decodedInstructionStep = try ORKESerializer.core_object(fromJSONData: instructionStepJSONData) as? ORKInstructionStep
        #expect(instructionStep == decodedInstructionStep)
    }

    @Test
    func testCoreJSONDataForObject() throws {
        let instructionStep = getInstructionStepExample()
        _ = try ORKESerializer.core_JSONData(for: instructionStep)
    }

    @Test
    func testCoreJSONObjectForObject() throws {
        let instructionStep = getInstructionStepExample()
        _ = try ORKESerializer.core_JSONObject(for: instructionStep)
    }

    @Test
    func testCoreJSONObjectForObjectWithContext() throws {
        let instructionStep = getInstructionStepExample()
        let serialiazationContext = ORKESerializationContext(localizer: nil, imageProvider: nil, stringInterpolator: nil, propertyInjector: nil)
        _ = try ORKESerializer.core_JSONObject(for: instructionStep, context: serialiazationContext)
    }

    @Test
    func testCoreObjectFromJSONObject() throws {
        let instructionStep = getInstructionStepExample()
        let instructionStepJSON = try ORKESerializer.core_JSONObject(for: instructionStep)
        let decodedInstructionStep = try ORKESerializer.core_object(fromJSONObject: instructionStepJSON) as? ORKInstructionStep
        #expect(instructionStep == decodedInstructionStep)
    }

    @Test
    func testCoreObjectFromJSONObjectWithContext() throws {
        let instructionStep = getInstructionStepExample()
        let serialiazationContext = ORKESerializationContext(localizer: nil, imageProvider: nil, stringInterpolator: nil, propertyInjector: nil)
        let instructionStepJSON = try ORKESerializer.core_JSONObject(for: instructionStep)
        let decodedInstructionStep = try ORKESerializer.core_object(fromJSONObject: instructionStepJSON, context: serialiazationContext) as? ORKInstructionStep
        #expect(instructionStep == decodedInstructionStep)
    }

    private func getInstructionStepExample() -> ORKInstructionStep {
        let instructionStep = ORKInstructionStep(identifier: "InstructionStepIdentifier")
        instructionStep.title = "Step Title"
        instructionStep.detailText = "Detail Text"
        return instructionStep
    }

}
