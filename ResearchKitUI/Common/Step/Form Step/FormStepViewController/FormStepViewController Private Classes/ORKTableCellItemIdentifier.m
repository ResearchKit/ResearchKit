/*
 Copyright (c) 2025, Apple Inc. All rights reserved.
 
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

#import "ORKTableCellItemIdentifier.h"

#import "ORKHelpers_Internal.h"

@implementation ORKTableCellItemIdentifier {
    BOOL _isDontKnow;
}

- (instancetype)initWithFormItemIdentifier:(NSString *)formItemIdentifier choiceIndex:(NSInteger)index {
    self = [super init];
    if (self != nil) {
        _formItemIdentifier = [formItemIdentifier copy];
        _choiceIndex = index;
        _isDontKnow = NO;
    }
    return self;
}

+ (instancetype)dontKnowIdentifierWithFormItemIdentifier:(NSString *)formItemIdentifier {
    ORKTableCellItemIdentifier *item = [[self alloc] initWithFormItemIdentifier:formItemIdentifier choiceIndex:NSNotFound];
    item->_isDontKnow = YES;
    return item;
}

- (BOOL)isDontKnow {
    return _isDontKnow;
}

- (NSUInteger)hash {
    return _formItemIdentifier.hash ^ (NSUInteger)_choiceIndex ^ (_isDontKnow ? 0x80000000UL : 0UL);
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }

    __typeof(self) castObject = object;
    return (ORKEqualObjects(_formItemIdentifier, castObject->_formItemIdentifier)
            && (_choiceIndex == castObject->_choiceIndex)
            && (_isDontKnow == castObject->_isDontKnow));
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    __typeof(self) copy = [[[self class] alloc] init];
    copy->_formItemIdentifier = [_formItemIdentifier copy];
    copy->_choiceIndex = _choiceIndex;
    copy->_isDontKnow = _isDontKnow;
    return copy;
}

- (NSString *)description {
    if (_isDontKnow) {
        return [NSString stringWithFormat:@"[%@ '%@', DontKnow]", [super description], _formItemIdentifier];
    }
    NSString *indexString = (_choiceIndex == NSNotFound) ? @"NSNotFound" : @(_choiceIndex).stringValue;
    return [NSString stringWithFormat:@"[%@ '%@', index: %@]", [super description], _formItemIdentifier, indexString];
}

@end
