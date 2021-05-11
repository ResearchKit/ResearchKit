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
#import "ORKStep_Private.h"

#import "ORKStepViewController.h"

#import "ORKOrderedTask.h"
#import "ORKStepViewController_Internal.h"
#import "ORKBodyItem.h"

#import "ORKHelpers_Internal.h"


@implementation ORKStep

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        ORKThrowInvalidArgumentExceptionIfNil(identifier);
        _identifier = [identifier copy];
        self.showsProgress = YES;
    }
    return self;
}

+ (Class)stepViewControllerClass {
    return [ORKStepViewController class];
}

- (Class)stepViewControllerClass {
    return [[self class] stepViewControllerClass];
}

- (ORKStepViewController *)instantiateStepViewControllerWithResult:(ORKResult *)result {
    Class stepViewControllerClass = [self stepViewControllerClass];
    
    ORKStepViewController *stepViewController = [[stepViewControllerClass alloc] initWithStep:self result:result];
    
    // Set the restoration info using the given class
    stepViewController.restorationIdentifier = self.identifier;
    stepViewController.restorationClass = stepViewControllerClass;
    
    return stepViewController;
}

- (instancetype)copyWithIdentifier:(NSString *)identifier {
    ORKThrowInvalidArgumentExceptionIfNil(identifier)
    ORKStep *step = [self copy];
    step->_identifier = [identifier copy];
    return step;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKStep *step = [[[self class] allocWithZone:zone] initWithIdentifier:[_identifier copy]];
    step.title = _title;
    step.optional = _optional;
    step.text = _text;
    step.detailText = self.detailText;
    step.headerTextAlignment = _headerTextAlignment;
    step.bodyItemTextAlignment = _bodyItemTextAlignment;
    step.buildInBodyItems = _buildInBodyItems;
    step.footnote = self.footnote;
    step.image = self.image;
    step.imageContentMode = self.imageContentMode;
    step.auxiliaryImage = self.auxiliaryImage;
    step.iconImage = self.iconImage;
    step.bodyItems = [_bodyItems copy];
    step.showsProgress = _showsProgress;
    step.shouldTintImages = _shouldTintImages;
    step.useSurveyMode = _useSurveyMode;
    step.useExtendedPadding = _useExtendedPadding;
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
            && ORKEqualObjects(self.detailText, castObject.detailText)
            && (self.headerTextAlignment == castObject.headerTextAlignment)
            && (self.bodyItemTextAlignment == castObject.bodyItemTextAlignment)
            && (self.buildInBodyItems == castObject.buildInBodyItems)
            && ORKEqualObjects(self.footnote, castObject.footnote)
            && ORKEqualObjects(self.image, castObject.image)
            && ORKEqualObjects(self.auxiliaryImage, castObject.auxiliaryImage)
            && ORKEqualObjects(self.iconImage, castObject.iconImage)
            && ORKEqualObjects(self.bodyItems, castObject.bodyItems)
            && (self.imageContentMode == castObject.imageContentMode)
            && (self.showsProgress == castObject.showsProgress)
            && (self.optional == castObject.optional)
            && (self.shouldTintImages == castObject.shouldTintImages)
            && (self.useSurveyMode == castObject.useSurveyMode)
            && (self.useExtendedPadding == castObject.useExtendedPadding));
}

- (NSUInteger)hash {
    // Ignore the task reference - it's not part of the content of the step.
    return _identifier.hash ^ _title.hash ^ _text.hash ^ self.detailText.hash ^_headerTextAlignment ^ _bodyItemTextAlignment ^ (_buildInBodyItems ? 0xf : 0x0) ^ _imageContentMode ^ self.footnote.hash ^ (_optional ? 0xf : 0x0) ^ _bodyItems.hash ^ (_showsProgress ? 0xf : 0x0) ^ (_useExtendedPadding ? 0xf : 0x0);
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
        ORK_DECODE_OBJ_CLASS(aDecoder, detailText, NSString);
        ORK_DECODE_ENUM(aDecoder, headerTextAlignment);
        ORK_DECODE_ENUM(aDecoder, bodyItemTextAlignment);
        ORK_DECODE_OBJ_CLASS(aDecoder, footnote, NSString);
        ORK_DECODE_IMAGE(aDecoder, image);
        ORK_DECODE_ENUM(aDecoder, imageContentMode);
        ORK_DECODE_IMAGE(aDecoder, auxiliaryImage);
        ORK_DECODE_IMAGE(aDecoder, iconImage);
        ORK_DECODE_OBJ_ARRAY(aDecoder, bodyItems, ORKBodyItem);
        ORK_DECODE_BOOL(aDecoder, showsProgress);
        ORK_DECODE_BOOL(aDecoder, optional);
        ORK_DECODE_OBJ_CLASS(aDecoder, task, ORKOrderedTask);
        ORK_DECODE_BOOL(aDecoder, shouldTintImages);
        ORK_DECODE_BOOL(aDecoder, useSurveyMode);
        ORK_DECODE_BOOL(aDecoder, buildInBodyItems);
        ORK_DECODE_BOOL(aDecoder, useExtendedPadding);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, identifier);
    ORK_ENCODE_OBJ(aCoder, title);
    ORK_ENCODE_OBJ(aCoder, text);
    ORK_ENCODE_OBJ(aCoder, detailText);
    ORK_ENCODE_ENUM(aCoder, headerTextAlignment);
    ORK_ENCODE_ENUM(aCoder, bodyItemTextAlignment);
    ORK_ENCODE_OBJ(aCoder, footnote);
    ORK_ENCODE_IMAGE(aCoder, image);
    ORK_ENCODE_ENUM(aCoder, imageContentMode);
    ORK_ENCODE_IMAGE(aCoder, auxiliaryImage);
    ORK_ENCODE_IMAGE(aCoder, iconImage);
    ORK_ENCODE_OBJ(aCoder, bodyItems);
    ORK_ENCODE_BOOL(aCoder, showsProgress);
    ORK_ENCODE_BOOL(aCoder, optional);
    ORK_ENCODE_BOOL(aCoder, shouldTintImages);
    ORK_ENCODE_BOOL(aCoder, useSurveyMode);
    ORK_ENCODE_BOOL(aCoder, buildInBodyItems);
    ORK_ENCODE_BOOL(aCoder, useExtendedPadding);
    if ([_task isKindOfClass:[ORKOrderedTask class]]) {
        ORK_ENCODE_OBJ(aCoder, task);
    }
}

- (void)setAuxiliaryImage:(UIImage *)auxiliaryImage {
    _auxiliaryImage = auxiliaryImage;
    if (auxiliaryImage) {
        self.shouldTintImages = YES;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@ %@>", super.description, self.identifier, self.title];
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

#if HEALTH
- (NSSet<HKObjectType *> *)requestedHealthKitTypesForReading {
    return nil;
}
#endif

@end
