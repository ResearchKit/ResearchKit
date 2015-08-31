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


#import "ORKPasscodeStep.h"
#import "ORKPasscodeStepViewController.h"
#import "ORKHelpers.h"


@implementation ORKPasscodeStep

+ (Class)stepViewControllerClass {
    return [ORKPasscodeStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                      passcodeFlow:(ORKPasscodeFlow)passcodeFlow
                              text:(NSString *)text {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.passcodeFlow = passcodeFlow;
        self.text = text;
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                      passcodeFlow:(ORKPasscodeFlow)passcodeFlow {
    return [self initWithIdentifier:identifier
                       passcodeFlow:passcodeFlow
                               text:nil];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    ORKThrowMethodUnavailableException();
    return nil;
}

- (BOOL)showsProgress {
    return NO;
}

- (void)validateParameters {
    [super validateParameters];
    
    if (self.passcodeFlow == ORKPasscodeFlowCreate && self.userPasscode) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Passcode step with ORKPasscodeFlowCreate cannot have the property userPasscode set." userInfo:nil];
    } else if (self.passcodeFlow == ORKPasscodeFlowEdit && !self.userPasscode) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Passcode step with ORKPasscodeFlowEdit requires the property userPasscode to be set" userInfo:nil];
    } else if (self.passcodeFlow == ORKPasscodeFlowAuthenticate && !self.userPasscode) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Passcode step with ORKPasscodeFlowAuthenticate requires the property userPasscode to be set" userInfo:nil];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKPasscodeStep *step = [super copyWithZone:zone];
    step.passcodeFlow = self.passcodeFlow;
    return step;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return isParentSame && (self.passcodeFlow == castObject.passcodeFlow);
}

- (NSUInteger)hash {
    return [super hash];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, passcodeFlow);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, passcodeFlow);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
