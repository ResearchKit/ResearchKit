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


#import "ORKBodyItem.h"
#import "ORKLearnMoreInstructionStep.h"
#import "ORKHelpers_Internal.h"

@implementation ORKBodyItem

- (instancetype)initWithText:(NSString *)text detailText:(NSString *)detailText image:(nullable UIImage *)image learnMoreItem:(nullable ORKLearnMoreItem *)learnMoreItem bodyItemStyle:(ORKBodyItemStyle)bodyItemStyle {
    return [self initWithText:text detailText:detailText image:image learnMoreItem:learnMoreItem bodyItemStyle:bodyItemStyle useCardStyle:NO];
}

- (instancetype)initWithText:(NSString *)text detailText:(NSString *)detailText image:(nullable UIImage *)image learnMoreItem:(nullable ORKLearnMoreItem *)learnMoreItem bodyItemStyle:(ORKBodyItemStyle)bodyItemStyle useCardStyle:(BOOL)useCardStyle {
    self = [super init];
    if (self) {
        self.text = text;
        self.detailText = detailText;
        self.learnMoreItem = learnMoreItem;
        self.bodyItemStyle = bodyItemStyle;
        self.image = image;
        self.useCardStyle = useCardStyle;
        self.useSecondaryColor = NO;
    }
    [self validateParameters];
    return self;
}

- (instancetype)initWithHorizontalRule {
    return [self initWithText:nil
                   detailText:nil
                        image:nil
                learnMoreItem:nil
                bodyItemStyle:ORKBodyItemStyleHorizontalRule
                 useCardStyle:NO];
}

- (void)validateParameters {
    if (_bodyItemStyle != ORKBodyItemStyleHorizontalRule && !_text && !_detailText && !_learnMoreItem) {
        NSAssert(NO, @"Parameters text, detailText and learnMoreItem cannot be nil at the same time.");
    }
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, text, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, detailText, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, learnMoreItem, ORKLearnMoreItem);
        ORK_DECODE_INTEGER(aDecoder, bodyItemStyle);
        ORK_DECODE_IMAGE(aDecoder, image);
        ORK_DECODE_BOOL(aDecoder, useCardStyle);
        ORK_DECODE_BOOL(aDecoder, useSecondaryColor);
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, text);
    ORK_ENCODE_OBJ(aCoder, detailText);
    ORK_ENCODE_OBJ(aCoder, learnMoreItem);
    ORK_ENCODE_INTEGER(aCoder, bodyItemStyle);
    ORK_ENCODE_IMAGE(aCoder, image);
    ORK_ENCODE_BOOL(aCoder, useCardStyle);
    ORK_ENCODE_BOOL(aCoder, useSecondaryColor);
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    ORKBodyItem *bodyItem = [[[self class] allocWithZone:zone] init];
    bodyItem->_text = [self.text copy];
    bodyItem->_detailText = [self.detailText copy];
    bodyItem->_learnMoreItem = [self.learnMoreItem copy];
    bodyItem->_bodyItemStyle = self.bodyItemStyle;
    bodyItem->_image = [self.image copy];
    bodyItem->_useCardStyle = self.useCardStyle;
    bodyItem->_useSecondaryColor = self.useSecondaryColor;
    return bodyItem;
}

- (NSUInteger)hash {
    return _text.hash ^ _detailText.hash ^ _learnMoreItem.hash ^ _image.hash;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }

    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.text, castObject.text)
            && ORKEqualObjects(self.detailText, castObject.detailText)
            && ORKEqualObjects(self.learnMoreItem, castObject.learnMoreItem)
            && (self.bodyItemStyle == castObject.bodyItemStyle)
            && ORKEqualObjects(self.image, castObject.image)
            && (self.useCardStyle == castObject.useCardStyle)
            && (self.useSecondaryColor == castObject.useSecondaryColor));
}

@end
