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
@testable import ResearchKit

class ORKFamilyHistoryResultTests: XCTestCase {
        
    func testCopiesAreEqual() {
        let result = simpleFamilyHistoryResultWithIdentifier()
        let copy = result.copy() as! ORKFamilyHistoryResult
        
        XCTAssertEqual(copy, result)
        
        // relatedPerson references are deep copied when copying the family history result.
        // The properties of each relatedPerson should be equal, but the relatedPerson objects should not be pointer equal
        XCTAssertNotIdentical(copy.relatedPersons?.first, result.relatedPersons?.first)
        XCTAssertEqual(copy.relatedPersons?.first, result.relatedPersons?.first)
        XCTAssertNotIdentical(copy.relatedPersons?.last, result.relatedPersons?.last)
        XCTAssertEqual(copy.relatedPersons?.last, result.relatedPersons?.last)

        XCTAssertEqual(copy.displayedConditions, result.displayedConditions)
    }
    
    func testIsEqual() {
        let result = simpleFamilyHistoryResultWithIdentifier()

        do { // confirm changing the conditions breaks equality
            let copy = result.copy() as! ORKFamilyHistoryResult
            XCTAssertEqual(copy, result)
            
            copy.displayedConditions = ["none"]
            XCTAssertNotEqual(result, copy)
        }

        do { // confirm changing the relatedPersons array breaks equality
            let copy = result.copy() as! ORKFamilyHistoryResult
            XCTAssertEqual(copy, result)
            
            copy.relatedPersons = []
            XCTAssertNotEqual(result, copy)
        }

        do { // confirm changing the identifier breaks equality
            let copy = simpleFamilyHistoryResultWithIdentifier("xyz")
            copy.relatedPersons = result.relatedPersons
            copy.displayedConditions = result.displayedConditions
            
            XCTAssertNotEqual(copy, result)
        }
    }
    
    func simpleFamilyHistoryResultWithIdentifier(_ identifier: String = "abc") -> ORKFamilyHistoryResult {
        let result = ORKFamilyHistoryResult(identifier: identifier)
        result.displayedConditions = [
            "gout",
            "heart disease",
            "hypertension"
        ]
        result.relatedPersons = [
            ORKRelatedPerson(
                identifier: "aaa",
                groupIdentifier: "parents",
                identifierForCellTitle: "title",
                taskResult: ORKTaskResult(taskIdentifier: "1", taskRun: UUID(), outputDirectory: nil)
            ),
            ORKRelatedPerson(
                identifier: "lil",
                groupIdentifier: "children",
                identifierForCellTitle: "title",
                taskResult: ORKTaskResult(taskIdentifier: "2", taskRun: UUID(), outputDirectory: nil)
            ),
        ]
        return result
    }
}

