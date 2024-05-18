/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

import XCTest

import ResearchKit

final class ORKFormItemVisibilityRuleTests: XCTestCase {

    func testAbstractRuleRestrictions() throws {
        throw XCTSkip("executeUsingObjCExceptionHandling seems to fail, skipping this test.")
        
        let abstractBaseClass = ORKFormItemVisibilityRule.self
        XCTAssertThrowsError(try NSObject.executeUsingObjCExceptionHandling {
            _ = abstractBaseClass.init()
        }) { error in
            let exception = (error as NSError).userInfo[ORKUnderlyingExceptionKey] as! NSException
            XCTAssertEqual(exception.name, NSExceptionName.internalInconsistencyException)
        }
    }

    func testSubclassInitCanCallSuper() throws {
        let subclassInstance = ExampleFormItemVisibilityRule(evaluationLogic: "expression")
        XCTAssertTrue(subclassInstance.classForCoder == ExampleFormItemVisibilityRule.self)
        XCTAssertFalse(subclassInstance.classForCoder == ORKFormItemVisibilityRule.self)
    }

    func testSubclassCopyCanCallSuper() throws {
        let example = ExampleFormItemVisibilityRule(evaluationLogic: "expression")
        let copy = example.copy()
        XCTAssertTrue(object_getClass(copy) == ExampleFormItemVisibilityRule.self)
        
        if let copy = copy as? ExampleFormItemVisibilityRule {
            XCTAssertEqual(example, copy)
        } else {
            XCTFail("copy of ExampleFormItemVisibilityRule was not of type ExampleFormItemVisibilityRule")
        }
    }

    func testSubclassDecodingWorks() throws {
        // verify that a subclass can be be encoded and then decoded
        // verify that the decoded instance is the concrete subclass not the abstract class
        let example = ExampleFormItemVisibilityRule(evaluationLogic: "expression")
        
        let encoder = NSKeyedArchiver(requiringSecureCoding: true)
        let ArchiveKey = "formItemVisibilityRule"
        encoder.encode(example, forKey: ArchiveKey)
        encoder.finishEncoding()
        let data = encoder.encodedData
        
        let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: data)
        let decodedObject = unarchiver.decodeObject(of: [ORKFormItemVisibilityRule.self], forKey: ArchiveKey)
        XCTAssertNotNil(decodedObject)
        
        guard let decodedRule = decodedObject as? ORKFormItemVisibilityRule else {
            XCTFail("decoded rule was not of type ORKFormItemVisibilityRule")
            return
        }
        XCTAssertTrue(decodedRule.classForKeyedArchiver == ExampleFormItemVisibilityRule.self)
    }
    
    func testSubclassIsEqualWorks() throws {
        
        // test that when they should be equal that they are equal
        let subclass = ExampleFormItemVisibilityRule(evaluationLogic: "expression")
        let copy = subclass.copy() as? ExampleFormItemVisibilityRule
        XCTAssertEqual(subclass, copy)
        
        // test that when when the should NOT be equal, that they in fact are not equal
        let secondSubclass = ExampleFormItemVisibilityRule(evaluationLogic: "another expression")
        XCTAssertNotEqual(subclass, secondSubclass)
        
        // In bogus example subclass, test that two otherwise equal objects are not equal since they differ by class
        let bogusSubclass = BogusFormItemVisibilityRule(evaluationLogic: subclass.evaluationLogic)
        XCTAssertNotEqual(subclass, bogusSubclass)
    }

    func testSubclassMissingImplementationThrows() throws {
        throw XCTSkip("executeUsingObjCExceptionHandling seems to fail, skipping this test.")
        
        // test that a subclass that doesn't implement formItemVisibilityForTaskResult throws
        
        let taskResult = ORKTaskResult(taskIdentifier: "", taskRun: UUID(), outputDirectory: nil)
        let rule = ExampleFormItemVisibilityRule()
        let bogusRule = BogusFormItemVisibilityRule()
        
        // regular rule should work
        _ = rule.formItemVisibility(for: taskResult)
        
        // bogus rule class doesn't implement formItemVisibility(for: ORKTaskResult)

        XCTAssertThrowsError(try NSObject.executeUsingObjCExceptionHandling {
            bogusRule.formItemVisibility(for: taskResult)
        }) { error in
            let exception = (error as NSError).userInfo[ORKUnderlyingExceptionKey] as! NSException
            XCTAssertEqual(exception.name, NSExceptionName.genericException)
        }
    }
    
    func testAssigningRuleToFormItem() throws {
        let formItemWithRule = createFormItemWithVisibilityRule()
        XCTAssertNotNil(formItemWithRule)
        XCTAssertNotNil(formItemWithRule.visibilityRule)
    }
    
    func testFormItemWithRuleArchives() throws {
        let formItemWithRule = createFormItemWithVisibilityRule()
        
        // archive the ORKFormItem with an attached Rule
        let encoder = NSKeyedArchiver(requiringSecureCoding: true)
        let ArchiveKey = "formItemWithVisibilityRule"
        encoder.encode(formItemWithRule, forKey: ArchiveKey)
        encoder.finishEncoding()
        let data = encoder.encodedData
        
        let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: data)
        let decodedObject = unarchiver.decodeObject(of: [ORKFormItem.self], forKey: ArchiveKey)
        XCTAssertNotNil(decodedObject)
        
        // decode and ensure is not nil
        guard let decodedObject = decodedObject as? ORKFormItem else {
            XCTFail("decoded rule was not of type ORKFormItemVisibilityRule")
            return
        }
        XCTAssertTrue(decodedObject.classForKeyedArchiver == ORKFormItem.self)
        
        // ensure decoded item has a rule and ensure is not nil
        guard let decodedRule = decodedObject.visibilityRule as? ExampleFormItemVisibilityRule else {
            XCTFail("decoded rule was not of type ORKFormItemVisibilityRule")
            return
        }
        XCTAssertTrue(decodedRule.classForKeyedArchiver == ExampleFormItemVisibilityRule.self)
    }
    
    func testFormItemWithOutRuleArchives() throws {
        let formItemWithOutRule = createFormItem()

        // encode and decode a formItem without a rule
        let encoder = NSKeyedArchiver(requiringSecureCoding: true)
        let ArchiveKey = "formItemWithOutVisibilityRule"
        encoder.encode(formItemWithOutRule, forKey: ArchiveKey)
        encoder.finishEncoding()
        let data = encoder.encodedData
        
        let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: data)
        let decodedObject = unarchiver.decodeObject(of: [ORKFormItem.self], forKey: ArchiveKey)
        XCTAssertNotNil(decodedObject)
        
        guard let decodedObject = decodedObject as? ORKFormItem else {
            XCTFail("decoded rule was not of type ORKFormItemVisibilityRule")
            return
        }
        // ensure we are still an ORKFormItem and visibilityRule is nil
        XCTAssertTrue(decodedObject.classForKeyedArchiver == ORKFormItem.self)
        XCTAssertNil(decodedObject.visibilityRule)
    }
    
    func testAssigningAndMutatingVisibilityRule() throws {
        let formItem = createFormItem()
        let visibilityRule = BogusFormItemVisibilityRuleWithMutableProperties()
        formItem.visibilityRule = visibilityRule
        
        visibilityRule.evaluationLogic = "SOME_VAR == TRUE"
        
        // we expect our mutated rule to be mutated not the assigned rule
        XCTAssertNotEqual(visibilityRule.evaluationLogic, (formItem.visibilityRule as! BogusFormItemVisibilityRuleWithMutableProperties).evaluationLogic)
    }
    
    func createFormItem() -> ORKFormItem {
        let formItem = ORKFormItem(identifier: "formItemIdentifier", text: "Hello", answerFormat: ORKBooleanAnswerFormat())
        return formItem
    }
    
    func createFormItemWithVisibilityRule() -> ORKFormItem {
        let formItem = createFormItem()
        let visibilityRule = ExampleFormItemVisibilityRule()
        formItem.visibilityRule = visibilityRule
        return formItem
    }
}

final class ExampleFormItemVisibilityRule: ORKFormItemVisibilityRule {
    
    public private(set) var evaluationLogic: String?
    
    init(evaluationLogic: String?) {
        super.init()
        self.evaluationLogic = evaluationLogic
    }
    
    override init() {
        super.init()
    }
    
    enum CodingKeys: CodingKey {
        case evaluationLogic
    }
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let result = super.copy(with: zone) as! Self
        result.evaluationLogic = self.evaluationLogic
        return result
    }
    
    /*
     It's a runtime error if a superclass supports secure coding and this class overrides -initWithCoder:, but does
     not also override +supportsSecureCoding. The class must implement +supportsSecureCoding and return YES to verify
     that its implementation of -initWithCoder: is secure coding compliant, otherwise you get NSInvalidUnarchiveOperationException
     */
    class override var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let key = CodingKeys.evaluationLogic.stringValue
        evaluationLogic = coder.decodeObject(of: [NSString.self], forKey: key) as? String
    }

    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(self.evaluationLogic, forKey: CodingKeys.evaluationLogic.stringValue)
    }
        
    override public func isEqual(_ object: Any?) -> Bool {
        guard
            let object = object as? ExampleFormItemVisibilityRule,
            super.isEqual(object),
            evaluationLogic == object.evaluationLogic
        else {
            return false
        }
        return true
     }
    
    override func formItemVisibility(for taskResult: ORKTaskResult?) -> Bool {
        return true
    }
    
}

final class BogusFormItemVisibilityRule: ORKFormItemVisibilityRule {
    
    public private(set) var evaluationLogic: String?
    
    init(evaluationLogic: String?) {
        super.init()
        self.evaluationLogic = evaluationLogic
    }
    
    override init() {
        super.init()
    }
    
    enum CodingKeys: CodingKey {
        case evaluationLogic
    }
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let result = super.copy(with: zone) as! Self
        result.evaluationLogic = self.evaluationLogic
        return result
    }

    /*
     It's a runtime error if a superclass supports secure coding and this class overrides -initWithCoder:, but does
     not also override +supportsSecureCoding. The class must implement +supportsSecureCoding and return YES to verify
     that its implementation of -initWithCoder: is secure coding compliant, otherwise you get NSInvalidUnarchiveOperationException
     */
    class override var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    
        let container = try! (coder as! Decoder).container(keyedBy: CodingKeys.self)
        evaluationLogic = try! container.decode(
            String.self,
            forKey: .evaluationLogic
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(evaluationLogic, forKey: .evaluationLogic)
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard
            let object = object as? BogusFormItemVisibilityRule,
            super.isEqual(object),
            evaluationLogic == object.evaluationLogic
        else {
            return false
        }
        return true
     }
}

final class BogusFormItemVisibilityRuleWithMutableProperties: ORKFormItemVisibilityRule {
    
    public var evaluationLogic: String?
    
    init(evaluationLogic: String?) {
        super.init()
        self.evaluationLogic = evaluationLogic
    }
    
    override init() {
        super.init()
    }
    
    enum CodingKeys: CodingKey {
        case evaluationLogic
    }
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let result = super.copy(with: zone) as! Self
        result.evaluationLogic = self.evaluationLogic
        return result
    }

    /*
     It's a runtime error if a superclass supports secure coding and this class overrides -initWithCoder:, but does
     not also override +supportsSecureCoding. The class must implement +supportsSecureCoding and return YES to verify
     that its implementation of -initWithCoder: is secure coding compliant, otherwise you get NSInvalidUnarchiveOperationException
     */
    class override var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    
        let container = try! (coder as! Decoder).container(keyedBy: CodingKeys.self)
        evaluationLogic = try! container.decode(
            String.self,
            forKey: .evaluationLogic
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(evaluationLogic, forKey: .evaluationLogic)
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard
            let object = object as? BogusFormItemVisibilityRule,
            super.isEqual(object),
            evaluationLogic == object.evaluationLogic
        else {
            return false
        }
        return true
     }
}
