/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


@import XCTest;
@import ResearchKit.Private;


@interface ORKResultTests : XCTestCase

@end


@implementation ORKResultTests

- (ORKTaskResult *)createTaskResultTree {
    // Construction
    ORKFileResult *fileResult1 = [[ORKFileResult alloc] init];
    fileResult1.fileURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    fileResult1.contentType = @"file";
    
    ORKTextQuestionResult *questionResult1 = [[ORKTextQuestionResult alloc] init];
    questionResult1.identifier = @"qid";
    questionResult1.answer = @"answer";
    questionResult1.questionType = ORKQuestionTypeText;
    
    ORKConsentSignatureResult *consentResult1 = [[ORKConsentSignatureResult alloc] init];
    consentResult1.signature = [[ORKConsentSignature alloc] init];
    
    ORKStepResult *stepResult1 = [[ORKStepResult alloc] initWithStepIdentifier:@"StepIdentifier" results:@[fileResult1, questionResult1, consentResult1]];
    
    ORKTaskResult *taskResult1 = [[ORKTaskResult alloc] initWithTaskIdentifier:@"taskIdetifier"
                                                                   taskRunUUID:[NSUUID UUID]
                                                               outputDirectory: [NSURL fileURLWithPath:NSTemporaryDirectory()]];
    taskResult1.results = @[stepResult1];
    
    return taskResult1;
}

- (void)compareTaskResult1:(ORKTaskResult *)taskResult1 andTaskResult2:(ORKTaskResult *)taskResult2 {
    // Compare
    XCTAssert([taskResult1.taskRunUUID isEqual:taskResult2.taskRunUUID], @"");
    XCTAssert([taskResult1.outputDirectory.absoluteString isEqual:taskResult2.outputDirectory.absoluteString], @"");
    XCTAssert([taskResult1.identifier isEqualToString:taskResult2.identifier], @"");
    
    XCTAssert(taskResult1 != taskResult2, @"");

    [taskResult1.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ORKResult *result1 = obj;
        ORKResult *result2 = taskResult2.results[idx];
        XCTAssertNotNil(result2, @"");
        XCTAssert(result1.class == result2.class);
        XCTAssert(result2.class == ORKStepResult.class);
        ORKStepResult *stepResult1 = (ORKStepResult *)result1;
        ORKStepResult *stepResult2 = (ORKStepResult *)result2;
        
        XCTAssert(stepResult1 != stepResult2, @"");
        
        [stepResult1.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ORKResult *result1 = obj;
            ORKResult *result2 = stepResult2.results[idx];
            XCTAssertNotNil(result2, @"");
            XCTAssert(result1.class == result2.class);
            XCTAssert([result1.startDate isEqualToDate: result2.startDate], @"");
            XCTAssert([result1.endDate isEqualToDate: result2.endDate], @"");
            
            XCTAssert(result1 != result2, @"");
            
            if ([result1 isKindOfClass:[ORKQuestionResult class]]) {
                ORKQuestionResult *q1 = (ORKQuestionResult *)result1;
                ORKQuestionResult *q2 = (ORKQuestionResult *)result2;
                
                XCTAssert(q1.questionType == q2.questionType, @"");
                if (![q1.answer isEqual:q2.answer]) {
                    XCTAssert([q1.answer isEqual:q2.answer], @"");
                }
                XCTAssert([q1.identifier isEqualToString:q2.identifier], @"%@ and %@", q1.identifier, q2.identifier);
            } else if ([result1 isKindOfClass:[ORKFileResult class]]) {
                ORKFileResult *f1 = (ORKFileResult *)result1;
                ORKFileResult *f2 = (ORKFileResult *)result2;
                
                XCTAssert( [f1.fileURL.absoluteString isEqual:f2.fileURL.absoluteString], @"");
                XCTAssert( [f1.contentType isEqualToString:f2.contentType], @"");
            } else if ([result1 isKindOfClass:[ORKConsentSignatureResult class]]) {
                ORKConsentSignatureResult *c1 = (ORKConsentSignatureResult *)result1;
                ORKConsentSignatureResult *c2 = (ORKConsentSignatureResult *)result2;
                
                XCTAssert(c1.signature != c2.signature, @"");
            }
        }];
    }];
}

- (void)testResultSerialization {
    ORKTaskResult *taskResult1 = [self createTaskResultTree];
    
    // Archive
    id data = [NSKeyedArchiver archivedDataWithRootObject:taskResult1];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    unarchiver.requiresSecureCoding = YES;
    ORKTaskResult *taskResult2 = [unarchiver decodeObjectOfClass:[ORKTaskResult class] forKey:NSKeyedArchiveRootObjectKey];
    
    [self compareTaskResult1:taskResult1 andTaskResult2:taskResult2];

    XCTAssertEqualObjects(taskResult1, taskResult2);
}

- (void)testResultCopy {
    ORKTaskResult *taskResult1 = [self createTaskResultTree];
    
    ORKTaskResult *taskResult2 = [taskResult1 copy];
    
    [self compareTaskResult1:taskResult1 andTaskResult2:taskResult2];
    
    XCTAssertEqualObjects(taskResult1, taskResult2);
}

- (void)testCollectionResult {
    ORKCollectionResult *result = [[ORKCollectionResult alloc] initWithIdentifier:@"001"];
    [result setResults:@[ [[ORKResult alloc]initWithIdentifier: @"101"], [[ORKResult alloc]initWithIdentifier: @"007"] ]];
    
    ORKResult *childResult = [result resultForIdentifier:@"005"];
    XCTAssertNil(childResult, @"%@", childResult.identifier);
    
    childResult = [result resultForIdentifier:@"007"];
    XCTAssertEqual(childResult.identifier, @"007", @"%@", childResult.identifier);
    
    childResult = [result resultForIdentifier: @"101"];
    XCTAssertEqual(childResult.identifier, @"101", @"%@", childResult.identifier);
}

- (void)testPageResult {
    
    NSArray *steps = @[[[ORKStep alloc] initWithIdentifier:@"step1"],
                       [[ORKStep alloc] initWithIdentifier:@"step2"],
                       [[ORKStep alloc] initWithIdentifier:@"step3"],
                       ];
    ORKPageStep *pageStep = [[ORKPageStep alloc] initWithIdentifier:@"pageStep" steps:steps];
    
    ORKChoiceQuestionResult *step1Result1 = [[ORKChoiceQuestionResult alloc] initWithIdentifier:@"step1.result1"];
    step1Result1.choiceAnswers = @[@(1)];
    ORKChoiceQuestionResult *step1Result2 = [[ORKChoiceQuestionResult alloc] initWithIdentifier:@"step1.result2"];
    step1Result2.choiceAnswers = @[@(2)];
    ORKChoiceQuestionResult *step2Result1 = [[ORKChoiceQuestionResult alloc] initWithIdentifier:@"step2.result1"];
    step2Result1.choiceAnswers = @[@(3)];
    
    ORKStepResult *inputResult = [[ORKStepResult alloc] initWithStepIdentifier:@"pageStep"
                                                                      results:@[step1Result1, step1Result2, step2Result1]];
    
    // Test that the page result creates ORKStepResults for each result that matches the prefix test
    ORKPageResult *pageResult = [[ORKPageResult alloc] initWithPageStep:pageStep stepResult:inputResult];
    XCTAssertEqual(pageResult.results.count, 2);
    
    ORKStepResult *stepResult1 = [pageResult stepResultForStepIdentifier:@"step1"];
    XCTAssertNotNil(stepResult1);
    XCTAssertEqual(stepResult1.results.count, 2);
    
    ORKStepResult *stepResult2 = [pageResult stepResultForStepIdentifier:@"step2"];
    XCTAssertNotNil(stepResult2);
    XCTAssertEqual(stepResult2.results.count, 1);
    
    ORKStepResult *stepResult3 = [pageResult stepResultForStepIdentifier:@"step3"];
    XCTAssertNil(stepResult3);
    
    // Check that the flattened results match the input results
    NSArray *flattedResults = [pageResult flattenResults];
    XCTAssertEqualObjects(inputResult.results, flattedResults);
}

@end
