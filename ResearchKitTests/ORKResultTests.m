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

@interface ORKResultTestsHelper: NSObject <ORKTaskViewControllerDelegate>
@end

// For access to taskViewController's managed results
@interface ORKTaskViewController (Testing_Privates)

- (void)setManagedResult:(ORKStepResult *)result forKey:(NSString *)aKey;
- (void)requestHealthStoreAccessWithReadTypes:(NSSet *)readTypes
                                   writeTypes:(NSSet *)writeTypes
                                      handler:(void (^)(void))handler;


@end

@interface ORKResultTests : XCTestCase

@end


@implementation ORKResultTests

- (ORKTaskResult *)createTaskResultTree {
    // Construction
    ORKFileResult *fileResult1 = [[ORKFileResult alloc] initWithIdentifier:@"fileResultIdentifier"];
    
    NSURL *baseURL = [NSURL fileURLWithPath:NSHomeDirectory()];
    NSURL *standardizedBaseURL = [baseURL URLByStandardizingPath];
    fileResult1.fileURL = [NSURL fileURLWithPath:@"ResultFile" relativeToURL:standardizedBaseURL];
    fileResult1.contentType = @"file";
    
    ORKTextQuestionResult *questionResult1 = [[ORKTextQuestionResult alloc] initWithIdentifier:@"questionResultIdentifier"];
    questionResult1.identifier = @"qid";
    questionResult1.answer = @"answer";
    questionResult1.questionType = ORKQuestionTypeText;
    
    ORKConsentSignatureResult *consentResult1 = [[ORKConsentSignatureResult alloc] initWithIdentifier:@"consentSignatureResultIdentifier"];
    consentResult1.signature = [[ORKConsentSignature alloc] init];
    
    ORKStepResult *stepResult1 = [[ORKStepResult alloc] initWithStepIdentifier:@"StepIdentifier" results:@[fileResult1, questionResult1, consentResult1]];
    
    ORKTaskResult *taskResult1 = [[ORKTaskResult alloc] initWithTaskIdentifier:@"TaskIdentifier"
                                                                   taskRunUUID:[NSUUID UUID]
                                                               outputDirectory: [NSURL fileURLWithPath:@"OutputFile" relativeToURL:standardizedBaseURL]];
    taskResult1.results = @[stepResult1];
    return taskResult1;
}

- (void)compareTaskResult1:(ORKTaskResult *)taskResult1 andTaskResult2:(ORKTaskResult *)taskResult2 {
    // Compare
    XCTAssert([taskResult1.taskRunUUID isEqual:taskResult2.taskRunUUID], @"");
    XCTAssert([taskResult1.outputDirectory.absoluteString isEqualToString:taskResult2.outputDirectory.absoluteString], @"");
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

- (void)testTaskViewControllerNullDataRestorationThrows {
    NSData *taskData = [NSData data];
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"test" steps:@[]];
    ORKResultTestsHelper *taskDelegate = [[ORKResultTestsHelper alloc] init];
    
    ORKTaskViewController *taskViewController;
    
    @try {
        NSError *error = nil;
        taskViewController = [[ORKTaskViewController alloc] initWithTask:task restorationData:taskData delegate:taskDelegate error:&error];
        XCTFail("ORKTaskViewController init with bad restoration data should throw");
    } @catch (NSException *exception) {
        XCTAssertEqual(NSInternalInconsistencyException, exception.name);
    }
}

- (void)testTaskViewControllerPrematureViewLoading {
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"test" steps:@[
        [[ORKInstructionStep alloc] initWithIdentifier:@"test"]
    ]];
    ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    ORKStepViewController *viewController = [taskViewController viewControllerForStep:task.steps.firstObject];
    
    XCTAssertFalse(viewController.isViewLoaded, "TaskViewController's viewControllerForStep should return a viewController *without* its view loaded");
}

- (void)testMutableDecoding {
    NSMutableArray *things = [[NSMutableArray alloc] initWithObjects:@"hello", @"world", nil];
    __auto_type keyedArchiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
    [keyedArchiver encodeObject:things forKey:@"mutableThings"];
    [keyedArchiver encodeObject:@[@"farewell"] forKey:@"immutableThings"];
    [keyedArchiver finishEncoding];
    
    NSData *data = [keyedArchiver encodedData];
    __auto_type keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil];
    NSSet *decodableTypes = [NSSet setWithObjects:NSMutableArray.self, NSString.self, nil];

    {
        // decoding an mutable array actually returns a mutable array
        NSMutableArray *decodedArray = [keyedUnarchiver decodeObjectOfClasses:decodableTypes forKey:@"mutableThings"];
        XCTAssertTrue([decodedArray isKindOfClass:NSMutableArray.self], "decoding a mutable array should return a mutable array");
        
        [decodedArray addObject:@"test"];
        XCTAssertEqual(decodedArray.count, 3);
        XCTAssertEqualObjects(decodedArray.lastObject, @"test");
    }
    
    {
        // decoding an immutable array as if it were mutable works, but should fail when using it as mutable
        NSMutableArray *decodedArray = [keyedUnarchiver decodeObjectOfClasses:decodableTypes forKey:@"immutableThings"];
        XCTAssertFalse([decodedArray isKindOfClass:NSMutableArray.self], "decoding an immutable array should return an immutable array");
        XCTAssertTrue([decodedArray isKindOfClass:NSArray.self]);
        XCTAssertThrows([decodedArray addObject:@"test"]);
    }
}

- (void)testTaskViewControllerRestorationWorks {
    ORKFormStep *formItemStep = [[ORKFormStep alloc] initWithIdentifier:@"step"];
    
    formItemStep.formItems = @[
        [[ORKFormItem alloc] initWithIdentifier:@"item1" text:nil answerFormat:ORKAnswerFormat.booleanAnswerFormat],
        [[ORKFormItem alloc] initWithIdentifier:@"item2" text:nil answerFormat:ORKAnswerFormat.textAnswerFormat],
        [[ORKFormItem alloc] initWithIdentifier:@"item3" text:nil answerFormat:[ORKAnswerFormat integerAnswerFormatWithUnit:nil]]
    ];
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"test" steps:@[formItemStep]];

    NSData *encodedTaskViewControllerData;
    {
        // create the task as if we were to present it
        ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
        
        // Trigger requestHealth access to fill in the read/write types ivars
        NSSet *readTypes = [NSSet setWithObjects:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate], nil];
        NSSet *writeTypes = [NSSet setWithObjects:[HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierBloating], nil];
        [taskViewController requestHealthStoreAccessWithReadTypes:readTypes writeTypes:writeTypes handler:^(){
           // intentionally left empty
        }];

        // viewWillAppear fills in the _managedStepIdentifiers in the taskViewController
        [taskViewController viewWillAppear:false];
        
        // make a few answers to test with, simulating answers entered by a user
        __auto_type booleanAnswer = [[ORKBooleanQuestionResult alloc] initWithIdentifier:@"item1"];
        booleanAnswer.booleanAnswer = @(YES);

        __auto_type textAnswer = [[ORKTextQuestionResult alloc] initWithIdentifier:@"item2"];
        textAnswer.textAnswer = @"there is no answer, only questions";

        __auto_type integerAnswer = [[ORKNumericQuestionResult alloc] initWithIdentifier:@"item3"];
        integerAnswer.numericAnswer = @(42);

        ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"step" results:@[
            booleanAnswer, textAnswer, integerAnswer
        ]];

        // set the answers using taskViewController-internal method, to simulate user data entry
        [taskViewController setManagedResult:stepResult forKey:@"step"];
        
        // archive it
        __auto_type keyedArchiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
        [taskViewController encodeRestorableStateWithCoder:keyedArchiver];
        encodedTaskViewControllerData = [keyedArchiver encodedData];
    }
    XCTAssertNotNil(encodedTaskViewControllerData);
    
    // init a new taskViewController with the restoration data
    {
        // important to start with the same task so the identifiers match
        ORKResultTestsHelper *taskDelegate = [[ORKResultTestsHelper alloc] init];
        ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] initWithTask:task restorationData:encodedTaskViewControllerData delegate:taskDelegate error:nil];
        
        // confirm the read/write HK type info made it across the encode/decode bridge
        XCTAssertEqualObjects([taskViewController requestedHealthTypesForRead], [NSSet setWithObject:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]]);
        XCTAssertEqualObjects([taskViewController requestedHealthTypesForWrite], [NSSet setWithObject:[HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierBloating]]);
        
        ORKStepResult *stepResult = (ORKStepResult *)[[[taskViewController result] results] firstObject];
        NSArray<ORKQuestionResult*> *questionResults = (NSArray<ORKQuestionResult*> *)[stepResult results];
        XCTAssertEqual([questionResults count], 3);

        XCTAssertEqual(questionResults[0].answer, @(YES));
        XCTAssertEqual(questionResults[0].identifier, @"item1");
        XCTAssertEqualObjects(questionResults[1].answer, @"there is no answer, only questions");
        XCTAssertEqual(questionResults[1].identifier, @"item2");
        XCTAssertEqualObjects(questionResults[2].answer, @(42));
        XCTAssertEqual(questionResults[2].identifier, @"item3");
    }
    
}

- (void)testResultSecureCoding {
    ORKTaskResult *taskResult1 = [self createTaskResultTree];
    
    // Archive
    id data = [NSKeyedArchiver archivedDataWithRootObject:taskResult1 requiringSecureCoding:YES error:nil];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil];
    unarchiver.requiresSecureCoding = YES;
    ORKTaskResult *taskResult2 = [unarchiver decodeObjectOfClass:[ORKTaskResult class] forKey:NSKeyedArchiveRootObjectKey];
    
    [self compareTaskResult1:taskResult1 andTaskResult2:taskResult2];
    XCTAssertEqualObjects(taskResult1, taskResult2);
}

- (void)testConsentDocumentDecoding {
    ORKConsentDocument *document = [[ORKConsentDocument alloc] init];
    document.signatures = @[
        [[ORKConsentSignature alloc] init],
        [[ORKConsentSignature alloc] init],
        [[ORKConsentSignature alloc] init]
    ];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
    [archiver encodeObject:document forKey:@"rootDocumet"];
    NSData *data = archiver.encodedData;
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil];
    unarchiver.requiresSecureCoding = true;
    ORKConsentDocument *decodedDocument = [unarchiver decodeObjectOfClass:ORKConsentDocument.self forKey:@"rootDocumet"];
    XCTAssertEqual(decodedDocument.signatures.count, 3);
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
    step1Result1.choiceAnswers = @[ @(1) ];
    ORKChoiceQuestionResult *step1Result2 = [[ORKChoiceQuestionResult alloc] initWithIdentifier:@"step1.result2"];
    step1Result2.choiceAnswers = @[ @(2) ];
    ORKChoiceQuestionResult *step2Result1 = [[ORKChoiceQuestionResult alloc] initWithIdentifier:@"step2.result1"];
    step2Result1.choiceAnswers = @[ @(3) ];
    
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

@implementation ORKResultTestsHelper

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(nullable NSError *)error {
    // intentionally left empty
}

@end



