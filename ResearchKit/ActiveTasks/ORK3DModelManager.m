/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import "ORK3DModelManager.h"
#import "ORK3DModelManager_Internal.h"
#import "ORKHelpers_Internal.h"

NSNotificationName const ORK3DModelEnableContinueButtonNotification = @"ORK3DModelEnableContinueButtonNotification";
NSNotificationName const ORK3DModelDisableContinueButtonNotification = @"ORK3DModelDisableContinueButtonNotification";
NSNotificationName const ORK3DModelEndStepNotification = @"ORK3DModelEndStepNotification";

@implementation ORK3DModelManager

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _allowsSelection = YES;
        _highlightColor = [UIColor yellowColor];
        _identifiersOfObjectsToHighlight = nil;
    }
    
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORK3DModelManager *modelManager = [[[self class] allocWithZone:zone] init];
    modelManager->_allowsSelection = self.allowsSelection;
    modelManager->_highlightColor = [_highlightColor copy];
    modelManager->_identifiersOfObjectsToHighlight = [self.identifiersOfObjectsToHighlight copy];
    return  modelManager;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self ) {
        ORK_DECODE_BOOL(aDecoder, allowsSelection);
        ORK_DECODE_OBJ_ARRAY(aDecoder, identifiersOfObjectsToHighlight, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, highlightColor, UIColor);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_BOOL(aCoder, allowsSelection);
    ORK_ENCODE_OBJ(aCoder, identifiersOfObjectsToHighlight);
    ORK_ENCODE_OBJ(aCoder, highlightColor);
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    __typeof(self) castObject = object;
    return ((self.allowsSelection == castObject.allowsSelection) &&
            (ORKEqualObjects(self.highlightColor, castObject.highlightColor)) &&
            (ORKEqualObjects(self.identifiersOfObjectsToHighlight, castObject.identifiersOfObjectsToHighlight)));
}

- (NSUInteger)hash
{
    return [_identifiersOfObjectsToHighlight hash] ^ (_allowsSelection ? 0xf : 0x0) ^ [_highlightColor hash];
}

#pragma mark - Instance Methods

- (void)setContinueEnabled:(BOOL)enabled {
    if (enabled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ORK3DModelEnableContinueButtonNotification object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:ORK3DModelDisableContinueButtonNotification object:self];
    }
}

- (void)endStep {
    [[NSNotificationCenter defaultCenter] postNotificationName:ORK3DModelEndStepNotification object:self];
}

#pragma mark - ORK3DModelManagerProtocol

- (void)addContentToView:(UIView *)view {
    [NSException raise:@"addContentToView not overwitten" format:@"Subclasses must overwrite the addContentToView function"];
}

- (void)stepWillEnd {
    [NSException raise:@"stepWillEnd not overwitten" format:@"Subclasses must overwrite the stepWillEnd function"];
}

- (NSArray<ORKResult *> *)provideResults {
    [NSException raise:@"provideResults not overwitten" format:@"Subclasses must overwrite the provideResults function"];
       return nil;
}

@end
