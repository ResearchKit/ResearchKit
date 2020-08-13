/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2018, Brian Ganninger.
 
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


@interface ORKJSONSerializationTests : XCTestCase <NSKeyedUnarchiverDelegate>

@end


@implementation ORKJSONSerializationTests

@end


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


@interface MockCountingDictionary : NSObject<NSMutableCopying, NSCopying>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)startObserving;

- (void)stopObserving;

- (NSArray *)untouchedKeys;

@property (nonatomic, strong) NSMutableSet *touchedKeys;

- (NSDictionary *)_containedDictionary;

@end


@implementation MockCountingDictionary {
    NSMutableDictionary *_d;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    _d = [dictionary mutableCopy];
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

- (NSArray *)untouchedKeys {
    NSMutableArray *untouchedKeys = [NSMutableArray new];
    NSArray *keys = [_d allKeys];
    for (NSString *key in keys) {
        if ([self.touchedKeys containsObject:key] == NO) {
            [untouchedKeys addObject:key];
        }
    }
    return [untouchedKeys copy];
}

- (id)objectForKey:(id)aKey {
    if (aKey && self.touchedKeys) {
        [self.touchedKeys addObject:aKey];
    }
    return [_d objectForKey:aKey];
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    [_d setObject:anObject forKey:aKey];
}

- (id)objectForKeyedSubscript:(id)key {
    if (key && self.touchedKeys) {
        [self.touchedKeys addObject:key];
    }
    return [_d objectForKeyedSubscript:key];
}

- (NSDictionary *)_containedDictionary {
    return [_d copy];
}

- (nonnull id)copyWithZone:(nullable NSZone *)__unused zone {
    // Return self rather than a copy
    return self;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)__unused zone {
    // Return self rather than a copy
    return self;
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

#define ORK_MAKE_TEST_INIT_ALT(class, block) \
@interface class (ORKTest_Alt) \
- (instancetype)orktest_init_alt; \
@end \
\
@implementation class (ORKTest_Alt) \
- (instancetype)orktest_init_alt { \
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
ORK_MAKE_TEST_INIT(ORKDontKnowAnswer, ^{return [ORKDontKnowAnswer answer];});
ORK_MAKE_TEST_INIT(ORKLoginStep, ^{return [self initWithIdentifier:[NSUUID UUID].UUIDString title:@"title" text:@"text" loginViewControllerClass:NSClassFromString(@"ORKLoginStepViewController") ];});
ORK_MAKE_TEST_INIT(ORKVerificationStep, ^{return [self initWithIdentifier:[NSUUID UUID].UUIDString text:@"text" verificationViewControllerClass:NSClassFromString(@"ORKVerificationStepViewController") ];});
ORK_MAKE_TEST_INIT(ORKStep, ^{return [self initWithIdentifier:[NSUUID UUID].UUIDString];});
ORK_MAKE_TEST_INIT(ORKReviewStep, ^{return [[self class] standaloneReviewStepWithIdentifier:[NSUUID UUID].UUIDString steps:@[] resultSource:[ORKTaskResult new]];});
ORK_MAKE_TEST_INIT(ORKOrderedTask, ^{return [self initWithIdentifier:@"test1" steps:nil];});
ORK_MAKE_TEST_INIT(ORKImageChoice, ^{return [super init];});
ORK_MAKE_TEST_INIT(ORKTextChoice, ^{return [super init];});
ORK_MAKE_TEST_INIT(ORKTextChoiceOther, ^{return [self initWithText:@"test" primaryTextAttributedString:nil detailText:@"test1" detailTextAttributedString:nil value:@"value" exclusive:YES textViewPlaceholderText:@"test2" textViewInputOptional:NO textViewStartsHidden:YES];});
ORK_MAKE_TEST_INIT(ORKPredicateStepNavigationRule, ^{return [self initWithResultPredicates:@[[ORKResultPredicate predicateForBooleanQuestionResultWithResultSelector:[ORKResultSelector selectorWithResultIdentifier:@"test"] expectedAnswer:YES]] destinationStepIdentifiers:@[@"test2"]];});
ORK_MAKE_TEST_INIT(ORKResultSelector, ^{return [self initWithResultIdentifier:@"resultIdentifier"];});
ORK_MAKE_TEST_INIT(ORKRecorderConfiguration, ^{return [self initWithIdentifier:@"testRecorder"];});
ORK_MAKE_TEST_INIT(ORKAccelerometerRecorderConfiguration, ^{return [super initWithIdentifier:@"testRecorder"];});
ORK_MAKE_TEST_INIT(ORKHealthQuantityTypeRecorderConfiguration, ^{ return [super initWithIdentifier:@"testRecorder"];});
ORK_MAKE_TEST_INIT(ORKAudioRecorderConfiguration, ^{ return [super initWithIdentifier:@"testRecorder"];});
ORK_MAKE_TEST_INIT(ORKDeviceMotionRecorderConfiguration, ^{ return [super initWithIdentifier:@"testRecorder"];});
ORK_MAKE_TEST_INIT(ORKHealthClinicalTypeRecorderConfiguration, ^{return [self initWithIdentifier:@"testRecorder" healthClinicalType:[HKClinicalType clinicalTypeForIdentifier:HKClinicalTypeIdentifierAllergyRecord] healthFHIRResourceType:nil];});
ORK_MAKE_TEST_INIT(CLCircularRegion, (^{
    return [self initWithCenter:CLLocationCoordinate2DMake(2.0, 3.0) radius:100.0 identifier:@"identifier"];
}));
ORK_MAKE_TEST_INIT_ALT(CLCircularRegion, (^{
    return [self initWithCenter:CLLocationCoordinate2DMake(3.0, 4.0) radius:150.0 identifier:@"identifier"];
}));
ORK_MAKE_TEST_INIT(ORKLocation, (^{
    CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
    postalAddress.city = @"cityA";
    postalAddress.street = @"street";
    ORKLocation *location = [self initWithCoordinate:CLLocationCoordinate2DMake(2.0, 3.0) region:[[CLCircularRegion alloc] orktest_init] userInput:@"addressStringA" postalAddress:postalAddress];
    return location;
}));
ORK_MAKE_TEST_INIT_ALT(ORKLocation, (^{
    CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
    postalAddress.city = @"cityB";
    postalAddress.street = @"street";
    ORKLocation *location = [self initWithCoordinate:CLLocationCoordinate2DMake(4.0, 5.0) region:[[CLCircularRegion alloc] orktest_init_alt] userInput:@"addressStringB" postalAddress:postalAddress];
    return location;
}));
ORK_MAKE_TEST_INIT(HKSampleType, (^{
    return [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
}));
ORK_MAKE_TEST_INIT(HKQuantityType, (^{
    return [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
}));
ORK_MAKE_TEST_INIT(HKCorrelationType, (^{
    return [HKCorrelationType correlationTypeForIdentifier:HKCorrelationTypeIdentifierBloodPressure];
}));
ORK_MAKE_TEST_INIT(HKCharacteristicType, (^{
    return [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType];
}));
ORK_MAKE_TEST_INIT(HKClinicalType, (^{
    return [HKClinicalType clinicalTypeForIdentifier:HKClinicalTypeIdentifierAllergyRecord];
}));
ORK_MAKE_TEST_INIT(NSNumber, (^{
    return [self initWithInt:123];
}));
ORK_MAKE_TEST_INIT(HKUnit, (^{
    return [HKUnit unitFromString:@"kg"];
}));
ORK_MAKE_TEST_INIT(NSURL, (^{
    return [self initFileURLWithPath:@"/usr"];
}));
ORK_MAKE_TEST_INIT(NSTimeZone, (^{
    return [NSTimeZone timeZoneForSecondsFromGMT:60*60];
}));
ORK_MAKE_TEST_INIT(NSCalendar, (^{
    return [self initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
}));
ORK_MAKE_TEST_INIT(NSRegularExpression, (^{
    return [self initWithPattern:@"." options:0 error:nil];
}));
ORK_MAKE_TEST_INIT(UIColor, (^{ return [self initWithRed:1 green:1 blue:1 alpha:1]; }));

@interface ORKJSONTestImageSerialization : NSObject<ORKESerializationImageProvider>

@property (nonatomic, readonly) NSDictionary *imageTable;
@property (nonatomic) BOOL generateImages;

- (void)reset;

@end

@implementation ORKJSONTestImageSerialization {
    NSMutableDictionary<NSString *, UIImage *> *_imageTable;
    NSMutableDictionary<NSValue *, NSString *> *_reverseImageTable;
}

- (id)init {
    self = [super init];
    if (self) {
        _imageTable = [[NSMutableDictionary alloc] init];
        _reverseImageTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSDictionary *)imageTable {
    return [_imageTable copy];
}

- (void)reset {
    [_imageTable removeAllObjects];
    [_reverseImageTable removeAllObjects];
}

- (UIImage *)imageForReference:(NSDictionary *)reference {
    NSString *s = reference[@"imageName"];
    if (_generateImages && ![_imageTable objectForKey:s]) {
        UIImage *image = [UIImage new];
        NSValue *imagePointer = [NSValue valueWithPointer:(const void *)image];
        _imageTable[s] = image;
        _reverseImageTable[imagePointer] = s;
    }
    return _imageTable[s];
}

- (nullable NSDictionary *)referenceBySavingImage:(UIImage *)image {
    NSValue *imagePointer = [NSValue valueWithPointer:(const void *)image];
    NSString *path = _reverseImageTable[imagePointer];
    if (path == nil) {
        path = [[NSUUID UUID] UUIDString];
    }
    _imageTable[path] = image;
    _reverseImageTable[imagePointer] = path;
    
    return @{@"imageName" : path};
}

@end

@interface ORKJSONSerializationTestConfiguration : NSObject
@property (nonatomic, readonly) NSArray<Class> *classesWithORKSerialization;
@property (nonatomic, readonly) NSArray<Class> *classesWithSecureCoding;
@property (nonatomic, readonly) NSArray<Class> *classesExcludedForORKESerialization;
@property (nonatomic, readonly) NSArray<NSString *> *propertyExclusionList;
@property (nonatomic, readonly) NSArray<NSString *> *knownNotSerializedProperties;
@property (nonatomic, readonly) NSArray<NSString *> *allowedUnTouchedKeys;

+ (NSArray<Class> *)_classesWithSecureCoding;

@end

@implementation ORKJSONSerializationTestConfiguration

- (id)init {
    self = [super init];
    if (self) {
        _classesWithORKSerialization = [ORKESerializer serializableClasses];
        _classesWithSecureCoding = [[self class] _classesWithSecureCoding];
        _classesExcludedForORKESerialization = @[
                                                 [ORKStepNavigationRule class],     // abstract base class
                                                 [ORKSkipStepNavigationRule class],     // abstract base class
                                                 [ORKStepModifier class],     // abstract base class
                                                 [ORKPredicateSkipStepNavigationRule class],     // NSPredicate doesn't yet support JSON serialization
                                                 [ORKKeyValueStepModifier class],     // NSPredicate doesn't yet support JSON serialization
                                                 [ORKCollector class], // ORKCollector doesn't support JSON serialization
                                                 [ORKHealthCollector class],
                                                 [ORKHealthCorrelationCollector class],
                                                 [ORKMotionActivityCollector class],
                                                 [ORKShoulderRangeOfMotionStep class],
                                                 [ORKTouchAbilityTouch class],
                                                 [ORKTouchAbilityTrack class],
                                                 [ORKTouchAbilityTrial class],
                                                 [ORKTouchAbilityTapStep class],
                                                 [ORKTouchAbilityTapTrial class],
                                                 [ORKTouchAbilityPinchStep class],
                                                 [ORKTouchAbilitySwipeStep class],
                                                 [ORKTouchAbilityTapResult class],
                                                 [ORKTouchAbilityPinchTrial class],
                                                 [ORKTouchAbilityLongPressTrial class],
                                                 [ORKTouchAbilityScrollTrial class],
                                                 [ORKTouchAbilityRotationTrial class],
                                                 [ORKTouchAbilitySwipeTrial class],
                                                 [ORKTouchAbilityGestureRecoginzerEvent class],
                                                 [ORKTouchAbilityRotationGestureRecoginzerEvent class],
                                                 [ORKTouchAbilityPinchGestureRecoginzerEvent class],
                                                 [ORKTouchAbilitySwipeGestureRecoginzerEvent class],
                                                 [ORKTouchAbilityPanGestureRecoginzerEvent class],
                                                 [ORKTouchAbilityLongPressGestureRecoginzerEvent class],
                                                 [ORKTouchAbilityTapGestureRecoginzerEvent class],
                                                 [ORKCustomStep class],
                                                 [ORKTouchAbilityRotationStep class],
                                                 [ORKTouchAbilityLongPressStep class],
                                                 [ORKTouchAbilityScrollStep class],
                                                 [ORKTouchAbilityPinchResult class],
                                                 [ORKTouchAbilityRotationResult class],
                                                 [ORKTouchAbilityLongPressResult class],
                                                 [ORKTouchAbilitySwipeResult class],
                                                 [ORKTouchAbilityScrollResult class]
                                                 ];
        
        _propertyExclusionList = @[
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
                                   @"textViewText",
                                   @"ORKConsentSection.image",
                                   @"ORKNavigablePageStep.steps",
                                   @"ORKPageStep.steps",
                                   @"ORKRegistrationStep.passcodeValidationRegex",
                                   @"ORKSpeechRecognitionResult.transcription",
                                   @"ORKTextAnswerFormat.validationRegex",
                                   ];
        
        _knownNotSerializedProperties = @[
                                          @"ORKActiveStep.image",
                                          @"ORKAmslerGridResult.image",
                                          @"ORKAnswerFormat.healthKitUnit",
                                          @"ORKAnswerFormat.healthKitUserUnit",
                                          @"ORKAnswerFormat.questionType",
                                          @"ORKBodyItem.image",
                                          @"ORKCollectionResult.firstResult",
                                          @"ORKConsentDocument.sectionFormatter", // created on demand
                                          @"ORKConsentDocument.sections",
                                          @"ORKConsentDocument.signatureFormatter", // created on demand
                                          @"ORKConsentDocument.signatures",
                                          @"ORKConsentDocument.writer", // created on demand
                                          @"ORKConsentSection.customImage",
                                          @"ORKConsentSection.escapedContent",
                                          @"ORKConsentSection.image",
                                          @"ORKConsentSignature.signatureImage",
                                          @"ORKContinuousScaleAnswerFormat.maximumImage",
                                          @"ORKContinuousScaleAnswerFormat.minimumImage",
                                          @"ORKContinuousScaleAnswerFormat.numberFormatter",
                                          @"ORKCustomStep.contentView",  // UIView is not able to be serialized
                                          @"ORKDataResult.data",
                                          @"ORKFormItem.step",  // weak ref - object will be nil
                                          @"ORKHealthClinicalTypeRecorderConfiguration.healthClinicalType",
                                          @"ORKHealthClinicalTypeRecorderConfiguration.healthFHIRResourceType",
                                          @"ORKHeightAnswerFormat.useMetricSystem",
                                          @"ORKImageCaptureStep.templateImage",
                                          @"ORKImageChoice.normalStateImage",
                                          @"ORKImageChoice.selectedStateImage",
                                          @"ORKImageChoice.value",
                                          @"ORKInstructionStep.attributedDetailText",
                                          @"ORKInstructionStep.auxiliaryImage",
                                          @"ORKInstructionStep.iconImage",
                                          @"ORKInstructionStep.image",
                                          @"ORKLoginStep.loginViewControllerClass",
                                          @"ORKNavigablePageStep.steps",
                                          @"ORKNumericAnswerFormat.defaultNumericAnswer",
                                          @"ORKOrderedTask.progressLabelColor",
                                          @"ORKOrderedTask.providesBackgroundAudioPrompts",
                                          @"ORKOrderedTask.requestedPermissions",
                                          @"ORKPageStep.steps",
                                          @"ORKQuestionResult.answer",
                                          @"ORKQuestionStep.question",
                                          @"ORKQuestionStep.questionType",
                                          @"ORKRegistrationStep.passcodeInvalidMessage",
                                          @"ORKRegistrationStep.passcodeRules",
                                          @"ORKRegistrationStep.passcodeValidationRegularExpression",
                                          @"ORKRegistrationStep.phoneNumberInvalidMessage",
                                          @"ORKRegistrationStep.phoneNumberValidationRegularExpression",
                                          @"ORKResult.saveable",
                                          @"ORKReviewStep.isStandalone",
                                          @"ORKScaleAnswerFormat.maximumImage",
                                          @"ORKScaleAnswerFormat.minimumImage",
                                          @"ORKScaleAnswerFormat.numberFormatter",
                                          @"ORKSignatureResult.signatureImage",
                                          @"ORKSignatureResult.signaturePath",
                                          @"ORKSpatialSpanMemoryStep.customTargetImage",
                                          @"ORKStep.allowsBackNavigation",
                                          @"ORKStep.auxiliaryImage",
                                          @"ORKStep.iconImage",
                                          @"ORKStep.image",
                                          @"ORKStep.requestedPermissions",
                                          @"ORKStep.restorable",
                                          @"ORKStep.showsProgress",
                                          @"ORKStep.task", // weak ref - object will be nil,
                                          @"ORKTableStep.bulletIconNames",
                                          @"ORKTextAnswerFormat.autocapitalizationType",
                                          @"ORKTextAnswerFormat.autocorrectionType",
                                          @"ORKTextAnswerFormat.maximumLength",
                                          @"ORKTextAnswerFormat.passwordRules",
                                          @"ORKTextAnswerFormat.spellCheckingType",
                                          @"ORKTextAnswerFormat.textContentType",
                                          @"ORKTextChoice.detailTextAttributedString",
                                          @"ORKTextChoice.primaryTextAttributedString",
                                          @"ORKTextChoice.value",
                                          @"ORKTimeIntervalAnswerFormat.defaultInterval",
                                          @"ORKTimeIntervalAnswerFormat.maximumInterval",
                                          @"ORKTimeIntervalAnswerFormat.step",
                                          @"ORKVerificationStep.verificationViewControllerClass",
                                          @"ORKVideoCaptureStep.templateImage",
                                          @"ORKWeightAnswerFormat.useMetricSystem",
                                          @"ORKWebViewStep.customViewProvider"
                                          ];
        _allowedUnTouchedKeys = @[@"_class"];
    }
    return self;
}

+ (NSArray<Class> *)_classesWithSecureCoding {
    NSArray *classesExcluded = @[]; // classes not intended to be serialized standalone
    NSMutableArray *stringsForClassesExcluded = [NSMutableArray array];
    for (Class c in classesExcluded) {
        [stringsForClassesExcluded addObject:NSStringFromClass(c)];
    }
    
    [stringsForClassesExcluded addObject:@"ORKFreehandDrawingGestureRecognizer"];
    [stringsForClassesExcluded addObject:@"ORKSignatureGestureRecognizer"];
    [stringsForClassesExcluded addObject:@"ORKTouchGestureRecognizer"];
    [stringsForClassesExcluded addObject:@"ORKHealthClinicalTypeRecorderConfiguration"];
    [stringsForClassesExcluded addObject:@"ORKUSDZModelManagerScene"];
    [stringsForClassesExcluded addObject:@"ORKBlurFooterView"];
    [stringsForClassesExcluded addObject:@"ORKFrontFacingCameraStepOptionsView"];
    
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

@end


@interface ORKJSONSerializationTests (Tests)

@end


@implementation ORKJSONSerializationTests  (Tests)

- (Class)unarchiver:(NSKeyedUnarchiver *) __unused unarchiver cannotDecodeObjectOfClassName:(NSString *)name originalClasses:(NSArray *)classNames {
    ORK_Log_Info("Cannot decode object with class: %@ (original classes: %@)", name, classNames);
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
    
    ORKQuestionStep *questionStep = [ORKQuestionStep questionStepWithIdentifier:@"id1" title:@"question" question:@"this is the question" answer:[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:@[[[ORKTextChoice alloc] initWithText:@"test1" detailText:nil value:@(1) exclusive:NO]  ]]];
    
    ORKQuestionStep *questionStep2 = [ORKQuestionStep questionStepWithIdentifier:@"id2" title:@"question" question:@"this is the question" answer:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:@"kg"]];
    
    ORKQuestionStep *questionStep3 = [ORKQuestionStep questionStepWithIdentifier:@"id3"  title:@"question" question:@"this is the question" answer:[ORKScaleAnswerFormat scaleAnswerFormatWithMaximumValue:10.0 minimumValue:1.0 defaultValue:5.0 step:1.0 vertical:YES maximumValueDescription:@"High value" minimumValueDescription:@"Low value"]];
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"id" steps:@[activeStep, questionStep, questionStep2, questionStep3]];
    
    NSDictionary *dict1 = [ORKESerializer JSONObjectForObject:task error:nil];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict1 options:NSJSONWritingPrettyPrinted error:nil];
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"json"]];
    [data writeToFile:tempPath atomically:YES];
    ORK_Log_Info("JSON file at %@", tempPath);
    
    ORKOrderedTask *task2 = [ORKESerializer objectFromJSONObject:dict1 error:nil];
    
    NSDictionary *dict2 = [ORKESerializer JSONObjectForObject:task2 error:nil];
    
    XCTAssertTrue([dict1 isEqualToDictionary:dict2], @"Should be equal");
    
}

/*
 Verify that all the known classes that can have dont know answers, serialize them as separate properties with
 the prefix noAnswer_
 */
- (void)testDontKnowSerialization {
    
    NSDictionary *examples = @{
        @"ORKBooleanQuestionResult" : @"booleanAnswer",
        @"ORKDateQuestionResult": @"dateAnswer",
        @"ORKNumericQuestionResult" : @"numericAnswer",
        @"ORKScaleQuestionResult" : @"scaleAnswer"
    };
    [examples enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull className, NSString *  _Nonnull answerProp, __unused BOOL * _Nonnull stop) {
        ORKQuestionResult *result = [(ORKQuestionResult *)[NSClassFromString(className) alloc] initWithIdentifier:[[NSUUID UUID] UUIDString]];
        [result setAnswer:[ORKDontKnowAnswer answer]];
        result.startDate = [NSDate date];
        result.endDate = [NSDate date];
        NSDictionary *dict = [ORKESerializer JSONObjectForObject:result error:nil];
        
        // Do not expect the property name for the answer to have a value
        XCTAssertNil([dict valueForKey:answerProp]);
        
        // Do expect the "dont know" version of the property name for the answer to have a value.
        XCTAssertEqualObjects(@"ORKDontKnowAnswer",
                              [[dict valueForKey:[@"noAnswer_" stringByAppendingString:answerProp]] valueForKey:@"_class"]);
        
    }];
}

- (void)_verifyDontKnowExampleFromPath:(NSString *)path
                    answerPropertyName:(NSString *)propertyName
                               context:(ORKESerializationContext *)context {

    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:NULL];
    id instance = [ORKESerializer objectFromJSONObject:dict context:context error:NULL];
    XCTAssertNotNil(instance);
    XCTAssertEqualObjects([instance valueForKey:propertyName], [ORKDontKnowAnswer answer]);
}

/*
 Verifies there is a sample for every JSON-serializable class.
 Verifies all registered properties for each of those classes is present in the sample.
 Verifies that all properties in the sample are registered.
 Attempts a decode of the sample, twice: once with image decoding enabled and once with images mapped to nil.
 Provides special handling for dont know answers, verifying that they deserialize as expected.
 */
- (void)testORKSampleDeserialization {
    NSString *bundlePath = [[NSBundle bundleForClass:[ORKJSONSerializationTests class]] pathForResource:@"samples" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSArray<NSString *> *paths = [bundle pathsForResourcesOfType:@"json" inDirectory:nil forLocalization:nil];
    
    ORKJSONTestImageSerialization *testImageSerialization = [[ORKJSONTestImageSerialization alloc] init];
    testImageSerialization.generateImages = YES;
    ORKESerializationContext *context = [[ORKESerializationContext alloc] initWithLocalizer:nil
                                                                              imageProvider:testImageSerialization
                                                                         stringInterpolator:nil
                                                                           propertyInjector:nil];
    
    ORKJSONSerializationTestConfiguration *testConfiguration = [[ORKJSONSerializationTestConfiguration alloc] init];
    
    NSArray *classesWithORKSerialization = testConfiguration.classesWithORKSerialization;
    
    for (Class c in classesWithORKSerialization) {
        XCTAssertNotNil([bundle pathForResource:NSStringFromClass(c) ofType:@"json"], @"Missing JSON serialization example for %@", NSStringFromClass(c));
    }
    
    // Decode where images are "decoded"
    for (NSString *path in paths) {
        
        if ([[path lastPathComponent] hasPrefix:@"DontKnow"]) {
            continue;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:NULL];
        NSString *className = [[path lastPathComponent] stringByDeletingPathExtension];
        NSMutableArray<NSString *> *knownProperties = [[ORKESerializer serializedPropertiesForClass:NSClassFromString(className)] mutableCopy];
        NSMutableArray<NSString *> *loadedProperties = [[dict allKeys] mutableCopy];
        [loadedProperties removeObject:@"_class"];
        NSSet *knownPropSet = [NSSet setWithArray:knownProperties];
        NSSet *loadedPropSet = [NSSet setWithArray:loadedProperties];
        NSMutableSet *intersectionSet = [knownPropSet mutableCopy]; [intersectionSet intersectSet:loadedPropSet];
        NSMutableSet *extraKnownProps = [knownPropSet mutableCopy]; [extraKnownProps minusSet:intersectionSet];
        NSMutableSet *extraLoadedProps = [loadedPropSet mutableCopy]; [extraLoadedProps minusSet:intersectionSet];
        XCTAssertEqualObjects(extraKnownProps, [NSSet set], @"Extra properties registered but not in example for %@", className);
        XCTAssertEqualObjects(extraLoadedProps, [NSSet set], @"Extra properties in sample but not registered for %@ on %@", className, path);
        id instance = [ORKESerializer objectFromJSONObject:dict context:context error:NULL];
        XCTAssertNotNil(instance);
        XCTAssertEqualObjects(NSStringFromClass([instance class]), className);
    }
    
    context.imageProvider = nil;
    
    // Decode with image decoding failing and returning nil instead of an image: silently suppress the failure
    for (NSString *path in paths) {
        if ([[path lastPathComponent] hasPrefix:@"DontKnow"]) {
            continue;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:NULL];
        NSString *className = [[path lastPathComponent] stringByDeletingPathExtension];
        id instance = [ORKESerializer objectFromJSONObject:dict context:context error:NULL];
        XCTAssertNotNil(instance);
        XCTAssertEqualObjects(NSStringFromClass([instance class]), className);
    }

    // Test the dont know examples
    NSDictionary *examples = @{
        @"DontKnowBooleanResult" : @"booleanAnswer",
        @"DontKnowDateResult": @"dateAnswer",
        @"DontKnowNumericResult" : @"numericAnswer",
        @"DontKnowScaleResult" : @"scaleAnswer"
    };
    [examples enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull propName, __unused BOOL * _Nonnull stop) {
        [self _verifyDontKnowExampleFromPath:[bundle pathForResource:key ofType:@"json"]
                          answerPropertyName:propName
                                     context:context];
    }];
    
    
    
}

#define GENERATE_SAMPLES 0

// JSON Serialization
- (void)testORKSerialization {
    ORKJSONTestImageSerialization *testImageSerialization = [[ORKJSONTestImageSerialization alloc] init];
    ORKESerializationContext *context = [[ORKESerializationContext alloc] initWithLocalizer:nil imageProvider:testImageSerialization stringInterpolator:nil propertyInjector:nil];
    
    ORKJSONSerializationTestConfiguration *testConfiguration = [[ORKJSONSerializationTestConfiguration alloc] init];
    // Find all classes that are serializable this way
    NSArray *classesWithORKSerialization = testConfiguration.classesWithORKSerialization;
    
    // All classes that conform to NSSecureCoding should also support ORKESerialization
    NSArray *classesWithSecureCoding = testConfiguration.classesWithSecureCoding;
    
    NSArray *classesExcludedForORKESerialization = testConfiguration.classesExcludedForORKESerialization;
    
    if ((classesExcludedForORKESerialization.count + classesWithORKSerialization.count) != classesWithSecureCoding.count) {
        NSMutableArray *unregisteredList = [classesWithSecureCoding mutableCopy];
        [unregisteredList removeObjectsInArray:classesWithORKSerialization];
        [unregisteredList removeObjectsInArray:classesExcludedForORKESerialization];
        XCTAssertEqual(unregisteredList.count, 0, @"Classes didn't implement ORKSerialization %@", unregisteredList);
    }
    
    // Predefined exception
    NSArray *propertyExclusionList = testConfiguration.propertyExclusionList;
    NSArray *knownNotSerializedProperties = testConfiguration.knownNotSerializedProperties;
    NSArray *allowedUnTouchedKeys = testConfiguration.allowedUnTouchedKeys;

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
            
            objc_property_t *objcProperties = class_copyPropertyList(currentClass, &count);
            for (uint i = 0; i < count; i++) {
                objc_property_t objcProperty = objcProperties[i];
                ClassProperty *classProperty = [[ClassProperty alloc] initWithObjcProperty:objcProperty];
                
                NSString *dottedPropertyName = [NSString stringWithFormat:@"%@.%@",
                                                NSStringFromClass(currentClass),
                                                classProperty.propertyName];
                NSString *dottedOriginalClassPropertyName = [NSString stringWithFormat:@"%@.%@",
                                                             NSStringFromClass(aClass),
                                                             classProperty.propertyName];
                if (![propertyExclusionList containsObject:classProperty.propertyName] &&
                    ![propertyExclusionList containsObject:dottedPropertyName] &&
                    ![propertyExclusionList containsObject:dottedOriginalClassPropertyName]) {
                    if (classProperty.isPrimitiveType == NO) {
                        // Assign value to object type property
                        if (classProperty.propertyClass == [NSObject class] &&
                            (aClass == [ORKTextChoice class] || aClass == [ORKImageChoice class]))
                        {
                            // Map NSObject to string, since it's used where either a string or a number is acceptable
                            [instance setValue:@"test" forKey:classProperty.propertyName];
                        } else {
                            id itemInstance = [self instanceForClass:classProperty.propertyClass];
                            [instance setValue:itemInstance forKey:classProperty.propertyName];
                        }
                    }
                    if ([classProperty.propertyName isEqualToString:@"steps"]) {
                        NSLog(@"steps");
                    }
                    [propertyNames addObject:classProperty.propertyName];
                    dottedPropertyNames[classProperty.propertyName] = dottedPropertyName;
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
        id mockDictionary = [[MockCountingDictionary alloc] initWithDictionary:[ORKESerializer JSONObjectForObject:instance context:context error:NULL]];
        
        // Must contain corrected _class field
        XCTAssertTrue([NSStringFromClass(aClass) isEqualToString:mockDictionary[@"_class"]]);
        
        // All properties should have matching fields in dictionary (allow predefined exceptions)
        for (NSString *propertyName in propertyNames) {
            if (mockDictionary[propertyName] == nil) {
                NSString *notSerializedProperty = dottedPropertyNames[propertyName];
                BOOL success = [knownNotSerializedProperties containsObject:notSerializedProperty];
                if (!success) {
                    XCTAssertTrue(success, "Unexpected notSerializedProperty = %@ (%@)", notSerializedProperty, NSStringFromClass(aClass));
                }
            }
        }
        
        [mockDictionary startObserving];
        
        id instance2 = [ORKESerializer objectFromJSONObject:mockDictionary context:context error:NULL];
        
        NSArray *untouchedKeys = [mockDictionary untouchedKeys];
        
        // Make sure all keys are touched by initializer
        for (NSString *key in untouchedKeys) {
            XCTAssertTrue([allowedUnTouchedKeys containsObject:key], @"untouched %@ in %@", key, aClass);
        }
        
        [mockDictionary stopObserving];
        
        // Serialize again, the output ought to be equal
        NSDictionary *dictionary2 = [ORKESerializer JSONObjectForObject:instance2 context:context error:NULL];
        BOOL isMatch = [mockDictionary isEqualToDictionary:dictionary2];
        if (!isMatch) {
            XCTAssertTrue(isMatch, @"Should be equal for class: %@", NSStringFromClass(aClass));
        }
        
#if GENERATE_SAMPLES
        [self writeDictionary:dictionary2 forClass:aClass];
#endif
        
        [testImageSerialization reset];
    }
    
}

- (void)writeDictionary:(NSDictionary *)dictionary forClass:(Class)aClass {
    NSURL *docsDir = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
    NSString *outputPath = [[docsDir path] stringByAppendingPathComponent:[NSStringFromClass(aClass) stringByAppendingString:@".json"]];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:NULL];
    [data writeToFile:outputPath atomically:YES];
    ORK_Log_Info("%@", outputPath);
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
        [instance setValue:(index ? [[ORKLocation alloc] orktest_init] : [[ORKLocation alloc] orktest_init_alt]) forKey:p.propertyName];
    } else if (p.propertyClass == [CLCircularRegion class]) {
        [instance setValue:index?[[CLCircularRegion alloc] orktest_init_alt]:[[CLCircularRegion alloc] orktest_init] forKey:p.propertyName];
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
    ORKJSONSerializationTestConfiguration *testConfiguration = [[ORKJSONSerializationTestConfiguration alloc] init];
    NSArray<Class> *classesWithSecureCoding = testConfiguration.classesWithSecureCoding;
    NSArray *propertyExclusionList = testConfiguration.propertyExclusionList;
    NSArray *knownNotSerializedProperties = testConfiguration.knownNotSerializedProperties;
    
    // Test Each class
    for (Class aClass in classesWithSecureCoding) {
        
        id instance = [self instanceForClass:aClass];
        
        // Find all properties of this class
        NSMutableArray *propertyNames = [NSMutableArray array];
        unsigned int count;
        objc_property_t *props = class_copyPropertyList(aClass, &count);
        for (uint i = 0; i < count; i++) {
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
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:instance requiringSecureCoding:YES error:nil];
        XCTAssertNotNil(data);
        
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil];
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
        if (aClass == [NSDateComponents class] ||
            aClass == [ORKDateQuestionResult class] ||
            aClass == [ORKDateAnswerFormat class] ||
            [aClass superclass] == [UIGestureRecognizer class]) {
            continue;
        }
        
        NSData *data2 = [NSKeyedArchiver archivedDataWithRootObject:newInstance requiringSecureCoding:YES error:nil];
        
        NSKeyedUnarchiver *unarchiver2 = [[NSKeyedUnarchiver alloc] initForReadingFromData:data2 error:nil];
        unarchiver2.requiresSecureCoding = YES;
        unarchiver2.delegate = self;
        id newInstance2 = [unarchiver2 decodeObjectOfClasses:decodingClasses forKey:NSKeyedArchiveRootObjectKey];
        NSData *data3 = [NSKeyedArchiver archivedDataWithRootObject:newInstance2 requiringSecureCoding:YES error:nil];
        
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
                                 [ORKVideoCaptureStep class],
                                 [ORKImageCaptureStep class]
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
                                       @"ORKWeightAnswerFormat.useMetricSystem",
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
                                       @"ORKQuestionStep.useCardView",
                                       @"ORKFormStep.useCardView",
                                       @"ORKSpeechRecognitionStep.shouldHideTranscript",
                                       @"ORKTableStep.isBulleted",
                                       @"ORKTableStep.allowsSelection",
                                       @"ORKPDFViewerStep.actionBarOption",
                                       ];
    
    NSArray *hashExclusionList = @[
                                   @"ORKDateQuestionResult.calendar",
                                   @"ORKDateQuestionResult.timeZone",
                                   @"ORKToneAudiometryResult.outputVolume",
                                   @"ORKToneAudiometryResult.channel",
                                   @"ORKConsentSection.contentURL",
                                   @"ORKConsentSection.customAnimationURL",
                                   @"ORKNumericAnswerFormat.minimum",
                                   @"ORKNumericAnswerFormat.maximum",
                                   @"ORKNumericAnswerFormat.maximumFractionDigits",
                                   @"ORKNumericAnswerFormat.defaultNumericAnswer",
                                   @"ORKVideoCaptureStep.duration",
                                   @"ORKTextAnswerFormat.validationRegularExpression",
                                   @"ORKPDFViewerStep.pdfURL"
                                   ];
    
    // Test Each class
    for (Class aClass in classesWithSecureCodingAndCopying) {
        id instance = [self instanceForClass:aClass];
        
        // Find all properties of this class
        NSMutableArray *propertyNames = [NSMutableArray array];
        unsigned int count;
        objc_property_t *props = class_copyPropertyList(aClass, &count);
        for (uint i = 0; i < count; i++) {
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
        
        for (uint i = 0; i < count; i++) {
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
                        XCTAssertNotEqual([instance hash], [copiedInstance hash], @"(%@, %@) %@", [instance valueForKey:p.propertyName], [copiedInstance valueForKey:p.propertyName], dottedPropertyName);
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
    NSData *d1 = [NSKeyedArchiver archivedDataWithRootObject:a requiringSecureCoding:YES error:nil];
    NSDateComponents *b = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSDateComponents class] fromData:d1 error:nil];
    NSData *d2 = [NSKeyedArchiver archivedDataWithRootObject:b requiringSecureCoding:YES error:nil];
    
    XCTAssertEqualObjects(d1, d2);
    XCTAssertEqualObjects(a, b);
}

- (void)testAddResult {
    
    // Classes for which tests are not currently implemented
    NSArray <NSString *> *excludedClassNames = @[
                                                 @"ORKVisualConsentStepViewController",     // Requires step with scenes
                                                 @"ORKImageCaptureStepViewController"
                                                 ];
    
    // Classes that do not allow adding a result should throw an exception
    NSArray <NSString *> *exceptionClassNames = @[
                                                  @"ORKPasscodeStepViewController",
                                                  ];
    
    NSDictionary <NSString *, NSString *> *mapStepClassForViewController = @{ // classes that require custom step class
                                                                             @"ORKActiveStepViewController" : @"ORKActiveStep",
                                                                             @"ORKCompletionStepViewController" : @"ORKCompletionStep",
                                                                             @"ORKConsentReviewStepViewController" : @"ORKConsentReviewStep",
                                                                             @"ORKFormStepViewController" : @"ORKFormStep",
                                                                             @"ORKHolePegTestPlaceStepViewController" : @"ORKHolePegTestPlaceStep",
                                                                             @"ORKHolePegTestRemoveStepViewController" : @"ORKHolePegTestRemoveStep",
                                                                             @"ORKImageCaptureStepViewController" : @"ORKImageCaptureStep",
                                                                             @"ORKPSATStepViewController" : @"ORKPSATStep",
                                                                             @"ORKQuestionStepViewController" : @"ORKQuestionStep",
                                                                             @"ORKSpatialSpanMemoryStepViewController" : @"ORKSpatialSpanMemoryStep",
                                                                             @"ORKStroopStepViewController" : @"ORKStroopStep",
                                                                             @"ORKTimedWalkStepViewController" : @"ORKTimedWalkStep",
                                                                             @"ORKTowerOfHanoiViewController" : @"ORKTowerOfHanoiStep",
                                                                             @"ORKVideoCaptureStepViewController" : @"ORKVideoCaptureStep",
                                                                             @"ORKVideoInstructionStepViewController" : @"ORKVideoInstructionStep",
                                                                             @"ORKVisualConsentStepViewController" : @"ORKVisualConsentStep",
                                                                             @"ORKWalkingTaskStepViewController" : @"ORKWalkingTaskStep",
                                                                             @"ORKTableStepViewController" : @"ORKTableStep",
                                                                             @"ORKdBHLToneAudiometryStepViewController" : @"ORKdBHLToneAudiometryStep",

                                                                             @"ORKSecondaryTaskStepViewController" : @"ORKSecondaryTaskStep",
                                                                             @"ORKHeadphoneDetectStepViewController" : @"ORKHeadphoneDetectStep",
                                                                             @"ORKWebViewStepViewController": @"ORKWebViewStep",
                                                                             
                                                                             @"ORKCustomStepViewController":@"ORKCustomStep",
                                                                             @"ORKRequestPermissionsStepViewController":@"ORKRequestPermissionsStep"
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
                                                                @"ORKStroopStep" : @{@"numberOfAttempts" : @15},
                                                                @"ORKTimedWalkStep" : @{@"distanceInMeters" : @30.0,
                                                                                        @"stepDuration" : @2.0},
                                                                @"ORKWalkingTaskStep" : @{@"numberOfStepsPerLeg" : @2},
                                                                @"ORKWebViewStep" : @{@"html": @""}
                                                                };
    
    // Find all classes that subclass from ORKStepViewController
    NSMutableArray *stepViewControllerClassses = [NSMutableArray new];
    int numClasses;
    Class * classes = NULL;
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    
    if (numClasses > 0 ) {
        classes = (Class *)realloc(classes, sizeof(Class) * (unsigned)numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        Class aClass = nil;
        for (int i = 0; i < numClasses; i++) {
            aClass = classes[i];
            
            if ([excludedClassNames containsObject:NSStringFromClass(aClass)]) {
                continue;
            }
            
            if ([NSStringFromClass(aClass) hasPrefix:@"ORK"] &&
                [aClass isSubclassOfClass:[ORKStepViewController class]]) {
                
                [stepViewControllerClassses addObject:aClass];
            }
        }
        
        free(classes);
    }
    
    // Test Each class
    for (Class aClass in stepViewControllerClassses) {
        
        // Instantiate the step view controller
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

- (void)testInvalidDBHLValue {
    // Non ORKInvalidDBHLValue-containing sample
    ORKdBHLToneAudiometryFrequencySample *sample = [[ORKdBHLToneAudiometryFrequencySample alloc] init];
    sample.channel = ORKAudioChannelLeft;
    sample.frequency = 1000;
    sample.calculatedThreshold = 0.5;
    
    NSDictionary *sampleDictionary = [ORKESerializer JSONObjectForObject:sample error:NULL];
    ORKdBHLToneAudiometryFrequencySample *deserializedSample = [ORKESerializer objectFromJSONObject:sampleDictionary error:NULL];
    
    XCTAssertEqualObjects(sample, deserializedSample);

    NSData *sampleData = [ORKESerializer JSONDataForObject:sample error:NULL];
    deserializedSample = [ORKESerializer objectFromJSONData:sampleData error:NULL];

    XCTAssertEqualObjects(sample, deserializedSample);

    // ORKInvalidDBHLValue-containing sample
    sample.calculatedThreshold = ORKInvalidDBHLValue;
    
    sampleDictionary = [ORKESerializer JSONObjectForObject:sample error:NULL];
    deserializedSample = [ORKESerializer objectFromJSONObject:sampleDictionary error:NULL];
    
    XCTAssertEqualObjects(sample, deserializedSample);

    sampleData = [ORKESerializer JSONDataForObject:sample error:NULL];
    deserializedSample = [ORKESerializer objectFromJSONData:sampleData error:NULL];

    XCTAssertEqualObjects(sample, deserializedSample);
}

- (void)testMissingDefaultValueKeyInScaleAnswerFormat {
    ORKESerializationContext *context = [[ORKESerializationContext alloc] initWithLocalizer:nil imageProvider:nil stringInterpolator:nil propertyInjector:nil];

    NSDictionary *payloadForContinuousScale = @{@"minimumValueDescription":@"",@"maximum":@100,@"_class":@"ORKContinuousScaleAnswerFormat",@"vertical":@NO,@"minimum":@0,@"maximumFractionDigits":@0,@"hideSelectedValue":@NO,@"hideRanges":@NO,@"hideLabels":@NO,@"numberStyle":@"percent",@"maximumValueDescription":@"",@"showDontKnowButton":@NO,@"customDontKnowButtonText":@""};

    ORKContinuousScaleAnswerFormat *continuousScaleAnswerFormat = (ORKContinuousScaleAnswerFormat *)[ORKESerializer objectFromJSONObject:payloadForContinuousScale context:context error:NULL];
    XCTAssertEqual(continuousScaleAnswerFormat.defaultValue, DBL_MAX);

    NSDictionary *payloadForScale = @{@"minimumValueDescription":@"",@"maximum":@100,@"_class":@"ORKScaleAnswerFormat",@"vertical":@NO,@"minimum":@0,@"hideSelectedValue":@NO,@"hideRanges":@NO,@"hideLabels":@NO,@"hideValueMarkers":@NO,@"step":@10,@"maximumValueDescription":@"",@"showDontKnowButton":@NO,@"customDontKnowButtonText":@""};
    ORKScaleAnswerFormat *scaleAnswerFormat = (ORKScaleAnswerFormat *)[ORKESerializer objectFromJSONObject:payloadForScale context:context error:NULL];
    XCTAssertEqual(scaleAnswerFormat.defaultValue, INT_MAX);
}

@end

