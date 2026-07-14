/*
 Copyright (c) 2024, Apple Inc. All rights reserved.
 
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

#import "ORKESerialization+Helpers.h"

#import <ResearchKit/ORKAnswerFormat.h>

#import <Contacts/CNMutablePostalAddress.h>

#import <Speech/Speech.h>

#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
#import <HealthKit/HealthKit.h>
#endif

#import <ResearchKit/ResearchKit-Swift.h>

static NSString *_ClassKey = @"_class";
ORKESerializationKey const ORKESerializationKeyImageName = @"imageName";

@implementation ORKESerializationBundleLocalizer

- (instancetype)initWithBundle:(NSBundle *)bundle tableName:(NSString *)tableName {
    self = [super init];
    if (self) {
        _bundle = bundle;
        _tableName = [tableName copy];
    }
    return self;
}

- (NSString *)localizedStringForKey:(NSString *)string
{
    // Keys that exist in the localization table will be localized.
    //
    // If the key is not found in the table the provided key string will be returned as is,
    // supporting the expected functionality for inputs that contain both strings to be
    // localized as well as strings to be displayed as is.
    return [self.bundle localizedStringForKey:string value:string table:self.tableName];
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

- (instancetype)initWithBasePath:(NSString *)basePath modifiers:(NSArray<ORKESerializationPropertyModifier *> *)modifiers {
    self = [super init];
    if (self) {
        _basePath = [basePath copy];
        NSMutableDictionary *propertyValues = [NSMutableDictionary dictionary];
        [modifiers enumerateObjectsUsingBlock:^(ORKESerializationPropertyModifier * _Nonnull obj, __unused NSUInteger idx, __unused BOOL * _Nonnull stop) {
            if (obj.type == ORKESerializationPropertyModifierTypePath && [obj.value isKindOfClass:[NSString class]]) {
                propertyValues[obj.keypath] = [_basePath stringByAppendingPathComponent:(NSString *)obj.value];
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


@implementation ORKESerializationBundleImageProvider

- (instancetype)initWithBundle:(NSBundle *)bundle {
    self = [super init];
    if (self) {
        _bundle = bundle;
    }
    return self;
}

- (UIImage *)imageForReference:(NSDictionary *)reference {
    id value = [reference objectForKey:ORKESerializationKeyImageName];
    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *imageName = (NSString *)value;

    // Try to get a system symbol image first
    UIImage *image = [UIImage systemImageNamed:imageName];
    if (image == nil) {
        image = [UIImage imageNamed:imageName inBundle:_bundle compatibleWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceIdiom:[UIDevice currentDevice].userInterfaceIdiom]];
    }
    return image;
}

// Writing to bundle is not supported: supply a placeholder
- (nullable NSDictionary *)referenceBySavingImage:(UIImage __unused *)image {
    return @{ORKESerializationKeyImageName : @""};
}

@end

@implementation ORKESerializationContext

- (instancetype)initWithLocalizer:(nullable id<ORKESerializationLocalizer>)localizer
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

- (instancetype)initWithPropertyName:(nonnull NSString *)propertyName
                          valueClass:(nonnull Class)valueClass
                      containerClass:(nonnull Class)containerClass
                  secondPropertyName:(nonnull NSString *)secondPropertyName
                    secondValueClass:(nonnull Class)secondValueClass
                secondContainerClass:(nonnull Class)secondContainerClass
                      writeAfterInit:(BOOL)writeAfterInit
                  objectsToJSONBlock:(nullable ORKESerializationObjectsToJSONBlock)objectsToJSON
                  jsonToObjectsBlock:(nullable ORKESerializationJSONToObjectsBlock)jsonToObjectsBlock
                   skipSerialization:(BOOL)skipSerialization {
    self = [super init];
    if (self) {
        _propertyName = propertyName;
        _valueClass = valueClass;
        _containerClass = containerClass;
        _secondPropertyName = secondPropertyName;
        _secondValueClass = secondValueClass;
        _secondContainerClass = secondContainerClass;
        _writeAfterInit = writeAfterInit;
        _objectsToJSONBlock = objectsToJSON;
        _jsonToObjectsBlock = jsonToObjectsBlock;
        _skipSerialization = skipSerialization;
    }
    return self;
}

- (instancetype)imagePropertyObjectWithPropertyName:(NSString *)propertyName 
                                     containerClass:(Class)containerClass
                                     writeAfterInit:(BOOL)writeAfterInit
                                  skipSerialization:(BOOL)skipSerialization {
    return [[ORKESerializableProperty alloc] initWithPropertyName:propertyName
                                                       valueClass:[UIImage class]
                                                   containerClass:containerClass
                                                   writeAfterInit:writeAfterInit
                                                objectToJSONBlock:^id _Nullable(id object, ORKESerializationContext *context) { return [context.imageProvider referenceBySavingImage:object]; }
                                                jsonToObjectBlock:^id _Nullable(id jsonObject, ORKESerializationContext *context) {
                                                    if (![jsonObject isKindOfClass:[NSDictionary class]]) {
                                                        return nil;
                                                    }
                                                    return [context.imageProvider imageForReference:jsonObject];
                                                }
                                                skipSerialization:skipSerialization];
}

@end

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


@implementation ORKESerializerHelper

+ (NSArray *)ORKChoiceAnswerStyleTable {
    static NSArray *table;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"singleChoice", @"multipleChoice"];
    });
    
    return table;
}

+ (NSArray *)ORKDateAnswerStyleTable {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"dateTime", @"date"];
    });
    return table;
}

+ (NSArray *)ORKNumericAnswerStyleTable {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"decimal", @"integer"];
    });
    return table;
}

+ (ORKNumericAnswerStyle)ORKNumericAnswerStyleFromString:(NSString *)string {
    return (ORKNumericAnswerStyle)[self tableMapReverseWithValue:string table:[self ORKNumericAnswerStyleTable]];
}

+ (NSString *)ORKNumericAnswerStyleToStringWithStyle:(ORKNumericAnswerStyle)style {
    return [self tableMapForwardWithIndex:style table:[self ORKNumericAnswerStyleTable]];
}

+ (id)tableMapForwardWithIndex:(NSInteger)index table:(NSArray *)table {
    return table[(NSUInteger)index];
}

+ (NSInteger)tableMapReverseWithValue:(id)value table:(NSArray *)table {
    NSUInteger idx = [table indexOfObject:value];
    if (idx == NSNotFound) {
        idx = 0;
    }
    return (NSInteger)idx;
}

+ (NSArray *)numberFormattingStyleTable {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"default", @"percent"];
    });
    return table;
}

+ (NSDictionary *)dictionaryFromRegularExpression:(NSRegularExpression *)regularExpression {
    NSDictionary *dictionary = regularExpression ?
    @{
      @"pattern": regularExpression.pattern ?: @"",
      @"options": [self arrayFromRegularExpressionOptions:regularExpression.options]
      } :
    @{};
    return dictionary;
}

+ (NSArray *)arrayFromRegularExpressionOptions:(NSRegularExpressionOptions)regularExpressionOptions {
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

+ (NSRegularExpression *)regularExpressionsFromDictionary:(NSDictionary *)dict {
    NSRegularExpression *regularExpression;
    if (dict.count == 2) {
        regularExpression = [NSRegularExpression regularExpressionWithPattern:dict[@"pattern"]
                                                                      options:[self regularExpressionOptionsFromArray:dict[@"options"]]
                                                                        error:nil];
    }
    return regularExpression;
}

+ (NSRegularExpressionOptions)regularExpressionOptionsFromArray:(NSArray *)array {
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

+ (NSDictionary *)dictionaryFromPasswordRules:(UITextInputPasswordRules *)passwordRules {
    NSDictionary *dictionary = passwordRules ?
    @{
      @"rules": passwordRules.passwordRulesDescriptor ?: @""
      } :
    @{};
    return dictionary;
}

+ (UITextInputPasswordRules *)passwordRulesFromDictionary:(NSDictionary *)dict {
    UITextInputPasswordRules *passwordRules;
    if (dict.count == 1) {
        passwordRules = [UITextInputPasswordRules passwordRulesWithDescriptor:dict[@"rules"]];
    }
    return passwordRules;
}

+ (NSString *)ORKMeasurementSystemToString:(ORKMeasurementSystem)measurementSystem {
    return [self tableMapForwardWithIndex:measurementSystem table:[self ORKMeasurementSystemTable]];
}

+ (NSArray *)ORKMeasurementSystemTable {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"local", @"metric", @"USC"];
    });
    return table;
}

+ (ORKMeasurementSystem)ORKMeasurementSystemFromString:(NSString *)string {
    return [self tableMapReverseWithValue:string table:[self ORKMeasurementSystemTable]];
}

+ (NSString *)ORKEStringFromDateISO8601:(NSDate *)date timeZone:(NSTimeZone *)timeZone {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setTimeZone:timeZone];
    return [formatter stringFromDate:date];
}

/// Parses the date and timezone from an ISO8601-formatted date string.
/// - Parameters:
///     - string: the ISO8601-formatted date string ("yyyy-MM-dd'T'HH:mm:ssZ", example: 1987-03-06T07:30:00-0400)
///     - dateKey: the key to use for the dictionary result containing the date value
///     - timeZoneKey: the key to use for the dictionary result containing the timezone value
/// - Returns: a dictionary containing the date and timezone, keyed with `dateKey` and `timeZoneKey` respectively.
+ (NSDictionary *)ORKEDateAndTimeZoneFromStringISO8601:(NSString *)string dateKey:(nonnull NSString *)dateKey timeZoneKey:(nonnull NSString *)timeZoneKey {
    NSTimeZone *eventTimeZone = [[NSTimeZone alloc] initWithIso8601String:string];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setTimeZone:eventTimeZone];
    NSDate *eventDate = [formatter dateFromString:string];

    return @{
        dateKey: eventDate,
        timeZoneKey: eventTimeZone
    };
}

+ (NSDictionary *)dictionaryFromUIEdgeInsets:(UIEdgeInsets)insets {
    return @{ @"top": @(insets.top), @"left": @(insets.left), @"bottom": @(insets.bottom), @"right": @(insets.right) };
}

+ (UIEdgeInsets)edgeInsetsFromDictionary:(NSDictionary *)dict {
    return (UIEdgeInsets){.top = ((NSNumber *)dict[@"top"]).doubleValue, .left = ((NSNumber *)dict[@"left"]).doubleValue, .bottom = ((NSNumber *)dict[@"bottom"]).doubleValue, .right = ((NSNumber *)dict[@"right"]).doubleValue};
}

+ (NSString *)ORKImageChoiceAnswerStyleToString:(ORKNumericAnswerStyle)style {
    return [self tableMapForwardWithIndex:style table:[self ORKImageChoiceAnswerStyleTable]];
}

+ (NSArray *)ORKImageChoiceAnswerStyleTable {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"singleChoice", @"multipleChoice"];
    });
    return table;
}

+ (ORKNumericAnswerStyle)ORKImageChoiceAnswerStyleFromString:(NSString *)string {
    return [self tableMapReverseWithValue:string table:[self ORKImageChoiceAnswerStyleTable]];
}

+ (NSDictionary *)dictionaryFromPostalAddress:(CNPostalAddress *)address {
    return @{ @"city": address.city, @"street": address.street };
}

+ (nullable NSDictionary *)dictionaryFromColor:(UIColor *)color {
    NSString *colorName = color.ork_namedSystemColorName;
    if (colorName != nil) {
        return @{@"name": colorName};
    }

    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a]) {
        return @{@"r":@(r), @"g":@(g), @"b":@(b), @"a":@(a)};
    }
    return nil;
}

+ (nullable UIColor *)colorFromDictionary:(NSDictionary *)dict {
    NSString *colorName = [dict objectForKey:@"name"];
    if ([colorName isKindOfClass:[NSString class]]) {
        return [UIColor ork_colorFromName:colorName];
    }

    CGFloat r = [[dict objectForKey:@"r"] floatValue];
    CGFloat g = [[dict objectForKey:@"g"] floatValue];
    CGFloat b = [[dict objectForKey:@"b"] floatValue];
    CGFloat a = [[dict objectForKey:@"a"] floatValue];
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

+ (nullable NSDictionary *)dictionaryFromP3Color:(UIColor *)color {
    NSString *colorName = color.ork_namedSystemColorName;
    if (colorName != nil) {
        return @{@"name": colorName};
    }

    CGColorSpaceRef p3ColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceDisplayP3);
    CGColorRef p3CGColor = CGColorCreateCopyByMatchingToColorSpace(p3ColorSpace, kCGRenderingIntentDefault, color.CGColor, NULL);
    CGColorSpaceRelease(p3ColorSpace);

    if (p3CGColor == NULL) {
        return nil;
    }
    
    size_t componentCount = CGColorGetNumberOfComponents(p3CGColor);
    if (componentCount != 4) {
        CGColorRelease(p3CGColor);
        return nil;
    }

    // Round to 4 decimal places to eliminate floating point noise introduced
    // by the color space conversion while preserving precision beyond 8-bit color depth.
    const CGFloat *components = CGColorGetComponents(p3CGColor);
    NSDictionary *result = @{
        @"r": @(round(components[0] * 1e4) / 1e4),
        @"g": @(round(components[1] * 1e4) / 1e4),
        @"b": @(round(components[2] * 1e4) / 1e4),
        @"a": @(round(components[3] * 1e4) / 1e4)
    };
    CGColorRelease(p3CGColor);
    return result;
}

+ (nullable UIColor *)p3ColorFromDictionary:(NSDictionary *)dict {
    NSString *colorName = [dict objectForKey:@"name"];
    if ([colorName isKindOfClass:[NSString class]]) {
        return [UIColor ork_colorFromName:colorName];
    }

    CGFloat r = [[dict objectForKey:@"r"] floatValue];
    CGFloat g = [[dict objectForKey:@"g"] floatValue];
    CGFloat b = [[dict objectForKey:@"b"] floatValue];
    CGFloat a = [[dict objectForKey:@"a"] floatValue];
    return [UIColor colorWithDisplayP3Red:r green:g blue:b alpha:a];
}

+ (NSArray<NSString *> *)buttonIdentifierTable {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"none", @"left", @"right"];
    });
    return table;
}

+ (NSDictionary *)dictionaryFromCGPoint:(CGPoint)p {
    return @{ @"x": @(p.x), @"y": @(p.y) };
}

+ (CGPoint)pointFromDictionary:(NSDictionary *)dict {
    return (CGPoint){.x = ((NSNumber *)dict[@"x"]).doubleValue, .y = ((NSNumber *)dict[@"y"]).doubleValue};
}

+ (NSDictionary *)dictionaryFromCGSize:(CGSize)s {
    return @{ @"h": @(s.height), @"w": @(s.width) };
}

+ (CGSize)sizeFromDictionary:(NSDictionary *)dict {
    return (CGSize){.width = ((NSNumber *)dict[@"w"]).doubleValue, .height = ((NSNumber *)dict[@"h"]).doubleValue };
}

+ (NSDictionary *)dictionaryFromCGRect:(CGRect)r {
    return @{ @"origin": [self dictionaryFromCGPoint:r.origin], @"size": [self dictionaryFromCGSize:r.size] };
}

+ (CGRect)rectFromDictionary:(NSDictionary *)dict {
    return (CGRect){.origin = [self pointFromDictionary:dict[@"origin"]], .size = [self sizeFromDictionary:dict[@"size"]]};
}

+ (NSDictionary *)dictionaryForORKSpeechRecognitionResult {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict addEntriesFromDictionary:@{PROPERTY(transcription, SFTranscription, NSObject, NO,
                                     (^id(id transcription, __unused ORKESerializationContext *context) { return [self dictionaryFromSFTranscription:transcription]; }),
                                                 // Decode not supported: SFTranscription is immmutable
                                              (^id(id __unused transcriptionDict, __unused ORKESerializationContext *context) { return nil; }))}];
    [dict addEntriesFromDictionary:@{PROPERTY(recognitionMetadata, SFSpeechRecognitionMetadata, NSObject, NO,
                                     (^id(id recognitionMetadata, __unused ORKESerializationContext *context) { return [self dictionaryFromSFSpeechRecognitionMetadata: recognitionMetadata]; }),
                                              (^id(id __unused recognitionMetadataDict, __unused ORKESerializationContext *context) { return nil; }))}];

    return [dict copy];
}

+ (NSDictionary *)dictionaryFromSFTranscriptionSegment:(SFTranscriptionSegment *)segment {
    if (segment == nil) { return @{}; }

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    [dict setObject:segment.substring forKey:@"substring"];
    [dict setObject:[self dictionaryFromNSRange:segment.substringRange] forKey:@"substringRange"];
    [dict setObject:@(segment.timestamp) forKey:@"timestamp"];
    [dict setObject:@(segment.duration) forKey:@"duration"];
    [dict setObject:@(segment.confidence) forKey:@"confidence"];
    [dict setObject:segment.alternativeSubstrings.copy forKey:@"alternativeSubstrings"];

    return [dict copy];
}

+ (NSDictionary *)dictionaryFromSFTranscription:(SFTranscription *)transcription {
    if (transcription == nil) { return @{}; };
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[transcription.segments count]];
    for (id value in transcription.segments) {
        [result addObject:[ORKESerializerHelper dictionaryFromSFTranscriptionSegment:value]];
    }
    
    [dict setObject:transcription.formattedString forKey:@"formattedString"];
    [dict setObject:result forKey:@"segments"];

    return [dict copy];
}

+ (NSDictionary *)dictionaryFromSFSpeechRecognitionMetadata:(SFSpeechRecognitionMetadata *)metadata  API_AVAILABLE(ios(14.5)){
    if (metadata == nil) { return @{}; }
    return @{
        @"speakingRate": @(metadata.speakingRate),
        @"averagePauseDuration": @(metadata.averagePauseDuration),
        @"speechStartTimestamp": @(metadata.speechStartTimestamp),
        @"speechDuration": @(metadata.speechDuration),
        @"voiceAnalytics": [self dictionaryFromSFVoiceAnalytics:metadata.voiceAnalytics]
    };
}

+ (NSDictionary *)dictionaryFromSFVoiceAnalytics:(SFVoiceAnalytics *)voiceAnalytics {
    if (voiceAnalytics == nil) { return @{}; }
    return @{
        @"jitter" : [self dictionaryFromSFAcousticFeature:voiceAnalytics.jitter],
        @"shimmer" : [self dictionaryFromSFAcousticFeature:voiceAnalytics.shimmer],
        @"pitch" : [self dictionaryFromSFAcousticFeature:voiceAnalytics.pitch],
        @"voicing" : [self dictionaryFromSFAcousticFeature:voiceAnalytics.voicing]
             };
}

+ (NSDictionary *)dictionaryFromNSRange:(NSRange)r {
    return @{ @"location": @(r.location) , @"length": @(r.length) };
}

+ (NSDictionary *)dictionaryFromSFAcousticFeature:(SFAcousticFeature *)acousticFeature {
    if (acousticFeature == nil) { return @{}; }
    return @{ @"acousticFeatureValuePerFrame" : acousticFeature.acousticFeatureValuePerFrame,
              @"frameDuration" : @(acousticFeature.frameDuration)
              };
}

+ (NSArray *)memoryGameStatusTable {
    static NSArray *table = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = @[@"unknown", @"success", @"failure", @"timeout"];
    });
    return table;
}

#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION

+ (NSString *)identifierFromClinicalType:(HKClinicalType *)type {
    return type.identifier;
}

+ (HKClinicalType *)typeFromIdentifier:(NSString *)identifier {
    return [HKClinicalType clinicalTypeForIdentifier:identifier];
}

#endif

#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION

+ (CLLocationCoordinate2D)coordinateFromDictionary:(NSDictionary *)dict {
    return (CLLocationCoordinate2D){.latitude = ((NSNumber *)dict[@"latitude"]).doubleValue, .longitude = ((NSNumber *)dict[@"longitude"]).doubleValue };
}

+ (NSDictionary *)dictionaryFromCoordinate:(CLLocationCoordinate2D)coordinate {
    return @{ @"latitude": @(coordinate.latitude), @"longitude": @(coordinate.longitude) };
}

+ (NSDictionary *)dictionaryFromCircularRegion:(CLCircularRegion *)region {
    NSDictionary *dictionary = region ?
    @{
        @"coordinate": [self dictionaryFromCoordinate:region.center],
      @"radius": @(region.radius),
      @"identifier": region.identifier
      } :
    @{};
    return dictionary;
}

+ (CLCircularRegion *)circularRegionFromDictionary:(NSDictionary *)dict {
    CLCircularRegion *circularRegion;
    if (dict.count == 3) {
        circularRegion = [[CLCircularRegion alloc] initWithCenter:[self coordinateFromDictionary:dict[@"coordinate"]]
                                                           radius:((NSNumber *)dict[@"radius"]).doubleValue
                                                       identifier:dict[@"identifier"]];
    }
    return circularRegion;
}

+ (CNPostalAddress *)postalAddressFromDictionary:(NSDictionary *)dict {
    CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
    postalAddress.city = dict[@"city"];
    postalAddress.street = dict[@"street"];
    return [postalAddress copy];
}

#endif

@end
