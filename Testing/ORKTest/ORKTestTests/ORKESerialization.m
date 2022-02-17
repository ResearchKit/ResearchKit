/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015-2016, Ricardo Sánchez-Sáez.
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


#import "ORKESerialization.h"

@import ResearchKit;
@import ResearchKit.Private;

@import MapKit;
@import Speech;

static NSString *noAnswerPrefix = @"noAnswer_";
static NSString *_ClassKey = @"_class";

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

static NSArray *ORKImageChoiceAnswerStyleTable() {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"singleChoice", @"multipleChoice"];
    });
    return table;
}

static NSArray *ORKMeasurementSystemTable() {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"local", @"metric", @"USC"];
    });
    return table;
}

static id tableMapForward(NSInteger index, NSArray *table) {
    return table[(NSUInteger)index];
}

static NSInteger tableMapReverse(id value, NSArray *table) {
    NSUInteger idx = [table indexOfObject:value];
    if (idx == NSNotFound)
    {
        idx = 0;
    }
    return (NSInteger)idx;
}

static NSDictionary *dictionaryFromCGPoint(CGPoint p) {
    return @{ @"x": @(p.x), @"y": @(p.y) };
}

static NSDictionary *dictionaryFromNSRange(NSRange r) {
    return @{ @"location": @(r.location) , @"length": @(r.length) };
}

static NSDictionary *dictionaryFromSFAcousticFeature(SFAcousticFeature *acousticFeature) {
    if (acousticFeature == nil) { return @{}; }
    return @{ @"acousticFeatureValuePerFrame" : acousticFeature.acousticFeatureValuePerFrame,
              @"frameDuration" : @(acousticFeature.frameDuration)
              };
}

static NSDictionary *dictionaryFromSFVoiceAnalytics(SFVoiceAnalytics *voiceAnalytics) {
    if (voiceAnalytics == nil) { return @{}; }
    return @{
             @"jitter" : dictionaryFromSFAcousticFeature(voiceAnalytics.jitter),
             @"shimmer" : dictionaryFromSFAcousticFeature(voiceAnalytics.shimmer),
             @"pitch" : dictionaryFromSFAcousticFeature(voiceAnalytics.pitch),
             @"voicing" : dictionaryFromSFAcousticFeature(voiceAnalytics.voicing)
             };
}

static NSDictionary *dictionaryFromSFTranscriptionSegment(SFTranscriptionSegment *segment) {
    if (segment == nil) { return @{}; }
    return @{
             @"substring" : segment.substring,
             @"substringRange" : dictionaryFromNSRange(segment.substringRange),
             @"timestamp" : @(segment.timestamp),
             @"duration" : @(segment.duration),
             @"confidence" : @(segment.confidence),
             @"alternativeSubstrings" : segment.alternativeSubstrings.copy,
             @"voiceAnalytics" : dictionaryFromSFVoiceAnalytics(segment.voiceAnalytics)
             };
}

typedef id (*mapFunction)(id);
static NSArray *mapArray(NSArray *input, mapFunction function) {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[input count]];
    for (id value in input) {
        [result addObject:function(value)];
    }
    return result;
}

static NSDictionary *dictionaryFromSFTranscription(SFTranscription *transcription) {
    if (transcription == nil) { return @{}; };
    return @{
             @"formattedString": transcription.formattedString,
             @"speakingRate" : @(transcription.speakingRate),
             @"averagePauseDuration" : @(transcription.averagePauseDuration),
             @"segments" : mapArray(transcription.segments, dictionaryFromSFTranscriptionSegment)
             };
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

static ORKNumericAnswerStyle ORKImageChoiceAnswerStyleFromString(NSString *s) {
    return tableMapReverse(s, ORKImageChoiceAnswerStyleTable());
}

static NSString *ORKImageChoiceAnswerStyleToString(ORKNumericAnswerStyle style) {
    return tableMapForward(style, ORKImageChoiceAnswerStyleTable());
}

static ORKMeasurementSystem ORKMeasurementSystemFromString(NSString *s) {
    return tableMapReverse(s, ORKMeasurementSystemTable());
}

static NSString *ORKMeasurementSystemToString(ORKMeasurementSystem measurementSystem) {
    return tableMapForward(measurementSystem, ORKMeasurementSystemTable());
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

static NSDictionary *dictionaryFromPostalAddress(CNPostalAddress *address) {
   return @{ @"city": address.city, @"street": address.street };
}

static NSString *identifierFromClinicalType(HKClinicalType *type) {
    return type.identifier;
}

static NSString *dontKnowFakePropertyName(NSString *propertyName) {
    return [noAnswerPrefix stringByAppendingString:propertyName];
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

static NSDictionary *dictionaryFromPasswordRules(UITextInputPasswordRules *passwordRules) {
    NSDictionary *dictionary = passwordRules ?
    @{
      @"rules": passwordRules.passwordRulesDescriptor ?: @""
      } :
    @{};
    return dictionary;
}

static UITextInputPasswordRules *passwordRulesFromDictionary(NSDictionary *dict) {
    UITextInputPasswordRules *passwordRules;
    if (dict.count == 1) {
        passwordRules = [UITextInputPasswordRules passwordRulesWithDescriptor:dict[@"rules"]];
    }
    return passwordRules;
}

static CNPostalAddress *postalAddressFromDictionary(NSDictionary *dict) {
    CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
    postalAddress.city = dict[@"city"];
    postalAddress.street = dict[@"street"];
    return [postalAddress copy];
}

static HKClinicalType *typeFromIdentifier(NSString *identifier) {
    return [HKClinicalType clinicalTypeForIdentifier:identifier];
}

static UIColor * _Nullable colorFromDictionary(NSDictionary *dict) {
    CGFloat r = [[dict objectForKey:@"r"] floatValue];
    CGFloat g = [[dict objectForKey:@"g"] floatValue];
    CGFloat b = [[dict objectForKey:@"b"] floatValue];
    CGFloat a = [[dict objectForKey:@"a"] floatValue];
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

static NSDictionary * _Nullable dictionaryFromColor(UIColor *color) {
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a]) {
        return @{@"r":@(r), @"g":@(g), @"b":@(b), @"a":@(a)};
    }
    return nil;
}

static NSMutableDictionary *ORKESerializationEncodingTable(void);
static id propFromDict(NSDictionary *dict, NSString *propName, ORKESerializationContext *context);
static NSArray *classEncodingsForClass(Class c) ;
static id objectForJsonObject(id input, Class expectedClass, ORKESerializationJSONToObjectBlock converterBlock, ORKESerializationContext *context);

__unused static NSInteger const SerializationVersion = 1; // Will be used moving forward as we get additional versions

#define ESTRINGIFY2(x) #x
#define ESTRINGIFY(x) ESTRINGIFY2(x)

#define ENTRY(entryName, mInitBlock, mProperties) \
    @ESTRINGIFY(entryName) : [[ORKESerializableTableEntry alloc] initWithClass: [entryName class] \
                                                                     initBlock: mInitBlock \
                                                                    properties: mProperties]

#define PROPERTY(propertyName, mValueClass, mContainerClass, mWriteAfterInit, mObjectToJSONBlock, mJsonToObjectBlock) \
    @ESTRINGIFY(propertyName) : ([[ORKESerializableProperty alloc] initWithPropertyName: @ESTRINGIFY(propertyName) \
                                                                             valueClass: [mValueClass class] \
                                                                         containerClass: [mContainerClass class] \
                                                                         writeAfterInit: mWriteAfterInit \
                                                                      objectToJSONBlock: mObjectToJSONBlock \
                                                                      jsonToObjectBlock: mJsonToObjectBlock \
                                                                      skipSerialization: NO])

#define SKIP_PROPERTY(propertyName, mValueClass, mContainerClass, mWriteAfterInit, mObjectToJSONBlock, mJsonToObjectBlock) \
@ESTRINGIFY(propertyName) : ([[ORKESerializableProperty alloc] initWithPropertyName: @ESTRINGIFY(propertyName) \
                                                                         valueClass: [mValueClass class] \
                                                                     containerClass: [mContainerClass class] \
                                                                     writeAfterInit: mWriteAfterInit \
                                                                  objectToJSONBlock: mObjectToJSONBlock \
                                                                  jsonToObjectBlock: mJsonToObjectBlock \
                                                                  skipSerialization: YES])

#define IMAGEPROPERTY(propertyName, containerClass, writeAfterInit) @ESTRINGIFY(propertyName) : \
                                                                        imagePropertyObject(@ESTRINGIFY(propertyName), \
                                                                                            [containerClass class], \
                                                                                            writeAfterInit, \
                                                                                            NO)

#define DYNAMICCAST(x, c) ((c *) ([x isKindOfClass:[c class]] ? x : nil))

@class ORKESerializableProperty;

@interface ORKESerializableTableEntry : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithClass:(Class)class
                    initBlock:(ORKESerializationInitBlock)initBlock
                   properties:(NSDictionary<NSString *, ORKESerializableProperty *> *)properties NS_DESIGNATED_INITIALIZER;

@property (nonatomic) Class class;
@property (nonatomic, copy) ORKESerializationInitBlock initBlock;
@property (nonatomic, strong) NSMutableDictionary<NSString *, ORKESerializableProperty *> *properties;

@end

static NSString * const _SerializedBundleImageNameKey = @"imageName";

@implementation ORKESerializationBundleImageProvider {
    NSBundle *_bundle;
}

- (instancetype)initWithBundle:(NSBundle *)bundle {
    self = [super init];
    if (self) {
        _bundle = bundle;
    }
    return self;
}

- (NSBundle *)bundle {
    return _bundle;
}

- (UIImage *)imageForReference:(NSDictionary *)reference {
    NSString *imageName = [reference objectForKey:_SerializedBundleImageNameKey];
    
    /*
     * Serialization should support the use of SFSymbols as a provided imageName.
     * If the imageName can be converted to an SFSymbol, the symbol will be used,
     * otherwise it will attempt to find the image name in the specified bundle.
     */
    UIImage *symbolImage = [UIImage systemImageNamed:imageName];
    if (symbolImage != nil) {
        return symbolImage;
    }
    
    return [UIImage imageNamed:imageName inBundle:_bundle compatibleWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceIdiom:[UIDevice currentDevice].userInterfaceIdiom]];
}

// Writing to bundle is not supported: supply a placeholder
- (nullable NSDictionary *)referenceBySavingImage:(UIImage __unused *)image {
    return @{_SerializedBundleImageNameKey : @""};
}

@end

@implementation ORKESerializationPropertyModifier

- (instancetype)initWithKeypath:(NSString *)keypath value:(id)value type:(ORKESerializationPropertyModifierType)type {
    self = [super init];
    if (self) {
        _keypath = [keypath copy];
        _value = [value copy];
        _type = type;
    }
    return self;
}

@end

@implementation ORKESerializationPropertyInjector

- (instancetype)initWithBundle:(NSBundle *)bundle modifiers:(NSArray<ORKESerializationPropertyModifier *> *)modifiers {
    self = [super init];
    if (self) {
        _bundle = bundle;
        NSMutableDictionary *propertyValues = [NSMutableDictionary dictionary];
        NSString *bundlePath = bundle.bundlePath;
        [modifiers enumerateObjectsUsingBlock:^(ORKESerializationPropertyModifier * _Nonnull obj, __unused NSUInteger idx, __unused BOOL * _Nonnull stop) {
            if (obj.type == ORKESerializationPropertyModifierTypePath && [obj.value isKindOfClass:[NSString class]]) {
                propertyValues[obj.keypath] = [bundlePath stringByAppendingPathComponent:(NSString *)obj.value];
            } else {
                propertyValues[obj.keypath] = obj.value;
            }
        }];
        _propertyValues = [propertyValues copy];
        
    }
    return self;
}

- (NSDictionary *)injectedDictionaryWithDictionary:(NSDictionary *)inputDictionary {
    NSMutableDictionary *mutatedDictionary = [inputDictionary mutableCopy];
    [_propertyValues enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull keypath, id  _Nonnull obj, __unused BOOL * _Nonnull stop) {
        NSArray<NSString *> *components = [keypath componentsSeparatedByString:@"."];
        NSCAssert(components.count == 2, @"Unexpected number of components in keypath %@", keypath);
        NSString *class = components[0];
        NSString *key = components[1];
        // Only inject the property if it's the corresponding class,and the key exists in the dictionary
        if ([class isEqualToString:mutatedDictionary[_ClassKey]] && mutatedDictionary[key] != nil) {
            mutatedDictionary[key] = obj;
        }
    }];
    return [mutatedDictionary copy];
}

@end

@interface ORKESerializableProperty : NSObject

- (instancetype)initWithPropertyName:(NSString *)propertyName
                          valueClass:(Class)valueClass
                      containerClass:(Class)containerClass
                      writeAfterInit:(BOOL)writeAfterInit
                   objectToJSONBlock:(ORKESerializationObjectToJSONBlock)objectToJSON
                   jsonToObjectBlock:(ORKESerializationJSONToObjectBlock)jsonToObjectBlock
                   skipSerialization:(BOOL)skipSerialization;

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic) Class valueClass;
@property (nonatomic) Class containerClass;
@property (nonatomic) BOOL writeAfterInit;
@property (nonatomic, copy) ORKESerializationObjectToJSONBlock objectToJSONBlock;
@property (nonatomic, copy) ORKESerializationJSONToObjectBlock jsonToObjectBlock;
@property (nonatomic) BOOL skipSerialization;

@end

static ORKESerializableProperty *imagePropertyObject(NSString *propertyName,
                                                     Class containerClass,
                                                     BOOL writeAfterInit,
                                                     BOOL skipSerialization) {
    return [[ORKESerializableProperty alloc] initWithPropertyName:propertyName
                                                       valueClass:[UIImage class]
                                                   containerClass:containerClass
                                                   writeAfterInit:writeAfterInit
                                                objectToJSONBlock:^id _Nullable(id object, ORKESerializationContext *context) {
        return [context.imageProvider referenceBySavingImage:object];
    }
                                                jsonToObjectBlock:^id _Nullable(id jsonObject, ORKESerializationContext *context) {
        return [context.imageProvider imageForReference:jsonObject];
    }
                                                skipSerialization:skipSerialization];
}

@implementation ORKESerializableTableEntry

- (instancetype)initWithClass:(Class)class
                    initBlock:(ORKESerializationInitBlock)initBlock
                   properties:(NSDictionary *)properties {
    self = [super init];
    if (self) {
        _class = class;
        _initBlock = initBlock;
        _properties = [properties mutableCopy];
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
                   jsonToObjectBlock:(ORKESerializationJSONToObjectBlock)jsonToObjectBlock
                   skipSerialization:(BOOL)skipSerialization {
    self = [super init];
    if (self) {
        _propertyName = propertyName;
        _valueClass = valueClass;
        _containerClass = containerClass;
        _writeAfterInit = writeAfterInit;
        _objectToJSONBlock = objectToJSON;
        _jsonToObjectBlock = jsonToObjectBlock;
        _skipSerialization = skipSerialization;
    }
    return self;
}

@end

@implementation ORKESerializationContext

- (instancetype)initWithLocalizer:(nullable ORKESerializationLocalizer *)localizer
                    imageProvider:(nullable id<ORKESerializationImageProvider>)imageProvider
               stringInterpolator:(nullable id<ORKESerializationStringInterpolator>)stringInterpolator
                 propertyInjector:(nullable ORKESerializationPropertyInjector *)propertyInjector {
    self = [super init];
    if (self) {
        _localizer = localizer;
        _imageProvider = imageProvider;
        _stringInterpolator = stringInterpolator;
        _propertyInjector = propertyInjector;
    }
    return self;
}

- (instancetype)initWithBundle:(NSBundle *)bundle
         localizationTableName:(NSString *)localizationTableName
            stringInterpolator:(nullable id<ORKESerializationStringInterpolator>)stringInterpolator
             propertyModifiers:(NSArray<ORKESerializationPropertyModifier *> *)modifiers {
    ORKESerializationLocalizer *localizer = [[ORKESerializationLocalizer alloc] initWithBundle:bundle tableName:localizationTableName];
    ORKESerializationBundleImageProvider *imageProvider = [[ORKESerializationBundleImageProvider alloc] initWithBundle:bundle];
    ORKESerializationPropertyInjector *propertyInjector = [[ORKESerializationPropertyInjector alloc] initWithBundle:bundle modifiers:modifiers];
    return [self initWithLocalizer:localizer imageProvider:imageProvider stringInterpolator:stringInterpolator propertyInjector:propertyInjector];
}

- (instancetype)initWithBundle:(NSBundle *)bundle
         localizationTableName:(NSString *)localizationTableName
             propertyModifiers:(NSArray<ORKESerializationPropertyModifier *> *)modifiers {
    return [self initWithBundle:bundle localizationTableName:localizationTableName stringInterpolator:nil propertyModifiers:modifiers];
}

@end

static id propFromDict(NSDictionary *dict, NSString *propName, ORKESerializationContext *context) {
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
    if (input == nil) {
        input = dict[dontKnowFakePropertyName(propName)];
        propertyClass = [ORKDontKnowAnswer class];
        converterBlock = nil;
    }
    id output = nil;
    if (input != nil) {
        if ([containerClass isSubclassOfClass:[NSArray class]]) {
            NSMutableArray *outputArray = [NSMutableArray array];
            for (id value in DYNAMICCAST(input, NSArray)) {
                id convertedValue = objectForJsonObject(value, propertyClass, converterBlock, context);
                NSCAssert(convertedValue != nil, @"Could not convert to object of class %@", propertyClass);
                [outputArray addObject:convertedValue];
            }
            output = outputArray;
        } else if ([containerClass isSubclassOfClass:[NSDictionary class]]) {
            NSMutableDictionary *outputDictionary = [NSMutableDictionary dictionary];
            for (NSString *key in [DYNAMICCAST(input, NSDictionary) allKeys]) {
                id convertedValue = objectForJsonObject(DYNAMICCAST(input, NSDictionary)[key], propertyClass, converterBlock, nil);
                NSCAssert(convertedValue != nil, @"Could not convert to object of class %@", propertyClass);
                outputDictionary[key] = convertedValue;
            }
            output = outputDictionary;
        } else {
            NSCAssert(containerClass == [NSObject class], @"Unexpected container class %@", containerClass);
            
            output = objectForJsonObject(input, propertyClass, converterBlock, context);

            // Edge case for ORKAnswerFormat options. Certain formats (e.g. ORKTextChoiceAnswerFormat) contain
            // text strings (e.g. 'Yes', 'No') that need to be localized but are already of the expected type.
            //
            // Remaining localization/interpolication is done in `objectForJsonObject`.
            if ([output isKindOfClass:[NSString class]] && ![propName isEqualToString:@"identifier"]) {
                ORKESerializationLocalizer *localizer = context.localizer;
                id<ORKESerializationStringInterpolator> stringInterpolator = context.stringInterpolator;

                if (localizer != nil) {
                    output =  [localizer localizedStringForString:output];
                }

                if (stringInterpolator != nil) {
                    output = [stringInterpolator interpolatedStringForString:output];
                }
            }
        }
    }
    return output;
}

@implementation ORKESerializationLocalizer

- (instancetype)initWithBundle:(NSBundle *)bundle tableName:(NSString *)tableName {
    self = [super init];
    if (self) {
        _bundle = bundle;
        _tableName = [tableName copy];
    }
    return self;
}

- (NSString *)localizedStringForString:(NSString *)string
{
    // Keys that exist in the localization table will be localized.
    //
    // If the key is not found in the table the provided key string will be returned as is,
    // supporting the expected functionality for inputs that contain both strings to be
    // localized as well as strings to be displayed as is.
    return [self.bundle localizedStringForKey:string value:string table:self.tableName];
}

@end


#define NUMTOSTRINGBLOCK(table) ^id(id num, __unused ORKESerializationContext *context) { return table[((NSNumber *)num).unsignedIntegerValue]; }
#define STRINGTONUMBLOCK(table) ^id(id string, __unused ORKESerializationContext *context) { NSUInteger index = [table indexOfObject:string]; \
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
static NSMutableDictionary<NSString *, ORKESerializableTableEntry *> *ORKESerializationEncodingTable() {
    static dispatch_once_t onceToken;
    static NSMutableDictionary<NSString *, ORKESerializableTableEntry *> *internalEncodingTable = nil;
    dispatch_once(&onceToken, ^{
        internalEncodingTable =
        [@{
           ENTRY(ORKResultSelector,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKResultSelector *selector = [[ORKResultSelector alloc] initWithTaskIdentifier:GETPROP(dict, taskIdentifier)
                                                                                      stepIdentifier:GETPROP(dict, stepIdentifier)
                                                                                    resultIdentifier:GETPROP(dict, resultIdentifier)];
                     return selector;
                 },
                 (@{
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
                 },
                 (@{
                      PROPERTY(resultPredicates, NSPredicate, NSArray, NO, nil, nil),
                      PROPERTY(destinationStepIdentifiers, NSString, NSArray, NO, nil, nil),
                      PROPERTY(defaultStepIdentifier, NSString, NSObject, NO, nil, nil),
                      PROPERTY(additionalTaskResults, ORKTaskResult, NSArray, YES, nil, nil),
                      })),
           ENTRY(ORKDirectStepNavigationRule,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKDirectStepNavigationRule *rule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:GETPROP(dict, destinationStepIdentifier)];
                     return rule;
                 },
                 (@{
                      PROPERTY(destinationStepIdentifier, NSString, NSObject, NO, nil, nil),
                      })),
           ENTRY(ORKAudioLevelNavigationRule,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKAudioLevelNavigationRule *rule = [[ORKAudioLevelNavigationRule alloc] initWithAudioLevelStepIdentifier:GETPROP(dict, audioLevelStepIdentifier)                                                                                             destinationStepIdentifier:GETPROP(dict, destinationStepIdentifier)
                                                                                                             recordingSettings:GETPROP(dict, recordingSettings)];
                     return rule;
                 },
                 (@{
                      PROPERTY(audioLevelStepIdentifier, NSString, NSObject, NO, nil, nil),
                      PROPERTY(destinationStepIdentifier, NSString, NSObject, NO, nil, nil),
                      PROPERTY(recordingSettings, NSDictionary, NSObject, NO, nil, nil),
                      })),
           ENTRY(ORKOrderedTask,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                                                 steps:GETPROP(dict, steps)];
                     return task;
                 },
                 (@{
                      PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
                      PROPERTY(steps, ORKStep, NSArray, NO, nil, nil),
                      })),
           ENTRY(ORKNavigableOrderedTask,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                                                                   steps:GETPROP(dict, steps)];
                     return task;
                 },
                 (@{
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
                    PROPERTY(detailText, NSString, NSObject, YES, nil, nil),
                    PROPERTY(headerTextAlignment, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(footnote, NSString, NSObject, YES, nil, nil),
                    PROPERTY(shouldTintImages, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(useSurveyMode, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(bodyItems, ORKBodyItem, NSArray, YES, nil, nil),
                    PROPERTY(imageContentMode, NSNumber, NSObject, YES, nil, nil),
                    IMAGEPROPERTY(iconImage, NSObject, YES),
                    IMAGEPROPERTY(auxiliaryImage, NSObject, YES),
                    IMAGEPROPERTY(image, NSObject, YES),
                    PROPERTY(bodyItemTextAlignment, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(buildInBodyItems, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(useExtendedPadding, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKBodyItem,
                 ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
                     ORKBodyItem *bodyItem = [[ORKBodyItem alloc] initWithText:GETPROP(dict, text)
                                                                    detailText:GETPROP(dict, detailText)
                                                                         image:nil
                                                                 learnMoreItem:GETPROP(dict, learnMoreItem)
                                                                 bodyItemStyle:[GETPROP(dict, bodyItemStyle) intValue]
                                                                  useCardStyle:GETPROP(dict, useCardStyle)];
                     return bodyItem;
                 },
                 (@{
                    PROPERTY(text, NSString, NSObject, NO, nil, nil),
                    PROPERTY(detailText, NSString, NSObject, NO, nil, nil),
                    PROPERTY(bodyItemStyle, NSNumber, NSObject, NO, nil, nil),
                    IMAGEPROPERTY(image, NSObject, YES),
                    PROPERTY(learnMoreItem, ORKLearnMoreItem, NSObject, YES, nil, nil),
                    PROPERTY(useCardStyle, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(useSecondaryColor, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKLearnMoreItem,
                 ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
                     ORKLearnMoreItem *learnMoreItem = [[ORKLearnMoreItem alloc] initWithText:GETPROP(dict, text) learnMoreInstructionStep:GETPROP(dict, learnMoreInstructionStep)];
                     return learnMoreItem;
                 },
                 (@{
                    PROPERTY(text, NSString, NSObject, YES, nil, nil),
                    PROPERTY(learnMoreInstructionStep, ORKLearnMoreInstructionStep, NSObject, YES, nil, nil),
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
                    PROPERTY(excludeInstructionSteps, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKVisualConsentStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKVisualConsentStep alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                                    document:GETPROP(dict, consentDocument)];
                 },
                 (@{
                   PROPERTY(consentDocument, ORKConsentDocument, NSObject, NO, nil, nil),
                   })),
           ENTRY(ORKPDFViewerStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKPDFViewerStep alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                                  pdfURL:GETPROP(dict, pdfURL)];
                 },
                 (@{
                    PROPERTY(pdfURL, NSURL, NSObject, YES,
                             ^id(id url, __unused ORKESerializationContext *context) { return [(NSURL *)url absoluteString]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [NSURL URLWithString:string]; }),
                    PROPERTY(actionBarOption, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKPasscodeStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKPasscodeStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(passcodeType, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(useBiometrics, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(passcodeFlow, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKWaitStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKWaitStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(indicatorType, NSNumber, NSObject, YES, nil, nil),
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
                    PROPERTY(placeholder, NSString, NSObject, YES, nil, nil),
                    PROPERTY(question, NSString, NSObject, YES, nil, nil),
                    PROPERTY(useCardView, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(learnMoreItem, ORKLearnMoreItem, NSObject, YES, nil, nil),
                    PROPERTY(tagText, NSString, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKInstructionStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKInstructionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(detailText, NSString, NSObject, YES, nil, nil),
                    PROPERTY(footnote, NSString, NSObject, YES, nil, nil),
                    PROPERTY(centerImageVertically, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKLearnMoreInstructionStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKLearnMoreInstructionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    })),
           ENTRY(ORKLearnMoreItem,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKLearnMoreItem alloc] initWithText:GETPROP(dict, text) learnMoreInstructionStep:GETPROP(dict, learnMoreInstructionStep)];
                 },
                 (@{
                    PROPERTY(text, NSString, NSObject, YES, nil, nil),
                    PROPERTY(learnMoreInstructionStep, ORKLearnMoreInstructionStep, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKSecondaryTaskStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKSecondaryTaskStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(secondaryTask, ORKOrderedTask, NSObject, YES, nil, nil),
                    PROPERTY(secondaryTaskButtonTitle, NSString, NSObject, YES, nil, nil),
                    PROPERTY(nextButtonTitle, NSString, NSObject, YES, nil, nil),
                    PROPERTY(requiredAttempts, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKVideoInstructionStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKVideoInstructionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(videoURL, NSURL, NSObject, YES,
                             ^id(id url, __unused ORKESerializationContext *context) { return [(NSURL *)url absoluteString]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [NSURL URLWithString:string]; }),
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
           ENTRY(ORKWebViewStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKWebViewStep *step = [[ORKWebViewStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                     return step;
                 },
                 (@{
                    PROPERTY(html, NSString, NSObject, YES, nil, nil),
                    PROPERTY(customCSS, NSString, NSObject, YES, nil, nil),
                    PROPERTY(showSignatureAfterContent, NSNumber, NSObject, YES, nil, nil)
                    })),
           ENTRY(ORKWebViewStepResult,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKWebViewStepResult *result = [[ORKWebViewStepResult alloc] initWithIdentifier:GETPROP(dict, identifier)];
                     return result;
                 },
                 (@{
                    PROPERTY(result, NSString, NSObject, YES, nil, nil)
                    })),
           ENTRY(ORKHealthQuantityTypeRecorderConfiguration,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKHealthQuantityTypeRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier) healthQuantityType:GETPROP(dict, quantityType) unit:GETPROP(dict, unit)];
                 },
                 (@{
                    PROPERTY(quantityType, HKQuantityType, NSObject, NO,
                             ^id(id type, __unused ORKESerializationContext *context) { return [(HKQuantityType *)type identifier]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [HKQuantityType quantityTypeForIdentifier:string]; }),
                    PROPERTY(unit, HKUnit, NSObject, NO,
                             ^id(id unit, __unused ORKESerializationContext *context) { return [(HKUnit *)unit unitString]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [HKUnit unitFromString:string]; }),
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
                    PROPERTY(recorderConfigurations, ORKRecorderConfiguration, NSArray, YES, nil, nil)
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
                 ((@{
                     PROPERTY(toneDuration, NSNumber, NSObject, YES, nil, nil),
                     PROPERTY(practiceStep, NSNumber, NSObject, YES, nil, nil),
                     }))),
           ENTRY(ORKdBHLToneAudiometryStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKdBHLToneAudiometryStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(toneDuration, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(maxRandomPreStimulusDelay, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(postStimulusDelay, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(maxNumberOfTransitionsPerFrequency, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(initialdBHLValue, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(dBHLStepUpSize, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(dBHLStepUpSizeFirstMiss, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(dBHLStepUpSizeSecondMiss, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(dBHLStepUpSizeThirdMiss, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(dBHLStepDownSize, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(dBHLMinimumThreshold, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(headphoneType, NSString, NSObject, YES, nil, nil),
                    PROPERTY(earPreference, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(frequencyList, NSArray, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKHolePegTestPlaceStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKHolePegTestPlaceStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(movingDirection, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(dominantHandTested, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(numberOfPegs, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(threshold, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(rotated, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKHolePegTestRemoveStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKHolePegTestRemoveStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(movingDirection, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(dominantHandTested, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(numberOfPegs, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(threshold, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKImageCaptureStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKImageCaptureStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(templateImageInsets, NSValue, NSObject, YES,
                             ^id(id value, __unused ORKESerializationContext *context) { return value?dictionaryFromUIEdgeInsets(((NSValue *)value).UIEdgeInsetsValue):nil; },
                             ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithUIEdgeInsets:edgeInsetsFromDictionary(dict)]; }),
                    PROPERTY(accessibilityHint, NSString, NSObject, YES, nil, nil),
                    PROPERTY(accessibilityInstructions, NSString, NSObject, YES, nil, nil),
                    PROPERTY(captureRaw, NSNumber, NSObject, YES, nil, nil),
                    IMAGEPROPERTY(templateImage, NSObject, YES),
                    })),
           ENTRY(ORKVideoCaptureStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKVideoCaptureStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(templateImageInsets, NSValue, NSObject, YES,
                             ^id(id value, __unused ORKESerializationContext *context) { return value?dictionaryFromUIEdgeInsets(((NSValue *)value).UIEdgeInsetsValue):nil; },
                             ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithUIEdgeInsets:edgeInsetsFromDictionary(dict)]; }),
                    PROPERTY(duration, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(audioMute, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(torchMode, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(devicePosition, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(accessibilityHint, NSString, NSObject, YES, nil, nil),
                    PROPERTY(accessibilityInstructions, NSString, NSObject, YES, nil, nil),
                    IMAGEPROPERTY(templateImage, NSObject, YES),
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
                    IMAGEPROPERTY(customTargetImage, NSObject, YES),
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
                 ((@{
                     PROPERTY(items, NSObject, NSArray, YES, nil, nil),
                     PROPERTY(isBulleted, NSNumber, NSObject, YES, nil, nil),
                     PROPERTY(bulletIconNames, NSString, NSArray, YES, nil, nil),
                     PROPERTY(allowsSelection, NSNumber, NSObject, YES, nil, nil),
                     PROPERTY(bulletType, NSNumber, NSObject, YES, nil, nil),
                     PROPERTY(pinNavigationContainer, NSNumber, NSObject, YES, nil, nil),
                     }))),
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
                     return [[ORKRangeOfMotionStep alloc] initWithIdentifier:GETPROP(dict, identifier) limbOption:(NSUInteger)[GETPROP(dict, identifier) integerValue]];
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
           ENTRY(ORKStroopStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKStroopStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(numberOfAttempts, NSNumber, NSObject, YES, nil, nil)})),
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
           ENTRY(ORKSpeechInNoiseStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKSpeechInNoiseStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 ((@{
                     PROPERTY(speechFileNameWithExtension, NSString, NSObject, YES, nil, nil),
                     PROPERTY(noiseFileNameWithExtension, NSString, NSObject, YES, nil, nil),
                     PROPERTY(filterFileNameWithExtension, NSString, NSObject, YES, nil, nil),
                     PROPERTY(gainAppliedToNoise, NSNumber, NSObject, YES, nil, nil),
                     PROPERTY(willAudioLoop, NSNumber, NSObject, YES, nil, nil),
                     PROPERTY(hideGraphView, NSNumber, NSObject, YES, nil, nil),
                     }))),
           ENTRY(ORKSpeechRecognitionStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKSpeechRecognitionStep alloc] initWithIdentifier:GETPROP(dict, identifier) image:nil text:GETPROP(dict, speechRecognitionText)];
                 },
                 (@{
                    PROPERTY(shouldHideTranscript, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(speechRecognitionText, NSString, NSObject, NO, nil, nil),
                    PROPERTY(speechRecognizerLocale, NSString, NSObject, YES, nil, nil)
                    })),
           ENTRY(ORKEnvironmentSPLMeterStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKEnvironmentSPLMeterStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(thresholdValue, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(samplingInterval, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(requiredContiguousSamples, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKEnvironmentSPLMeterResult,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKEnvironmentSPLMeterResult alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(sensitivityOffset, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(recordedSPLMeterSamples, NSNumber, NSArray, YES, nil, nil)
                    })),
           ENTRY(ORKStreamingAudioRecorderConfiguration,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKStreamingAudioRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
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
           ENTRY(ORKAmslerGridStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKAmslerGridStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(eyeSide, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKAmslerGridResult,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKAmslerGridResult alloc] initWithIdentifier:GETPROP(dict, identifier)image:[UIImage new] path:GETPROP(dict, path) eyeSide:(ORKAmslerGridEyeSide)[GETPROP(dict, eyeSide) integerValue]];
                 },
                 (@{
                    PROPERTY(eyeSide, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(path, UIBezierPath, NSArray, NO, nil, nil),
                    IMAGEPROPERTY(image, NSObject, YES),
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
                    PROPERTY(requiresScrollToBottom, NSNumber, NSObject, YES, nil, nil)
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
                             ^id(id url, __unused ORKESerializationContext *context) { return [(NSURL *)url absoluteString]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [NSURL URLWithString:string]; }),
                    PROPERTY(customLearnMoreButtonTitle, NSString, NSObject, YES, nil, nil),
                    PROPERTY(customAnimationURL, NSURL, NSObject, YES,
                             ^id(id url, __unused ORKESerializationContext *context) { return [(NSURL *)url absoluteString]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [NSURL URLWithString:string]; }),
                    PROPERTY(omitFromDocument, NSNumber, NSObject, YES, nil, nil),
                    IMAGEPROPERTY(customImage, NSObject, YES),
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
                    IMAGEPROPERTY(signatureImage, NSObject, YES),
                    })),
           ENTRY(ORKRegistrationStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKRegistrationStep alloc] initWithIdentifier:GETPROP(dict, identifier) title:GETPROP(dict, title) text:GETPROP(dict, text) options:(NSUInteger)((NSNumber *)GETPROP(dict, options)).integerValue];
                 },
                 (@{
                    PROPERTY(options, NSNumber, NSObject, NO, nil, nil)
                    })),
           ENTRY(ORKRequestPermissionsStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKRequestPermissionsStep alloc] initWithIdentifier:GETPROP(dict, identifier) permissionTypes:GETPROP(dict, permissionTypes)];
                 },
                 (@{
                    PROPERTY(permissionTypes, ORKPermissionType, NSArray, YES, nil, nil)
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
           ENTRY(ORKdBHLToneAudiometryOnboardingStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKdBHLToneAudiometryOnboardingStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(useCardView, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKFormStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKFormStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                    PROPERTY(formItems, ORKFormItem, NSArray, YES, nil, nil),
                    PROPERTY(footnote, NSString, NSObject, YES, nil, nil),
                    PROPERTY(useCardView, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(footerText, NSString, NSObject, YES, nil, nil),
                    PROPERTY(cardViewStyle, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKFormItem,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKFormItem alloc] initWithIdentifier:GETPROP(dict, identifier) text:GETPROP(dict, text) answerFormat:GETPROP(dict, answerFormat)];
                 },
                 (@{
                    PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
                    PROPERTY(optional, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(showsProgress, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(text, NSString, NSObject, NO, nil, nil),
                    PROPERTY(detailText, NSString, NSObject, YES, nil, nil),
                    PROPERTY(placeholder, NSString, NSObject, YES, nil, nil),
                    PROPERTY(answerFormat, ORKAnswerFormat, NSObject, NO, nil, nil),
                    PROPERTY(learnMoreItem, ORKLearnMoreItem, NSObject, YES, nil, nil),
                    PROPERTY(tagText, NSString, NSObject, YES, nil, nil),
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
                             ^id(id type, __unused ORKESerializationContext *context) { return [(HKCharacteristicType *)type identifier]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [HKCharacteristicType characteristicTypeForIdentifier:string]; }),
                    PROPERTY(defaultDate, NSDate, NSObject, YES,
                             ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                    PROPERTY(minimumDate, NSDate, NSObject, YES,
                             ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                    PROPERTY(maximumDate, NSDate, NSObject, YES,
                             ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                    PROPERTY(calendar, NSCalendar, NSObject, YES,
                             ^id(id calendar, __unused ORKESerializationContext *context) { return [(NSCalendar *)calendar calendarIdentifier]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [NSCalendar calendarWithIdentifier:string]; }),
                    PROPERTY(shouldRequestAuthorization, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKHealthKitQuantityTypeAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKHealthKitQuantityTypeAnswerFormat alloc] initWithQuantityType:GETPROP(dict, quantityType) unit:GETPROP(dict, unit) style:((NSNumber *)GETPROP(dict, numericAnswerStyle)).integerValue];
                 },
                 (@{
                    PROPERTY(unit, HKUnit, NSObject, NO,
                             ^id(id unit, __unused ORKESerializationContext *context) { return [(HKUnit *)unit unitString]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [HKUnit unitFromString:string]; }),
                    PROPERTY(quantityType, HKQuantityType, NSObject, NO,
                             ^id(id type, __unused ORKESerializationContext *context) { return [(HKQuantityType *)type identifier]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [HKQuantityType quantityTypeForIdentifier:string]; }),
                    PROPERTY(numericAnswerStyle, NSNumber, NSObject, NO,
                             ^id(id num, __unused ORKESerializationContext *context) { return ORKNumericAnswerStyleToString(((NSNumber *)num).integerValue); },
                             ^id(id string, __unused ORKESerializationContext *context) { return @(ORKNumericAnswerStyleFromString(string)); }),
                    PROPERTY(shouldRequestAuthorization, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKAnswerFormat,
                 nil,
                 (@{
                     PROPERTY(showDontKnowButton, NSNumber, NSObject, YES, nil, nil),
                     PROPERTY(customDontKnowButtonText, NSString, NSObject, YES, nil, nil)
                    })),
           ENTRY(ORKDontKnowAnswer,
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
                     return [[ORKImageChoiceAnswerFormat alloc] initWithImageChoices:GETPROP(dict, imageChoices) style:((NSNumber *)GETPROP(dict, style)).integerValue vertical:((NSNumber *)GETPROP(dict, vertical)).boolValue];
                 },
                 (@{
                    PROPERTY(imageChoices, ORKImageChoice, NSArray, NO, nil, nil),
                    PROPERTY(style, NSNumber, NSObject, NO,
                             ^id(id number, __unused ORKESerializationContext *context) { return ORKImageChoiceAnswerStyleToString(((NSNumber *)number).integerValue); },
                             ^id(id string, __unused ORKESerializationContext *context) { return @(ORKImageChoiceAnswerStyleFromString(string)); }),
                    PROPERTY(vertical, NSNumber, NSObject, NO, nil, nil),
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
           ENTRY(ORKTextChoiceOther,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKTextChoiceOther alloc] initWithText:GETPROP(dict, text) primaryTextAttributedString:nil detailText:GETPROP(dict, detailText) detailTextAttributedString:nil value:GETPROP(dict, value) exclusive:((NSNumber *)GETPROP(dict, exclusive)).boolValue textViewPlaceholderText:GETPROP(dict, textViewPlaceholderText) textViewInputOptional:((NSNumber *)GETPROP(dict, textViewInputOptional)).boolValue textViewStartsHidden:((NSNumber *)GETPROP(dict, textViewStartsHidden)).boolValue];
                 },
                 (@{
                    PROPERTY(textViewPlaceholderText, NSString, NSObject, NO, nil, nil),
                    PROPERTY(textViewInputOptional, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(textViewStartsHidden, NSNumber, NSObject, NO, nil, nil),
                    })),
           ENTRY(ORKImageChoice,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKImageChoice alloc] initWithNormalImage:nil selectedImage:nil text:GETPROP(dict, text) value:GETPROP(dict, value)];
                 },
                 (@{
                    PROPERTY(text, NSString, NSObject, NO, nil, nil),
                    PROPERTY(value, NSObject, NSObject, NO, nil, nil),
                    IMAGEPROPERTY(normalStateImage, NSObject, YES),
                    IMAGEPROPERTY(selectedStateImage, NSObject, YES),
                    })),
           ENTRY(ORKTimeOfDayAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKTimeOfDayAnswerFormat alloc] initWithDefaultComponents:GETPROP(dict, defaultComponents)];
                 },
                 (@{
                    PROPERTY(defaultComponents, NSDateComponents, NSObject, NO,
                             ^id(id components, __unused ORKESerializationContext *context) { return ORKTimeOfDayStringFromComponents(components);  },
                             ^id(id string, __unused ORKESerializationContext *context) { return ORKTimeOfDayComponentsFromString(string); }),
                    PROPERTY(minuteInterval, NSNumber, NSObject, YES, nil, nil)
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
                             ^id(id calendar, __unused ORKESerializationContext *context) { return [(NSCalendar *)calendar calendarIdentifier]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [NSCalendar calendarWithIdentifier:string]; }),
                    PROPERTY(minimumDate, NSDate, NSObject, NO,
                             ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                    PROPERTY(maximumDate, NSDate, NSObject, NO,
                             ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                    PROPERTY(defaultDate, NSDate, NSObject, NO,
                             ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                    PROPERTY(minuteInterval, NSNumber, NSObject, YES, nil, nil),
                    })),
           ENTRY(ORKNumericAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     ORKNumericAnswerFormat *format = [[ORKNumericAnswerFormat alloc] initWithStyle:((NSNumber *)GETPROP(dict, style)).integerValue
                                                                                               unit:GETPROP(dict, unit)
                                                                                            minimum:GETPROP(dict, minimum)
                                                                                            maximum:GETPROP(dict, maximum)
                                                                              maximumFractionDigits:GETPROP(dict, maximumFractionDigits)];
                     format.defaultNumericAnswer = GETPROP(dict, defaultNumericAnswer);
                     return format;
                 },
                 (@{
                    PROPERTY(style, NSNumber, NSObject, NO,
                             ^id(id num, __unused ORKESerializationContext *context) { return ORKNumericAnswerStyleToString(((NSNumber *)num).integerValue); },
                             ^id(id string, __unused ORKESerializationContext *context) { return @(ORKNumericAnswerStyleFromString(string)); }),
                    PROPERTY(unit, NSString, NSObject, NO, nil, nil),
                    PROPERTY(minimum, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(maximum, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(maximumFractionDigits, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(defaultNumericAnswer, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(hideUnitWhenAnswerIsEmpty, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(placeholder, NSString, NSObject, YES, nil, nil)
                    })),
           ENTRY(ORKScaleAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     NSNumber *defaultValue = (NSNumber *)GETPROP(dict, defaultValue);
                     // FIXME:- We are adding this for scenarios where the payload does not have the "defaultValue" key
                     if (defaultValue == nil) {
                         defaultValue = [[NSNumber alloc] initWithInt:INT_MAX];
                     }
                     return [[ORKScaleAnswerFormat alloc] initWithMaximumValue:((NSNumber *)GETPROP(dict, maximum)).integerValue
                                                                  minimumValue:((NSNumber *)GETPROP(dict, minimum)).integerValue
                                                                  defaultValue:defaultValue.integerValue
                                                                          step:((NSNumber *)GETPROP(dict, step)).integerValue
                                                                      vertical:((NSNumber *)GETPROP(dict, vertical)).boolValue
                                                       maximumValueDescription:GETPROP(dict, maximumValueDescription)
                                                       minimumValueDescription:GETPROP(dict, minimumValueDescription)];
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
                    PROPERTY(gradientLocations, NSNumber, NSArray, YES, nil, nil),
                    PROPERTY(hideSelectedValue, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideRanges, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideLabels, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideValueMarkers, NSNumber, NSObject, YES, nil, nil),
                    IMAGEPROPERTY(minimumImage, NSObject, YES),
                    IMAGEPROPERTY(maximumImage, NSObject, YES),
                    })),
           ENTRY(ORKContinuousScaleAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     NSNumber *defaultValue = (NSNumber *)GETPROP(dict, defaultValue);
                     // FIXME:- We are adding this for scenarios where the payload does not have the "defaultValue" key
                     if (defaultValue == nil) {
                         defaultValue = [[NSNumber alloc] initWithDouble:DBL_MAX];
                     }
                     return [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:((NSNumber *)GETPROP(dict, maximum)).doubleValue
                                                                            minimumValue:((NSNumber *)GETPROP(dict, minimum)).doubleValue
                                                                            defaultValue:defaultValue.doubleValue
                                                                   maximumFractionDigits:((NSNumber *)GETPROP(dict, maximumFractionDigits)).integerValue
                                                                                vertical:((NSNumber *)GETPROP(dict, vertical)).boolValue
                                                                 maximumValueDescription:GETPROP(dict, maximumValueDescription)
                                                                 minimumValueDescription:GETPROP(dict, minimumValueDescription)];
                 },
                 (@{
                    PROPERTY(minimum, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(maximum, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(defaultValue, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(maximumFractionDigits, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(vertical, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(numberStyle, NSNumber, NSObject, YES,
                             ^id(id numeric, __unused ORKESerializationContext *context) { return tableMapForward(((NSNumber *)numeric).integerValue, numberFormattingStyleTable()); },
                             ^id(id string, __unused ORKESerializationContext *context) { return @(tableMapReverse(string, numberFormattingStyleTable())); }),
                    PROPERTY(maximumValueDescription, NSString, NSObject, NO, nil, nil),
                    PROPERTY(minimumValueDescription, NSString, NSObject, NO, nil, nil),
                    PROPERTY(gradientColors, UIColor, NSArray, YES, nil, nil),
                    PROPERTY(gradientLocations, NSNumber, NSArray, YES, nil, nil),
                    PROPERTY(hideSelectedValue, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideRanges, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideLabels, NSNumber, NSObject, YES, nil, nil),
                    IMAGEPROPERTY(minimumImage, NSObject, YES),
                    IMAGEPROPERTY(maximumImage, NSObject, YES),
                    })),
           ENTRY(ORKTextScaleAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKTextScaleAnswerFormat alloc] initWithTextChoices:GETPROP(dict, textChoices) defaultIndex:(NSInteger)[GETPROP(dict, defaultIndex) doubleValue] vertical:[GETPROP(dict, vertical) boolValue]];
                 },
                 (@{
                    PROPERTY(textChoices, ORKTextChoice, NSArray<ORKTextChoice *>, NO, nil, nil),
                    PROPERTY(defaultIndex, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(vertical, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(gradientColors, UIColor, NSArray, YES, nil, nil),
                    PROPERTY(gradientLocations, NSNumber, NSArray, YES, nil, nil),
                    PROPERTY(hideSelectedValue, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideRanges, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideLabels, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideValueMarkers, NSNumber, NSObject, YES, nil, nil)
                    })),
           ENTRY(ORKTextAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKTextAnswerFormat alloc] initWithMaximumLength:((NSNumber *)GETPROP(dict, maximumLength)).integerValue];
                 },
                 (@{
                    PROPERTY(maximumLength, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(validationRegularExpression, NSRegularExpression, NSObject, YES,
                             ^id(id value, __unused ORKESerializationContext *context) { return dictionaryFromRegularExpression((NSRegularExpression *)value); },
                             ^id(id dict, __unused ORKESerializationContext *context) { return regularExpressionsFromDictionary(dict); } ),
                    PROPERTY(invalidMessage, NSString, NSObject, YES, nil, nil),
                    PROPERTY(defaultTextAnswer, NSString, NSObject, YES, nil, nil),
                    PROPERTY(autocapitalizationType, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(autocorrectionType, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(spellCheckingType, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(keyboardType, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(multipleLines, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideClearButton, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(hideCharacterCountLabel, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(secureTextEntry, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(textContentType, NSString, NSObject, YES, nil, nil),
                    PROPERTY(passwordRules, UITextInputPasswordRules, NSObject, YES,
                             ^id(id value, __unused ORKESerializationContext *context) { return dictionaryFromPasswordRules((UITextInputPasswordRules *)value); },
                             ^id(id dict, __unused ORKESerializationContext *context) { return passwordRulesFromDictionary(dict); } ),
                    PROPERTY(placeholder, NSString, NSObject, YES, nil, nil)
                    })),
           ENTRY(ORKEmailAnswerFormat,
                 nil,
                 (@{
                    PROPERTY(usernameField, NSNumber, NSObject, YES, nil, nil),
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
                    PROPERTY(measurementSystem, NSNumber, NSObject, NO,
                             ^id(id number, __unused ORKESerializationContext *context) { return ORKMeasurementSystemToString(((NSNumber *)number).integerValue); },
                             ^id(id string, __unused ORKESerializationContext *context) { return @(ORKMeasurementSystemFromString(string)); }),
                    })),
           ENTRY(ORKWeightAnswerFormat,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKWeightAnswerFormat alloc] initWithMeasurementSystem:((NSNumber *)GETPROP(dict, measurementSystem)).integerValue
                                                                    numericPrecision:((NSNumber *)GETPROP(dict, numericPrecision)).integerValue
                                                                        minimumValue:((NSNumber *)GETPROP(dict, minimumValue)).doubleValue
                                                                        maximumValue:((NSNumber *)GETPROP(dict, maximumValue)).doubleValue
                                                                        defaultValue:((NSNumber *)GETPROP(dict, defaultValue)).doubleValue];
                 },
                 (@{
                    PROPERTY(measurementSystem, NSNumber, NSObject, NO,
                             ^id(id number, __unused ORKESerializationContext *context) { return ORKMeasurementSystemToString(((NSNumber *)number).integerValue); },
                             ^id(id string, __unused ORKESerializationContext *context) { return @(ORKMeasurementSystemFromString(string)); }),
                    PROPERTY(numericPrecision, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(minimumValue, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(maximumValue, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(defaultValue, NSNumber, NSObject, NO, nil, nil),
                    })),
           ENTRY(ORKLocationAnswerFormat,
                 ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
                     return [[ORKLocationAnswerFormat alloc] init];
                 },
                 (@{
                    PROPERTY(useCurrentLocation, NSNumber, NSObject, YES, nil, nil),
                    PROPERTY(placeholder, NSString, NSObject, YES, nil, nil)
                    })),
           ENTRY(ORKSESAnswerFormat,
                 ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
               return [[ORKSESAnswerFormat alloc] init];
           },
                 (@{
                     PROPERTY(topRungText, NSString, NSObject, YES, nil, nil),
                     PROPERTY(bottomRungText, NSString, NSObject, YES, nil, nil)
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
                             ^id(id date, __unused ORKESerializationContext *context) { return ORKEStringFromDateISO8601(date); },
                             ^id(id string, __unused ORKESerializationContext *context) { return ORKEDateFromStringISO8601(string); }),
                    PROPERTY(endDate, NSDate, NSObject, YES,
                             ^id(id date, __unused ORKESerializationContext *context) { return ORKEStringFromDateISO8601(date); },
                             ^id(id string, __unused ORKESerializationContext *context) { return ORKEDateFromStringISO8601(string); }),
                    PROPERTY(userInfo, NSDictionary, NSObject, YES, nil, nil)
                    })),
           ENTRY(ORKTappingSample,
                 nil,
                 (@{
                    PROPERTY(timestamp, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(duration, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(buttonIdentifier, NSNumber, NSObject, NO,
                             ^id(id numeric, __unused ORKESerializationContext *context) { return tableMapForward(((NSNumber *)numeric).integerValue, buttonIdentifierTable()); },
                             ^id(id string, __unused ORKESerializationContext *context) { return @(tableMapReverse(string, buttonIdentifierTable())); }),
                    PROPERTY(location, NSValue, NSObject, NO,
                             ^id(id value, __unused ORKESerializationContext *context) { return value?dictionaryFromCGPoint(((NSValue *)value).CGPointValue):nil; },
                             ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithCGPoint:pointFromDictionary(dict)]; })
                    })),
           ENTRY(ORKTappingIntervalResult,
                 nil,
                 (@{
                    PROPERTY(samples, ORKTappingSample, NSArray, NO, nil, nil),
                    PROPERTY(stepViewSize, NSValue, NSObject, NO,
                             ^id(id value, __unused ORKESerializationContext *context) { return value?dictionaryFromCGSize(((NSValue *)value).CGSizeValue):nil; },
                             ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithCGSize:sizeFromDictionary(dict)]; }),
                    PROPERTY(buttonRect1, NSValue, NSObject, NO,
                             ^id(id value, __unused ORKESerializationContext *context) { return value?dictionaryFromCGRect(((NSValue *)value).CGRectValue):nil; },
                             ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithCGRect:rectFromDictionary(dict)]; }),
                    PROPERTY(buttonRect2, NSValue, NSObject, NO,
                             ^id(id value, __unused ORKESerializationContext *context) { return value?dictionaryFromCGRect(((NSValue *)value).CGRectValue):nil; },
                             ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithCGRect:rectFromDictionary(dict)]; })
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
                             ^id(id value, __unused ORKESerializationContext *context) { return value?dictionaryFromCGPoint(((NSValue *)value).CGPointValue):nil; },
                             ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithCGPoint:pointFromDictionary(dict)]; })
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
                             ^id(id numeric, __unused ORKESerializationContext *context) { return tableMapForward(((NSNumber *)numeric).integerValue, memoryGameStatusTable()); },
                             ^id(id string, __unused ORKESerializationContext *context) { return @(tableMapReverse(string, memoryGameStatusTable())); }),
                    PROPERTY(targetRects, NSValue, NSArray, NO,
                             ^id(id value, __unused ORKESerializationContext *context) { return value?dictionaryFromCGRect(((NSValue *)value).CGRectValue):nil; },
                             ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithCGRect:rectFromDictionary(dict)]; })
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
                             ^id(id url, __unused ORKESerializationContext *context) { return [url absoluteString]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [NSURL URLWithString:string]; })
                    })),
           ENTRY(ORKToneAudiometrySample,
                 nil,
                 (@{
                    PROPERTY(frequency, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(channel, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(amplitude, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(channelSelected, NSNumber, NSObject, NO, nil, nil)
                    })),
           ENTRY(ORKToneAudiometryResult,
                 nil,
                 (@{
                    PROPERTY(outputVolume, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(samples, ORKToneAudiometrySample, NSArray, NO, nil, nil),
                    })),
           ENTRY(ORKdBHLToneAudiometryUnit,
                 nil,
                 (@{
                    PROPERTY(dBHLValue, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(startOfUnitTimeStamp, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(preStimulusDelay, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(userTapTimeStamp, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(timeoutTimeStamp, NSNumber, NSObject, NO, nil, nil)
                    })),
           ENTRY(ORKdBHLToneAudiometryFrequencySample,
                 nil,
                 (@{
                    PROPERTY(frequency, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(calculatedThreshold, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(channel, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(units, ORKdBHLToneAudiometryUnit, NSArray, NO, nil, nil)
                    })),
           ENTRY(ORKdBHLToneAudiometryResult,
                 nil,
                 (@{
                    PROPERTY(outputVolume, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(tonePlaybackDuration, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(postStimulusDelay, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(headphoneType, NSString, NSObject, NO, nil, nil),
                    PROPERTY(samples, ORKdBHLToneAudiometryFrequencySample, NSArray, NO, nil, nil),
                    })),
           ENTRY(ORKReactionTimeResult,
                 nil,
                 (@{
                    PROPERTY(timestamp, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(fileResult, ORKResult, NSObject, NO, nil, nil)
                    })),
           ENTRY(ORKSpeechRecognitionResult,
                 nil,
                 (@{
                    PROPERTY(transcription, SFTranscription, NSObject, NO,
                             (^id(id transcription, __unused ORKESerializationContext *context) { return dictionaryFromSFTranscription(transcription); }),
                             // Decode not supported: SFTranscription is immmutable
                             (^id(id __unused transcriptionDict, __unused ORKESerializationContext *context) { return nil; })),
                    })),
           ENTRY(ORKStroopResult,
                 nil,
                 (@{
                    PROPERTY(startTime, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(endTime, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(color, NSString, NSObject, NO, nil, nil),
                    PROPERTY(text, NSString, NSObject, NO, nil, nil),
                    PROPERTY(colorSelected, NSString, NSObject, NO, nil, nil)
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
                    PROPERTY(start, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(finish, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(minimum, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(maximum, NSNumber, NSObject, NO, nil, nil),
                    PROPERTY(range, NSNumber, NSObject, NO, nil, nil),
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
           ENTRY(ORKScaleQuestionResult,
                 nil,
                 (@{
                    PROPERTY(scaleAnswer, NSNumber, NSObject, NO, nil, nil),
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
                             ^id(id dateComponents, __unused ORKESerializationContext *context) { return ORKTimeOfDayStringFromComponents(dateComponents); },
                             ^id(id string, __unused ORKESerializationContext *context) { return ORKTimeOfDayComponentsFromString(string); })
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
                             ^id(id date, __unused ORKESerializationContext *context) { return ORKEStringFromDateISO8601(date); },
                             ^id(id string, __unused ORKESerializationContext *context) { return ORKEDateFromStringISO8601(string); }),
                    PROPERTY(calendar, NSCalendar, NSObject, NO,
                             ^id(id calendar, __unused ORKESerializationContext *context) { return [(NSCalendar *)calendar calendarIdentifier]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [NSCalendar calendarWithIdentifier:string]; }),
                    PROPERTY(timeZone, NSTimeZone, NSObject, NO,
                             ^id(id timeZone, __unused ORKESerializationContext *context) { return @([timeZone secondsFromGMT]); },
                             ^id(id number, __unused ORKESerializationContext *context) { return [NSTimeZone timeZoneForSecondsFromGMT:(NSInteger)((NSNumber *)number).doubleValue]; })
                    })),
           ENTRY(ORKLocation,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     CLLocationCoordinate2D coordinate = coordinateFromDictionary(dict[@ESTRINGIFY(coordinate)]);
                     return [[ORKLocation alloc] initWithCoordinate:coordinate
                                                             region:GETPROP(dict, region)
                                                          userInput:GETPROP(dict, userInput)
                                                      postalAddress:GETPROP(dict, postalAddress)];
                 },
                 (@{
                    PROPERTY(userInput, NSString, NSObject, NO, nil, nil),
                    PROPERTY(postalAddress, CNPostalAddress, NSObject, NO,
                             ^id(id value, __unused ORKESerializationContext *context) { return dictionaryFromPostalAddress(value); },
                             ^id(id dict, __unused ORKESerializationContext *context) { return  postalAddressFromDictionary(dict); }),
                    PROPERTY(coordinate, NSValue, NSObject, NO,
                             ^id(id value, __unused ORKESerializationContext *context) { return value ? dictionaryFromCoordinate(((NSValue *)value).MKCoordinateValue) : nil; },
                             ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithMKCoordinate:coordinateFromDictionary(dict)]; }),
                    PROPERTY(region, CLCircularRegion, NSObject, NO,
                             ^id(id value, __unused ORKESerializationContext *context) { return dictionaryFromCircularRegion((CLCircularRegion *)value); },
                             ^id(id dict, __unused ORKESerializationContext *context) { return circularRegionFromDictionary(dict); }),
                    })),
           ENTRY(ORKLocationQuestionResult,
                 nil,
                 (@{
                    PROPERTY(locationAnswer, ORKLocation, NSObject, NO, nil, nil)
                    })),
           ENTRY(ORKSESQuestionResult,
                 nil,
                 (@{
                     PROPERTY(rungPicked, NSNumber, NSObject, NO, nil, nil)
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
                             ^id(id uuid, __unused ORKESerializationContext *context) { return [uuid UUIDString]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [[NSUUID alloc] initWithUUIDString:string]; }),
                    PROPERTY(outputDirectory, NSURL, NSObject, NO,
                             ^id(id url, __unused ORKESerializationContext *context) { return [url absoluteString]; },
                             ^id(id string, __unused ORKESerializationContext *context) { return [NSURL URLWithString:string]; })
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
           ENTRY(ORK3DModelManager,
          ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
               return [[ORK3DModelManager alloc] init];
           },
           (@{
              PROPERTY(allowsSelection, NSNumber, NSObject, YES, nil, nil),
              PROPERTY(identifiersOfObjectsToHighlight, NSString, NSArray, YES, nil, nil),
              PROPERTY(highlightColor, UIColor, NSObject, YES,
                       ^id(id color, __unused ORKESerializationContext *context) { return dictionaryFromColor(color); },
                       ^id(id dict, __unused ORKESerializationContext *context) { return  colorFromDictionary(dict); })
              })),
           ENTRY(ORKUSDZModelManagerResult,
                 nil,
                 (@{
                     PROPERTY(identifiersOfSelectedObjects, NSString, NSArray, YES, nil, nil),
                     PROPERTY(identifierOfObjectSelectedAtClose, NSString, NSObject, YES, nil, nil)
                  })),
           ENTRY(ORKUSDZModelManager,
           ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKUSDZModelManager alloc] initWithUSDZFileName:GETPROP(dict, fileName)];
            },
            (@{
               PROPERTY(enableContinueAfterSelection, NSNumber, NSObject, YES, nil, nil),
               PROPERTY(fileName, NSString, NSObject, NO, nil, nil),
               })),
           ENTRY(ORK3DModelStep,
           ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORK3DModelStep alloc] initWithIdentifier:GETPROP(dict, identifier) modelManager:GETPROP(dict, modelManager)];
            },
            (@{
               PROPERTY(modelManager, ORK3DModelManager, NSObject, YES, nil, nil),
               })),        
           ENTRY(ORKFrontFacingCameraStep,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                    return [[ORKFrontFacingCameraStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                 },
                 (@{
                     PROPERTY(maximumRecordingLimit, NSNumber, NSObject, YES, nil, nil),
                     PROPERTY(allowsReview, NSNumber, NSObject, YES, nil, nil),
                     PROPERTY(allowsRetry, NSNumber, NSObject, YES, nil, nil)
                    })),
           ENTRY(ORKFrontFacingCameraStepResult,
                 nil,
                 (@{
                     PROPERTY(retryCount, NSNumber, NSObject, NO, nil, nil)
                  })),
           } mutableCopy];
        if (@available(iOS 12.0, *)) {
            [internalEncodingTable addEntriesFromDictionary:@{ ENTRY(ORKHealthClinicalTypeRecorderConfiguration,
                   ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                       return [[ORKHealthClinicalTypeRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier) healthClinicalType:GETPROP(dict, healthClinicalType) healthFHIRResourceType:GETPROP(dict, healthFHIRResourceType)];
                   },
                   (@{
                      PROPERTY(healthClinicalType, HKClinicalType, NSObject, NO,
                               ^id(id type, __unused ORKESerializationContext *context) { return identifierFromClinicalType(type); },
                               ^id(id identifier, __unused ORKESerializationContext *context) { return  typeFromIdentifier(identifier); }),
                      PROPERTY(healthFHIRResourceType, NSString, NSObject, NO, nil, nil),
                      })) }];
        }
    });
    return internalEncodingTable;
}
#undef GETPROP

static NSArray<ORKESerializableTableEntry *> *classEncodingsForClass(Class class) {
    NSDictionary<NSString *, ORKESerializableTableEntry *> *encodingTable = ORKESerializationEncodingTable();
    
    NSMutableArray<ORKESerializableTableEntry *> *classEncodings = [NSMutableArray array];
    Class currentClass = class;
    while (currentClass != nil) {
        NSString *className = NSStringFromClass(currentClass);
        ORKESerializableTableEntry *classEncoding = encodingTable[className];
        if (classEncoding) {
            [classEncodings addObject:classEncoding];
        }
        currentClass = [currentClass superclass];
    }
    return [classEncodings copy];
}

static id objectForJsonObject(id input,
                              Class expectedClass,
                              ORKESerializationJSONToObjectBlock converterBlock,
                              ORKESerializationContext *context) {
    id output = nil;
    
    if (converterBlock != nil) {
        input = converterBlock(input, context);
        if (input == nil) {
            // Object converted to nothing
            return nil;
        }
    }
    
    ORKESerializationLocalizer *localizer = context.localizer;
    id<ORKESerializationStringInterpolator> stringInterpolator = context.stringInterpolator;

    if (expectedClass != nil && [input isKindOfClass:expectedClass]) {
        // Input is already of the expected class, do nothing
        output = input;
    } else if ([input isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)input;
        NSString *className = input[_ClassKey];
        
        ORKESerializationPropertyInjector *propertyInjector = context.propertyInjector;
        if (propertyInjector != nil) {
            NSDictionary *dictionary = (NSDictionary *)input;
            dict = [propertyInjector injectedDictionaryWithDictionary:dictionary];
        }

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
                               ^id(NSDictionary *propDict, NSString *param) {
                                   return propFromDict(propDict, param, context); });
            writeAllProperties = NO;
        } else {
            Class class = NSClassFromString(className);
            if (class == [ORKDontKnowAnswer class]) {
                output = [ORKDontKnowAnswer answer];
            } else {
                output = [[class alloc] init];
            }
        }
        
        for (__strong NSString *key in [dict allKeys]) {
            if ([key isEqualToString:_ClassKey]) {
                continue;
            }
            if ([key hasPrefix:noAnswerPrefix]) {
                key = [key substringFromIndex:[noAnswerPrefix length]];
            }
            
            BOOL haveSetProp = NO;
            for (ORKESerializableTableEntry *encoding in classEncodings) {
                NSDictionary *propertyTable = encoding.properties;
                ORKESerializableProperty *propertyEntry = propertyTable[key];
                if (propertyEntry != nil) {
                    // Only write the property if it has not already been set during init
                    if (writeAllProperties || propertyEntry.writeAfterInit) {
                        id property = propFromDict(dict, key, context);
                        if ([property isKindOfClass: [NSString class]] && ![key isEqualToString:@"identifier"]) {
                            if (localizer != nil) {
                                property = [localizer localizedStringForString:property];
                            }

                            if (stringInterpolator != nil) {
                                property = [stringInterpolator interpolatedStringForString:property];
                            }
                        }
                        [output setValue:property forKey:key];
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
    return [NSJSONSerialization isValidJSONObject:object] || [object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNull class]] || [object isKindOfClass:[ORKDontKnowAnswer class]];
}

static id jsonObjectForObject(id object, ORKESerializationContext *context) {
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
        
        NSMutableSet<NSString *> *excludedPoperties = [NSMutableSet set];
        for (ORKESerializableTableEntry *encoding in classEncodings) {
            NSDictionary<NSString *, ORKESerializableProperty *> *propertyTable = encoding.properties;
            for (NSString *propertyName in [propertyTable allKeys]) {
                ORKESerializableProperty *propertyEntry = propertyTable[propertyName];
                if (propertyEntry.skipSerialization) {
                    [excludedPoperties addObject:propertyEntry.propertyName];
                    continue;
                }
                if ([excludedPoperties containsObject:propertyEntry.propertyName]) {
                    continue;
                }
                ORKESerializationObjectToJSONBlock converter = propertyEntry.objectToJSONBlock;
                Class containerClass = propertyEntry.containerClass;
                id valueForKey = [object valueForKey:propertyName];
                BOOL valueIsDontKnowAnswer = [valueForKey isKindOfClass:[ORKDontKnowAnswer class]];
                if (valueIsDontKnowAnswer) {
                    converter = nil;
                }
                if (valueForKey != nil) {
                    if ([containerClass isSubclassOfClass:[NSArray class]]) {
                        NSMutableArray *a = [NSMutableArray array];
                        for (id valueItem in valueForKey) {
                            id outputItem;
                            if (converter != nil) {
                                outputItem = converter(valueItem, context);
                                NSCAssert(isValid(valueItem), @"Expected valid JSON object");
                            } else {
                                // Recurse for each property
                                outputItem = jsonObjectForObject(valueItem, context);
                            }
                            [a addObject:outputItem];
                        }
                        valueForKey = a;
                    } else {
                        if (converter != nil) {
                            valueForKey = converter(valueForKey, context);
                            NSCAssert((valueForKey == nil) || isValid(valueForKey), @"Expected valid JSON object");
                        } else {
                            // Recurse for each property
                            valueForKey = jsonObjectForObject(valueForKey, context);
                        }
                    }
                }
                
                if (valueForKey != nil) {
                    if (valueIsDontKnowAnswer) {
                        encodedDict[dontKnowFakePropertyName(propertyName)] = valueForKey;
                    } else {
                        encodedDict[propertyName] = valueForKey;
                    }
                }
            }
        }
        
        jsonOutput = encodedDict;
    } else if ([c isSubclassOfClass:[NSArray class]]) {
        NSArray *inputArray = (NSArray *)object;
        NSMutableArray *encodedArray = [NSMutableArray arrayWithCapacity:[inputArray count]];
        for (id input in inputArray) {
            // Recurse for each array element
            [encodedArray addObject:jsonObjectForObject(input, context)];
        }
        jsonOutput = encodedArray;
    } else if ([c isSubclassOfClass:[NSDictionary class]]) {
        NSDictionary *inputDict = (NSDictionary *)object;
        NSMutableDictionary *encodedDictionary = [NSMutableDictionary dictionaryWithCapacity:[inputDict count]];
        for (NSString *key in [inputDict allKeys] ) {
            // Recurse for each dictionary value
            encodedDictionary[key] = jsonObjectForObject(inputDict[key], context);
        }
        jsonOutput = encodedDictionary;
    } else if (![c isSubclassOfClass:[NSPredicate class]]) {  // Ignore NSPredicate which cannot be easily serialized for now
        NSCAssert(isValid(object), @"Expected valid JSON object");
        // Leaf: native JSON object
        jsonOutput = object;
    }
    
    return jsonOutput;
}

+ (NSDictionary *)JSONObjectForObject:(id)object error:(__unused NSError * __autoreleasing *)error {
    return [self JSONObjectForObject:object context:[[ORKESerializationContext alloc] initWithLocalizer:nil imageProvider:nil stringInterpolator:nil propertyInjector:nil] error:error];
}

+ (NSDictionary *)JSONObjectForObject:(id)object context:(ORKESerializationContext *)context error:(__unused NSError * __autoreleasing *)error {
    id json = jsonObjectForObject(object, context);
    return json;
}

+ (id)objectFromJSONObject:(NSDictionary *)object error:(__unused NSError * __autoreleasing *)error {
    return objectForJsonObject(object, nil, nil, [[ORKESerializationContext alloc] initWithLocalizer:nil imageProvider:nil stringInterpolator:nil propertyInjector:nil]);
}

+ (id)objectFromJSONObject:(NSDictionary *)object context:(ORKESerializationContext *)context error:(__unused NSError * __autoreleasing *)error {
    return objectForJsonObject(object, nil, nil, context);
}

+ (NSData *)JSONDataForObject:(id)object error:(NSError * __autoreleasing *)error {
    id json = jsonObjectForObject(object, [[ORKESerializationContext alloc] initWithLocalizer:nil imageProvider:nil stringInterpolator:nil propertyInjector:nil]);
    return [NSJSONSerialization dataWithJSONObject:json options:(NSJSONWritingOptions)0 error:error];
}

+ (id)objectFromJSONData:(NSData *)data error:(NSError * __autoreleasing *)error {
    id json = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:error];
    id ret = nil;
    if (json != nil) {
        ret = objectForJsonObject(json, nil, nil, [[ORKESerializationContext alloc] initWithLocalizer:nil imageProvider:nil stringInterpolator:nil propertyInjector:nil]);
    }
    return ret;
}

+ (NSArray *)serializableClasses {
    NSMutableArray *a = [NSMutableArray array];
    NSDictionary *table = ORKESerializationEncodingTable();
    for (NSString *key in [table allKeys]) {
        if ([key containsString:@"SwiftStroop"] || [key containsString:@"DataCollectionState"]) {
            continue;
        }
        [a addObject:NSClassFromString(key)];
    }
    return a;
}


+ (NSArray<NSString *> *)serializedPropertiesForClass:(Class)c {
    NSArray<ORKESerializableTableEntry *> *entries = classEncodingsForClass(c);
    NSMutableArray *properties = [NSMutableArray array];
    for (ORKESerializableTableEntry *entry in entries) {
        [properties addObjectsFromArray:[entry.properties allKeys]];
    }
    return properties;
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
                            jsonToObjectBlock:(ORKESerializationJSONToObjectBlock)jsonToObjectBlock
                            skipSerialization:(BOOL)skipSerialization {
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
                                                        jsonToObjectBlock:jsonToObjectBlock
                                                        skipSerialization:skipSerialization];
        entry.properties[propertyName] = property;
    } else {
        property.propertyName = propertyName;
        property.valueClass = valueClass;
        property.containerClass = containerClass;
        property.writeAfterInit = writeAfterInit;
        property.objectToJSONBlock = objectToJSON;
        property.jsonToObjectBlock = jsonToObjectBlock;
        property.skipSerialization = skipSerialization;
    }
}

@end
