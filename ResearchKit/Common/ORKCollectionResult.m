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

#import "ORKCollectionResult.h"

#import "ORKCollectionResult_Private.h"
#import "ORKPageStep.h"
#import "ORKQuestionResult_Private.h"
#import "ORKResult_Private.h"
#import "ORKStep.h"
#import "ORKTask.h"

#import "ORKHelpers_Internal.h"

@interface ORKCollectionResult ()

- (void)setResultsCopyObjects:(NSArray *)results;

@end


@implementation ORKCollectionResult

- (BOOL)isSaveable {
    BOOL saveable = NO;
    
    for (ORKResult *result in _results) {
        if ([result isSaveable]) {
            saveable = YES;
            break;
        }
    }
    return saveable;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, results);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, results, ORKResult);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.results, castObject.results));
}

- (NSUInteger)hash {
    return super.hash ^ self.results.hash;
}

- (void)setResultsCopyObjects:(NSArray *)results {
    _results = ORKArrayCopyObjects(results);
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKCollectionResult *result = [super copyWithZone:zone];
    [result setResultsCopyObjects: self.results];
    return result;
}

- (NSArray *)results {
    if (_results == nil) {
        _results = [NSArray new];
    }
    return _results;
}

- (ORKResult *)resultForIdentifier:(NSString *)identifier {
    
    if (identifier == nil) {
        return nil;
    }
    
    __block ORKQuestionResult *result = nil;
    
    // Look through the result set in reverse-order to account for the possibility of
    // multiple results with the same identifier (due to a navigation loop)
    NSEnumerator *enumerator = self.results.reverseObjectEnumerator;
    id obj = enumerator.nextObject;
    while ((result== nil) && (obj != nil)) {
        
        if (NO == [obj isKindOfClass:[ORKResult class]]) {
            @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat: @"Expected result object to be ORKResult type: %@", obj] userInfo:nil];
        }
        
        NSString *anIdentifier = [(ORKResult *)obj identifier];
        if ([anIdentifier isEqual:identifier]) {
            result = obj;
        }
        obj = enumerator.nextObject;
    }
    
    return result;
}

- (ORKResult *)firstResult {
    
    return self.results.firstObject;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    NSMutableString *description = [NSMutableString stringWithFormat:@"%@; results: (", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces]];
    
    NSUInteger numberOfResults = self.results.count;
    [self.results enumerateObjectsUsingBlock:^(ORKResult *result, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [description appendString:@"\n"];
        }
        [description appendFormat:@"%@", [result descriptionWithNumberOfPaddingSpaces:numberOfPaddingSpaces + NumberOfPaddingSpacesForIndentationLevel]];
        if (idx != numberOfResults - 1) {
            [description appendString:@",\n"];
        } else {
            [description appendString:@"\n"];
        }
    }];
    
    [description appendFormat:@"%@)%@", ORKPaddingWithNumberOfSpaces((numberOfResults == 0) ? 0 : numberOfPaddingSpaces), self.descriptionSuffix];
    return [description copy];
}

@end


#pragma mark - ORKTaskResult

@implementation ORKTaskResult

- (instancetype)initWithTaskIdentifier:(NSString *)identifier
                           taskRunUUID:(NSUUID *)taskRunUUID
                       outputDirectory:(NSURL *)outputDirectory {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self->_taskRunUUID = [taskRunUUID copy];
        self->_outputDirectory = [outputDirectory copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, taskRunUUID);
    ORK_ENCODE_URL(aCoder, outputDirectory);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, taskRunUUID, NSUUID);
        ORK_DECODE_URL(aDecoder, outputDirectory);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.taskRunUUID, castObject.taskRunUUID) &&
            ORKEqualFileURLs(self.outputDirectory, castObject.outputDirectory));
}

- (NSUInteger)hash {
    return super.hash ^ self.taskRunUUID.hash ^ self.outputDirectory.hash;
}


- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTaskResult *result = [super copyWithZone:zone];
    result->_taskRunUUID = [self.taskRunUUID copy];
    result->_outputDirectory =  [self.outputDirectory copy];
    return result;
}

- (ORKStepResult *)stepResultForStepIdentifier:(NSString *)stepIdentifier {
    return (ORKStepResult *)[self resultForIdentifier:stepIdentifier];
}

@end


#pragma mark - ORKStepResult

@implementation ORKStepResult

- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier results:(NSArray *)results {
    self = [super initWithIdentifier:stepIdentifier];
    if (self) {
        [self setResultsCopyObjects:results];
        [self updateEnabledAssistiveTechnology];
    }
    return self;
}

- (void)updateEnabledAssistiveTechnology {
    if (UIAccessibilityIsVoiceOverRunning()) {
        _enabledAssistiveTechnology = [UIAccessibilityNotificationVoiceOverIdentifier copy];
    } else if (UIAccessibilityIsSwitchControlRunning()) {
        _enabledAssistiveTechnology = [UIAccessibilityNotificationSwitchControlIdentifier copy];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, enabledAssistiveTechnology);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, enabledAssistiveTechnology, NSString);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.enabledAssistiveTechnology, castObject.enabledAssistiveTechnology));
}

- (NSUInteger)hash {
    return super.hash ^ _enabledAssistiveTechnology.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKStepResult *result = [super copyWithZone:zone];
    result->_enabledAssistiveTechnology = [_enabledAssistiveTechnology copy];
    return result;
}

- (NSString *)descriptionPrefixWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; enabledAssistiveTechnology: %@", [super descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], _enabledAssistiveTechnology ? : @"None"];
}

@end


#pragma mark - ORKPageResult

@implementation ORKPageResult

- (instancetype)initWithPageStep:(ORKPageStep *)step stepResult:(ORKStepResult*)result {
    self = [super initWithTaskIdentifier:step.identifier taskRunUUID:[NSUUID UUID] outputDirectory:nil];
    if (self) {
        NSArray <NSString *> *stepIdentifiers = [step.steps valueForKey:@"identifier"];
        NSMutableArray *results = [NSMutableArray new];
        for (NSString *identifier in stepIdentifiers) {
            NSString *prefix = [NSString stringWithFormat:@"%@.", identifier];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier BEGINSWITH %@", prefix];
            NSArray *filteredResults = [result.results filteredArrayUsingPredicate:predicate];
            if (filteredResults.count > 0) {
                NSMutableArray *subresults = [NSMutableArray new];
                for (ORKResult *subresult in filteredResults) {
                    ORKResult *copy = [subresult copy];
                    copy.identifier = [subresult.identifier substringFromIndex:prefix.length];
                    [subresults addObject:copy];
                }
                [results addObject:[[ORKStepResult alloc] initWithStepIdentifier:identifier results:subresults]];
            }
        }
        self.results = results;
    }
    return self;
}

- (void)addStepResult:(ORKStepResult *)stepResult {
    if (stepResult == nil) {
        return;
    }
    
    // Remove previous step result and add the new one
    NSMutableArray *results = [self.results mutableCopy] ?: [NSMutableArray new];
    ORKResult *previousResult = [self resultForIdentifier:stepResult.identifier];
    if (previousResult) {
        [results removeObject:previousResult];
    }
    [results addObject:stepResult];
    self.results = results;
}

- (void)removeStepResultWithIdentifier:(NSString *)identifier {
    ORKResult *result = [self resultForIdentifier:identifier];
    if (result != nil) {
        NSMutableArray *results = [self.results mutableCopy];
        [results removeObject:result];
        self.results = results;
    }
}

- (void)removeStepResultsAfterStepWithIdentifier:(NSString *)identifier {
    ORKResult *result = [self resultForIdentifier:identifier];
    if (result != nil) {
        NSUInteger idx = [self.results indexOfObject:result];
        if (idx != NSNotFound) {
            self.results = [self.results subarrayWithRange:NSMakeRange(0, idx)];
        }
    }
}

- (NSArray <ORKResult *> *)flattenResults {
    NSMutableArray *results = [NSMutableArray new];
    for (ORKResult *result in self.results) {
        if ([result isKindOfClass:[ORKStepResult class]]) {
            ORKStepResult *stepResult = (ORKStepResult *)result;
            if (stepResult.results.count > 0) {
                // For each subresult in this step, append the step identifier onto the result
                for (ORKResult *currentResult in stepResult.results) {
                    ORKResult *copy = [currentResult copy];
                    NSString *subIdentifier = currentResult.identifier ?: [NSString stringWithFormat:@"%@", @(currentResult.hash)];
                    copy.identifier = [NSString stringWithFormat:@"%@.%@", stepResult.identifier, subIdentifier];
                    [results addObject:copy];
                }
            } else {
                // If this is an empty step result then add a base class instance with this identifier
                [results addObject:[[ORKResult alloc] initWithIdentifier:stepResult.identifier]];
            }
        } else {
            // If this is *not* a step result then just add it as-is
            [results addObject:result];
        }
    }
    return [results copy];
}

- (instancetype)copyWithOutputDirectory:(NSURL *)outputDirectory {
    typeof(self) copy = [[[self class] alloc] initWithTaskIdentifier:self.identifier taskRunUUID:self.taskRunUUID outputDirectory:outputDirectory];
    copy.results = self.results;
    return copy;
}

@end
