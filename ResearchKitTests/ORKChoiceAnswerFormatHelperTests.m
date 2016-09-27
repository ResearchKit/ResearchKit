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

#import "ORKChoiceAnswerFormatHelper.h"


@interface ORKChoiceAnswerFormatHelperTests : XCTestCase

@end


@implementation ORKChoiceAnswerFormatHelperTests

- (NSArray *)textChoices {
    
    static NSArray *choices = nil;
    
    if (choices == nil) {
        choices = @[[ORKTextChoice choiceWithText:@"choice 01" value:@"c1"],
                        [ORKTextChoice choiceWithText:@"choice 02" value:@"c2"],
                        [ORKTextChoice choiceWithText:@"choice 03" value:@"c3"],
                        [ORKTextChoice choiceWithText:@"choice 04" value:@"c4"]];
    }
    
    return choices;
}

- (NSArray *)imageChoices {
    
    static NSArray *choices = nil;
    
    if (choices == nil) {
        choices = @[[ORKImageChoice choiceWithNormalImage:nil selectedImage:nil text:@"choice 01" value:@"c1"],
                    [ORKImageChoice choiceWithNormalImage:nil selectedImage:nil text:@"choice 02" value:@"c2"],
                    [ORKImageChoice choiceWithNormalImage:nil selectedImage:nil text:@"choice 03" value:@"c3"]];
    }
    
    return choices;
}

- (void)testCount {
   
    {
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                         textChoices:[self textChoices]];
        ORKChoiceAnswerFormatHelper *formatHelper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
        XCTAssertEqual(formatHelper.choiceCount, [self textChoices].count, @"");
    }
    
    {
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithImageChoices:[self imageChoices]];
        ORKChoiceAnswerFormatHelper *formatHelper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
        XCTAssertEqual(formatHelper.choiceCount, [self imageChoices].count, @"");
    }
    
    {
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:[self textChoices]];
        ORKChoiceAnswerFormatHelper *formatHelper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
        XCTAssertEqual(formatHelper.choiceCount, [self textChoices].count+1, @"");
    }
}

- (void)testTextChoice {
    {
        NSArray *textChoices = [self textChoices];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                               textChoices:textChoices];
        
        
        ORKChoiceAnswerFormatHelper *formatHelper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
        [textChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ORKTextChoice *tc = obj;
            ORKTextChoice *tc2 = [formatHelper textChoiceAtIndex:idx];
            XCTAssertEqual(tc, tc2, @"");
            XCTAssertNil([formatHelper imageChoiceAtIndex:idx],@"");
        }];
    }
    
    {
        NSArray *textChoices = [self textChoices];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices];
        
        
        ORKChoiceAnswerFormatHelper *formatHelper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
        [textChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ORKTextChoice *tc = obj;
            ORKTextChoice *tc2 = [formatHelper textChoiceAtIndex:idx+1];
            XCTAssertEqual(tc, tc2, @"");
            XCTAssertNil([formatHelper imageChoiceAtIndex:idx],@"");
        }];
    }
}

- (void)testImageChoice {
    {
        NSArray *imageChoices = [self imageChoices];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithImageChoices:imageChoices];
        
        
        ORKChoiceAnswerFormatHelper *formatHelper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
        [imageChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ORKImageChoice *tc = obj;
            ORKImageChoice *tc2 = [formatHelper imageChoiceAtIndex:idx];
            XCTAssertEqual(tc, tc2, @"");
            XCTAssertNil([formatHelper textChoiceAtIndex:idx],@"");
        }];
    }
}

- (void)verifyAnswerForSelectedIndexes:(ORKChoiceAnswerFormatHelper *)formatHelper choices:(NSArray *)choices {
    NSMutableArray *indexArray = [NSMutableArray new];
    
    [choices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        id answer = [formatHelper answerForSelectedIndex:idx];
        
        XCTAssert([answer isKindOfClass:[NSArray class]]);
        NSArray *answerArray = answer;
        
        id value = ((ORKTextChoice *)choices[idx]).value;
        
        if (value == nil) {
            value = @(idx);
        }
        
        XCTAssert(answerArray.count == 1 && [answerArray.firstObject isEqual:value], @"%@", answerArray);
        
        answer = [formatHelper answerForSelectedIndexes:@[@(idx)]];
        XCTAssert([answer isKindOfClass:[NSArray class]]);
        answerArray = answer;

        XCTAssert(answerArray.count == 1 && [answerArray.firstObject isEqual:value], @"%@", answerArray);
        
        [indexArray addObject:@(idx)];
        
        answer = [formatHelper answerForSelectedIndexes:indexArray];
        XCTAssert([answer isKindOfClass:[NSArray class]]);
        answerArray = answer;

        XCTAssertEqual(answerArray.count, idx + 1, @"%@", answerArray);
        
    }];
}

- (void)testAnswerForSelectedIndexes {
    {
        NSArray *textChoices = [self textChoices];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices];
        
        ORKChoiceAnswerFormatHelper *formatHelper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
        id answer = [formatHelper answerForSelectedIndexes:@[@(0)]];
        
        XCTAssert(answer == ORKNullAnswerValue(), @"%@", answer);
        
        answer = [formatHelper answerForSelectedIndex:0];
        
        XCTAssert(answer == ORKNullAnswerValue(), @"%@", answer);
        
        [textChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            id answer = [formatHelper answerForSelectedIndex:idx+1];
            
            id value = ((ORKTextChoice *)textChoices[idx]).value;
            
            if (value == nil) {
                value = @(idx);
            }
            
            XCTAssert([answer isKindOfClass:[NSArray class]]);
            NSArray *answerArray = answer;
            XCTAssert(answerArray.count == 1 && [answerArray.firstObject isEqual:value], @"%@", answer);
            
            answer = [formatHelper answerForSelectedIndexes:@[@(idx+1)]];
            XCTAssert([answer isKindOfClass:[NSArray class]]);
            answerArray = answer;
            
            XCTAssert(answerArray.count == 1 && [answerArray.firstObject isEqual:value], @"%@", answer);
        }];
        
    }
    
    {
        NSArray *textChoices = [self textChoices];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                               textChoices:textChoices];
        
        ORKChoiceAnswerFormatHelper *formatHelper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
       
        [self verifyAnswerForSelectedIndexes:formatHelper choices:textChoices];
    }
    
    {
        NSArray *imageChoices = [self imageChoices];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithImageChoices:imageChoices];
        
        ORKChoiceAnswerFormatHelper *formatHelper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
        [self verifyAnswerForSelectedIndexes:formatHelper choices:imageChoices];
    }
}

- (void)verifySelectedIndexesForAnswer:(ORKChoiceAnswerFormatHelper *)formatHelper choices:(NSArray *)choices {
    
    NSArray *indexes = [formatHelper selectedIndexesForAnswer:nil];
    
    XCTAssertEqual(indexes.count, 0, @"%@", indexes);
    
    indexes = [formatHelper selectedIndexesForAnswer:ORKNullAnswerValue()];
    
    XCTAssertEqual(indexes.count, 0, @"%@", indexes);
    
    NSNumber *indexNumber = [formatHelper selectedIndexForAnswer:nil];
    
    XCTAssertNil(indexNumber, @"%@", indexNumber);
    
    indexNumber = [formatHelper selectedIndexForAnswer:ORKNullAnswerValue()];
    
    XCTAssertNil(indexNumber, @"%@", indexNumber);
    
    [choices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        id value = ((ORKTextChoice *)obj).value;
        
        if (value == nil) {
            value = @(idx);
        }
        
        NSNumber *indexNumber = [formatHelper selectedIndexForAnswer:@[value]];
        
        XCTAssertEqualObjects(indexNumber, @(idx), @"%@ vs %@", indexNumber, @(idx));
        
        NSArray *indexArray = [formatHelper selectedIndexesForAnswer:@[value]];
        
        XCTAssertEqualObjects( indexArray.firstObject, @(idx), @"%@ vs %@", indexArray[0], @(idx));
        
    }];
}

- (void)testSelectedIndexesForAnswer {
    {
        NSArray *textChoices = [self textChoices];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices];
        
        ORKChoiceAnswerFormatHelper *formatHelper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
        NSArray *indexes = [formatHelper selectedIndexesForAnswer:nil];
        
        XCTAssertEqualObjects(indexes.firstObject, @(0), @"%@", indexes);
        
        indexes = [formatHelper selectedIndexesForAnswer:ORKNullAnswerValue()];
        
        XCTAssertEqualObjects(indexes.firstObject, @(0), @"%@", indexes);
        
        NSNumber *indexNumber = [formatHelper selectedIndexForAnswer:nil];
        
        XCTAssert([indexNumber isKindOfClass:[NSNumber class]] && indexNumber.unsignedIntegerValue == 0, @"%@", indexNumber);
        
        indexNumber = [formatHelper selectedIndexForAnswer:ORKNullAnswerValue()];
        
        XCTAssert([indexNumber isKindOfClass:[NSNumber class]] && indexNumber.unsignedIntegerValue == 0, @"%@", indexNumber);
        
        [textChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            id value = ((ORKTextChoice *)obj).value;
            
            if (value == nil) {
                value = @(idx);
            }
            
            NSNumber *indexNumber = [formatHelper selectedIndexForAnswer:@[value]];
            
            XCTAssertEqualObjects(indexNumber, @(idx+1), @"%@ vs %@", indexNumber, @(idx+1));
            
            NSArray *indexArray = [formatHelper selectedIndexesForAnswer:@[value]];
            
            XCTAssertEqualObjects(indexArray.firstObject, @(idx+1), @"%@ vs %@", indexArray[0], @(idx+1));
            
        }];
        
    }
    
    {
        NSArray *textChoices = [self textChoices];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                               textChoices:textChoices];
        
        ORKChoiceAnswerFormatHelper *formatHelper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
       [self verifySelectedIndexesForAnswer:formatHelper choices:textChoices];
        
    }
    
    {
        NSArray *imageChoices = [self imageChoices];
        
        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithImageChoices:imageChoices];
        
        ORKChoiceAnswerFormatHelper *formatHelper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
        [self verifySelectedIndexesForAnswer:formatHelper choices:imageChoices];
        
    }
}

@end
