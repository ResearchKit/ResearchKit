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
struct RegistrationCategorySerializationTests {

    @Test
    func testRegisterSerializableClassMethod() {
        // register custom class
        ORKESerializer.registerSerializableClass(
            ExampleCustomStep.self,
            initBlock: { dictionary, getter -> ExampleCustomStep? in
                guard let identifier =
                        getter(dictionary, "\(#keyPath(ExampleCustomStep.identifier))") as? String else { return nil }
                return ExampleCustomStep(identifier: identifier)
            }
        )

        // initialize an instance of the serializer
        let serializer = ORKESerializer(entryProviders: [])

        // verify that the serializer now accounts for the registered custom step
        let serializableClasses = serializer.serializableClasses()
        let customStepString = NSStringFromClass(ExampleCustomStep.self)
        #expect(serializableClasses.contains(customStepString))
    }

    @Test
    func testRegisterSerializablePropertyMethod() {
        // register custom property
        let customPropertyName = "extraIdentifier"
        ORKESerializer.registerSerializableClassPropertyName(
            customPropertyName,
            for: ExampleTwoCustomStep.self,
            valueClass: NSString.self,
            containerClass: nil,
            writeAfterInit: false,
            objectToJSONBlock: nil,
            jsonToObjectBlock: nil,
            skipSerialization: false
        )

        // initialize an instance of the serializer
        let serializer = ORKESerializer(entryProviders: [])

        // verify that the serializer now accounts for the registered custom property
        let serializableProperties = serializer.serializedProperties(for: ExampleTwoCustomStep.self)
        #expect(serializableProperties.contains(customPropertyName))
    }

    @Test
    func testRegisteredClassSerialization() throws {
        // register custom class
        ORKESerializer.registerSerializableClass(
            ExampleCustomStep.self,
            initBlock: { dictionary, getter -> ExampleCustomStep? in
                guard let identifier =
                        getter(dictionary, "\(#keyPath(ExampleCustomStep.identifier))") as? String else { return nil }
                return ExampleCustomStep(identifier: identifier)
            }
        )

        // initialize serializer with core entry provider
        let coreEntryProvider = ORKCoreSerializationEntryProvider()
        let serializer = ORKESerializer(entryProviders: [coreEntryProvider])

        // initialize a ExampleCustomStep
        let customStep = ExampleCustomStep(identifier: "ExampleCustomStepID")

        // encode and decode the custom step before comparing it with the original object
        let data = try serializer.jsonData(for: customStep)
        let decodedCustomStep = try #require(serializer.object(fromJSONData: data) as? ExampleCustomStep)
        #expect(decodedCustomStep == customStep)
    }

    @Test
    func testResisteredPropertySerialization() throws {
        // register custom property and class
        let customPropertyName = "extraIdentifier"
        ORKESerializer.registerSerializableClassPropertyName(
            customPropertyName,
            for: ExampleTwoCustomStep.self,
            valueClass: NSString.self,
            containerClass: nil,
            writeAfterInit: false,
            objectToJSONBlock: nil,
            jsonToObjectBlock: nil,
            skipSerialization: false
        )

        ORKESerializer.registerSerializableClass(
            ExampleTwoCustomStep.self,
            initBlock: { dictionary, getter -> ExampleTwoCustomStep? in
                guard let identifier =
                        getter(dictionary, "\(#keyPath(ExampleTwoCustomStep.identifier))") as? String else { return nil }
                return ExampleTwoCustomStep(identifier: identifier)
            }
        )

        // initialize serializer with core entry provider
        let coreEntryProvider = ORKCoreSerializationEntryProvider()
        let serializer = ORKESerializer(entryProviders: [coreEntryProvider])

        // initialize a ExampleTwoCustomStep
        let customStep = ExampleTwoCustomStep(identifier: "ExampleTwoCustomStepID")

        // encode and decode the custom step before comparing it with the original object
        let data = try serializer.jsonData(for: customStep)
        let decodedCustomStep = try #require(serializer.object(fromJSONData: data) as? ExampleTwoCustomStep)
        #expect(decodedCustomStep == customStep)
    }

}

// MARK: Example custom classes

class ExampleCustomStep: ORKInstructionStep {
    override init(identifier: String) {
        super.init(identifier: identifier)
        self.title = "Custom Step"
        self.text = "This is a custom step, the background should be red."
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func makeViewController(with result: ORKResult?) -> ORKStepViewController {
        ORKInstructionStepViewController(step: self, result: result)
    }
}

class ExampleTwoCustomStep: ORKInstructionStep {
    @objc var extraIdentifier: String?
    override init(identifier: String) {
        super.init(identifier: identifier)
        self.title = "Custom Step"
        self.text = "This is a custom step, the background should be red."
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func makeViewController(with result: ORKResult?) -> ORKStepViewController {
        ORKInstructionStepViewController(step: self, result: result)
    }
}
