/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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

#import "ORKSecondaryTaskStep.h"
#import "ORKSecondaryTaskStepViewController.h"
#import "ORKHelpers_Internal.h"

@implementation ORKSecondaryTaskStep


+ (Class)stepViewControllerClass {
    return [ORKSecondaryTaskStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {

    self = [super initWithIdentifier:identifier];
    if (self) {
        self.requiredAttempts = 1;
        self.optional = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, secondaryTask, ORKOrderedTask);
        ORK_DECODE_OBJ_CLASS(aDecoder, secondaryTaskButtonTitle, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, nextButtonTitle, NSString);
        ORK_DECODE_INTEGER(aDecoder, requiredAttempts);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, secondaryTask);
    ORK_ENCODE_OBJ(aCoder, secondaryTaskButtonTitle);
    ORK_ENCODE_OBJ(aCoder, nextButtonTitle);
    ORK_ENCODE_INTEGER(aCoder, requiredAttempts);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKSecondaryTaskStep *step = [super copyWithZone:zone];
    step->_secondaryTask = [_secondaryTask copy];
    step->_secondaryTaskButtonTitle = [_secondaryTaskButtonTitle copy];
    step->_nextButtonTitle = [_nextButtonTitle copy];
    step->_requiredAttempts = _requiredAttempts;
    return step;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];

    __typeof(self) castObject = object;
    return (isParentSame
            && ORKEqualObjects(self.secondaryTask, castObject.secondaryTask)
            && ORKEqualObjects(self.secondaryTaskButtonTitle, castObject.secondaryTaskButtonTitle)
            && ORKEqualObjects(self.nextButtonTitle, castObject.nextButtonTitle)
            && self.requiredAttempts == castObject.requiredAttempts);
}

- (NSUInteger)hash {
    return super.hash ^ self.secondaryTask.hash ^ self.secondaryTaskButtonTitle.hash ^ self.nextButtonTitle.hash ^ self.requiredAttempts;
}

@end
