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

extension NSPredicate {
    class var truePredicate: NSPredicate {
        return NSPredicate(value: true)
    }
    
    class var falsePredicate: NSPredicate {
        return NSPredicate(value: false)
    }
}

final class ORKPredicateFormItemVisibilityRuleTests: XCTestCase {
    func testRuleCreation() throws {
        do {
            let rule = ORKPredicateFormItemVisibilityRule(predicate: .truePredicate);
            XCTAssertNotNil(rule)
            XCTAssertNotNil(rule.predicate)
            XCTAssertEqual(rule.predicate, .truePredicate)
        }

        do {
            let predicate = NSPredicate(format: "$has_dogs == YES")
            let rule = ORKPredicateFormItemVisibilityRule(predicate: predicate);
            XCTAssertNotNil(rule)
            XCTAssertNotNil(rule.predicate)
            XCTAssertEqual(predicate, rule.predicate)
        }
    }
    
    func testRuleCopying() throws {
        do {
            let rule = ORKPredicateFormItemVisibilityRule(predicate: .truePredicate);
            let copy = rule.copy() as? ORKPredicateFormItemVisibilityRule
            XCTAssertNotNil(copy)
            XCTAssertEqual(copy, rule)
        }

        do {
            let predicate = NSPredicate(format: "$has_dogs == YES")
            let rule = ORKPredicateFormItemVisibilityRule(predicate: predicate);
            let copy = rule.copy() as? ORKPredicateFormItemVisibilityRule
            XCTAssertNotNil(copy)
            XCTAssertNotNil(copy?.predicate)
            XCTAssertEqual(copy, rule)
        }
    }
    
    func testIsEqual() throws {
        do {
            let rule = ORKPredicateFormItemVisibilityRule(predicate: .truePredicate);
            let bogusRule = BogusFormItemVisibilityRule()
            XCTAssertNotEqual(rule, bogusRule)
        }

        do {
            let predicate = NSPredicate(format: "$has_dogs == YES")
            let rule1 = ORKPredicateFormItemVisibilityRule(predicate: .truePredicate);
            let rule2 = ORKPredicateFormItemVisibilityRule(predicate: predicate);
            XCTAssertNotEqual(rule1, rule2)
        }

        do {
            let predicate = NSPredicate(value: true)
            let rule1 = ORKPredicateFormItemVisibilityRule(predicate: .truePredicate);
            let rule2 = ORKPredicateFormItemVisibilityRule(predicate: predicate);
            XCTAssertEqual(rule1, rule2)
        }
    }
    
    func testHashing() throws {
        let predicate = NSPredicate(format: "$has_dogs == YES")
        let rule1 = ORKPredicateFormItemVisibilityRule(predicate: .truePredicate);
        let rule2 = ORKPredicateFormItemVisibilityRule(predicate: predicate);
        let rule3 = ORKPredicateFormItemVisibilityRule(predicate: predicate);
                
        do {
            let set = NSSet(array: [rule2, rule3])
            XCTAssertEqual(set.count, 1, "equal rules should replace hash to one object in a set")
        }
        do {
            let set = NSSet(array: [rule1, rule3])
            XCTAssertEqual(set.count, 2, "unequal rules should coexist in a set")
        }
        do {
            let set = NSSet(array: [rule1, NSPredicate.truePredicate])
            XCTAssertEqual(set.count, 2, "Even though rule.hash is just _predicate.hash, the two types should occypy two slots in a set")
        }
        do {
            let set = Set([rule1, rule2, rule3])
            XCTAssertEqual(set.count, 2)
        }
        do {
            let set = Set([rule1, NSPredicate.truePredicate])
            XCTAssertEqual(set.count, 2)
        }
    }
    
    func testAllowEvaluationOnRule() throws {
        let formItems = [ORKFormItem(identifier: "item1", text: "text1", answerFormat: ORKTextAnswerFormat()), ORKFormItem(identifier: "item2", text: "text2", answerFormat: ORKTextAnswerFormat()), ORKFormItem(identifier: "item3", text: "text3", answerFormat: ORKTextAnswerFormat())] as NSArray
        let predicate = NSPredicate(format: "identifier = 'item1'")
        let rule = ORKPredicateFormItemVisibilityRule(predicate: predicate)
        
        // archive the ORKPredicateFormItemVisibilityRule
        let encoder = NSKeyedArchiver(requiringSecureCoding: true)
        let ArchiveKey = "formItemWithVisibilityRule"
        encoder.encode(rule, forKey: ArchiveKey)
        encoder.finishEncoding()
        let data = encoder.encodedData
        
        let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: data)
        let decodedObject = unarchiver.decodeObject(of: ORKPredicateFormItemVisibilityRule.self, forKey: ArchiveKey)
        XCTAssertNotNil(decodedObject)
        
        // allowEvaluation() is called under the hood  when decoding
        
        let filteredItems = formItems.filtered(using: decodedObject!.predicate)
        
        XCTAssertTrue(filteredItems.count == 1)
        XCTAssertEqual((filteredItems.first! as! ORKFormItem).identifier, "item1")
    }
    
    func testAllowEvaluationOnCustomRule() throws {
        let result = ORKTaskResult(taskIdentifier: "TaskIdentifier", taskRun: UUID(), outputDirectory: nil)
        
        let choiceResult =  ORKChoiceQuestionResult(identifier: "dogsFormItem")
        choiceResult.answer = ["Yes" as NSString] as any NSCopying & NSSecureCoding & NSObjectProtocol
        
        result.results = [ORKStepResult(stepIdentifier:"formStepIdentifier", results: [choiceResult])]

        let selector = ORKResultSelector(
            stepIdentifier: String(describing: "formStepIdentifier"),
            resultIdentifier: String(describing: "dogsFormItem")
        )
        
        let predicate = ORKResultPredicate.predicateForChoiceQuestionResult(
            with: selector,
            expectedAnswerValue: "Yes" as NSString
        )

        let rule = ORKPredicateFormItemVisibilityRule(predicate: predicate)

        XCTAssertTrue(
            rule.formItemVisibility(for: result)
        )
        
        // archive the ORKPredicateFormItemVisibilityRule
        let encoder = NSKeyedArchiver(requiringSecureCoding: true)
        let ArchiveKey = "formItemWithVisibilityRule"
        encoder.encode(rule, forKey: ArchiveKey)
        encoder.finishEncoding()
        let data = encoder.encodedData
        
        let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: data)
        let decodedRule = unarchiver.decodeObject(of: ORKPredicateFormItemVisibilityRule.self, forKey: ArchiveKey)
        XCTAssertNotNil(decodedRule)
        
        // allowEvaluation() is called under the hood  when decoding

        XCTAssertTrue(
            decodedRule!.formItemVisibility(for: result)
        )
    }

    func testDecodedPredicateEvaluationOutsideRulesThrows() throws {
        throw XCTSkip("executeUsingObjCExceptionHandling seems to fail, skipping this test.")
        
        let formItems = [ORKFormItem(identifier: "item1", text: "text1", answerFormat: ORKTextAnswerFormat()), ORKFormItem(identifier: "item2", text: "text2", answerFormat: ORKTextAnswerFormat()), ORKFormItem(identifier: "item3", text: "text3", answerFormat: ORKTextAnswerFormat())] as NSArray
        let predicate = NSPredicate(format: "identifier = 'item1'")
        
        // archive the NSPredicate
        let encoder = NSKeyedArchiver(requiringSecureCoding: true)
        let ArchiveKey = "formItemWithVisibilityRule"
        encoder.encode(predicate, forKey: ArchiveKey)
        encoder.finishEncoding()
        let data = encoder.encodedData
        
        let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: data)
        let decodedPredicate = unarchiver.decodeObject(of: NSPredicate.self, forKey: ArchiveKey)
        XCTAssertNotNil(decodedPredicate)

        XCTAssertThrowsError(try NSObject.executeUsingObjCExceptionHandling {
            formItems.filtered(using: decodedPredicate!)
        }) { error in
            let exception = (error as NSError).userInfo[ORKUnderlyingExceptionKey] as! NSException
            XCTAssertEqual(exception.name, NSExceptionName.internalInconsistencyException)
        }
    }
    
    func testDecodedORKResultPredicateEvaluationOutsideRulesThrows() throws {
        throw XCTSkip("executeUsingObjCExceptionHandling seems to fail, skipping this test.")
        
        let result = ORKTaskResult(taskIdentifier: "TaskIdentifier", taskRun: UUID(), outputDirectory: nil)
        
        let choiceResult =  ORKChoiceQuestionResult(identifier: "dogsFormItem")
        choiceResult.answer = ["Yes" as NSString] as any NSCopying & NSSecureCoding & NSObjectProtocol
        
        result.results = [ORKStepResult(stepIdentifier:"formStepIdentifier", results: [choiceResult])]

        let selector = ORKResultSelector(
            stepIdentifier: String(describing: "formStepIdentifier"),
            resultIdentifier: String(describing: "dogsFormItem")
        )
        
        let predicate = ORKResultPredicate.predicateForChoiceQuestionResult(
            with: selector,
            expectedAnswerValue: "Yes" as NSString
        )

        XCTAssertTrue(
            predicate.evaluate(with: [result], substitutionVariables: [
                ORKResultPredicateTaskIdentifierVariableName: result.identifier
            ])
        )
        
        // archive the NSPredicate
        let encoder = NSKeyedArchiver(requiringSecureCoding: true)
        let ArchiveKey = "formItemWithVisibilityRule"
        encoder.encode(predicate, forKey: ArchiveKey)
        encoder.finishEncoding()
        let data = encoder.encodedData
        
        let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: data)
        let decodedPredicate = unarchiver.decodeObject(of: NSPredicate.self, forKey: ArchiveKey)
        XCTAssertNotNil(decodedPredicate)

        XCTAssertThrowsError(try NSObject.executeUsingObjCExceptionHandling {
            decodedPredicate!.evaluate(with: [result], substitutionVariables: [
                    ORKResultPredicateTaskIdentifierVariableName: result.identifier
            ])
        }) { error in
            let exception = (error as NSError).userInfo[ORKUnderlyingExceptionKey] as! NSException
            XCTAssertEqual(exception.name, NSExceptionName.internalInconsistencyException)
        }
    }
}
