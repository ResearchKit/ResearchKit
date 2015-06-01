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


#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>
#import <CoreMotion/CoreMotion.h>
#import <objc/runtime.h>
#import <stdio.h>
#import <stdlib.h>
#import <HealthKit/HealthKit.h>

#import <ResearchKit/ORKResult_Private.h>
#import "ORKESerialization.h"


@interface ClassProperty : NSObject

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, strong) Class propertyClass;
@property (nonatomic) BOOL isPrimitiveType;

- (instancetype)initWithObjcProperty:(objc_property_t)property;

@end


@implementation ClassProperty

- (instancetype)initWithObjcProperty:(objc_property_t)property {
    
    self = [super init];
    if (self) {
        const char * name = property_getName(property);
        self.propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        
        const char * type = property_getAttributes(property);
        NSString * typeString = [NSString stringWithUTF8String:type];
        NSArray * attributes = [typeString componentsSeparatedByString:@","];
        NSString * typeAttribute = [attributes objectAtIndex:0];
        
        _isPrimitiveType = YES;
        if ([typeAttribute hasPrefix:@"T@"]) {
             _isPrimitiveType = NO;
            Class typeClass = nil;
            if ([typeAttribute length] > 4) {
                NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];  //turns @"NSDate" into NSDate
                typeClass = NSClassFromString(typeClassName);
            } else {
                typeClass = [NSObject class];
            }
            self.propertyClass = typeClass;
           
        } else if ([@[@"Ti", @"Tq", @"TI", @"TQ"] containsObject:typeAttribute]) {
            self.propertyClass = [NSNumber class];
        }
    }
    return self;
}

@end


@interface MockCountingDictionary : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)startObserving;

- (void)stopObserving;

- (NSArray *)unTouchedKeys;

@property (nonatomic, strong) NSMutableSet *touchedKeys;

@end


@implementation MockCountingDictionary {
    NSDictionary *_d;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    _d = dictionary;
    return self;
}

- (BOOL)isKindOfClass:(Class)aClass {
    if ([aClass isSubclassOfClass:[NSDictionary class]]) {
        return YES;
    }
    return [super isKindOfClass:aClass];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [_d methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([_d respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:_d];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

- (void)startObserving {
    self.touchedKeys = [NSMutableSet new];
}

- (void)stopObserving {
    self.touchedKeys = nil;
}

- (NSArray *)unTouchedKeys {
    NSMutableArray *unTouchedKeys = [NSMutableArray new];
    NSArray *keys = [_d allKeys];
    for (NSString *key in keys) {
        if ([self.touchedKeys containsObject:key] == NO) {
            [unTouchedKeys addObject:key];
        }
    }
    return [unTouchedKeys copy];
}

- (id)objectForKey:(id)aKey {
    if (aKey && self.touchedKeys) {
        [self.touchedKeys addObject:aKey];
    }
    return [_d objectForKey:aKey];
}

- (id)objectForKeyedSubscript:(id)key {
    if (key && self.touchedKeys) {
        [self.touchedKeys addObject:key];
    }
    return [_d objectForKeyedSubscript:key];
}

@end


@interface ORKJSONSerializationTests : XCTestCase <NSKeyedUnarchiverDelegate>

@end


@implementation ORKJSONSerializationTests

- (Class)unarchiver:(NSKeyedUnarchiver *)unarchiver cannotDecodeObjectOfClassName:(NSString *)name originalClasses:(NSArray *)classNames {
    NSLog(@"Cannot decode object with class: %@ (original classes: %@)", name, classNames);
    return nil;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTaskResult {
    
    //ORKTaskResult *result = [[ORKTaskResult alloc] initWithTaskIdentifier:@"a000012" taskRunUUID:[NSUUID UUID] outputDirectory:[NSURL fileURLWithPath:NSTemporaryDirectory()]];
    
    ORKQuestionResult *qr = [[ORKQuestionResult alloc] init];
    qr.answer = @(1010);
    qr.questionType = ORKQuestionTypeInteger;
    qr.identifier = @"a000012.s05";
    
    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"stepIdentifier" results:@[qr]];
    stepResult.results = @[qr];
}

- (void)testTaskModel {
    
    ORKActiveStep *activeStep = [[ORKActiveStep alloc] initWithIdentifier:@"id"];
    activeStep.shouldPlaySoundOnStart = YES;
    activeStep.shouldVibrateOnStart = YES;
    activeStep.stepDuration = 100.0;
    activeStep.recorderConfigurations =
    @[[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:@"id.accelerometer" frequency:11.0],
      [[ORKTouchRecorderConfiguration alloc] initWithIdentifier:@"id.touch"],
      [[ORKAudioRecorderConfiguration alloc] initWithIdentifier:@"id.audio" recorderSettings:@{}]];
    
    ORKQuestionStep *questionStep = [ORKQuestionStep questionStepWithIdentifier:@"id" title:@"question" answer:[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:@[[[ORKTextChoice alloc] initWithText:@"test1" detailText:nil value:@(1)]  ]]];
    
    ORKQuestionStep *questionStep2 = [ORKQuestionStep questionStepWithIdentifier:@"id"
                                                                     title:@"question" answer:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:@"kg"]];

    ORKQuestionStep *questionStep3 = [ORKQuestionStep questionStepWithIdentifier:@"id"
                                                                           title:@"question" answer:[ORKScaleAnswerFormat scaleAnswerFormatWithMaximumValue:10.0 minimumValue:1.0 defaultValue:5.0 step:1.0 vertical:YES maximumValueDescription:@"High value" minimumValueDescription:@"Low value"]];

    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"id" steps:@[activeStep, questionStep, questionStep2, questionStep3]];
    
    NSDictionary *dict1 = [ORKESerializer JSONObjectForObject:task error:nil];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict1 options:NSJSONWritingPrettyPrinted error:nil];
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"json"]];
    [data writeToFile:tempPath atomically:YES];
    NSLog(@"JSON file at %@", tempPath);
    
    NSLog(@"----%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] );
    
    NSLog(@"######################################################");
    
    NSLog(@"----%@",dict1);
    
    NSLog(@"######################################################");
    
    ORKOrderedTask *task2 = [ORKESerializer objectFromJSONObject:dict1 error:nil];
    
    NSDictionary *dict2 = [ORKESerializer JSONObjectForObject:task2 error:nil];
    
    NSLog(@"----%@",dict2);
    
    
    XCTAssertTrue([dict1 isEqualToDictionary:dict2], @"Should be equal");
    
}

- (void)testORKSerialization {
    
     // Find all classes that are serializable this way
    NSArray *classesWithORKSerialization = [ORKESerializer serializableClasses];
    
    // Predefined exception
    NSArray *propertyExclusionList = @[@"superclass",
                                       @"description",
                                       @"debugDescription",
                                       @"hash",
                                       @"requestedHealthKitTypesForReading",
                                       @"requestedHealthKitTypesForWriting",
                                       @"healthKitUnit",
                                       @"answer",
                                       @"firstResult"];
    NSArray *knownNotSerializedProperties = @[@"ORKStep.task",
                                              @"ORKStep.restorable",
                                              @"ORKAnswerFormat.questionType",
                                              @"ORKQuestionStep.questionType",
                                              @"ORKActiveStep.image",
                                              @"ORKConsentSection.customImage",
                                              @"ORKConsentSection.escapedContent",
                                              @"ORKConsentSignature.signatureImage",
                                              @"ORKConsentDocument.writer",
                                              @"ORKConsentDocument.signatureFormatter",
                                              @"ORKConsentDocument.sectionFormatter",
                                              @"ORKConsentDocument.sections",
                                              @"ORKConsentDocument.signatures",
                                              @"ORKContinuousScaleAnswerFormat.numberFormatter",
                                              @"ORKFormItem.step",
                                              @"ORKHealthKitCharacteristicTypeAnswerFormat.characteristicType",
                                              @"ORKTimeIntervalAnswerFormat.maximumInterval",
                                              @"ORKTimeIntervalAnswerFormat.defaultInterval",
                                              @"ORKTimeIntervalAnswerFormat.step",
                                              @"ORKTextAnswerFormat.maximumLength",
                                              @"ORKTextAnswerFormat.autocapitalizationType",
                                              @"ORKTextAnswerFormat.autocorrectionType",
                                              @"ORKTextAnswerFormat.spellCheckingType",
                                              @"ORKInstructionStep.image",
                                              @"ORKImageChoice.normalStateImage",
                                              @"ORKImageChoice.selectedStateImage",
                                              @"ORKImageCaptureStep.templateImage",
                                              @"ORKStep.requestedPermissions",
                                              @"ORKOrderedTask.providesBackgroundAudioPrompts",
                                              @"ORKScaleAnswerFormat.numberFormatter",
                                              @"ORKSpatialSpanMemoryStep.customTargetImage",
                                              @"ORKStep.allowsBackNavigation",
                                              @"ORKAnswerFormat.healthKitUserUnit",
                                              @"ORKOrderedTask.requestedPermissions",
                                              @"ORKStep.showsProgress",
                                              @"ORKResult.saveable",
                                              @"ORKCollectionResult.firstResult"];
    NSArray *allowedUnTouchedKeys = @[@"_class"];
    
    // Test Each class
    for (Class aClass in classesWithORKSerialization) {
        
        id instance = [[aClass alloc] init];
        
        // Find all properties of this class
        NSMutableArray *propertyNames = [NSMutableArray array];
        NSMutableDictionary *dottedPropertyNames = [NSMutableDictionary dictionary];
        unsigned int count;
        
        // Walk superclasses of this class, looking at all properties.
        // Otherwise we don't catch failures to base-call in initWithDictionary (etc)
        Class currentClass = aClass;
        while ([classesWithORKSerialization containsObject:currentClass]) {
            
            objc_property_t *props = class_copyPropertyList(currentClass, &count);
            for (int i = 0; i < count; i++) {
                objc_property_t property = props[i];
                ClassProperty *p = [[ClassProperty alloc] initWithObjcProperty:property];
                
                if ([propertyExclusionList containsObject: p.propertyName] == NO) {
                    if (p.isPrimitiveType == NO) {
                        // Assign value to object type property
                        if (p.propertyClass == [NSObject class] && (aClass == [ORKTextChoice class]|| aClass == [ORKImageChoice class]))
                        {
                            // Map NSObject to string, since it's used where either a string or a number is acceptable
                            [instance setValue:@"test" forKey:p.propertyName];
                        } else if (p.propertyClass == [NSNumber class]) {
                            [instance setValue:@(123) forKey:p.propertyName];
                        } else if (p.propertyClass == [HKUnit class]) {
                            [instance setValue:[HKUnit unitFromString:@"kg"] forKey:p.propertyName];
                        } else if (p.propertyClass == [NSURL class]) {
                            [instance setValue:[NSURL fileURLWithPath:@"/usr"] forKey:p.propertyName];
                        } else if (p.propertyClass == [NSTimeZone class]) {
                            [instance setValue:[NSTimeZone timeZoneForSecondsFromGMT:60*60] forKey:p.propertyName];
                        } else if (p.propertyClass == [HKQuantityType class]) {
                            [instance setValue:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass] forKey:p.propertyName];
                        } else if (p.propertyClass == [HKCharacteristicType class]) {
                            //[instance setValue:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType] forKey:p.propertyName];
                        } else if (p.propertyClass == [NSCalendar class]) {
                            [instance setValue:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] forKey:p.propertyName];
                        } else {
                            [instance setValue:[[p.propertyClass alloc] init] forKey:p.propertyName];
                        }
                    }
                    [propertyNames addObject:p.propertyName];
                    dottedPropertyNames[p.propertyName] = [NSString stringWithFormat:@"%@.%@",NSStringFromClass(currentClass),p.propertyName];
                }
            }
            currentClass = [currentClass superclass];

        }
        
        if ([aClass isSubclassOfClass:[ORKContinuousScaleAnswerFormat class]]) {
            [instance setValue:@(100) forKey:@"maximum"];
            [instance setValue:@(ORKNumberFormattingStylePercent) forKey:@"numberStyle"];
        } else if ([aClass isSubclassOfClass:[ORKScaleAnswerFormat class]]) {
            [instance setValue:@(0) forKey:@"minimum"];
            [instance setValue:@(100) forKey:@"maximum"];
            [instance setValue:@(10) forKey:@"step"];
        } else if ([aClass isSubclassOfClass:[ORKImageChoice class]] || [aClass isSubclassOfClass:[ORKTextChoice class]]) {
            [instance setValue:@"blah" forKey:@"value"];
        } else if ([aClass isSubclassOfClass:[ORKConsentSection class]]) {
            [instance setValue:[NSURL URLWithString:@"http://www.apple.com/"] forKey:@"customAnimationURL"];
        } else if ([aClass isSubclassOfClass:[ORKImageCaptureStep class]]) {
            [instance setValue:[NSValue valueWithUIEdgeInsets:(UIEdgeInsets){1,1,1,1}] forKey:@"templateImageInsets"];
        }
        
        // Serialization
        id mockDictionary = [[MockCountingDictionary alloc] initWithDictionary:[ORKESerializer JSONObjectForObject:instance error:NULL]];
        
        // Must contain corrected _class field
        XCTAssertTrue([NSStringFromClass(aClass) isEqualToString:mockDictionary[@"_class"]]);
        
        // All properties should have matching fields in dictionary (allow predefined exceptions)
        for (NSString *pName in propertyNames) {
            if (mockDictionary[pName] == nil) {
                NSString *notSerializedProperty = dottedPropertyNames[pName];
                BOOL success = [knownNotSerializedProperties containsObject:notSerializedProperty];
                if (! success)
                {
                    XCTAssertTrue(success, "Unexpected notSerializedProperty = %@ (%@)", notSerializedProperty, NSStringFromClass(aClass));
                }
            }
        }
        
        [mockDictionary startObserving];
       
        id instance2 = [ORKESerializer objectFromJSONObject:mockDictionary error:NULL];
       
        NSArray *unTouchedKeys = [mockDictionary unTouchedKeys];
        
        // Make sure all keys are touched by initializer
        for (NSString *key in unTouchedKeys) {
            XCTAssertTrue([allowedUnTouchedKeys containsObject:key], @"untouched %@", key);
        }
        
        [mockDictionary stopObserving];
        
        // Serialize again, the output ought to be equal
        NSDictionary *dictionary2 = [ORKESerializer JSONObjectForObject:instance2 error:NULL];
        BOOL isMatch = [mockDictionary isEqualToDictionary:dictionary2];
        if (! isMatch)
        {
            XCTAssertTrue(isMatch, @"Should be equal for class: %@", NSStringFromClass(aClass));
        }
    }

}

- (BOOL)applySomeValueToClassProperty:(ClassProperty *)p forObject:(id)instance index:(NSInteger)index forEqualityCheck:(BOOL)equality {
    // return YES if the index makes it distinct
    
    Class aClass = [instance class];
    // Assign value to object type property
    if (p.propertyClass == [NSObject class] && (aClass == [ORKTextChoice class]|| aClass == [ORKImageChoice class] || (aClass == [ORKQuestionResult class])))
    {
        // Map NSObject to string, since it's used where either a string or a number is acceptable
        [instance setValue:index?@"blah":@"test" forKey:p.propertyName];
    } else if (p.propertyClass == [NSNumber class]) {
        [instance setValue:index?@(12):@(123) forKey:p.propertyName];
    } else if (p.propertyClass == [NSURL class]) {
        [instance setValue:[NSURL fileURLWithPath:index?@"/xxx":@"/blah"] forKey:p.propertyName];
    } else if (p.propertyClass == [HKUnit class]) {
        [instance setValue:[HKUnit unitFromString:index?@"g":@"kg"] forKey:p.propertyName];
    } else if (p.propertyClass == [HKQuantityType class]) {
        [instance setValue:[HKQuantityType quantityTypeForIdentifier:index?HKQuantityTypeIdentifierActiveEnergyBurned : HKQuantityTypeIdentifierBodyMass] forKey:p.propertyName];
    } else if (p.propertyClass == [HKCharacteristicType class]) {
        [instance setValue:[HKCharacteristicType characteristicTypeForIdentifier:index?HKCharacteristicTypeIdentifierBiologicalSex: HKCharacteristicTypeIdentifierBloodType] forKey:p.propertyName];
    } else if (p.propertyClass == [NSCalendar class]) {
        [instance setValue:index?[NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese]:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] forKey:p.propertyName];
    } else if (p.propertyClass == [NSTimeZone class]) {
        [instance setValue:index?[NSTimeZone timeZoneWithName:[NSTimeZone knownTimeZoneNames][0]]:[NSTimeZone timeZoneForSecondsFromGMT:1000] forKey:p.propertyName];
    } else if (equality && (p.propertyClass == [UIImage class])) {
        // do nothing - meaningless for the equality check
        return NO;
    } else {
        [instance setValue:[[p.propertyClass alloc] init] forKey:p.propertyName];
        return NO;
    }
    return YES;
}

- (void)testORKSecureCoding {
    
    NSArray *classesExcluded = @[]; // classes not intended to be serialized standalone
    NSMutableArray *stringsForClassesExcluded = [NSMutableArray array];
    for (Class c in classesExcluded) {
        [stringsForClassesExcluded addObject:NSStringFromClass(c)];
    }
    
    // Find all classes that conform to NSSecureCoding
    NSMutableArray *classesWithSecureCoding = [NSMutableArray new];
    int numClasses = objc_getClassList(NULL, 0);
    Class classes[numClasses];
    numClasses = objc_getClassList(classes, numClasses);
    for (int index = 0; index < numClasses; index++) {
        Class aClass = classes[index];
        if ([stringsForClassesExcluded containsObject:NSStringFromClass(aClass)]) {
            continue;
        }
        
        if ([NSStringFromClass(aClass) hasPrefix:@"ORK"] &&
            [aClass conformsToProtocol:@protocol(NSSecureCoding)]) {
            
            [classesWithSecureCoding addObject:aClass];
        }
    }
    
    // Predefined exception
    NSArray *propertyExclusionList = @[@"superclass",
                                       @"description",
                                       @"debugDescription",
                                       @"hash",
                                       @"requestedHealthKitTypesForReading",
                                       @"requestedHealthKitTypesForWriting",
                                       @"healthKitUnit",
                                       @"firstResult",
                                       ];
    NSArray *knownNotSerializedProperties = @[@"ORKConsentDocument.writer", // created on demand
                                              @"ORKConsentDocument.signatureFormatter", // created on demand
                                              @"ORKConsentDocument.sectionFormatter", // created on demand
                                              @"ORKStep.task", // weak ref - object will be nil
                                              @"ORKFormItem.step",  // weak ref - object will be nil
                                              
                                              // id<> properties - these are actually serialized, but we can't fill them in properly for this test
                                              @"ORKTextChoice.value",
                                              @"ORKImageChoice.value",
                                              @"ORKQuestionResult.answer",
                                              
                                              // Not serialized - computed property
                                              @"ORKAnswerFormat.healthKitUnit",
                                              @"ORKAnswerFormat.healthKitUserUnit",
                                              @"ORKCollectionResult.firstResult",
                                              
                                              // Images: ignored so we can do the equality test and pass
                                              @"ORKImageChoice.normalStateImage",
                                              @"ORKImageChoice.selectedStateImage",
                                              @"ORKImageCaptureStep.templateImage",
                                              @"ORKConsentSignature.signatureImage",
                                              @"ORKConsentSection.customImage",
                                              @"ORKInstructionStep.image",
                                              @"ORKActiveStep.image",
                                              @"ORKSpatialSpanMemoryStep.customTargetImage"
                                              ];
    
    // Test Each class
    for (Class aClass in classesWithSecureCoding) {
        id instance = [[aClass alloc] init];
        
        // Find all properties of this class
        NSMutableArray *propertyNames = [NSMutableArray array];
        unsigned int count;
        objc_property_t *props = class_copyPropertyList(aClass, &count);
        for (int i = 0; i < count; i++) {
            objc_property_t property = props[i];
            ClassProperty *p = [[ClassProperty alloc] initWithObjcProperty:property];
            
            if ([propertyExclusionList containsObject: p.propertyName] == NO) {
                if (p.isPrimitiveType == NO) {
                    [self applySomeValueToClassProperty:p forObject:instance index:0 forEqualityCheck:YES];
                }
                [propertyNames addObject:p.propertyName];
            }
        }
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:instance];
        XCTAssertNotNil(data);
        
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        unarchiver.requiresSecureCoding = YES;
        unarchiver.delegate = self;
        id newInstance = [unarchiver decodeObjectOfClasses:[NSSet setWithArray:classesWithSecureCoding] forKey:NSKeyedArchiveRootObjectKey];
        
        // Set of classes we can check for equality. Would like to get rid of this once we implement
        NSSet *checkableClasses = [NSSet setWithObjects:[NSNumber class], [NSString class], [NSDictionary class], [NSURL class], nil];
        // All properties should have matching fields in dictionary( allow predefined exceptions)
        for (NSString *pName in propertyNames) {
            id newValue = [newInstance valueForKey:pName];
            id oldValue = [instance valueForKey:pName];
            
            if (newValue == nil) {
                NSString *notSerializedProperty = [NSString stringWithFormat:@"%@.%@", NSStringFromClass(aClass), pName];
                BOOL success = [knownNotSerializedProperties containsObject:notSerializedProperty];
                if (! success)
                {
                    XCTAssertTrue(success, "Unexpected notSerializedProperty = %@", notSerializedProperty);
                }
            }
            for (Class c in checkableClasses) {
                if ([oldValue isKindOfClass:c]) {
                    XCTAssertEqualObjects(newValue, oldValue);
                    break;
                }
            }
        }
    
        // NSData and NSDateComponents in your properties mess up the following test.
        // NSDateComponents - seems to be due to serializing and then deserializing introducing a leap month:no flag.
        if (aClass == [NSDateComponents class] || aClass == [ORKDateQuestionResult class] || aClass == [ORKDateAnswerFormat class] || aClass == [ORKDataResult class]) {
            continue;
        }
        
        NSData *data2 = [NSKeyedArchiver archivedDataWithRootObject:newInstance];
        if (![data isEqualToData:data2]) { // allow breakpointing
            XCTAssertEqualObjects(data, data2, @"data mismatch for %@", NSStringFromClass(aClass));
        }
        
        if (![newInstance isEqual:instance]) {
            XCTAssertEqualObjects(newInstance, instance, @"equality mismatch for %@", NSStringFromClass(aClass));
        }
    }
}

- (void)testEquality {
    NSArray *classesExcluded = @[]; // classes not intended to be serialized standalone
    NSMutableArray *stringsForClassesExcluded = [NSMutableArray array];
    for (Class c in classesExcluded) {
        [stringsForClassesExcluded addObject:NSStringFromClass(c)];
    }
    
    // Find all classes that conform to NSSecureCoding
    NSMutableArray *classesWithSecureCodingAndCopying = [NSMutableArray new];
    int numClasses = objc_getClassList(NULL, 0);
    Class classes[numClasses];
    numClasses = objc_getClassList(classes, numClasses);
    for (int index = 0; index < numClasses; index++) {
        Class aClass = classes[index];
        if ([stringsForClassesExcluded containsObject:NSStringFromClass(aClass)]) {
            continue;
        }
        
        if ([NSStringFromClass(aClass) hasPrefix:@"ORK"] &&
            [aClass conformsToProtocol:@protocol(NSSecureCoding)] &&
            [aClass conformsToProtocol:@protocol(NSCopying)]) {
            
            [classesWithSecureCodingAndCopying addObject:aClass];
        }
    }
    
    // Predefined exception
    NSArray *propertyExclusionList = @[@"superclass",
                                       @"description",
                                       @"debugDescription",
                                       @"hash",
                                       @"requestedHealthKitTypesForReading",
                                       @"healthKitUnit",
                                       @"requestedHealthKitTypesForWriting",
                                       @"answer",
                                       @"firstResult",
];
    
    // Test Each class
    for (Class aClass in classesWithSecureCodingAndCopying) {
        id instance = [[aClass alloc] init];
        
        // Find all properties of this class
        NSMutableArray *propertyNames = [NSMutableArray array];
        unsigned int count;
        objc_property_t *props = class_copyPropertyList(aClass, &count);
        for (int i = 0; i < count; i++) {
            objc_property_t property = props[i];
            ClassProperty *p = [[ClassProperty alloc] initWithObjcProperty:property];
            
            if ([propertyExclusionList containsObject: p.propertyName] == NO) {
                if (p.isPrimitiveType == NO) {
                    [self applySomeValueToClassProperty:p forObject:instance index:0 forEqualityCheck:YES];
                }
                [propertyNames addObject:p.propertyName];
            }
        }
        
        id copiedInstance = [instance copy];
        if (! [copiedInstance isEqual:instance]) {
            XCTAssertEqualObjects(copiedInstance, instance);
        }
       
        for (int i = 0; i < count; i++) {
            objc_property_t property = props[i];
            ClassProperty *p = [[ClassProperty alloc] initWithObjcProperty:property];
            
            if ([propertyExclusionList containsObject: p.propertyName] == NO) {
                if (p.isPrimitiveType == NO) {
                    copiedInstance = [instance copy];
                    if (instance == copiedInstance) {
                        // Totally immutable object.
                        continue;
                    }
                    if ([self applySomeValueToClassProperty:p forObject:copiedInstance index:1 forEqualityCheck:YES])
                    {
                        if ([copiedInstance isEqual:instance]) {
                            XCTAssertNotEqualObjects(copiedInstance, instance);
                        }
                        [self applySomeValueToClassProperty:p forObject:copiedInstance index:0 forEqualityCheck:YES];
                        XCTAssertEqualObjects(copiedInstance, instance);
                        
                        [copiedInstance setValue:nil forKey:p.propertyName];
                        XCTAssertNotEqualObjects(copiedInstance, instance);
                    }
                }
            }
        }
    }
}

- (void)testDateComponentsSerialization {
    
    // Trying to get NSDateComponents to change when you serialize / deserialize twice. But the test passes here.
    
    NSDateComponents *a = [NSDateComponents new];
    NSData *d1 = [NSKeyedArchiver archivedDataWithRootObject:a];
    NSDateComponents *b = [NSKeyedUnarchiver unarchiveObjectWithData:d1];
    NSData *d2 = [NSKeyedArchiver archivedDataWithRootObject:b];
    
    XCTAssertEqualObjects(d1, d2);
    XCTAssertEqualObjects(a, b);
}

@end
