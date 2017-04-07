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


@import XCTest;
@import ResearchKit.Private;

#import "ORKESerialization.h"

#import <objc/runtime.h>


@interface ClassProperty : NSObject

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, strong) Class propertyClass;
@property (nonatomic) BOOL isPrimitiveType;
@property (nonatomic) BOOL isBoolType;

- (instancetype)initWithObjcProperty:(objc_property_t)property;

@end


@implementation ClassProperty

- (instancetype)initWithObjcProperty:(objc_property_t)property {
    
    self = [super init];
    if (self) {
        const char *name = property_getName(property);
        self.propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        
        const char *type = property_getAttributes(property);
        NSString *typeString = [NSString stringWithUTF8String:type];
        NSArray *attributes = [typeString componentsSeparatedByString:@","];
        NSString *typeAttribute = attributes[0];
        
        _isPrimitiveType = YES;
        if ([typeAttribute hasPrefix:@"T@"]) {
             _isPrimitiveType = NO;
            Class typeClass = nil;
            if (typeAttribute.length > 4) {
                NSString *typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, typeAttribute.length-4)];  //turns @"NSDate" into NSDate
                typeClass = NSClassFromString(typeClassName);
            } else {
                typeClass = [NSObject class];
            }
            self.propertyClass = typeClass;
           
        } else if ([@[@"Ti", @"Tq", @"TI", @"TQ"] containsObject:typeAttribute]) {
            self.propertyClass = [NSNumber class];
        }
        else if ([typeAttribute isEqualToString:@"TB"]) {
            self.propertyClass = [NSNumber class];
            _isBoolType = YES;
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

#define ORK_MAKE_TEST_INIT(class, block) \
@interface class (ORKTest) \
- (instancetype)orktest_init; \
@end \
\
@implementation class (ORKTest) \
- (instancetype)orktest_init { \
    return block(); \
} \
@end \


/*
 Add an orktest_init method to all the classes which make init unavailable. This
 allows us to write very short code to instantiate valid objects during these tests.
 */
ORK_MAKE_TEST_INIT(ORKStepNavigationRule, ^{return [super init];});
ORK_MAKE_TEST_INIT(ORKSkipStepNavigationRule, ^{return [super init];});
ORK_MAKE_TEST_INIT(ORKStepModifier, ^{return [super init];});
ORK_MAKE_TEST_INIT(ORKKeyValueStepModifier, ^{return [super init];});
ORK_MAKE_TEST_INIT(ORKAnswerFormat, ^{return [super init];});
ORK_MAKE_TEST_INIT(ORKLoginStep, ^{return [self initWithIdentifier:[NSUUID UUID].UUIDString title:@"title" text:@"text" loginViewControllerClass:NSClassFromString(@"ORKLoginStepViewController") ];});
ORK_MAKE_TEST_INIT(ORKVerificationStep, ^{return [self initWithIdentifier:[NSUUID UUID].UUIDString text:@"text" verificationViewControllerClass:NSClassFromString(@"ORKVerificationStepViewController") ];});
ORK_MAKE_TEST_INIT(ORKStep, ^{return [self initWithIdentifier:[NSUUID UUID].UUIDString];});
ORK_MAKE_TEST_INIT(ORKReviewStep, ^{return [[self class] standaloneReviewStepWithIdentifier:[NSUUID UUID].UUIDString steps:@[] resultSource:[ORKTaskResult new]];});
ORK_MAKE_TEST_INIT(ORKOrderedTask, ^{return [self initWithIdentifier:@"test1" steps:nil];});
ORK_MAKE_TEST_INIT(ORKImageChoice, ^{return [super init];});
ORK_MAKE_TEST_INIT(ORKTextChoice, ^{return [super init];});
ORK_MAKE_TEST_INIT(ORKPredicateStepNavigationRule, ^{return [self initWithResultPredicates:@[[ORKResultPredicate predicateForBooleanQuestionResultWithResultSelector:[ORKResultSelector selectorWithResultIdentifier:@"test"] expectedAnswer:YES]] destinationStepIdentifiers:@[@"test2"]];});
ORK_MAKE_TEST_INIT(ORKResultSelector, ^{return [self initWithResultIdentifier:@"resultIdentifier"];});
ORK_MAKE_TEST_INIT(ORKRecorderConfiguration, ^{return [self initWithIdentifier:@"testRecorder"];});
ORK_MAKE_TEST_INIT(ORKAccelerometerRecorderConfiguration, ^{return [super initWithIdentifier:@"testRecorder"];});
ORK_MAKE_TEST_INIT(ORKHealthQuantityTypeRecorderConfiguration, ^{ return [super initWithIdentifier:@"testRecorder"];});
ORK_MAKE_TEST_INIT(ORKAudioRecorderConfiguration, ^{ return [super initWithIdentifier:@"testRecorder"];});
ORK_MAKE_TEST_INIT(ORKDeviceMotionRecorderConfiguration, ^{ return [super initWithIdentifier:@"testRecorder"];});
ORK_MAKE_TEST_INIT(ORKLocation, (^{
    ORKLocation *location = [self initWithCoordinate:CLLocationCoordinate2DMake(2.0, 3.0) region:[[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(2.0, 3.0) radius:100.0 identifier:@"identifier"] userInput:@"addressString" addressDictionary:@{@"city":@"city", @"street":@"street"}];
    return location;
}));
ORK_MAKE_TEST_INIT(HKSampleType, (^{
    return [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
}))
ORK_MAKE_TEST_INIT(HKQuantityType, (^{
    return [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
}))
ORK_MAKE_TEST_INIT(HKCorrelationType, (^{
    return [HKCorrelationType correlationTypeForIdentifier:HKCorrelationTypeIdentifierBloodPressure];
}))
ORK_MAKE_TEST_INIT(HKCharacteristicType, (^{
    return [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType];
}))
ORK_MAKE_TEST_INIT(CLCircularRegion, (^{
    return [self initWithCenter:CLLocationCoordinate2DMake(2.0, 3.0) radius:100.0 identifier:@"identifier"];
}))
ORK_MAKE_TEST_INIT(NSNumber, (^{
    return [self initWithInt:123];
}))
ORK_MAKE_TEST_INIT(HKUnit, (^{
    return [HKUnit unitFromString:@"kg"];
}))
ORK_MAKE_TEST_INIT(NSURL, (^{
    return [self initFileURLWithPath:@"/usr"];
}))
ORK_MAKE_TEST_INIT(NSTimeZone, (^{
    return [NSTimeZone timeZoneForSecondsFromGMT:60*60];
}))
ORK_MAKE_TEST_INIT(NSCalendar, (^{
    return [self initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
}))
ORK_MAKE_TEST_INIT(NSRegularExpression, (^{
    return [self initWithPattern:@"." options:0 error:nil];
}))


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
    
    ORKQuestionStep *questionStep = [ORKQuestionStep questionStepWithIdentifier:@"id1" title:@"question" answer:[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:@[[[ORKTextChoice alloc] initWithText:@"test1" detailText:nil value:@(1) exclusive:NO]  ]]];
    
    ORKQuestionStep *questionStep2 = [ORKQuestionStep questionStepWithIdentifier:@"id2"
                                                                     title:@"question" answer:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:@"kg"]];

    ORKQuestionStep *questionStep3 = [ORKQuestionStep questionStepWithIdentifier:@"id3"
                                                                           title:@"question" answer:[ORKScaleAnswerFormat scaleAnswerFormatWithMaximumValue:10.0 minimumValue:1.0 defaultValue:5.0 step:1.0 vertical:YES maximumValueDescription:@"High value" minimumValueDescription:@"Low value"]];

    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"id" steps:@[activeStep, questionStep, questionStep2, questionStep3]];
    
    NSDictionary *dict1 = [ORKESerializer JSONObjectForObject:task error:nil];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict1 options:NSJSONWritingPrettyPrinted error:nil];
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"json"]];
    [data writeToFile:tempPath atomically:YES];
    NSLog(@"JSON file at %@", tempPath);
    
    ORKOrderedTask *task2 = [ORKESerializer objectFromJSONObject:dict1 error:nil];
    
    NSDictionary *dict2 = [ORKESerializer JSONObjectForObject:task2 error:nil];
    
    XCTAssertTrue([dict1 isEqualToDictionary:dict2], @"Should be equal");
    
}

- (NSArray<Class> *)classesWithSecureCoding {
    
    NSArray *classesExcluded = @[]; // classes not intended to be serialized standalone
    NSMutableArray *stringsForClassesExcluded = [NSMutableArray array];
    for (Class c in classesExcluded) {
        [stringsForClassesExcluded addObject:NSStringFromClass(c)];
    }
    
    // Find all classes that conform to NSSecureCoding
    NSMutableArray<Class> *classesWithSecureCoding = [NSMutableArray new];
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
    
    return [classesWithSecureCoding copy];
}

// JSON Serialization
- (void)testORKSerialization {
    
    // Find all classes that are serializable this way
    NSArray *classesWithORKSerialization = [ORKESerializer serializableClasses];
    
    // All classes that conform to NSSecureCoding should also support ORKESerialization
    NSArray *classesWithSecureCoding = [self classesWithSecureCoding];
    
    NSArray *classesExcludedForORKESerialization = @[
                                                     [ORKStepNavigationRule class],     // abstract base class
                                                     [ORKSkipStepNavigationRule class],     // abstract base class
                                                     [ORKStepModifier class],     // abstract base class
                                                     [ORKPredicateSkipStepNavigationRule class],     // NSPredicate doesn't yet support JSON serialzation
                                                     [ORKKeyValueStepModifier class],     // NSPredicate doesn't yet support JSON serialzation
                                                     [ORKCollector class], // ORKCollector doesn't support JSON serialzation
                                                     [ORKHealthCollector class],
                                                     [ORKHealthCorrelationCollector class],
                                                     [ORKMotionActivityCollector class]
                                                     ];
    
    if ((classesExcludedForORKESerialization.count + classesWithORKSerialization.count) != classesWithSecureCoding.count) {
        NSMutableArray *unregisteredList = [classesWithSecureCoding mutableCopy];
        [unregisteredList removeObjectsInArray:classesWithORKSerialization];
        [unregisteredList removeObjectsInArray:classesExcludedForORKESerialization];
        XCTAssertEqual(unregisteredList.count, 0, @"Classes didn't implement ORKSerialization %@", unregisteredList);
    }
    
    // Predefined exception
    NSArray *propertyExclusionList = @[
                                       @"superclass",
                                       @"description",
                                       @"descriptionSuffix",
                                       @"debugDescription",
                                       @"hash",
                                       @"requestedHealthKitTypesForReading",
                                       @"requestedHealthKitTypesForWriting",
                                       @"healthKitUnit",
                                       @"answer",
                                       @"firstResult",
                                       @"ORKPageStep.steps",
                                       @"ORKNavigablePageStep.steps",
                                       @"ORKTextAnswerFormat.validationRegex",
                                       @"ORKRegistrationStep.passcodeValidationRegex",
                                       ];
    NSArray *knownNotSerializedProperties = @[
                                              @"ORKStep.task",
                                              @"ORKStep.restorable",
                                              @"ORKReviewStep.isStandalone",
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
                                              @"ORKTimeIntervalAnswerFormat.maximumInterval",
                                              @"ORKTimeIntervalAnswerFormat.defaultInterval",
                                              @"ORKTimeIntervalAnswerFormat.step",
                                              @"ORKTextAnswerFormat.maximumLength",
                                              @"ORKTextAnswerFormat.autocapitalizationType",
                                              @"ORKTextAnswerFormat.autocorrectionType",
                                              @"ORKTextAnswerFormat.spellCheckingType",
                                              @"ORKInstructionStep.image",
                                              @"ORKInstructionStep.auxiliaryImage",
                                              @"ORKInstructionStep.iconImage",
                                              @"ORKImageChoice.normalStateImage",
                                              @"ORKImageChoice.selectedStateImage",
                                              @"ORKImageCaptureStep.templateImage",
                                              @"ORKVideoCaptureStep.templateImage",
                                              @"ORKStep.requestedPermissions",
                                              @"ORKOrderedTask.providesBackgroundAudioPrompts",
                                              @"ORKScaleAnswerFormat.numberFormatter",
                                              @"ORKSpatialSpanMemoryStep.customTargetImage",
                                              @"ORKStep.allowsBackNavigation",
                                              @"ORKAnswerFormat.healthKitUserUnit",
                                              @"ORKOrderedTask.requestedPermissions",
                                              @"ORKStep.showsProgress",
                                              @"ORKResult.saveable",
                                              @"ORKCollectionResult.firstResult",
                                              @"ORKScaleAnswerFormat.minimumImage",
                                              @"ORKScaleAnswerFormat.maximumImage",
                                              @"ORKContinuousScaleAnswerFormat.minimumImage",
                                              @"ORKContinuousScaleAnswerFormat.maximumImage",
                                              @"ORKHeightAnswerFormat.useMetricSystem",
                                              @"ORKDataResult.data",
                                              @"ORKVerificationStep.verificationViewControllerClass",
                                              @"ORKLoginStep.loginViewControllerClass",
                                              @"ORKRegistrationStep.passcodeValidationRegularExpression",
                                              @"ORKRegistrationStep.passcodeInvalidMessage",
                                              @"ORKSignatureResult.signatureImage",
                                              @"ORKSignatureResult.signaturePath",
                                              @"ORKPageStep.steps",
                                              @"ORKNavigablePageStep.steps",
                                              ];
    NSArray *allowedUnTouchedKeys = @[@"_class"];
    
    // Test Each class
    for (Class aClass in classesWithORKSerialization) {
        
        id instance = [self instanceForClass:aClass];
        
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
                
                NSString *dottedPropertyName = [NSString stringWithFormat:@"%@.%@",NSStringFromClass(currentClass),p.propertyName];
                if ([propertyExclusionList containsObject: p.propertyName] == NO &&
                    [propertyExclusionList containsObject: dottedPropertyName] == NO) {
                    if (p.isPrimitiveType == NO) {
                        // Assign value to object type property
                        if (p.propertyClass == [NSObject class] && (aClass == [ORKTextChoice class] || aClass == [ORKImageChoice class]))
                        {
                            // Map NSObject to string, since it's used where either a string or a number is acceptable
                            [instance setValue:@"test" forKey:p.propertyName];
                        } else {
                            id itemInstance = [self instanceForClass:p.propertyClass];
                            [instance setValue:itemInstance forKey:p.propertyName];
                        }
                    }
                    [propertyNames addObject:p.propertyName];
                    dottedPropertyNames[p.propertyName] = dottedPropertyName;
                }
            }
            currentClass = [currentClass superclass];

        }
        
        if ([aClass isSubclassOfClass:[ORKTextScaleAnswerFormat class]]) {
            [instance setValue:@[[ORKTextChoice choiceWithText:@"Poor" value:@1], [ORKTextChoice choiceWithText:@"Excellent" value:@2]] forKey:@"textChoices"];
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
        } else if ([aClass isSubclassOfClass:[ORKImageCaptureStep class]] || [aClass isSubclassOfClass:[ORKVideoCaptureStep class]]) {
            [instance setValue:[NSValue valueWithUIEdgeInsets:(UIEdgeInsets){1,1,1,1}] forKey:@"templateImageInsets"];
        } else if ([aClass isSubclassOfClass:[ORKTimeIntervalAnswerFormat class]]) {
            [instance setValue:@(1) forKey:@"step"];
        } else if ([aClass isSubclassOfClass:[ORKLoginStep class]]) {
            [instance setValue:NSStringFromClass([ORKLoginStepViewController class]) forKey:@"loginViewControllerString"];
        } else if ([aClass isSubclassOfClass:[ORKVerificationStep class]]) {
            [instance setValue:NSStringFromClass([ORKVerificationStepViewController class]) forKey:@"verificationViewControllerString"];
        } else if ([aClass isSubclassOfClass:[ORKReviewStep class]]) {
            [instance setValue:[ORKTaskResult new] forKey:@"resultSource"]; // Manually add here because it's a protocol and hence property doesn't have a class
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
                if (!success) {
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
        if (!isMatch) {
            XCTAssertTrue(isMatch, @"Should be equal for class: %@", NSStringFromClass(aClass));
        }
    }

}

- (BOOL)applySomeValueToClassProperty:(ClassProperty *)p forObject:(id)instance index:(NSInteger)index forEqualityCheck:(BOOL)equality {
    // return YES if the index makes it distinct
    
    if (p.isPrimitiveType) {
        if (p.propertyClass == [NSNumber class]) {
            if (p.isBoolType) {
                XCTAssertNoThrow([instance setValue:index?@YES:@NO forKey:p.propertyName]);
            } else {
                XCTAssertNoThrow([instance setValue:index?@(12):@(123) forKey:p.propertyName]);
            }
            return YES;
        } else {
            return NO;
        }
    }
    
    Class aClass = [instance class];
    // Assign value to object type property
    if (p.propertyClass == [NSObject class] && (aClass == [ORKTextChoice class]|| aClass == [ORKImageChoice class] || (aClass == [ORKQuestionResult class])))
    {
        // Map NSObject to string, since it's used where either a string or a number is acceptable
        [instance setValue:index?@"blah":@"test" forKey:p.propertyName];
    } else if (p.propertyClass == [NSNumber class]) {
        [instance setValue:index?@(12):@(123) forKey:p.propertyName];
    } else if (p.propertyClass == [NSURL class]) {
        NSURL *url = [NSURL fileURLWithFileSystemRepresentation:[index?@"xxx":@"blah" UTF8String]  isDirectory:NO relativeToURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
        [instance setValue:url forKey:p.propertyName];
        [[NSFileManager defaultManager] createFileAtPath:[url path] contents:nil attributes:nil];
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
    } else if (p.propertyClass == [ORKLocation class]) {
        [instance setValue:[[ORKLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(index? 2.0 : 3.0, 3.0) region:[[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(2.0, 3.0) radius:100.0 identifier:@"identifier"] userInput:@"addressString" addressDictionary:@{@"city":@"city", @"street":@"street"}] forKey:p.propertyName];
    } else if (p.propertyClass == [CLCircularRegion class]) {
        [instance setValue:[[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(index? 2.0 : 3.0, 3.0) radius:100.0 identifier:@"identifier"] forKey:p.propertyName];
    } else if (p.propertyClass == [NSPredicate class]) {
        [instance setValue:[NSPredicate predicateWithFormat:index?@"1 == 1":@"1 == 2"] forKey:p.propertyName];
    } else if (p.propertyClass == [NSRegularExpression class]) {
        [instance setValue:[NSRegularExpression regularExpressionWithPattern:index ? @"." : @"[A-Z]"
                                                                     options:index ? 0 : NSRegularExpressionCaseInsensitive
                                                                       error:nil] forKey:p.propertyName];
    } else if (equality && (p.propertyClass == [UIImage class])) {
        // do nothing - meaningless for the equality check
        return NO;
    } else if (aClass == [ORKReviewStep class] && [p.propertyName isEqualToString:@"resultSource"]) {
        [instance setValue:[[ORKTaskResult alloc] initWithIdentifier:@"blah"] forKey:p.propertyName];
        return NO;
    } else {
        id instanceForChild = [self instanceForClass:p.propertyClass];
        [instance setValue:instanceForChild forKey:p.propertyName];
        return NO;
    }
    return YES;
}

- (void)testSecureCoding {
    
    NSArray<Class> *classesWithSecureCoding = [self classesWithSecureCoding];
    
    // Predefined exception
    NSArray *propertyExclusionList = @[@"superclass",
                                       @"description",
                                       @"descriptionSuffix",
                                       @"debugDescription",
                                       @"hash",
                                       @"requestedHealthKitTypesForReading",
                                       @"requestedHealthKitTypesForWriting",
                                       @"healthKitUnit",
                                       @"firstResult",
                                       @"correlationType",
                                       @"sampleType",
                                       @"unit",
                                       @"ORKPageStep.steps",
                                       @"ORKNavigablePageStep.steps",
                                       @"ORKTextAnswerFormat.validationRegex",
                                       @"ORKRegistrationStep.passcodeValidationRegex",
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
                                              @"ORKVerificationStep.verificationViewControllerClass",
                                              @"ORKLoginStep.loginViewControllerClass",
                                              
                                              // Not serialized - computed property
                                              @"ORKAnswerFormat.healthKitUnit",
                                              @"ORKAnswerFormat.healthKitUserUnit",
                                              @"ORKCollectionResult.firstResult",
                                              
                                              // Images: ignored so we can do the equality test and pass
                                              @"ORKImageChoice.normalStateImage",
                                              @"ORKImageChoice.selectedStateImage",
                                              @"ORKImageCaptureStep.templateImage",
                                              @"ORKVideoCaptureStep.templateImage",
                                              @"ORKConsentSignature.signatureImage",
                                              @"ORKConsentSection.customImage",
                                              @"ORKInstructionStep.image",
                                              @"ORKInstructionStep.auxiliaryImage",
                                              @"ORKInstructionStep.iconImage",
                                              @"ORKActiveStep.image",
                                              @"ORKSpatialSpanMemoryStep.customTargetImage",
                                              @"ORKScaleAnswerFormat.minimumImage",
                                              @"ORKScaleAnswerFormat.maximumImage",
                                              @"ORKContinuousScaleAnswerFormat.minimumImage",
                                              @"ORKContinuousScaleAnswerFormat.maximumImage",
                                              @"ORKSignatureResult.signatureImage",
                                              @"ORKSignatureResult.signaturePath",
                                              @"ORKPageStep.steps",
                                              @"ORKNavigablePageStep.steps",
                                              ];
    
    // Test Each class
    for (Class aClass in classesWithSecureCoding) {
        id instance = [self instanceForClass:aClass];
        
        // Find all properties of this class
        NSMutableArray *propertyNames = [NSMutableArray array];
        unsigned int count;
        objc_property_t *props = class_copyPropertyList(aClass, &count);
        for (int i = 0; i < count; i++) {
            objc_property_t property = props[i];
            ClassProperty *p = [[ClassProperty alloc] initWithObjcProperty:property];
            
            NSString *dottedPropertyName = [NSString stringWithFormat:@"%@.%@",NSStringFromClass(aClass),p.propertyName];
            if ([propertyExclusionList containsObject: p.propertyName] == NO &&
                [propertyExclusionList containsObject: dottedPropertyName] == NO) {
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
        NSMutableSet<Class> *decodingClasses = [NSMutableSet setWithArray:classesWithSecureCoding];
        [decodingClasses addObject:[NSDate class]];
        [decodingClasses addObject:[HKQueryAnchor class]];
        
        id newInstance = [unarchiver decodeObjectOfClasses:decodingClasses forKey:NSKeyedArchiveRootObjectKey];
        
        // Set of classes we can check for equality. Would like to get rid of this once we implement
        NSSet *checkableClasses = [NSSet setWithObjects:[NSNumber class], [NSString class], [NSDictionary class], [NSURL class], nil];
        // All properties should have matching fields in dictionary (allow predefined exceptions)
        for (NSString *pName in propertyNames) {
            id newValue = [newInstance valueForKey:pName];
            id oldValue = [instance valueForKey:pName];
            
            if (newValue == nil) {
                NSString *notSerializedProperty = [NSString stringWithFormat:@"%@.%@", NSStringFromClass(aClass), pName];
                BOOL success = [knownNotSerializedProperties containsObject:notSerializedProperty];
                if (!success) {
                    XCTAssertTrue(success, "Unexpected notSerializedProperty = %@", notSerializedProperty);
                }
            }
            for (Class c in checkableClasses) {
                if ([oldValue isKindOfClass:c]) {
                    if ([newValue isKindOfClass:[NSURL class]] || [oldValue isKindOfClass:[NSURL class]]) {
                        if (![[newValue absoluteString] isEqualToString:[oldValue absoluteString]]) {
                            XCTAssertTrue([[newValue absoluteString] isEqualToString:[oldValue absoluteString]]);
                        }
                    } else {
                        XCTAssertEqualObjects(newValue, oldValue);
                    }
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
        
        NSKeyedUnarchiver *unarchiver2 = [[NSKeyedUnarchiver alloc] initForReadingWithData:data2];
        unarchiver2.requiresSecureCoding = YES;
        unarchiver2.delegate = self;
        id newInstance2 = [unarchiver2 decodeObjectOfClasses:decodingClasses forKey:NSKeyedArchiveRootObjectKey];
        NSData *data3 = [NSKeyedArchiver archivedDataWithRootObject:newInstance2];
        
        if (![data isEqualToData:data2]) { // allow breakpointing
            if (![aClass isSubclassOfClass:[ORKConsentSection class]]
                // ORKConsentSection mis-matches, but it is still "equal" because
                // the net custom animation URL is a match.
                && ![aClass isSubclassOfClass:[ORKNavigableOrderedTask class]]
                // ORKNavigableOrderedTask contains ORKStepModifiers which is an abstract class
                // with no encoded properties, but encoded/decoded objects are still equal.
                && ![aClass isSubclassOfClass:[ORKKeyValueStepModifier class]]
                // ORKKeyValueStepModifier si a subclass of ORKStepModifier which is an abstract class
                // with no encoded properties, but encoded/decoded objects are still equal.
                ) {
                XCTAssertEqualObjects(data, data2, @"data mismatch for %@", NSStringFromClass(aClass));
            }
        }
        if (![data2 isEqualToData:data3]) { // allow breakpointing
            XCTAssertEqualObjects(data2, data3, @"data mismatch for %@", NSStringFromClass(aClass));
        }
        
        if (![newInstance isEqual:instance]) {
            XCTAssertEqualObjects(newInstance, instance, @"equality mismatch for %@", NSStringFromClass(aClass));
        }
        if (![newInstance2 isEqual:instance]) {
            XCTAssertEqualObjects(newInstance2, instance, @"equality mismatch for %@", NSStringFromClass(aClass));
        }
    }
}

- (id)instanceForClass:(Class)c {
    id result = nil;
    @try {
        if ([c instancesRespondToSelector:@selector(orktest_init)])
        {
            result = [[c alloc] orktest_init];
        } else {
            result = [[c alloc] init];
        }
    } @catch (NSException *exception) {
        XCTAssert(NO, @"Exception throw in init for %@. Exception: %@", NSStringFromClass(c), exception);
    }
    return result;
}

- (void)testEquality {
    NSArray *classesExcluded = @[
                                 [ORKStepNavigationRule class],     // abstract base class
                                 [ORKSkipStepNavigationRule class],     // abstract base class
                                 [ORKStepModifier class],     // abstract base class
                                 ];
    
    
    // Each time ORKRegistrationStep returns a new date in its answer fromat, cannot be tested.
    NSMutableArray *stringsForClassesExcluded = [NSMutableArray arrayWithObjects:NSStringFromClass([ORKRegistrationStep class]), nil];
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
                                       @"descriptionSuffix",
                                       @"debugDescription",
                                       @"hash",
                                       
                                       // ResearchKit specific
                                       @"answer",
                                       @"firstResult",
                                       @"healthKitUnit",
                                       @"providesBackgroundAudioPrompts",
                                       @"questionType",
                                       @"requestedHealthKitTypesForReading",
                                       @"requestedHealthKitTypesForWriting",
                                       @"requestedPermissions",
                                       @"shouldReportProgress",
                                       
                                       // For a specific class
                                       @"ORKHeightAnswerFormat.useMetricSystem",
                                       @"ORKNavigablePageStep.steps",
                                       @"ORKPageStep.steps",
                                       @"ORKResult.saveable",
                                       @"ORKReviewStep.isStandalone",
                                       @"ORKStep.allowsBackNavigation",
                                       @"ORKStep.restorable",
                                       @"ORKStep.showsProgress",
                                       @"ORKStepResult.isPreviousResult",
                                       @"ORKTextAnswerFormat.validationRegex",
                                       @"ORKVideoCaptureStep.duration",
                                       ];
    
    NSArray *hashExclusionList = @[
                                   @"ORKDateQuestionResult.calendar",
                                   @"ORKDateQuestionResult.timeZone",
                                   @"ORKToneAudiometryResult.outputVolume",
                                   @"ORKConsentSection.contentURL",
                                   @"ORKConsentSection.customAnimationURL",
                                   @"ORKNumericAnswerFormat.minimum",
                                   @"ORKNumericAnswerFormat.maximum",
                                   @"ORKVideoCaptureStep.duration",
                                   @"ORKTextAnswerFormat.validationRegularExpression",
                                   ];
    
    // Test Each class
    for (Class aClass in classesWithSecureCodingAndCopying) {
        id instance = [self instanceForClass:aClass];
        
        // Find all properties of this class
        NSMutableArray *propertyNames = [NSMutableArray array];
        unsigned int count;
        objc_property_t *props = class_copyPropertyList(aClass, &count);
        for (int i = 0; i < count; i++) {
            objc_property_t property = props[i];
            ClassProperty *p = [[ClassProperty alloc] initWithObjcProperty:property];
            
            NSString *dottedPropertyName = [NSString stringWithFormat:@"%@.%@",NSStringFromClass(aClass),p.propertyName];
            if ([propertyExclusionList containsObject: p.propertyName] == NO &&
                [propertyExclusionList containsObject: dottedPropertyName] == NO) {
                if (p.isPrimitiveType || [instance valueForKey:p.propertyName] == nil) {
                    [self applySomeValueToClassProperty:p forObject:instance index:0 forEqualityCheck:YES];
                }
                [propertyNames addObject:p.propertyName];
            }
        }
        
        id copiedInstance = [instance copy];
        if (![copiedInstance isEqual:instance]) {
            XCTAssertEqualObjects(copiedInstance, instance);
        }
       
        for (int i = 0; i < count; i++) {
            objc_property_t property = props[i];
            ClassProperty *p = [[ClassProperty alloc] initWithObjcProperty:property];
            
            NSString *dottedPropertyName = [NSString stringWithFormat:@"%@.%@",NSStringFromClass(aClass),p.propertyName];
            if ([propertyExclusionList containsObject: p.propertyName] == NO &&
                [propertyExclusionList containsObject: dottedPropertyName] == NO) {
                    copiedInstance = [instance copy];
                    if (instance == copiedInstance) {
                        // Totally immutable object.
                        continue;
                    }
                    if ([self applySomeValueToClassProperty:p forObject:copiedInstance index:1 forEqualityCheck:YES])
                    {
                        if ([copiedInstance isEqual:instance]) {
                            XCTAssertNotEqualObjects(copiedInstance, instance, @"%@", dottedPropertyName);
                        }
                        if (!p.isPrimitiveType &&
                            ![hashExclusionList containsObject:p.propertyName] &&
                            ![hashExclusionList containsObject:dottedPropertyName]) {
                            // Only check the hash for non-primitive type properties because often the
                            // hash into a table can be referenced using a subset of the properties used to test equality.
                            XCTAssertNotEqual([instance hash], [copiedInstance hash], @"%@", dottedPropertyName);
                        }
                        
                        [self applySomeValueToClassProperty:p forObject:copiedInstance index:0 forEqualityCheck:YES];
                        XCTAssertEqualObjects(copiedInstance, instance, @"%@", dottedPropertyName);
                        
                        if (p.isPrimitiveType == NO) {
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

- (void)testAddResult {
    
    // Classes for which tests are not currently implemented
    NSArray <NSString *> *excludedClassNames = @[
                                                 @"ORKVisualConsentStepViewController",     // Requires step with scenes
                                                 ];
    
    // Classes that do not allow adding a result should throw an exception
    NSArray <NSString *> *exceptionClassNames = @[
                                                  @"ORKPasscodeStepViewController",
                                                 ];
    
    NSDictionary <NSString *, NSString *> *mapStepClassForViewController = @{ // classes that require custom step class
                                                                             @"ORKActiveStepViewController" : @"ORKActiveStep",
                                                                             @"ORKConsentReviewStepViewController" : @"ORKConsentReviewStep",
                                                                             @"ORKFormStepViewController" : @"ORKFormStep",
                                                                             @"ORKHolePegTestPlaceStepViewController" : @"ORKHolePegTestPlaceStep",
                                                                             @"ORKHolePegTestRemoveStepViewController" : @"ORKHolePegTestRemoveStep",
                                                                             @"ORKImageCaptureStepViewController" : @"ORKImageCaptureStep",
                                                                             @"ORKPSATStepViewController" : @"ORKPSATStep",
                                                                             @"ORKQuestionStepViewController" : @"ORKQuestionStep",
                                                                             @"ORKSpatialSpanMemoryStepViewController" : @"ORKSpatialSpanMemoryStep",
                                                                             @"ORKTimedWalkStepViewController" : @"ORKTimedWalkStep",
                                                                             @"ORKTowerOfHanoiViewController" : @"ORKTowerOfHanoiStep",
                                                                             @"ORKVideoCaptureStepViewController" : @"ORKVideoCaptureStep",
                                                                             @"ORKVideoInstructionStepViewController" : @"ORKVideoInstructionStep",
                                                                             @"ORKVisualConsentStepViewController" : @"ORKVisualConsentStep",
                                                                             @"ORKWalkingTaskStepViewController" : @"ORKWalkingTaskStep",
                                                                             };
    
    NSDictionary <NSString *, NSDictionary *> *kvMapForStep = @{ // Steps that require modification to validate
                                                                   @"ORKHolePegTestPlaceStep" : @{@"numberOfPegs" : @2,
                                                                                                  @"stepDuration" : @2.0f },
                                                                   @"ORKHolePegTestRemoveStep" : @{@"numberOfPegs" : @2,
                                                                                                  @"stepDuration" : @2.0f },
                                                                   @"ORKPSATStep" : @{@"interStimulusInterval" : @1.0,
                                                                                      @"seriesLength" : @10,
                                                                                      @"stepDuration" : @11.0f,
                                                                                      @"presentationMode" : @(ORKPSATPresentationModeAuditory)},
                                                                   @"ORKSpatialSpanMemoryStep" : @{@"initialSpan" : @2,
                                                                                                   @"maximumSpan" : @5,
                                                                                                   @"playSpeed" : @1.0,
                                                                                                   @"maximumTests" : @3,
                                                                                                   @"maximumConsecutiveFailures" : @1},
                                                                   @"ORKTimedWalkStep" : @{@"distanceInMeters" : @30.0,
                                                                                           @"stepDuration" : @2.0},
                                                                   @"ORKWalkingTaskStep" : @{@"numberOfStepsPerLeg" : @2},
    };
    
    // Find all classes that subclass from ORKStepViewController
    NSMutableArray *stepViewControllerClassses = [NSMutableArray new];
    int numClasses = objc_getClassList(NULL, 0);
    Class classes[numClasses];
    numClasses = objc_getClassList(classes, numClasses);
    for (int index = 0; index < numClasses; index++) {
        Class aClass = classes[index];
        if ([excludedClassNames containsObject:NSStringFromClass(aClass)]) {
            continue;
        }
        
        if ([NSStringFromClass(aClass) hasPrefix:@"ORK"] &&
            [aClass isSubclassOfClass:[ORKStepViewController class]]) {
            
            [stepViewControllerClassses addObject:aClass];
        }
    }
    
    // Test Each class
    for (Class aClass in stepViewControllerClassses) {
        
        // Instatiate the step view controller
        NSString *stepClassName = mapStepClassForViewController[NSStringFromClass(aClass)];
        if (stepClassName == nil) {
            for (NSString *vcClassName in mapStepClassForViewController.allKeys) {
                if ([aClass isSubclassOfClass:NSClassFromString(vcClassName)]) {
                    stepClassName = mapStepClassForViewController[vcClassName];
                }
            }
        }
        Class stepClass = stepClassName ? NSClassFromString(stepClassName) : [ORKStep class];
        ORKStep *step = [self instanceForClass:stepClass];
        NSDictionary *kv = nil;
        if (stepClassName && (kv = kvMapForStep[stepClassName])) {
            [step setValuesForKeysWithDictionary:kv];
        }
        ORKStepViewController *stepViewController = [[aClass alloc] initWithStep:step];
        
        // Create a result
        ORKBooleanQuestionResult *result = [[ORKBooleanQuestionResult alloc] initWithIdentifier:@"test"];
        result.booleanAnswer = @YES;
        
        // -- Call method under test
        if ([exceptionClassNames containsObject:NSStringFromClass(aClass)]) {
            XCTAssertThrows([stepViewController addResult:result]);
            continue;
        } else {
            XCTAssertNoThrow([stepViewController addResult:result]);
        }
        
        ORKStepResult *stepResult = stepViewController.result;
        XCTAssertNotNil(stepResult, @"Step result is nil for %@", NSStringFromClass([stepViewController class]));
        XCTAssertTrue([stepResult isKindOfClass:[ORKStepResult class]], @"Step result is not subclass of ORKStepResult for %@", NSStringFromClass([stepViewController class]));
        if ([stepResult isKindOfClass:[ORKStepResult class]]) {
            XCTAssertNotNil(stepResult.results, @"Step result.results is nil for %@", NSStringFromClass([stepViewController class]));
            XCTAssertTrue([stepResult.results containsObject:result], @"Step result does not contain added result for %@", NSStringFromClass([stepViewController class]));
        }
    }
}

@end
