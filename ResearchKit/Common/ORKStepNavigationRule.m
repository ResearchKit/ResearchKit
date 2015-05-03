/*
 Copyright (c) 2015, Ricardo Sánchez-Sáez.
 
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


#import "ORKStepNavigationRule.h"
#import "ORKStepNavigationRule_Private.h"

#import "ORKHelpers.h"
#import "ORKResult.h"


@implementation ORKStepNavigationRule

- (instancetype)init_ork {
    return [super init];
}

- (NSString *)identifierForDestinationStepWithTaskResult:(ORKTaskResult *)taskResult {
    @throw [NSException exceptionWithName:NSGenericException reason:@"You should override this method in a subclass" userInfo:nil];
}

#pragma mark NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [super init];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    return YES;
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    typeof(self) rule = [[[self class] allocWithZone:zone] init];
    return rule;
}

@end


@interface ORKPredicateStepNavigationRule ()

@property (nonatomic, strong) NSArray *resultPredicates;
@property (nonatomic, strong) NSArray *matchingStepIdentifiers;
@property (nonatomic, copy) NSString *defaultStepIdentifier;

@end


@implementation ORKPredicateStepNavigationRule

- (instancetype)initWithResultPredicates:(NSArray *)resultPredicates
                 matchingStepIdentifiers:(NSArray *)matchingStepIdentifiers
                   defaultStepIdentifier:(NSString *)defaultStepIdentifier {
    self = [super init_ork];
    if (self) {
        self.resultPredicates = resultPredicates;
        self.matchingStepIdentifiers = matchingStepIdentifiers;
        self.defaultStepIdentifier = defaultStepIdentifier;
    }
    
    return self;
}

- (instancetype)initWithResultPredicates:(NSArray *)resultPredicates
                 matchingStepIdentifiers:(NSArray *)matchingStepIdentifiers {
    return [self initWithResultPredicates:resultPredicates
                  matchingStepIdentifiers:matchingStepIdentifiers
                    defaultStepIdentifier:nil];
}

- (NSString *)identifierForDestinationStepWithTaskResult:(ORKTaskResult *)ORKTaskResult {
    NSMutableArray *leafResults = [NSMutableArray new];
    for (ORKResult *result in ORKTaskResult.results) {
        if ([result isKindOfClass:[ORKCollectionResult class]]) {
            [leafResults addObjectsFromArray:[(ORKCollectionResult *)result results]];
        }
    }
    NSString *matchedPredicateIdentifier = nil;
    for (NSInteger i = 0; i < [_resultPredicates count]; i++) {
        NSPredicate *predicate = _resultPredicates[i];
        if ([predicate evaluateWithObject:leafResults]) {
            matchedPredicateIdentifier = _matchingStepIdentifiers[i];
            break;
        }
    }
    return matchedPredicateIdentifier ? : _defaultStepIdentifier;
}

#pragma mark NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, resultPredicates, NSPredicate);
        ORK_DECODE_OBJ_ARRAY(aDecoder, matchingStepIdentifiers, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, defaultStepIdentifier, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, resultPredicates);
    ORK_ENCODE_OBJ(aCoder, matchingStepIdentifiers);
    ORK_ENCODE_OBJ(aCoder, defaultStepIdentifier);
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    typeof(self) rule = [[[self class] allocWithZone:zone] init];
    rule->_resultPredicates = ORKArrayCopyObjects(_resultPredicates);
    rule->_matchingStepIdentifiers = ORKArrayCopyObjects(_matchingStepIdentifiers);
    rule ->_defaultStepIdentifier = [_defaultStepIdentifier copy];
    return rule;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    __typeof(self) castObject = object;
    return (isParentSame
            && ORKEqualObjects(self.resultPredicates, castObject.resultPredicates)
            && ORKEqualObjects(self.matchingStepIdentifiers, castObject.matchingStepIdentifiers)
            && ORKEqualObjects(self.defaultStepIdentifier, castObject.defaultStepIdentifier));
}

- (NSUInteger)hash {
    return [_resultPredicates hash] ^ [_matchingStepIdentifiers hash] ^ [_defaultStepIdentifier hash];
}

@end


@interface ORKDirectStepNavigationRule ()

@property (nonatomic, copy) NSString *destinationStepIdentifier;

@end


@implementation ORKDirectStepNavigationRule

- (instancetype)initWithDestinationStepIdentifier:(NSString *)destinationStepIdentifier {
    self = [super init_ork];
    if (self) {
        self.destinationStepIdentifier = destinationStepIdentifier;
    }
    
    return self;
}

- (NSString *)identifierForDestinationStepWithTaskResult:(ORKTaskResult *)ORKTaskResult {
    return self.destinationStepIdentifier;
}

#pragma mark NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, destinationStepIdentifier, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, destinationStepIdentifier);
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    typeof(self) rule = [[[self class] allocWithZone:zone] init];
    rule->_destinationStepIdentifier = [_destinationStepIdentifier copy];
    return rule;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    __typeof(self) castObject = object;
    return (isParentSame
            && ORKEqualObjects(self.destinationStepIdentifier, castObject.destinationStepIdentifier));
}

- (NSUInteger)hash {
    return [_destinationStepIdentifier hash];
}

@end
