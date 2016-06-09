/*
 Copyright (c) 2016, Sage Bionetworks
 
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

#import "ORKPageStep.h"
#import "ORKHelpers.h"
#import "ORKPageStepViewController.h"

@implementation ORKPageStep

- (instancetype)initWithIdentifier:(NSString *)identifier {
    return [self initWithIdentifier:identifier steps:@[]];
}

- (instancetype)initWithIdentifier:(NSString *)identifier steps:(NSArray<ORKStep *> *)steps {
    self = [super initWithIdentifier:identifier];
    if (self) {
        _steps = [steps copy] ?: @[];
        [self validateParameters];
    }
    return self;
}

#pragma mark - view controller instantiation

+ (Class)stepViewControllerClass {
    return [ORKPageStepViewController class];
}

#pragma mark - permissions

- (ORKPermissionMask)requestedPermissions {
    ORKPermissionMask permissions = 0;
    for (ORKStep *step in _steps) {
        permissions |= step.requestedPermissions;
    }
    return permissions;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKPageStep *copy = [super copyWithZone:zone];
    copy->_steps = ORKArrayCopyObjects(_steps);
    return copy;
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return ([super isEqual:object]
            && ORKEqualObjects(self.steps, castObject.steps));
}

- (NSUInteger)hash {
    return [super hash] ^ [_steps hash];
}

#pragma mark - step handling

- (void)validateParameters {
    NSArray *uniqueIdentifiers = [self.steps valueForKeyPath:@"@distinctUnionOfObjects.identifier"];
    BOOL itemsHaveNonUniqueIdentifiers = ( self.steps.count != uniqueIdentifiers.count );
    
    if (itemsHaveNonUniqueIdentifiers) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Each step should have a unique identifier" userInfo:nil];
    }
}

- (ORKStep *)stepAfterStepWithIdentifier:(NSString *)identifier withResult:(id <ORKTaskResultSource>)result {
    NSArray *steps = _steps;
    
    if (steps.count <= 0) {
        return nil;
    }
    
    if (identifier == nil) {
        return [steps firstObject];
    }
    
    NSUInteger index = [self indexOfStepWithIdentifier:identifier];
    if (NSNotFound != index && index != (steps.count - 1)) {
        return steps[index + 1];
    } else {
        return nil;
    }
}

- (ORKStep *)stepBeforeStepWithIdentifier:(NSString *)identifier withResult:(id <ORKTaskResultSource>)result {
    NSArray *steps = _steps;
    
    if (steps.count <= 0)  {
        return nil;
    }
    if (identifier == nil) {
        return [steps lastObject];
    }
    
    NSUInteger index = [self indexOfStepWithIdentifier:identifier];
    if (NSNotFound != index && index != 0) {
        return steps[index - 1];
    } else {
        return nil;
    }
}

- (NSUInteger)indexOfStepWithIdentifier:(NSString *)identifier {
    NSArray *identifiers = [_steps valueForKey:@"identifier"];
    return [identifiers indexOfObject:identifier];
}

- (ORKStep *)stepWithIdentifier:(NSString *)identifier {
    __block ORKStep *step = nil;
    [_steps enumerateObjectsUsingBlock:^(ORKStep *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:identifier]) {
            step = obj;
            *stop = YES;
        }
    }];
    return step;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, steps);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, steps, ORKStep);
    }
    return self;
}


@end
