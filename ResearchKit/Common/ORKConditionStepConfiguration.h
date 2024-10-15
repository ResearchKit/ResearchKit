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

#import <Foundation/Foundation.h>

#import <ResearchKit/ORKTypes.h>

@class ORKTaskResult;
@class ORKHealthCondition;
@class ORKFormItem;

NS_ASSUME_NONNULL_BEGIN

/**
 The base object for configuring the displayed health conditions
 for the family history step.
 */

ORK_CLASS_AVAILABLE
@interface ORKConditionStepConfiguration : NSObject <NSSecureCoding, NSCopying>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Creates a new conditions step configuration.
 
 This method is the primary designated initializer.
 
 @param stepIdentifier   The identifier attached to the form step that displays the health conditions.
 @param conditionsFormItemIdentifier   The identifier attached to the form item used from the health conditions list.
 @param conditions   List of health conditions displayed to participants.
 @param formItems   List of form items that are presented below the health conditions text choice. This is optional.
 */
- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier
          conditionsFormItemIdentifier:(NSString *)conditionsFormItemIdentifier
                            conditions:(NSArray<ORKHealthCondition *> *)conditions
                             formItems:(NSArray<ORKFormItem *> *)formItems NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, copy) NSString *stepIdentifier;
@property (nonatomic, readonly, copy) NSString *conditionsFormItemIdentifier;
@property (nonatomic, readonly, copy) NSArray<ORKHealthCondition *> *conditions;
@property (nonatomic, copy) NSArray<ORKFormItem *> *formItems;

@end

NS_ASSUME_NONNULL_END
