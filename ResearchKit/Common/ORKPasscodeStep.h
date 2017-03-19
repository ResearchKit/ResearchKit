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


@import Foundation;
#import <ResearchKit/ORKStep.h>


NS_ASSUME_NONNULL_BEGIN

/**
 An enumeration of values used in `ORKPasscodeStepViewController` to indicate the type of flow used
 by the view controller.
 */
typedef NS_ENUM(NSUInteger, ORKPasscodeFlow) {
    ORKPasscodeFlowCreate,
    ORKPasscodeFlowAuthenticate,
    ORKPasscodeFlowEdit
};

/**
 An `ORKPasscodeStep` object provides the participant a passcode creation step.
 
 It is recommended to use a passcode step as part of the consent process to ensure
 that the participant signing the consent is the same participant completing other 
 modules within that context.
 */
ORK_CLASS_AVAILABLE
@interface ORKPasscodeStep : ORKStep

/**
 Returns a new passcode step with the specified identifier and passcode flow.
 
 @param identifier    The identifier of the step (a step identifier should be unique within the task).
 @param passcodeFlow  The passcode flow to be used for the step.
 */
+ (instancetype)passcodeStepWithIdentifier:(NSString *)identifier
                              passcodeFlow:(ORKPasscodeFlow)passcodeFlow;

/**
 The passcode flow to be used for the step.
 
 The default value of this property is `ORKPasscodeFlowCreate`.
 */
@property (nonatomic) ORKPasscodeFlow passcodeFlow;

/**
 The passcode type to be used for the step.
 
 The default value of this property is `ORKPasscodeType4Digit`.
 */
@property (nonatomic) ORKPasscodeType passcodeType;

@end

NS_ASSUME_NONNULL_END
