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

#import "ORKRelativeGroup.h"

#import "ORKAnswerFormat_Private.h"
#import "ORKCollectionResult.h"
#import "ORKFormStep.h"
#import "ORKHelpers_Internal.h"


@implementation ORKRelativeGroup

- (instancetype)initWithIdentifier:(NSString *)identifier
                              name:(NSString *)name
                      sectionTitle:(NSString *)title
                 sectionDetailText:(NSString *)detailText
            identifierForCellTitle:(NSString *)identifierForCellTitle
                        maxAllowed:(NSUInteger)maxAllowed
                         formSteps:(NSArray<ORKFormStep *> *)formSteps
             detailTextIdentifiers:(NSArray<NSString *> *)detailTextIdentifiers {
    self = [super init];
    
    if (self) {
        _identifier = identifier;
        _name = name;
        _sectionTitle = title;
        _sectionDetailText = detailText;
        _identifierForCellTitle = identifierForCellTitle;
        _maxAllowed = maxAllowed;
        _formSteps = formSteps;
        _detailTextIdentifiers = detailTextIdentifiers;
    }
    
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, identifier);
    ORK_ENCODE_OBJ(aCoder, name);
    ORK_ENCODE_OBJ(aCoder, sectionTitle);
    ORK_ENCODE_OBJ(aCoder, sectionDetailText);
    ORK_ENCODE_OBJ(aCoder, identifierForCellTitle);
    ORK_ENCODE_INTEGER(aCoder, maxAllowed);
    ORK_ENCODE_OBJ(aCoder, formSteps);
    ORK_ENCODE_OBJ(aCoder, detailTextIdentifiers);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, identifier, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, name, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, sectionTitle, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, sectionDetailText, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, identifierForCellTitle, NSString);
        ORK_DECODE_INTEGER(aDecoder, maxAllowed);
        ORK_DECODE_OBJ_ARRAY(aDecoder, formSteps, ORKFormStep);
        ORK_DECODE_OBJ_ARRAY(aDecoder, detailTextIdentifiers, NSString);
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    ORKRelativeGroup *relativeGroup = [[[self class] allocWithZone:zone] initWithIdentifier:[_identifier copy]
                                                                                       name:[_name copy]
                                                                               sectionTitle:[_sectionTitle copy]
                                                                          sectionDetailText:[_sectionDetailText copy]
                                                                     identifierForCellTitle:[_identifierForCellTitle copy]
                                                                                 maxAllowed:_maxAllowed
                                                                                  formSteps:[_formSteps copy]
                                                                      detailTextIdentifiers:[_detailTextIdentifiers copy]];
    return relativeGroup;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.identifier, castObject.identifier)
            && ORKEqualObjects(self.name, castObject.name)
            && ORKEqualObjects(self.sectionTitle, castObject.sectionTitle)
            && ORKEqualObjects(self.sectionDetailText, castObject.sectionDetailText)
            && ORKEqualObjects(self.identifierForCellTitle, castObject.identifierForCellTitle)
            && ORKEqualObjects(self.formSteps, castObject.formSteps)
            && ORKEqualObjects(self.detailTextIdentifiers, castObject.detailTextIdentifiers)
            && self.maxAllowed == castObject.maxAllowed);
}

- (NSUInteger)hash {
    return super.hash ^ _identifier.hash ^ _name.hash ^ _sectionTitle.hash ^ _sectionDetailText.hash ^ _identifierForCellTitle.hash ^ _formSteps.hash ^ _detailTextIdentifiers.hash;
}

@end
