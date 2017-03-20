/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015-2016, Ricardo Sánchez-Sáez.

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


#import "ORKESerialization.h"

@import ResearchKit;
@import ResearchKit.Private;

@import MapKit;


static NSString *ORKEStringFromDateISO8601(NSDate *date) {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    return [formatter stringFromDate:date];
}

static NSDate *ORKEDateFromStringISO8601(NSString *string) {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    return [formatter dateFromString:string];
}

static NSArray *ORKNumericAnswerStyleTable() {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"decimal", @"integer"];
    });
    return table;
}

static id tableMapForward(NSInteger index, NSArray *table) {
    return table[index];
}

static NSInteger tableMapReverse(id value, NSArray *table) {
    NSUInteger idx = [table indexOfObject:value];
    if (idx == NSNotFound)
    {
        idx = 0;
    }
    return idx;
}

static NSDictionary *dictionaryFromCGPoint(CGPoint p) {
    return @{ @"x": @(p.x), @"y": @(p.y) };
}

static NSDictionary *dictionaryFromCGSize(CGSize s) {
    return @{ @"h": @(s.height), @"w": @(s.width) };
}

static NSDictionary *dictionaryFromCGRect(CGRect r) {
    return @{ @"origin": dictionaryFromCGPoint(r.origin), @"size": dictionaryFromCGSize(r.size) };
}

static NSDictionary *dictionaryFromUIEdgeInsets(UIEdgeInsets i) {
    return @{ @"top": @(i.top), @"left": @(i.left), @"bottom": @(i.bottom), @"right": @(i.right) };
}

static CGSize sizeFromDictionary(NSDictionary *dict) {
    return (CGSize){.width = ((NSNumber *)dict[@"w"]).doubleValue, .height = ((NSNumber *)dict[@"h"]).doubleValue };
}

static CGPoint pointFromDictionary(NSDictionary *dict) {
    return (CGPoint){.x = ((NSNumber *)dict[@"x"]).doubleValue, .y = ((NSNumber *)dict[@"y"]).doubleValue};
}

static CGRect rectFromDictionary(NSDictionary *dict) {
    return (CGRect){.origin = pointFromDictionary(dict[@"origin"]), .size = sizeFromDictionary(dict[@"size"])};
}

static UIEdgeInsets edgeInsetsFromDictionary(NSDictionary *dict) {
    return (UIEdgeInsets){.top = ((NSNumber *)dict[@"top"]).doubleValue, .left = ((NSNumber *)dict[@"left"]).doubleValue, .bottom = ((NSNumber *)dict[@"bottom"]).doubleValue, .right = ((NSNumber *)dict[@"right"]).doubleValue};
}

static NSDictionary *dictionaryFromCoordinate (CLLocationCoordinate2D coordinate) {
    return @{ @"latitude": @(coordinate.latitude), @"longitude": @(coordinate.longitude) };
}

static CLLocationCoordinate2D coordinateFromDictionary(NSDictionary *dict) {
    return (CLLocationCoordinate2D){.latitude = ((NSNumber *)dict[@"latitude"]).doubleValue, .longitude = ((NSNumber *)dict[@"longitude"]).doubleValue };
}

static ORKNumericAnswerStyle ORKNumericAnswerStyleFromString(NSString *s) {
    return tableMapReverse(s, ORKNumericAnswerStyleTable());
}

static NSString *ORKNumericAnswerStyleToString(ORKNumericAnswerStyle style) {
    return tableMapForward(style, ORKNumericAnswerStyleTable());
}

static NSDictionary *dictionaryFromCircularRegion(CLCircularRegion *region) {
    NSDictionary *dictionary = region ?
    @{
      @"coordinate": dictionaryFromCoordinate(region.center),
      @"radius": @(region.radius),
      @"identifier": region.identifier
      } :
    @{};
    return dictionary;
}

static CLCircularRegion *circularRegionFromDictionary(NSDictionary *dict) {
    CLCircularRegion *circularRegion;
    if (dict.count == 3) {
        circularRegion = [[CLCircularRegion alloc] initWithCenter:coordinateFromDictionary(dict[@"coordinate"])
                                                           radius:((NSNumber *)dict[@"radius"]).doubleValue
                                                       identifier:dict[@"identifier"]];
    }
    return circularRegion;
}

static NSArray *arrayFromRegularExpressionOptions(NSRegularExpressionOptions regularExpressionOptions) {
    NSMutableArray *optionsArray = [NSMutableArray new];
    if (regularExpressionOptions & NSRegularExpressionCaseInsensitive) {
        [optionsArray addObject:@"NSRegularExpressionCaseInsensitive"];
    }
    if (regularExpressionOptions & NSRegularExpressionAllowCommentsAndWhitespace) {
        [optionsArray addObject:@"NSRegularExpressionAllowCommentsAndWhitespace"];
    }
    if (regularExpressionOptions & NSRegularExpressionIgnoreMetacharacters) {
        [optionsArray addObject:@"NSRegularExpressionIgnoreMetacharacters"];
    }
    if (regularExpressionOptions & NSRegularExpressionDotMatchesLineSeparators) {
        [optionsArray addObject:@"NSRegularExpressionDotMatchesLineSeparators"];
    }
    if (regularExpressionOptions & NSRegularExpressionAnchorsMatchLines) {
        [optionsArray addObject:@"NSRegularExpressionAnchorsMatchLines"];
    }
    if (regularExpressionOptions & NSRegularExpressionUseUnixLineSeparators) {
        [optionsArray addObject:@"NSRegularExpressionUseUnixLineSeparators"];
    }
    if (regularExpressionOptions & NSRegularExpressionUseUnicodeWordBoundaries) {
        [optionsArray addObject:@"NSRegularExpressionUseUnicodeWordBoundaries"];
    }
    return [optionsArray copy];
}

static NSRegularExpressionOptions regularExpressionOptionsFromArray(NSArray *array) {
    NSRegularExpressionOptions regularExpressionOptions = 0;
    for (NSString *optionString in array) {
        if ([optionString isEqualToString:@"NSRegularExpressionCaseInsensitive"]) {
            regularExpressionOptions |= NSRegularExpressionCaseInsensitive;
        }
        else if ([optionString isEqualToString:@"NSRegularExpressionAllowCommentsAndWhitespace"]) {
            regularExpressionOptions |= NSRegularExpressionAllowCommentsAndWhitespace;
        }
        else if ([optionString isEqualToString:@"NSRegularExpressionIgnoreMetacharacters"]) {
            regularExpressionOptions |= NSRegularExpressionIgnoreMetacharacters;
        }
        else if ([optionString isEqualToString:@"NSRegularExpressionDotMatchesLineSeparators"]) {
            regularExpressionOptions |= NSRegularExpressionDotMatchesLineSeparators;
        }
        else if ([optionString isEqualToString:@"NSRegularExpressionAnchorsMatchLines"]) {
            regularExpressionOptions |= NSRegularExpressionAnchorsMatchLines;
        }
        else if ([optionString isEqualToString:@"NSRegularExpressionUseUnixLineSeparators"]) {
            regularExpressionOptions |= NSRegularExpressionUseUnixLineSeparators;
        }
        else if ([optionString isEqualToString:@"NSRegularExpressionUseUnicodeWordBoundaries"]) {
            regularExpressionOptions |= NSRegularExpressionUseUnicodeWordBoundaries;
        }
    }
    return regularExpressionOptions;
}

static NSDictionary *dictionaryFromRegularExpression(NSRegularExpression *regularExpression) {
    NSDictionary *dictionary = regularExpression ?
    @{
      @"pattern": regularExpression.pattern ?: @"",
      @"options": arrayFromRegularExpressionOptions(regularExpression.options)
      } :
    @{};
    return dictionary;
}

static NSRegularExpression *regularExpressionsFromDictionary(NSDictionary *dict) {
    NSRegularExpression *regularExpression;
    if (dict.count == 2) {
        regularExpression = [NSRegularExpression regularExpressionWithPattern:dict[@"pattern"]
                                                  options:regularExpressionOptionsFromArray(dict[@"options"])
                                                    error:nil];
    }
    return regularExpression;
}

static NSMutableDictionary *ORKESerializationEncodingTable();
static id propFromDict(NSDictionary *dict, NSString *propName);
static NSArray *classEncodingsForClass(Class c) ;
static id objectForJsonObject(id input, Class expectedClass, ORKESerializationJSONToObjectBlock converterBlock) ;

#define ESTRINGIFY2( x) #x
#define ESTRINGIFY(x) ESTRINGIFY2(x)

#define ENTRY(entryName, bb, props) @ESTRINGIFY(entryName) : [[ORKESerializableTableEntry alloc] initWithClass:[entryName class] initBlock:bb properties: props]

#define PROPERTY(x, vc, cc, ww, jb, ob) @ESTRINGIFY(x) : ([[ORKESerializableProperty alloc] initWithPropertyName:@ESTRINGIFY(x) valueClass:[vc class] containerClass:[cc class] writeAfterInit:ww objectToJSONBlock:jb jsonToObjectBlock:ob ])


#define DYNAMICCAST(x, c) ((c *) ([x isKindOfClass:[c class]] ? x : nil))


@interface ORKESerializableTableEntry : NSObject

- (instancetype)initWithClass:(Class)class
                    initBlock:(ORKESerializationInitBlock)initBlock
                   properties:(NSDictionary *)properties;

@property (nonatomic) Class class;
@property (nonatomic, copy) ORKESerializationInitBlock initBlock;
@property (nonatomic, strong) NSMutableDictionary *properties;

@end


@interface ORKESerializableProperty : NSObject

- (instancetype)initWithPropertyName:(NSString *)propertyName
                          valueClass:(Class)valueClass
                      containerClass:(Class)containerClass
                      writeAfterInit:(BOOL)writeAfterInit
                   objectToJSONBlock:(ORKESerializationObjectToJSONBlock)objectToJSON
                   jsonToObjectBlock:(ORKESerializationJSONToObjectBlock)jsonToObjectBlock;

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic) Class valueClass;
@property (nonatomic) Class containerClass;
@property (nonatomic) BOOL writeAfterInit;
@property (nonatomic, copy) ORKESerializationObjectToJSONBlock objectToJSONBlock;
@property (nonatomic, copy) ORKESerializationJSONToObjectBlock jsonToObjectBlock;

@end


@implementation ORKESerializableTableEntry

- (instancetype)initWithClass:(Class)class
                    initBlock:(ORKESerializationInitBlock)initBlock
                   properties:(NSDictionary *)properties {
    self = [super init];
    if (self) {
        _class = class;
        self.initBlock = initBlock;
        self.properties = [properties mutableCopy];
    }
    return self;
}

@end


@implementation ORKESerializableProperty

- (instancetype)initWithPropertyName:(NSString *)propertyName
                          valueClass:(Class)valueClass
                      containerClass:(Class)containerClass
                      writeAfterInit:(BOOL)writeAfterInit
                   objectToJSONBlock:(ORKESerializationObjectToJSONBlock)objectToJSON
                   jsonToObjectBlock:(ORKESerializationJSONToObjectBlock)jsonToObjectBlock {
    self = [super init];
    if (self) {
        self.propertyName = propertyName;
        self.valueClass = valueClass;
        self.containerClass = containerClass;
        self.writeAfterInit = writeAfterInit;
        self.objectToJSONBlock = objectToJSON;
        self.jsonToObjectBlock = jsonToObjectBlock;
    }
    return self;
}

@end


static NSString *_ClassKey = @"_class";

static id propFromDict(NSDictionary *dict, NSString *propName) {
    NSArray *classEncodings = classEncodingsForClass(NSClassFromString(dict[_ClassKey]));
    ORKESerializableProperty *propertyEntry = nil;
    for (ORKESerializableTableEntry *classEncoding in classEncodings) {
        
        NSDictionary *propertyEncoding = classEncoding.properties;
        propertyEntry = propertyEncoding[propName];
        if (propertyEntry != nil) {
            break;
        }
    }
    NSCAssert(propertyEntry != nil, @"Unexpected property %@ for class %@", propName, dict[_ClassKey]);
    
    Class containerClass = propertyEntry.containerClass;
    Class propertyClass = propertyEntry.valueClass;
    ORKESerializationJSONToObjectBlock converterBlock = propertyEntry.jsonToObjectBlock;
    
    id input = dict[propName];
    id output = nil;
    if (input != nil) {
        if ([containerClass isSubclassOfClass:[NSArray class]]) {
            NSMutableArray *outputArray = [NSMutableArray array];
            for (id value in DYNAMICCAST(input, NSArray)) {
                id convertedValue = objectForJsonObject(value, propertyClass, converterBlock);
                NSCAssert(convertedValue != nil, @"Could not convert to object of class %@", propertyClass);
                [outputArray addObject:convertedValue];
            }
            output = outputArray;
        } else if ([containerClass isSubclassOfClass:[NSDictionary class]]) {
            NSMutableDictionary *outputDictionary = [NSMutableDictionary dictionary];
            for (NSString *key in [DYNAMICCAST(input, NSDictionary) allKeys]) {
                id convertedValue = objectForJsonObject(DYNAMICCAST(input, NSDictionary)[key], propertyClass, converterBlock);
                NSCAssert(convertedValue != nil, @"Could not convert to object of class %@", propertyClass);
                outputDictionary[key] = convertedValue;
            }
            output = outputDictionary;
        } else {
            NSCAssert(containerClass == [NSObject class], @"Unexpected container class %@", containerClass);
            
            output = objectForJsonObject(input, propertyClass, converterBlock);
        }
    }
    return output;
}


#define NUMTOSTRINGBLOCK(table) ^id(id num) { return table[((NSNumber *)num).integerValue]; }
#define STRINGTONUMBLOCK(table) ^id(id string) { NSUInteger index = [table indexOfObject:string]; \
    NSCAssert(index != NSNotFound, @"Expected valid entry from table %@", table); \
    return @(index); \
}

@implementation ORKESerializer

static NSArray *ORKChoiceAnswerStyleTable() {
    static NSArray *table;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"singleChoice", @"multipleChoice"];
    });
    
    return table;
}

static NSArray *ORKDateAnswerStyleTable() {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"dateTime", @"date"];
    });
    return table;
}

static NSArray *buttonIdentifierTable() {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"none", @"left", @"right"];
    });
    return table;
}

static NSArray *memoryGameStatusTable() {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"unknown", @"success", @"failure", @"timeout"];
    });
    return table;
}

static NSArray *numberFormattingStyleTable() {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"default", @"percent"];
    });
    return table;
}

#define GETPROP(d,x) getter(d, @ESTRINGIFY(x))
static NSMutableDictionary *ORKESerializationEncodingTable() {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *encondingTable = nil;
    dispatch_once(&onceToken, ^{
encondingTable =
[@{
   ENTRY(ORKResultSelector,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             ORKResultSelector *selector = [[ORKResultSelector alloc] initWithTaskIdentifier:GETPROP(dict, taskIdentifier)
                                                                          stepIdentifier:GETPROP(dict, stepIdentifier)
                                                                        resultIdentifier:GETPROP(dict, resultIdentifier)];
             return selector;
         },(@{
            PROPERTY(taskIdentifier, NSString, NSObject, YES, nil, nil),
            PROPERTY(stepIdentifier, NSString, NSObject, YES, nil, nil),
            PROPERTY(resultIdentifier, NSString, NSObject, YES, nil, nil),
            })),
   ENTRY(ORKPredicateStepNavigationRule,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             ORKPredicateStepNavigationRule *rule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:GETPROP(dict, resultPredicates)
                                                                                          destinationStepIdentifiers:GETPROP(dict, destinationStepIdentifiers)
                                                                                               defaultStepIdentifier:GETPROP(dict, defaultStepIdentifier)
                                                                                                      validateArrays:NO];
             return rule;
         },(@{
              PROPERTY(resultPredicates, NSPredicate, NSArray, NO, nil, nil),
              PROPERTY(destinationStepIdentifiers, NSString, NSArray, NO, nil, nil),
              PROPERTY(defaultStepIdentifier, NSString, NSObject, NO, nil, nil),
              PROPERTY(additionalTaskResults, ORKTaskResult, NSArray, YES, nil, nil)
              })),
   ENTRY(ORKDirectStepNavigationRule,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             ORKDirectStepNavigationRule *rule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:GETPROP(dict, destinationStepIdentifier)];
             return rule;
         },(@{
              PROPERTY(destinationStepIdentifier, NSString, NSObject, NO, nil, nil),
              })),
   ENTRY(ORKAudioLevelNavigationRule,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             ORKAudioLevelNavigationRule *rule = [[ORKAudioLevelNavigationRule alloc] initWithAudioLevelStepIdentifier:GETPROP(dict, audioLevelStepIdentifier)                                                                                             destinationStepIdentifier:GETPROP(dict, destinationStepIdentifier)
                                                                                                     recordingSettings:GETPROP(dict, recordingSettings)];
             return rule;
         },(@{
              PROPERTY(audioLevelStepIdentifier, NSString, NSObject, NO, nil, nil),
              PROPERTY(destinationStepIdentifier, NSString, NSObject, NO, nil, nil),
              PROPERTY(recordingSettings, NSDictionary, NSObject, NO, nil, nil),
              })),
   ENTRY(ORKOrderedTask,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                                         steps:GETPROP(dict, steps)];
             return task;
         },(@{
              PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
              PROPERTY(steps, ORKStep, NSArray, NO, nil, nil)
              })),
   ENTRY(ORKNavigableOrderedTask,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                                                           steps:GETPROP(dict, steps)];
             return task;
         },(@{
              PROPERTY(stepNavigationRules, ORKStepNavigationRule, NSMutableDictionary, YES, nil, nil),
              PROPERTY(skipStepNavigationRules, ORKSkipStepNavigationRule, NSMutableDictionary, YES, nil, nil),
              PROPERTY(stepModifiers, ORKStepModifier, NSMutableDictionary, YES, nil, nil),
              PROPERTY(shouldReportProgress, NSNumber, NSObject, YES, nil, nil),
              })),
   ENTRY(ORKStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             ORKStep *step = [[ORKStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
             return step;
         },
         (@{
            PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
            PROPERTY(optional, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(title, NSString, NSObject, YES, nil, nil),
            PROPERTY(text, NSString, NSObject, YES, nil, nil),
            PROPERTY(shouldTintImages, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(useSurveyMode, NSNumber, NSObject, YES, nil, nil)
            })),
   ENTRY(ORKReviewStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             ORKReviewStep *reviewStep = [ORKReviewStep standaloneReviewStepWithIdentifier:GETPROP(dict, identifier)
                                                                                     steps:GETPROP(dict, steps)
                                                                              resultSource:GETPROP(dict, resultSource)];
             return reviewStep;
         },
         (@{
            PROPERTY(steps, ORKStep, NSArray, NO, nil, nil),
            PROPERTY(resultSource, ORKTaskResult, NSObject, NO, nil, nil),
            PROPERTY(excludeInstructionSteps, NSNumber, NSObject, YES, nil, nil)
            })),
   ENTRY(ORKVisualConsentStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKVisualConsentStep alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                            document:GETPROP(dict, consentDocument)];
         },
         @{
           PROPERTY(consentDocument, ORKConsentDocument, NSObject, NO, nil, nil)
           }),
   ENTRY(ORKPasscodeStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKPasscodeStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
           PROPERTY(passcodeType, NSNumber, NSObject, YES, nil, nil),
           PROPERTY(passcodeFlow, NSNumber, NSObject, YES, nil, nil)
           })),
   ENTRY(ORKWaitStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKWaitStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
           PROPERTY(indicatorType, NSNumber, NSObject, YES, nil, nil)
           })),
   ENTRY(ORKRecorderConfiguration,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             ORKRecorderConfiguration *recorderConfiguration = [[ORKRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier)];
             return recorderConfiguration;
         },
         (@{
            PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
            })),
   ENTRY(ORKQuestionStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKQuestionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(answerFormat, ORKAnswerFormat, NSObject, YES, nil, nil),
            PROPERTY(placeholder, NSString, NSObject, YES, nil, nil)
            })),
   ENTRY(ORKInstructionStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKInstructionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(detailText, NSString, NSObject, YES, nil, nil),
            PROPERTY(footnote, NSString, NSObject, YES, nil, nil),
            })),
   ENTRY(ORKVideoInstructionStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKVideoInstructionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(videoURL, NSURL, NSObject, YES,
                     ^id(id url) { return [(NSURL *)url absoluteString]; },
                     ^id(id string) { return [NSURL URLWithString:string]; }),
            PROPERTY(thumbnailTime, NSNumber, NSObject, YES, nil, nil),
            })),
   ENTRY(ORKCompletionStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKCompletionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            })),
   ENTRY(ORKCountdownStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKCountdownStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            })),
   ENTRY(ORKTouchAnywhereStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKTouchAnywhereStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            })),
   ENTRY(ORKHealthQuantityTypeRecorderConfiguration,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKHealthQuantityTypeRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier) healthQuantityType:GETPROP(dict, quantityType) unit:GETPROP(dict, unit)];
         },
         (@{
            PROPERTY(quantityType, HKQuantityType, NSObject, NO,
                     ^id(id type) { return [(HKQuantityType *)type identifier]; },
                     ^id(id string) { return [HKQuantityType quantityTypeForIdentifier:string]; }),
            PROPERTY(unit, HKUnit, NSObject, NO,
                     ^id(id unit) { return [(HKUnit *)unit unitString]; },
                     ^id(id string) { return [HKUnit unitFromString:string]; }),
            })),
   ENTRY(ORKActiveStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKActiveStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(stepDuration, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(shouldShowDefaultTimer, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(shouldSpeakCountDown, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(shouldSpeakRemainingTimeAtHalfway, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(shouldStartTimerAutomatically, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(shouldPlaySoundOnStart, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(shouldPlaySoundOnFinish, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(shouldVibrateOnStart, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(shouldVibrateOnFinish, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(shouldUseNextAsSkipButton, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(shouldContinueOnFinish, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(spokenInstruction, NSString, NSObject, YES, nil, nil),
            PROPERTY(finishedSpokenInstruction, NSString, NSObject, YES, nil, nil),
            PROPERTY(recorderConfigurations, ORKRecorderConfiguration, NSArray, YES, nil, nil),
            })),
   ENTRY(ORKAudioStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKAudioStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            })),
  ENTRY(ORKToneAudiometryStep,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKToneAudiometryStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
        },
        (@{
           PROPERTY(toneDuration, NSNumber, NSObject, YES, nil, nil),
           })),
   ENTRY(ORKToneAudiometryPracticeStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKToneAudiometryPracticeStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{})),
   ENTRY(ORKHolePegTestPlaceStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKHolePegTestPlaceStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(movingDirection, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(dominantHandTested, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(numberOfPegs, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(threshold, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(rotated, NSNumber, NSObject, YES, nil, nil)
            })),
   ENTRY(ORKHolePegTestRemoveStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKHolePegTestRemoveStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(movingDirection, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(dominantHandTested, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(numberOfPegs, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(threshold, NSNumber, NSObject, YES, nil, nil)
            })),
   ENTRY(ORKImageCaptureStep,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKImageCaptureStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
        },
        (@{
            PROPERTY(templateImageInsets, NSValue, NSObject, YES,
                ^id(id value) { return value?dictionaryFromUIEdgeInsets(((NSValue *)value).UIEdgeInsetsValue):nil; },
                ^id(id dict) { return [NSValue valueWithUIEdgeInsets:edgeInsetsFromDictionary(dict)]; }),
            PROPERTY(accessibilityHint, NSString, NSObject, YES, nil, nil),
            PROPERTY(accessibilityInstructions, NSString, NSObject, YES, nil, nil),
            })),
   ENTRY(ORKVideoCaptureStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKVideoCaptureStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(templateImageInsets, NSValue, NSObject, YES,
                     ^id(id value) { return value?dictionaryFromUIEdgeInsets(((NSValue *)value).UIEdgeInsetsValue):nil; },
                     ^id(id dict) { return [NSValue valueWithUIEdgeInsets:edgeInsetsFromDictionary(dict)]; }),
            PROPERTY(duration, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(audioMute, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(flashMode, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(devicePosition, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(accessibilityHint, NSString, NSObject, YES, nil, nil),
            PROPERTY(accessibilityInstructions, NSString, NSObject, YES, nil, nil),
            })),
  ENTRY(ORKSignatureStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKSignatureStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            })),
  ENTRY(ORKSpatialSpanMemoryStep,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKSpatialSpanMemoryStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
        },
        (@{
          PROPERTY(initialSpan, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(minimumSpan, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(maximumSpan, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(playSpeed, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(maximumTests, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(maximumConsecutiveFailures, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(requireReversal, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(customTargetPluralName, NSString, NSObject, YES, nil, nil),
          })),
  ENTRY(ORKWalkingTaskStep,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKWalkingTaskStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
        },
        (@{
          PROPERTY(numberOfStepsPerLeg, NSNumber, NSObject, YES, nil, nil),
          })),
   ENTRY(ORKTableStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKTableStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(items, NSObject, NSArray, YES, nil, nil),
            })),
   ENTRY(ORKTimedWalkStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKTimedWalkStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(distanceInMeters, NSNumber, NSObject, YES, nil, nil),
            })),
   ENTRY(ORKPSATStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKPSATStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(presentationMode, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(interStimulusInterval, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(stimulusDuration, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(seriesLength, NSNumber, NSObject, YES, nil, nil),
            })),
   ENTRY(ORKRangeOfMotionStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKRangeOfMotionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(limbOption, NSNumber, NSObject, YES, nil, nil),
            })),
   ENTRY(ORKShoulderRangeOfMotionStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKShoulderRangeOfMotionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(limbOption, NSNumber, NSObject, YES, nil, nil),
            })),
   ENTRY(ORKReactionTimeStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKReactionTimeStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(maximumStimulusInterval, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(minimumStimulusInterval, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(timeout, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(numberOfAttempts, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(thresholdAcceleration, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(successSound, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(timeoutSound, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(failureSound, NSNumber, NSObject, YES, nil, nil),
            })),
   ENTRY(ORKTappingIntervalStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKTappingIntervalStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            })),
   ENTRY(ORKTrailmakingStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKTrailmakingStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(trailType, NSString, NSObject, YES, nil, nil),
            })),
   ENTRY(ORKTowerOfHanoiStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKTowerOfHanoiStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
         },
         (@{
            PROPERTY(numberOfDisks, NSNumber, NSObject, YES, nil, nil),
            })),
  ENTRY(ORKAccelerometerRecorderConfiguration,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier) frequency:((NSNumber *)GETPROP(dict, frequency)).doubleValue];
        },
        (@{
          PROPERTY(frequency, NSNumber, NSObject, NO, nil, nil),
          })),
  ENTRY(ORKAudioRecorderConfiguration,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKAudioRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier) recorderSettings:GETPROP(dict, recorderSettings)];
        },
        (@{
          PROPERTY(recorderSettings, NSDictionary, NSObject, NO, nil, nil),
          })),
  ENTRY(ORKConsentDocument,
        nil,
        (@{
          PROPERTY(title, NSString, NSObject, NO, nil, nil),
          PROPERTY(sections, ORKConsentSection, NSArray, NO, nil, nil),
          PROPERTY(signaturePageTitle, NSString, NSObject, NO, nil, nil),
          PROPERTY(signaturePageContent, NSString, NSObject, NO, nil, nil),
          PROPERTY(signatures, ORKConsentSignature, NSArray, NO, nil, nil),
          PROPERTY(htmlReviewContent, NSString, NSObject, NO, nil, nil),
          })),
  ENTRY(ORKConsentSharingStep,
        ^(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKConsentSharingStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
        },
        (@{
           PROPERTY(localizedLearnMoreHTMLContent, NSString, NSObject, YES, nil, nil),
           })),
  ENTRY(ORKConsentReviewStep,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKConsentReviewStep alloc] initWithIdentifier:GETPROP(dict, identifier) signature:GETPROP(dict, signature) inDocument:GETPROP(dict,consentDocument)];
        },
        (@{
          PROPERTY(consentDocument, ORKConsentDocument, NSObject, NO, nil, nil),
          PROPERTY(reasonForConsent, NSString, NSObject, YES, nil, nil),
          PROPERTY(signature, ORKConsentSignature, NSObject, NO, nil, nil),
          })),
  ENTRY(ORKFitnessStep,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKFitnessStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
        },
        (@{
           })),
  ENTRY(ORKConsentSection,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKConsentSection alloc] initWithType:((NSNumber *)GETPROP(dict, type)).integerValue];
        },
        (@{
          PROPERTY(type, NSNumber, NSObject, NO, nil, nil),
          PROPERTY(title, NSString, NSObject, YES, nil, nil),
          PROPERTY(formalTitle, NSString, NSObject, YES, nil, nil),
          PROPERTY(summary, NSString, NSObject, YES, nil, nil),
          PROPERTY(content, NSString, NSObject, YES, nil, nil),
          PROPERTY(htmlContent, NSString, NSObject, YES, nil, nil),
          PROPERTY(contentURL, NSURL, NSObject, YES,
                   ^id(id url) { return [(NSURL *)url absoluteString]; },
                   ^id(id string) { return [NSURL URLWithString:string]; }),
          PROPERTY(customLearnMoreButtonTitle, NSString, NSObject, YES, nil, nil),
          PROPERTY(customAnimationURL, NSURL, NSObject, YES,
                   ^id(id url) { return [(NSURL *)url absoluteString]; },
                   ^id(id string) { return [NSURL URLWithString:string]; }),
          PROPERTY(omitFromDocument, NSNumber, NSObject, YES, nil, nil),
          })),
  ENTRY(ORKConsentSignature,
        nil,
        (@{
          PROPERTY(identifier, NSString, NSObject, YES, nil, nil),
          PROPERTY(title, NSString, NSObject, YES, nil, nil),
          PROPERTY(givenName, NSString, NSObject, YES, nil, nil),
          PROPERTY(familyName, NSString, NSObject, YES, nil, nil),
          PROPERTY(signatureDate, NSString, NSObject, YES, nil, nil),
          PROPERTY(requiresName, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(requiresSignatureImage, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(signatureDateFormatString, NSString, NSObject, YES, nil, nil),
          })),
  ENTRY(ORKRegistrationStep,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKRegistrationStep alloc] initWithIdentifier:GETPROP(dict, identifier) title:GETPROP(dict, title) text:GETPROP(dict, text) options:((NSNumber *)GETPROP(dict, options)).integerValue];
        },
        (@{
           PROPERTY(options, NSNumber, NSObject, NO, nil, nil)
           })),
   ENTRY(ORKVerificationStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKVerificationStep alloc] initWithIdentifier:GETPROP(dict, identifier) text:GETPROP(dict, text) verificationViewControllerClass:NSClassFromString(GETPROP(dict, verificationViewControllerString))];
         },
         (@{
            PROPERTY(verificationViewControllerString, NSString, NSObject, NO, nil, nil)
            })),
   ENTRY(ORKLoginStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKLoginStep alloc] initWithIdentifier:GETPROP(dict, identifier) title:GETPROP(dict, title) text:GETPROP(dict, text) loginViewControllerClass:NSClassFromString(GETPROP(dict, loginViewControllerString))];
         },
         (@{
            PROPERTY(loginViewControllerString, NSString, NSObject, NO, nil, nil)
            })),
  ENTRY(ORKDeviceMotionRecorderConfiguration,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier) frequency:((NSNumber *)GETPROP(dict, frequency)).doubleValue];
        },
        (@{
          PROPERTY(frequency, NSNumber, NSObject, NO, nil, nil),
          })),
  ENTRY(ORKFormStep,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKFormStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
        },
        (@{
          PROPERTY(formItems, ORKFormItem, NSArray, YES, nil, nil),
          PROPERTY(footnote, NSString, NSObject, YES, nil, nil),
          })),
  ENTRY(ORKFormItem,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKFormItem alloc] initWithIdentifier:GETPROP(dict, identifier) text:GETPROP(dict, text) answerFormat:GETPROP(dict, answerFormat)];
        },
        (@{
          PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
          PROPERTY(optional, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(text, NSString, NSObject, NO, nil, nil),
          PROPERTY(placeholder, NSString, NSObject, YES, nil, nil),
          PROPERTY(answerFormat, ORKAnswerFormat, NSObject, NO, nil, nil),
          })),
   ENTRY(ORKPageStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             ORKPageStep *step = [[ORKPageStep alloc] initWithIdentifier:GETPROP(dict, identifier) pageTask:GETPROP(dict, pageTask)];
             return step;
         },
         (@{
            PROPERTY(pageTask, ORKOrderedTask, NSObject, NO, nil, nil),
            })),
   ENTRY(ORKNavigablePageStep,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             ORKNavigablePageStep *step = [[ORKNavigablePageStep alloc] initWithIdentifier:GETPROP(dict, identifier) pageTask:GETPROP(dict, pageTask)];
             return step;
         },
         (@{
            PROPERTY(pageTask, ORKOrderedTask, NSObject, NO, nil, nil),
            })),
  ENTRY(ORKHealthKitCharacteristicTypeAnswerFormat,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKHealthKitCharacteristicTypeAnswerFormat alloc] initWithCharacteristicType:GETPROP(dict, characteristicType)];
        },
        (@{
          PROPERTY(characteristicType, HKCharacteristicType, NSObject, NO,
                   ^id(id type) { return [(HKCharacteristicType *)type identifier]; },
                   ^id(id string) { return [HKCharacteristicType characteristicTypeForIdentifier:string]; }),
          PROPERTY(defaultDate, NSDate, NSObject, YES,
                   ^id(id date) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                   ^id(id string) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
          PROPERTY(minimumDate, NSDate, NSObject, YES,
                   ^id(id date) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                   ^id(id string) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
          PROPERTY(maximumDate, NSDate, NSObject, YES,
                   ^id(id date) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                   ^id(id string) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
          PROPERTY(calendar, NSCalendar, NSObject, YES,
                   ^id(id calendar) { return [(NSCalendar *)calendar calendarIdentifier]; },
                   ^id(id string) { return [NSCalendar calendarWithIdentifier:string]; }),
          PROPERTY(shouldRequestAuthorization, NSNumber, NSObject, YES, nil, nil),
          })),
  ENTRY(ORKHealthKitQuantityTypeAnswerFormat,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKHealthKitQuantityTypeAnswerFormat alloc] initWithQuantityType:GETPROP(dict, quantityType) unit:GETPROP(dict, unit) style:((NSNumber *)GETPROP(dict, numericAnswerStyle)).integerValue];
        },
        (@{
          PROPERTY(unit, HKUnit, NSObject, NO,
                   ^id(id unit) { return [(HKUnit *)unit unitString]; },
                   ^id(id string) { return [HKUnit unitFromString:string]; }),
          PROPERTY(quantityType, HKQuantityType, NSObject, NO,
                   ^id(id type) { return [(HKQuantityType *)type identifier]; },
                   ^id(id string) { return [HKQuantityType quantityTypeForIdentifier:string]; }),
          PROPERTY(numericAnswerStyle, NSNumber, NSObject, NO,
                   ^id(id num) { return ORKNumericAnswerStyleToString(((NSNumber *)num).integerValue); },
                   ^id(id string) { return @(ORKNumericAnswerStyleFromString(string)); }),
          PROPERTY(shouldRequestAuthorization, NSNumber, NSObject, YES, nil, nil),
          })),
  ENTRY(ORKAnswerFormat,
        nil,
        (@{
          })),
  ENTRY(ORKValuePickerAnswerFormat,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKValuePickerAnswerFormat alloc] initWithTextChoices:GETPROP(dict, textChoices)];
        },
        (@{
          PROPERTY(textChoices, ORKTextChoice, NSArray, NO, nil, nil),
          })),
   ENTRY(ORKMultipleValuePickerAnswerFormat,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKMultipleValuePickerAnswerFormat alloc] initWithValuePickers:GETPROP(dict, valuePickers) separator:GETPROP(dict, separator)];
         },
         (@{
            PROPERTY(valuePickers, ORKValuePickerAnswerFormat, NSArray, NO, nil, nil),
            PROPERTY(separator, NSString, NSObject, NO, nil, nil),
            })),
  ENTRY(ORKImageChoiceAnswerFormat,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKImageChoiceAnswerFormat alloc] initWithImageChoices:GETPROP(dict, imageChoices)];
        },
        (@{
          PROPERTY(imageChoices, ORKImageChoice, NSArray, NO, nil, nil),
          })),
  ENTRY(ORKTextChoiceAnswerFormat,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKTextChoiceAnswerFormat alloc] initWithStyle:((NSNumber *)GETPROP(dict, style)).integerValue textChoices:GETPROP(dict, textChoices)];
        },
        (@{
          PROPERTY(style, NSNumber, NSObject, NO, NUMTOSTRINGBLOCK(ORKChoiceAnswerStyleTable()), STRINGTONUMBLOCK(ORKChoiceAnswerStyleTable())),
          PROPERTY(textChoices, ORKTextChoice, NSArray, NO, nil, nil),
          })),
  ENTRY(ORKTextChoice,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKTextChoice alloc] initWithText:GETPROP(dict, text) detailText:GETPROP(dict, detailText) value:GETPROP(dict, value) exclusive:((NSNumber *)GETPROP(dict, exclusive)).boolValue];
        },
        (@{
          PROPERTY(text, NSString, NSObject, NO, nil, nil),
          PROPERTY(value, NSObject, NSObject, NO, nil, nil),
          PROPERTY(detailText, NSString, NSObject, NO, nil, nil),
          PROPERTY(exclusive, NSNumber, NSObject, NO, nil, nil),
          })),
  ENTRY(ORKImageChoice,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKImageChoice alloc] initWithNormalImage:nil selectedImage:nil text:GETPROP(dict, text) value:GETPROP(dict, value)];
        },
        (@{
          PROPERTY(text, NSString, NSObject, NO, nil, nil),
          PROPERTY(value, NSObject, NSObject, NO, nil, nil),
          })),
  ENTRY(ORKTimeOfDayAnswerFormat,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKTimeOfDayAnswerFormat alloc] initWithDefaultComponents:GETPROP(dict, defaultComponents)];
        },
        (@{
          PROPERTY(defaultComponents, NSDateComponents, NSObject, NO,
                   ^id(id components) { return ORKTimeOfDayStringFromComponents(components);  },
                   ^id(id string) { return ORKTimeOfDayComponentsFromString(string); })
          })),
  ENTRY(ORKDateAnswerFormat,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKDateAnswerFormat alloc] initWithStyle:((NSNumber *)GETPROP(dict, style)).integerValue defaultDate:GETPROP(dict, defaultDate) minimumDate:GETPROP(dict, minimumDate) maximumDate:GETPROP(dict, maximumDate) calendar:GETPROP(dict, calendar)];
        },
        (@{
          PROPERTY(style, NSNumber, NSObject, NO,
                   NUMTOSTRINGBLOCK(ORKDateAnswerStyleTable()),
                   STRINGTONUMBLOCK(ORKDateAnswerStyleTable())),
          PROPERTY(calendar, NSCalendar, NSObject, NO,
                   ^id(id calendar) { return [(NSCalendar *)calendar calendarIdentifier]; },
                   ^id(id string) { return [NSCalendar calendarWithIdentifier:string]; }),
          PROPERTY(minimumDate, NSDate, NSObject, NO,
                   ^id(id date) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                   ^id(id string) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
          PROPERTY(maximumDate, NSDate, NSObject, NO,
                   ^id(id date) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                   ^id(id string) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
          PROPERTY(defaultDate, NSDate, NSObject, NO,
                   ^id(id date) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                   ^id(id string) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
          })),
  ENTRY(ORKNumericAnswerFormat,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKNumericAnswerFormat alloc] initWithStyle:((NSNumber *)GETPROP(dict, style)).integerValue unit:GETPROP(dict, unit) minimum:GETPROP(dict, minimum) maximum:GETPROP(dict, maximum)];
        },
        (@{
          PROPERTY(style, NSNumber, NSObject, NO,
                   ^id(id num) { return ORKNumericAnswerStyleToString(((NSNumber *)num).integerValue); },
                   ^id(id string) { return @(ORKNumericAnswerStyleFromString(string)); }),
          PROPERTY(unit, NSString, NSObject, NO, nil, nil),
          PROPERTY(minimum, NSNumber, NSObject, NO, nil, nil),
          PROPERTY(maximum, NSNumber, NSObject, NO, nil, nil),
          })),
  ENTRY(ORKScaleAnswerFormat,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKScaleAnswerFormat alloc] initWithMaximumValue:((NSNumber *)GETPROP(dict, maximum)).integerValue minimumValue:((NSNumber *)GETPROP(dict, minimum)).integerValue defaultValue:((NSNumber *)GETPROP(dict, defaultValue)).integerValue step:((NSNumber *)GETPROP(dict, step)).integerValue vertical:((NSNumber *)GETPROP(dict, vertical)).boolValue maximumValueDescription:GETPROP(dict, maximumValueDescription) minimumValueDescription:GETPROP(dict, minimumValueDescription)];
        },
        (@{
          PROPERTY(minimum, NSNumber, NSObject, NO, nil, nil),
          PROPERTY(maximum, NSNumber, NSObject, NO, nil, nil),
          PROPERTY(defaultValue, NSNumber, NSObject, NO, nil, nil),
          PROPERTY(step, NSNumber, NSObject, NO, nil, nil),
          PROPERTY(vertical, NSNumber, NSObject, NO, nil, nil),
          PROPERTY(maximumValueDescription, NSString, NSObject, NO, nil, nil),
          PROPERTY(minimumValueDescription, NSString, NSObject, NO, nil, nil),
          PROPERTY(gradientColors, UIColor, NSArray, YES, nil, nil),
          PROPERTY(gradientLocations, NSNumber, NSArray, YES, nil, nil)
          })),
  ENTRY(ORKContinuousScaleAnswerFormat,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:((NSNumber *)GETPROP(dict, maximum)).doubleValue minimumValue:((NSNumber *)GETPROP(dict, minimum)).doubleValue defaultValue:((NSNumber *)GETPROP(dict, defaultValue)).doubleValue maximumFractionDigits:((NSNumber *)GETPROP(dict, maximumFractionDigits)).integerValue vertical:((NSNumber *)GETPROP(dict, vertical)).boolValue maximumValueDescription:GETPROP(dict, maximumValueDescription) minimumValueDescription:GETPROP(dict, minimumValueDescription)];
        },
        (@{
          PROPERTY(minimum, NSNumber, NSObject, NO, nil, nil),
          PROPERTY(maximum, NSNumber, NSObject, NO, nil, nil),
          PROPERTY(defaultValue, NSNumber, NSObject, NO, nil, nil),
          PROPERTY(maximumFractionDigits, NSNumber, NSObject, NO, nil, nil),
          PROPERTY(vertical, NSNumber, NSObject, NO, nil, nil),
          PROPERTY(numberStyle, NSNumber, NSObject, YES,
                   ^id(id numeric) { return tableMapForward(((NSNumber *)numeric).integerValue, numberFormattingStyleTable()); },
                   ^id(id string) { return @(tableMapReverse(string, numberFormattingStyleTable())); }),
          PROPERTY(maximumValueDescription, NSString, NSObject, NO, nil, nil),
          PROPERTY(minimumValueDescription, NSString, NSObject, NO, nil, nil),
          PROPERTY(gradientColors, UIColor, NSArray, YES, nil, nil),
          PROPERTY(gradientLocations, NSNumber, NSArray, YES, nil, nil)
          })),
   ENTRY(ORKTextScaleAnswerFormat,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKTextScaleAnswerFormat alloc] initWithTextChoices:GETPROP(dict, textChoices) defaultIndex:[GETPROP(dict, defaultIndex) doubleValue] vertical:[GETPROP(dict, vertical) boolValue]];
         },
         (@{
            PROPERTY(textChoices, ORKTextChoice, NSArray<ORKTextChoice *>, NO, nil, nil),
            PROPERTY(defaultIndex, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(vertical, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(gradientColors, UIColor, NSArray, YES, nil, nil),
            PROPERTY(gradientLocations, NSNumber, NSArray, YES, nil, nil)
            })),
  ENTRY(ORKTextAnswerFormat,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKTextAnswerFormat alloc] initWithMaximumLength:((NSNumber *)GETPROP(dict, maximumLength)).integerValue];
        },
        (@{
          PROPERTY(maximumLength, NSNumber, NSObject, NO, nil, nil),
          PROPERTY(validationRegularExpression, NSRegularExpression, NSObject, YES,
                   ^id(id value) { return dictionaryFromRegularExpression((NSRegularExpression *)value); },
                   ^id(id dict) { return regularExpressionsFromDictionary(dict); } ),
          PROPERTY(invalidMessage, NSString, NSObject, YES, nil, nil),
          PROPERTY(autocapitalizationType, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(autocorrectionType, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(spellCheckingType, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(keyboardType, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(multipleLines, NSNumber, NSObject, YES, nil, nil),
          PROPERTY(secureTextEntry, NSNumber, NSObject, YES, nil, nil)
          })),
   ENTRY(ORKEmailAnswerFormat,
         nil,
         (@{
            })),
   ENTRY(ORKConfirmTextAnswerFormat,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKConfirmTextAnswerFormat alloc] initWithOriginalItemIdentifier:GETPROP(dict, originalItemIdentifier) errorMessage:GETPROP(dict, errorMessage)];
         },
         (@{
            PROPERTY(originalItemIdentifier, NSString, NSObject, NO, nil, nil),
            PROPERTY(errorMessage, NSString, NSObject, NO, nil, nil),
            PROPERTY(maximumLength, NSNumber, NSObject, YES, nil, nil)
            })),
  ENTRY(ORKTimeIntervalAnswerFormat,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKTimeIntervalAnswerFormat alloc] initWithDefaultInterval:((NSNumber *)GETPROP(dict, defaultInterval)).doubleValue step:((NSNumber *)GETPROP(dict, step)).integerValue];
        },
        (@{
          PROPERTY(defaultInterval, NSNumber, NSObject, NO, nil, nil),
          PROPERTY(step, NSNumber, NSObject, NO, nil, nil),
          })),
  ENTRY(ORKBooleanAnswerFormat,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKBooleanAnswerFormat alloc] initWithYesString:((NSString *)GETPROP(dict, yes)) noString:((NSString *)GETPROP(dict, no))];
        },
        (@{
           PROPERTY(yes, NSString, NSObject, NO, nil, nil),
           PROPERTY(no, NSString, NSObject, NO, nil, nil)
          })),
   ENTRY(ORKHeightAnswerFormat,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKHeightAnswerFormat alloc] initWithMeasurementSystem:((NSNumber *)GETPROP(dict, measurementSystem)).integerValue];
         },
         (@{
            PROPERTY(measurementSystem, NSNumber, NSObject, NO, nil, nil),
            })),
  ENTRY(ORKLocationAnswerFormat,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKLocationAnswerFormat alloc] init];
        },
        (@{
          PROPERTY(useCurrentLocation, NSNumber, NSObject, YES, nil, nil)
          })),
  ENTRY(ORKLocationRecorderConfiguration,
        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKLocationRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict,identifier)];
        },
        (@{
          })),
   ENTRY(ORKPedometerRecorderConfiguration,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKPedometerRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict,identifier)];
         },
        (@{
          })),
   ENTRY(ORKTouchRecorderConfiguration,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKTouchRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict,identifier)];
         },
        (@{
          })),
  ENTRY(ORKResult,
        nil,
        (@{
           PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
           PROPERTY(startDate, NSDate, NSObject, YES,
                    ^id(id date) { return ORKEStringFromDateISO8601(date); },
                    ^id(id string) { return ORKEDateFromStringISO8601(string); }),
           PROPERTY(endDate, NSDate, NSObject, YES,
                    ^id(id date) { return ORKEStringFromDateISO8601(date); },
                    ^id(id string) { return ORKEDateFromStringISO8601(string); }),
           PROPERTY(userInfo, NSDictionary, NSObject, YES, nil, nil)
           })),
  ENTRY(ORKTappingSample,
        nil,
        (@{
           PROPERTY(timestamp, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(duration, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(buttonIdentifier, NSNumber, NSObject, NO,
                    ^id(id numeric) { return tableMapForward(((NSNumber *)numeric).integerValue, buttonIdentifierTable()); },
                    ^id(id string) { return @(tableMapReverse(string, buttonIdentifierTable())); }),
           PROPERTY(location, NSValue, NSObject, NO,
                    ^id(id value) { return value?dictionaryFromCGPoint(((NSValue *)value).CGPointValue):nil; },
                    ^id(id dict) { return [NSValue valueWithCGPoint:pointFromDictionary(dict)]; })
           })),
  ENTRY(ORKTappingIntervalResult,
        nil,
        (@{
           PROPERTY(samples, ORKTappingSample, NSArray, NO, nil, nil),
           PROPERTY(stepViewSize, NSValue, NSObject, NO,
                    ^id(id value) { return value?dictionaryFromCGSize(((NSValue *)value).CGSizeValue):nil; },
                    ^id(id dict) { return [NSValue valueWithCGSize:sizeFromDictionary(dict)]; }),
           PROPERTY(buttonRect1, NSValue, NSObject, NO,
                    ^id(id value) { return value?dictionaryFromCGRect(((NSValue *)value).CGRectValue):nil; },
                    ^id(id dict) { return [NSValue valueWithCGRect:rectFromDictionary(dict)]; }),
           PROPERTY(buttonRect2, NSValue, NSObject, NO,
                    ^id(id value) { return value?dictionaryFromCGRect(((NSValue *)value).CGRectValue):nil; },
                    ^id(id dict) { return [NSValue valueWithCGRect:rectFromDictionary(dict)]; })
           })),
   ENTRY(ORKTrailmakingTap,
         nil,
         (@{
            PROPERTY(timestamp, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(index, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(incorrect, NSNumber, NSObject, NO, nil, nil),
            })),
   ENTRY(ORKTrailmakingResult,
         nil,
         (@{
            PROPERTY(taps, ORKTrailmakingTap, NSArray, NO, nil, nil),
            PROPERTY(numberOfErrors, NSNumber, NSObject, NO, nil, nil)
            })),
  ENTRY(ORKSpatialSpanMemoryGameTouchSample,
        nil,
        (@{
           PROPERTY(timestamp, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(targetIndex, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(correct, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(location, NSValue, NSObject, NO,
                    ^id(id value) { return value?dictionaryFromCGPoint(((NSValue *)value).CGPointValue):nil; },
                    ^id(id dict) { return [NSValue valueWithCGPoint:pointFromDictionary(dict)]; })
           })),
  ENTRY(ORKSpatialSpanMemoryGameRecord,
        nil,
        (@{
           PROPERTY(seed, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(sequence, NSNumber, NSArray, NO, nil, nil),
           PROPERTY(gameSize, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(gameStatus, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(score, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(touchSamples, ORKSpatialSpanMemoryGameTouchSample, NSArray, NO,
                    ^id(id numeric) { return tableMapForward(((NSNumber *)numeric).integerValue, memoryGameStatusTable()); },
                    ^id(id string) { return @(tableMapReverse(string, memoryGameStatusTable())); }),
           PROPERTY(targetRects, NSValue, NSArray, NO,
                    ^id(id value) { return value?dictionaryFromCGRect(((NSValue *)value).CGRectValue):nil; },
                    ^id(id dict) { return [NSValue valueWithCGRect:rectFromDictionary(dict)]; })
           })),
  ENTRY(ORKSpatialSpanMemoryResult,
        nil,
        (@{
           PROPERTY(score, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(numberOfGames, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(numberOfFailures, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(gameRecords, ORKSpatialSpanMemoryGameRecord, NSArray, NO, nil, nil)
           })),
  ENTRY(ORKFileResult,
        nil,
        (@{
           PROPERTY(contentType, NSString, NSObject, NO, nil, nil),
           PROPERTY(fileURL, NSURL, NSObject, NO,
                    ^id(id url) { return [url absoluteString]; },
                    ^id(id string) { return [NSURL URLWithString:string]; })
           })),
  ENTRY(ORKToneAudiometrySample,
        nil,
        (@{
           PROPERTY(frequency, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(channel, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(amplitude, NSNumber, NSObject, NO, nil, nil)
           })),
  ENTRY(ORKToneAudiometryResult,
        nil,
        (@{
           PROPERTY(outputVolume, NSNumber, NSObject, NO, nil, nil),
           PROPERTY(samples, ORKToneAudiometrySample, NSArray, NO, nil, nil),
           })),
   ENTRY(ORKReactionTimeResult,
         nil,
         (@{
            PROPERTY(timestamp, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(fileResult, ORKResult, NSObject, NO, nil, nil)
            })),
   ENTRY(ORKTimedWalkResult,
         nil,
         (@{
            PROPERTY(distanceInMeters, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(timeLimit, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(duration, NSNumber, NSObject, NO, nil, nil),
           })),
   ENTRY(ORKPSATSample,
         nil,
         (@{
            PROPERTY(correct, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(digit, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(answer, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(time, NSNumber, NSObject, NO, nil, nil),
            })),
   ENTRY(ORKPSATResult,
         nil,
         (@{
            PROPERTY(presentationMode, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(interStimulusInterval, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(stimulusDuration, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(length, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(totalCorrect, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(totalDyad, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(totalTime, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(initialDigit, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(samples, ORKPSATSample, NSArray, NO, nil, nil),
            })),
   ENTRY(ORKRangeOfMotionResult,
         nil,
         (@{
            PROPERTY(flexed, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(extended, NSNumber, NSObject, NO, nil, nil),
            })),
   ENTRY(ORKTowerOfHanoiResult,
         nil,
         (@{
            PROPERTY(puzzleWasSolved, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(moves, ORKTowerOfHanoiMove, NSArray, YES, nil, nil),
            })),
   ENTRY(ORKTowerOfHanoiMove,
         nil,
         (@{
            PROPERTY(timestamp, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(donorTowerIndex, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(recipientTowerIndex, NSNumber, NSObject, YES, nil, nil),
            })),
   ENTRY(ORKHolePegTestSample,
         nil,
         (@{
            PROPERTY(time, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(distance, NSNumber, NSObject, NO, nil, nil)
            })),
   ENTRY(ORKHolePegTestResult,
         nil,
         (@{
            PROPERTY(movingDirection, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(dominantHandTested, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(numberOfPegs, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(threshold, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(rotated, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(totalSuccesses, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(totalFailures, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(totalTime, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(totalDistance, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(samples, ORKHolePegTestSample, NSArray, NO, nil, nil),
            })),
   ENTRY(ORKPasscodeResult,
         nil,
         (@{
            PROPERTY(passcodeSaved, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(touchIdEnabled, NSNumber, NSObject, YES, nil, nil)
            })),
    ENTRY(ORKQuestionResult,
         nil,
         (@{
            PROPERTY(questionType, NSNumber, NSObject, NO, nil, nil)
            })),
   ENTRY(ORKDataResult,
         nil,
         (@{
            PROPERTY(contentType, NSString, NSObject, YES, nil, nil),
            PROPERTY(filename, NSString, NSObject, YES, nil, nil),
            })),
   ENTRY(ORKScaleQuestionResult,
         nil,
         (@{
            PROPERTY(scaleAnswer, NSNumber, NSObject, NO, nil, nil)
            })),
   ENTRY(ORKChoiceQuestionResult,
         nil,
         (@{
            PROPERTY(choiceAnswers, NSObject, NSObject, NO, nil, nil)
            })),
   ENTRY(ORKMultipleComponentQuestionResult,
         nil,
         (@{
            PROPERTY(componentsAnswer, NSObject, NSObject, NO, nil, nil),
            PROPERTY(separator, NSString, NSObject, NO, nil, nil)
            })),
   ENTRY(ORKBooleanQuestionResult,
         nil,
         (@{
            PROPERTY(booleanAnswer, NSNumber, NSObject, NO, nil, nil)
            })),
   ENTRY(ORKTextQuestionResult,
         nil,
         (@{
            PROPERTY(textAnswer, NSString, NSObject, NO, nil, nil)
            })),
   ENTRY(ORKNumericQuestionResult,
         nil,
         (@{
            PROPERTY(numericAnswer, NSNumber, NSObject, NO, nil, nil),
            PROPERTY(unit, NSString, NSObject, NO, nil, nil)
            })),
   ENTRY(ORKTimeOfDayQuestionResult,
         nil,
         (@{
            PROPERTY(dateComponentsAnswer, NSDateComponents, NSObject, NO,
                     ^id(id dateComponents) { return ORKTimeOfDayStringFromComponents(dateComponents); },
                     ^id(id string) { return ORKTimeOfDayComponentsFromString(string); })
            })),
   ENTRY(ORKTimeIntervalQuestionResult,
         nil,
         (@{
            PROPERTY(intervalAnswer, NSNumber, NSObject, NO, nil, nil)
            })),
   ENTRY(ORKDateQuestionResult,
         nil,
         (@{
            PROPERTY(dateAnswer, NSDate, NSObject, NO,
                     ^id(id date) { return ORKEStringFromDateISO8601(date); },
                     ^id(id string) { return ORKEDateFromStringISO8601(string); }),
            PROPERTY(calendar, NSCalendar, NSObject, NO,
                     ^id(id calendar) { return [(NSCalendar *)calendar calendarIdentifier]; },
                     ^id(id string) { return [NSCalendar calendarWithIdentifier:string]; }),
            PROPERTY(timeZone, NSTimeZone, NSObject, NO,
                     ^id(id timezone) { return @([timezone secondsFromGMT]); },
                     ^id(id number) { return [NSTimeZone timeZoneForSecondsFromGMT:((NSNumber *)number).doubleValue]; })
            })),
   ENTRY(ORKLocation,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             CLLocationCoordinate2D coordinate = coordinateFromDictionary(dict[@ESTRINGIFY(coordinate)]);
             return [[ORKLocation alloc] initWithCoordinate:coordinate
                                                     region:GETPROP(dict, region)
                                                  userInput:GETPROP(dict, userInput)
                                          addressDictionary:GETPROP(dict, addressDictionary)];
         },
         (@{
            PROPERTY(userInput, NSString, NSObject, NO, nil, nil),
            PROPERTY(addressDictionary, NSString, NSDictionary, NO, nil, nil),
            PROPERTY(coordinate, NSValue, NSObject, NO,
                     ^id(id value) { return value ? dictionaryFromCoordinate(((NSValue *)value).MKCoordinateValue) : nil; },
                     ^id(id dict) { return [NSValue valueWithMKCoordinate:coordinateFromDictionary(dict)]; }),
            PROPERTY(region, CLCircularRegion, NSObject, NO,
                     ^id(id value) { return dictionaryFromCircularRegion((CLCircularRegion *)value); },
                     ^id(id dict) { return circularRegionFromDictionary(dict); }),
            })),
   ENTRY(ORKLocationQuestionResult,
         nil,
         (@{
            PROPERTY(locationAnswer, ORKLocation, NSObject, NO, nil, nil)
            })),
   ENTRY(ORKConsentSignatureResult,
         nil,
         (@{
            PROPERTY(signature, ORKConsentSignature, NSObject, YES, nil, nil),
            PROPERTY(consented, NSNumber, NSObject, YES, nil, nil),
            })),
   ENTRY(ORKSignatureResult,
         nil,
         (@{
            })),
   ENTRY(ORKCollectionResult,
         nil,
         (@{
            PROPERTY(results, ORKResult, NSArray, YES, nil, nil)
            })),
   ENTRY(ORKTaskResult,
         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
             return [[ORKTaskResult alloc] initWithTaskIdentifier:GETPROP(dict, identifier) taskRunUUID:GETPROP(dict, taskRunUUID) outputDirectory:GETPROP(dict, outputDirectory)];
         },
         (@{
            PROPERTY(taskRunUUID, NSUUID, NSObject, NO,
                     ^id(id uuid) { return [uuid UUIDString]; },
                     ^id(id string) { return [[NSUUID alloc] initWithUUIDString:string]; }),
            PROPERTY(outputDirectory, NSURL, NSObject, NO,
                     ^id(id url) { return [url absoluteString]; },
                     ^id(id string) { return [NSURL URLWithString:string]; })
            })),
   ENTRY(ORKStepResult,
         nil,
         (@{
            PROPERTY(enabledAssistiveTechnology, NSString, NSObject, YES, nil, nil),
            PROPERTY(isPreviousResult, NSNumber, NSObject, YES, nil, nil),
            })),
   ENTRY(ORKPageResult,
         nil,
         (@{
            })),
   ENTRY(ORKVideoInstructionStepResult,
         nil,
         (@{
            PROPERTY(playbackStoppedTime, NSNumber, NSObject, YES, nil, nil),
            PROPERTY(playbackCompleted, NSNumber, NSObject, YES, nil, nil),
            })),
   
   } mutableCopy];
    });
    return encondingTable;
}
#undef GETPROP

static NSArray *classEncodingsForClass(Class c) {
    NSDictionary *encodingTable = ORKESerializationEncodingTable();
    
    NSMutableArray *classEncodings = [NSMutableArray array];
    Class sc = c;
    while (sc != nil) {
        NSString *className = NSStringFromClass(sc);
        ORKESerializableTableEntry *classEncoding = encodingTable[className];
        if (classEncoding) {
            [classEncodings addObject:classEncoding];
        }
        sc = [sc superclass];
    }
    return classEncodings;
}

static id objectForJsonObject(id input, Class expectedClass, ORKESerializationJSONToObjectBlock converterBlock) {
    id output = nil;
    if (converterBlock != nil) {
        input = converterBlock(input);
    }
    
    if (expectedClass != nil && [input isKindOfClass:expectedClass]) {
        // Input is already of the expected class, do nothing
        output = input;
    } else if ([input isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)input;
        NSString *className = input[_ClassKey];
        if (expectedClass != nil) {
            NSCAssert([NSClassFromString(className) isSubclassOfClass:expectedClass], @"Expected subclass of %@ but got %@", expectedClass, className);
        }
        NSArray *classEncodings = classEncodingsForClass(NSClassFromString(className));
        NSCAssert([classEncodings count] > 0, @"Expected serializable class but got %@", className);
        
        ORKESerializableTableEntry *leafClassEncoding = classEncodings.firstObject;
        ORKESerializationInitBlock initBlock = leafClassEncoding.initBlock;
        BOOL writeAllProperties = YES;
        if (initBlock != nil) {
            output = initBlock(dict,
                               ^id(NSDictionary *dict, NSString *param) {
                                   return propFromDict(dict, param); });
            writeAllProperties = NO;
        } else {
            output = [[NSClassFromString(className) alloc] init];
        }
        
        for (NSString *key in [dict allKeys]) {
            if ([key isEqualToString:_ClassKey]) {
                continue;
            }
            
            BOOL haveSetProp = NO;
            for (ORKESerializableTableEntry *encoding in classEncodings) {
                NSDictionary *propertyTable = encoding.properties;
                ORKESerializableProperty *propertyEntry = propertyTable[key];
                if (propertyEntry != nil) {
                    // Only write the property if it has not already been set during init
                    if (writeAllProperties || propertyEntry.writeAfterInit) {
                        [output setValue:propFromDict(dict,key) forKey:key];
                    }
                    haveSetProp = YES;
                    break;
                }
            }
            NSCAssert(haveSetProp, @"Unexpected property on %@: %@", className, key);
        }
        
    } else {
        NSCAssert(0, @"Unexpected input of class %@ for %@", [input class], expectedClass);
    }
    return output;
}

static BOOL isValid(id object) {
    return [NSJSONSerialization isValidJSONObject:object] || [object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNull class]];
}

static id jsonObjectForObject(id object) {
    if (object == nil) {
        // Leaf: nil
        return nil;
    }
    
    id jsonOutput = nil;
    Class c = [object class];
    
    NSArray *classEncodings = classEncodingsForClass(c);
    
    if ([classEncodings count]) {
        NSMutableDictionary *encodedDict = [NSMutableDictionary dictionary];
        encodedDict[_ClassKey] = NSStringFromClass(c);
        
        for (ORKESerializableTableEntry *encoding in classEncodings) {
            NSDictionary *propertyTable = encoding.properties;
            for (NSString *propertyName in [propertyTable allKeys]) {
                ORKESerializableProperty *propertyEntry = propertyTable[propertyName];
                ORKESerializationObjectToJSONBlock converter = propertyEntry.objectToJSONBlock;
                Class containerClass = propertyEntry.containerClass;
                id valueForKey = [object valueForKey:propertyName];
                if (valueForKey != nil) {
                    if ([containerClass isSubclassOfClass:[NSArray class]]) {
                        NSMutableArray *a = [NSMutableArray array];
                        for (id valueItem in valueForKey) {
                            id outputItem;
                            if (converter != nil) {
                                outputItem = converter(valueItem);
                                NSCAssert(isValid(valueItem), @"Expected valid JSON object");
                            } else {
                                // Recurse for each property
                                outputItem = jsonObjectForObject(valueItem);
                            }
                            [a addObject:outputItem];
                        }
                        valueForKey = a;
                    } else {
                        if (converter != nil) {
                            valueForKey = converter(valueForKey);
                            NSCAssert((valueForKey == nil) || isValid(valueForKey), @"Expected valid JSON object");
                        } else {
                            // Recurse for each property
                            valueForKey = jsonObjectForObject(valueForKey);
                        }
                    }
                }
                
                if (valueForKey != nil) {
                    encodedDict[propertyName] = valueForKey;
                }
            }
        }
        
        jsonOutput = encodedDict;
    } else if ([c isSubclassOfClass:[NSArray class]]) {
        NSArray *inputArray = (NSArray *)object;
        NSMutableArray *encodedArray = [NSMutableArray arrayWithCapacity:[inputArray count]];
        for (id input in inputArray) {
            // Recurse for each array element
            [encodedArray addObject:jsonObjectForObject(input)];
        }
        jsonOutput = encodedArray;
    } else if ([c isSubclassOfClass:[NSDictionary class]]) {
        NSDictionary *inputDict = (NSDictionary *)object;
        NSMutableDictionary *encodedDictionary = [NSMutableDictionary dictionaryWithCapacity:[inputDict count]];
        for (NSString *key in [inputDict allKeys] ) {
            // Recurse for each dictionary value
            encodedDictionary[key] = jsonObjectForObject(inputDict[key]);
        }
        jsonOutput = encodedDictionary;
    } else if (![c isSubclassOfClass:[NSPredicate class]]) {  // Ignore NSPredicate which cannot be easily serialized for now
        NSCAssert(isValid(object), @"Expected valid JSON object");
        
        // Leaf: native JSON object
        jsonOutput = object;
    }
    
    return jsonOutput;
}

+ (NSDictionary *)JSONObjectForObject:(id)object error:(NSError **)error {
    id json = jsonObjectForObject(object);
    return json;
}

+ (id)objectFromJSONObject:(NSDictionary *)object error:(NSError **)error {
    return objectForJsonObject(object, nil, nil);
}

+ (NSData *)JSONDataForObject:(id)object error:(NSError **)error {
    id json = jsonObjectForObject(object);
    return [NSJSONSerialization dataWithJSONObject:json options:(NSJSONWritingOptions)0 error:error];
}

+ (id)objectFromJSONData:(NSData *)data error:(NSError **)error {
    id json = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:error];
    id ret = nil;
    if (json != nil) {
        ret = objectForJsonObject(json, nil, nil);
    }
    return ret;
}

+ (NSArray *)serializableClasses {
    NSMutableArray *a = [NSMutableArray array];
    NSDictionary *table = ORKESerializationEncodingTable();
    for (NSString *key in [table allKeys]) {
        [a addObject:NSClassFromString(key)];
    }
    return a;
}

@end


@implementation ORKESerializer(Registration)

+ (void)registerSerializableClass:(Class)serializableClass
                        initBlock:(ORKESerializationInitBlock)initBlock {
    NSMutableDictionary *encodingTable = ORKESerializationEncodingTable();
    
    ORKESerializableTableEntry *entry = encodingTable[NSStringFromClass(serializableClass)];
    if (entry) {
        entry.class = serializableClass;
        entry.initBlock = initBlock;
    } else {
        entry = [[ORKESerializableTableEntry alloc] initWithClass:serializableClass initBlock:initBlock properties:@{}];
        encodingTable[NSStringFromClass(serializableClass)] = entry;
    }
}

+ (void)registerSerializableClassPropertyName:(NSString *)propertyName
                                     forClass:(Class)serializableClass
                                   valueClass:(Class)valueClass
                               containerClass:(Class)containerClass
                               writeAfterInit:(BOOL)writeAfterInit
                            objectToJSONBlock:(ORKESerializationObjectToJSONBlock)objectToJSON
                            jsonToObjectBlock:(ORKESerializationJSONToObjectBlock)jsonToObjectBlock {
    NSMutableDictionary *encodingTable = ORKESerializationEncodingTable();
    
    ORKESerializableTableEntry *entry = encodingTable[NSStringFromClass(serializableClass)];
    if (!entry) {
        entry = [[ORKESerializableTableEntry alloc] initWithClass:serializableClass initBlock:nil properties:@{}];
        encodingTable[NSStringFromClass(serializableClass)] = entry;
    }
    
    ORKESerializableProperty *property = entry.properties[propertyName];
    if (property == nil) {
        property = [[ORKESerializableProperty alloc] initWithPropertyName:propertyName
                                                               valueClass:valueClass
                                                           containerClass:containerClass
                                                           writeAfterInit:writeAfterInit
                                                        objectToJSONBlock:objectToJSON
                                                        jsonToObjectBlock:jsonToObjectBlock];
        entry.properties[propertyName] = property;
    } else {
        property.propertyName = propertyName;
        property.valueClass = valueClass;
        property.containerClass = containerClass;
        property.writeAfterInit = writeAfterInit;
        property.objectToJSONBlock = objectToJSON;
        property.jsonToObjectBlock = jsonToObjectBlock;
    }
}

@end
