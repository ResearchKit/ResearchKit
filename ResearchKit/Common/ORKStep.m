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


#import "ORKStep.h"
#import "ORKHelpers.h"
#import "ORKStep_Private.h"
#import "ORKStepViewController.h"
#import "ORKOrderedTask.h"


@implementation ORKStep

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        ORKThrowInvalidArgumentExceptionIfNil(identifier);
        _identifier = [identifier copy];
    }
    return self;
}

+ (Class)stepViewControllerClass {
    return [ORKStepViewController class];
}

- (Class)stepViewControllerClass {
    return [[self class] stepViewControllerClass];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKStep *step = [[[self class] allocWithZone:zone] initWithIdentifier:[_identifier copy]];
    step.title = _title;
    step.optional = _optional;
    step.text = _text;
    step.shouldTintImages = _shouldTintImages;
    step.useSurveyMode = _useSurveyMode;
    return step;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    // Ignore the task reference - it's not part of the content of the step.
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.identifier, castObject.identifier)
            && ORKEqualObjects(self.title, castObject.title)
            && ORKEqualObjects(self.text, castObject.text)
            && (self.optional == castObject.optional)
            && (self.shouldTintImages == castObject.shouldTintImages)
            && (self.useSurveyMode == castObject.useSurveyMode));
}

- (NSUInteger)hash {
    // Ignore the task reference - it's not part of the content of the step.
    return [_identifier hash] ^ [_title hash] ^ [_text hash] ^ (_optional ? 0xf : 0x0);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, identifier, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, title, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, text, NSString);
        ORK_DECODE_BOOL(aDecoder, optional);
        ORK_DECODE_OBJ_CLASS(aDecoder, task, ORKOrderedTask);
        ORK_DECODE_BOOL(aDecoder, shouldTintImages);
        ORK_DECODE_BOOL(aDecoder, useSurveyMode);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, identifier);
    ORK_ENCODE_OBJ(aCoder, title);
    ORK_ENCODE_OBJ(aCoder, text);
    ORK_ENCODE_BOOL(aCoder, optional);
    ORK_ENCODE_BOOL(aCoder, shouldTintImages);
    ORK_ENCODE_BOOL(aCoder, useSurveyMode);
    if ([_task isKindOfClass:[ORKOrderedTask class]]) {
        ORK_ENCODE_OBJ(aCoder, task);
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@ %@>", super.description, self.identifier, self.title];
}

- (BOOL)showsProgress {
    return YES;
}

- (BOOL)allowsBackNavigation {
    return YES;
}

- (BOOL)isRestorable {
    return YES;
}

- (void)validateParameters {
    
}

- (ORKPermissionMask)requestedPermissions {
    return ORKPermissionNone;
}

@end
