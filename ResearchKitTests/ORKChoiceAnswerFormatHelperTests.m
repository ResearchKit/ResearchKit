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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ORKChoiceAnswerFormatHelper.h"
#import "ORKAnswerFormat_internal.h"

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
        ORKAnswerFormat *af = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                         textChoices:[self textChoices]];
        
        
        ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:af];
        
        XCTAssertEqual(helper.choiceCount, [self textChoices].count, @"");
    }
    
    {
        ORKAnswerFormat *af = [ORKAnswerFormat choiceAnswerFormatWithImageChoices:[self imageChoices]];
        
        
        ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:af];
        
        XCTAssertEqual(helper.choiceCount, [self imageChoices].count, @"");
    }
    
    {
        ORKAnswerFormat *af = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:[self textChoices]];
        
        
        ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:af];
        
        XCTAssertEqual(helper.choiceCount, [self textChoices].count+1, @"");
    }
}

- (void)testTextChoice {
    
    {
        NSArray *textChoices = [self textChoices];
        
        ORKAnswerFormat *af = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                               textChoices:textChoices];
        
        
        ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:af];
        
        [textChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ORKTextChoice * tc = obj;
            ORKTextChoice * tc2 = [helper textChoiceAtIndex:idx];
            XCTAssertEqual(tc, tc2, @"");
            XCTAssertNil([helper imageChoiceAtIndex:idx],@"");
        }];
    }
    
    {
        NSArray *textChoices = [self textChoices];
        
        ORKAnswerFormat *af = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices];
        
        
        ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:af];
        
        [textChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ORKTextChoice * tc = obj;
            ORKTextChoice * tc2 = [helper textChoiceAtIndex:idx+1];
            XCTAssertEqual(tc, tc2, @"");
            XCTAssertNil([helper imageChoiceAtIndex:idx],@"");
        }];
    }
}

- (void)testImageChoice {
    
    {
        NSArray *imageChoices = [self imageChoices];
        
        ORKAnswerFormat *af = [ORKAnswerFormat choiceAnswerFormatWithImageChoices:imageChoices];
        
        
        ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:af];
        
        [imageChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ORKImageChoice * tc = obj;
            ORKImageChoice * tc2 = [helper imageChoiceAtIndex:idx];
            XCTAssertEqual(tc, tc2, @"");
            XCTAssertNil([helper textChoiceAtIndex:idx],@"");
        }];
    }

}

- (void)verifyAnswerForSelectedIndexes:(ORKChoiceAnswerFormatHelper *)helper choices:(NSArray *)choices {
    NSMutableArray *indexArray = [NSMutableArray new];
    
    [choices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        id answer = [helper answerForSelectedIndex:idx];
        
        id value = [(ORKTextChoice *)choices[idx] value];
        
        if (value == nil) {
            value = @(idx);
        }
        
        XCTAssert([answer count] == 1 && [[answer firstObject] isEqual:value], @"%@", answer);
        
        answer = [helper answerForSelectedIndexes:@[@(idx)]];
        
        XCTAssert([answer count] == 1 && [[answer firstObject] isEqual:value], @"%@", answer);
        
        [indexArray addObject:@(idx)];
        
        answer = [helper answerForSelectedIndexes:indexArray];
        
        XCTAssertEqual([answer count], idx + 1, @"%@", answer);
        
    }];
}

- (void)testAnswerForSelectedIndexes {

    {
        NSArray *textChoices = [self textChoices];
        
        ORKAnswerFormat *af = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices];
        
        ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:af];
        
        id answer = [helper answerForSelectedIndexes:@[@(0)]];
        
        XCTAssert([answer isKindOfClass:[NSArray class]] && [answer count] == 0, @"%@", answer);
        
        answer = [helper answerForSelectedIndex:0];
        
        XCTAssert([answer isKindOfClass:[NSArray class]] && [answer count] == 0, @"%@", answer);
        
        [textChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            id answer = [helper answerForSelectedIndex:idx+1];
            
            id value = [(ORKTextChoice *)textChoices[idx] value];
            
            if (value == nil) {
                value = @(idx);
            }
            
            XCTAssert([answer count] == 1 && [[answer firstObject] isEqual:value], @"%@", answer);
            
            answer = [helper answerForSelectedIndexes:@[@(idx+1)]];
            
            XCTAssert([answer count] == 1 && [[answer firstObject] isEqual:value], @"%@", answer);
        }];
        
    }
    
    {
        NSArray *textChoices = [self textChoices];
        
        ORKAnswerFormat *af = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                               textChoices:textChoices];
        
        ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:af];
        
       
        [self verifyAnswerForSelectedIndexes:helper choices:textChoices];
    }
    
    {
        NSArray *imageChoices = [self imageChoices];
        
        ORKAnswerFormat *af = [ORKAnswerFormat choiceAnswerFormatWithImageChoices:imageChoices];
        
        ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:af];
        
        [self verifyAnswerForSelectedIndexes:helper choices:imageChoices];
    }

}

- (void)verifySelectedIndexesForAnswer:(ORKChoiceAnswerFormatHelper *)helper choices:(NSArray *)choices {
    
    NSArray *indexes = [helper selectedIndexesForAnswer:nil];
    
    XCTAssertEqual(indexes.count, 0, @"%@", indexes);
    
    indexes = [helper selectedIndexesForAnswer:ORKNullAnswerValue()];
    
    XCTAssertEqual(indexes.count, 0, @"%@", indexes);
    
    NSNumber *indexNumber = [helper selectedIndexForAnswer:nil];
    
    XCTAssertNil(indexNumber, @"%@", indexNumber);
    
    indexNumber = [helper selectedIndexForAnswer:ORKNullAnswerValue()];
    
    XCTAssertNil(indexNumber, @"%@", indexNumber);
    
    [choices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        id value = [(ORKTextChoice *)obj value];
        
        if (value == nil) {
            value = @(idx);
        }
        
        NSNumber *indexNumber = [helper selectedIndexForAnswer:@[value]];
        
        XCTAssertEqualObjects(indexNumber, @(idx), @"%@ vs %@", indexNumber, @(idx));
        
        NSArray *indexArray = [helper selectedIndexesForAnswer:@[value]];
        
        XCTAssertEqualObjects( [indexArray firstObject], @(idx), @"%@ vs %@", indexArray[0], @(idx));
        
    }];
}

- (void)testSelectedIndexesForAnswer {
    
    {
        NSArray *textChoices = [self textChoices];
        
        ORKAnswerFormat *af = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices];
        
        ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:af];
        
        NSArray *indexes = [helper selectedIndexesForAnswer:nil];
        
        XCTAssertEqualObjects([indexes firstObject], @(0), @"%@", indexes);
        
        indexes = [helper selectedIndexesForAnswer:ORKNullAnswerValue()];
        
        XCTAssertEqualObjects([indexes firstObject], @(0), @"%@", indexes);
        
        NSNumber *indexNumber = [helper selectedIndexForAnswer:nil];
        
        XCTAssert([indexNumber isKindOfClass:[NSNumber class]] && [indexNumber unsignedIntegerValue] == 0, @"%@", indexNumber);
        
        indexNumber = [helper selectedIndexForAnswer:ORKNullAnswerValue()];
        
        XCTAssert([indexNumber isKindOfClass:[NSNumber class]] && [indexNumber unsignedIntegerValue] == 0, @"%@", indexNumber);
        
        [textChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            id value = [(ORKTextChoice *)obj value];
            
            if (value == nil) {
                value = @(idx);
            }
            
            NSNumber *indexNumber = [helper selectedIndexForAnswer:@[value]];
            
            XCTAssertEqualObjects(indexNumber, @(idx+1), @"%@ vs %@", indexNumber, @(idx+1));
            
            NSArray *indexArray = [helper selectedIndexesForAnswer:@[value]];
            
            XCTAssertEqualObjects([indexArray firstObject], @(idx+1), @"%@ vs %@", indexArray[0], @(idx+1));
            
        }];
        
    }
    
    {
        NSArray *textChoices = [self textChoices];
        
        ORKAnswerFormat *af = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                               textChoices:textChoices];
        
        ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:af];
        
       [self verifySelectedIndexesForAnswer:helper choices:textChoices];
        
    }
    
    {
        NSArray *imageChoices = [self imageChoices];
        
        ORKAnswerFormat *af = [ORKAnswerFormat choiceAnswerFormatWithImageChoices:imageChoices];
        
        ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:af];
        
        [self verifySelectedIndexesForAnswer:helper choices:imageChoices];
        
    }
    
}


@end
