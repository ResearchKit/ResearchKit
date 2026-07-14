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

#import <Contacts/CNContact.h>

#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION

#import <CoreLocation/CLCircularRegion.h>
#import <CoreLocation/CLLocation.h>

#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <ResearchKit/ORKAnswerFormat.h>

NS_ASSUME_NONNULL_BEGIN

#if defined(__cplusplus)
#  define ORKE_EXTERN extern "C" __attribute__((visibility("default")))
#else
#  define ORKE_EXTERN extern __attribute__((visibility("default")))
#endif

@class ORKSerializationEntryProvider;
@class SFTranscriptionSegment;
@class SFTranscription;
@class SFSpeechRecognitionMetadata;
@class SFVoiceAnalytics;
@class SFAcousticFeature;

typedef NSString *ORKESerializationKey NS_STRING_ENUM;
ORKE_EXTERN ORKESerializationKey const ORKESerializationKeyImageName;

@protocol ORKESerializationLocalizer

- (NSString *)localizedStringForKey:(ORKESerializationKey)string;

@end


@interface ORKESerializationBundleLocalizer : NSObject<ORKESerializationLocalizer>

- (instancetype)initWithBundle:(NSBundle *)bundle tableName:(NSString *)tableName;

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, copy) NSString *tableName;

- (NSString *)localizedStringForKey:(ORKESerializationKey)string;

@end

@protocol ORKESerializationImageProvider

- (nullable UIImage *)imageForReference:(NSDictionary *)reference;
- (nullable NSDictionary *)referenceBySavingImage:(UIImage *)image;

@end

typedef NS_ENUM(NSInteger, ORKESerializationPropertyModifierType) {
    ORKESerializationPropertyModifierTypePath
};

@interface ORKESerializationPropertyModifier: NSObject

- (instancetype)initWithKeypath:(NSString *)keypath value:(id)value type:(ORKESerializationPropertyModifierType)type;

@property (nonatomic, copy, readonly) NSString *keypath;
@property (nonatomic, copy, readonly) id value;
@property (nonatomic, assign, readonly) ORKESerializationPropertyModifierType type;

@end

@interface ORKESerializationBundleImageProvider : NSObject<ORKESerializationImageProvider>

- (instancetype)initWithBundle:(NSBundle *)bundle;

@property (nonatomic, strong, readonly) NSBundle *bundle;

@end

@interface ORKESerializationPropertyInjector : NSObject

- (instancetype)initWithBasePath:(NSString *)basePath modifiers:(nullable NSArray<ORKESerializationPropertyModifier *> *)modifiers;

- (NSDictionary *)injectedDictionaryWithDictionary:(NSDictionary *)inputDictionary;

@property (nonatomic, copy, readonly) NSString *basePath;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *propertyValues;

@end

@protocol ORKESerializationStringInterpolator

- (NSString *)interpolatedStringForString:(NSString *)string;

@end

@interface ORKESerializationContext : NSObject

- (instancetype)initWithLocalizer:(nullable id<ORKESerializationLocalizer>)localizer
                    imageProvider:(nullable id<ORKESerializationImageProvider>)imageProvider
               stringInterpolator:(nullable id<ORKESerializationStringInterpolator>)stringInterpolator
                 propertyInjector:(nullable ORKESerializationPropertyInjector *)propertyInjector;

@property (nonatomic, strong, nullable) id<ORKESerializationLocalizer> localizer;
@property (nonatomic, strong, nullable) id<ORKESerializationImageProvider> imageProvider;
@property (nonatomic, strong, nullable) id<ORKESerializationStringInterpolator> stringInterpolator;
@property (nonatomic, strong, nullable) ORKESerializationPropertyInjector *propertyInjector;

@end

typedef _Nullable id (^ORKESerializationPropertyGetter)(NSDictionary *dict, NSString *property);
typedef _Nullable id (^ORKESerializationInitBlock)(NSDictionary *dict, ORKESerializationPropertyGetter getter);
typedef _Nullable id (^ORKESerializationObjectToJSONBlock)(id object, ORKESerializationContext *context);
typedef _Nullable id (^ORKESerializationJSONToObjectBlock)(id jsonObject, ORKESerializationContext *context);
typedef _Nullable id (^ORKESerializationObjectsToJSONBlock)(id object, id secondObject, ORKESerializationContext *context);
typedef _Nullable id (^ORKESerializationJSONToObjectsBlock)(id jsonObject, ORKESerializationContext *context);

@interface ORKESerializableProperty : NSObject

- (instancetype)initWithPropertyName:(NSString *)propertyName
                          valueClass:(Class)valueClass
                      containerClass:(Class)containerClass
                      writeAfterInit:(BOOL)writeAfterInit
                   objectToJSONBlock:(nullable ORKESerializationObjectToJSONBlock)objectToJSON
                   jsonToObjectBlock:(nullable ORKESerializationJSONToObjectBlock)jsonToObjectBlock
                   skipSerialization:(BOOL)skipSerialization;

- (instancetype)initWithPropertyName:(NSString *)propertyName
                          valueClass:(Class)valueClass
                      containerClass:(Class)containerClass
                  secondPropertyName:(NSString *)secondPropertyName
                    secondValueClass:(Class)secondValueClass
                secondContainerClass:(Class)secondContainerClass
                      writeAfterInit:(BOOL)writeAfterInit
                   objectsToJSONBlock:(nullable ORKESerializationObjectsToJSONBlock)objectsToJSON
                   jsonToObjectsBlock:(nullable ORKESerializationJSONToObjectsBlock)jsonToObjectsBlock
                   skipSerialization:(BOOL)skipSerialization;

- (instancetype)imagePropertyObjectWithPropertyName:(NSString *)propertyName
                                     containerClass:(Class)containerClass
                                     writeAfterInit:(BOOL)writeAfterInit
                                  skipSerialization:(BOOL)skipSerialization;

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic) Class valueClass;
@property (nonatomic) Class containerClass;
@property (nonatomic) BOOL writeAfterInit;
@property (nonatomic, copy) NSString *secondPropertyName;
@property (nonatomic) Class secondValueClass;
@property (nonatomic) Class secondContainerClass;
@property (nonatomic, copy) ORKESerializationObjectToJSONBlock objectToJSONBlock;
@property (nonatomic, copy) ORKESerializationJSONToObjectBlock jsonToObjectBlock;
@property (nonatomic, copy) ORKESerializationObjectsToJSONBlock objectsToJSONBlock;
@property (nonatomic, copy) ORKESerializationJSONToObjectsBlock jsonToObjectsBlock;

@property (nonatomic) BOOL skipSerialization;

@end

@interface ORKESerializableTableEntry : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithClass:(Class)class
                    initBlock:(nullable ORKESerializationInitBlock)initBlock
                   properties:(NSDictionary<NSString *, ORKESerializableProperty *> *)properties NS_DESIGNATED_INITIALIZER;

@property (nonatomic) Class class;
@property (nonatomic, copy) ORKESerializationInitBlock initBlock;
@property (nonatomic, strong) NSMutableDictionary<NSString *, ORKESerializableProperty *> *properties;

@end

#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
@class HKClinicalType;
#endif

@interface ORKESerializerHelper : NSObject

+ (NSArray *)ORKChoiceAnswerStyleTable;

+ (NSArray *)ORKDateAnswerStyleTable;

+ (NSArray *)ORKNumericAnswerStyleTable;

+ (NSString *)ORKNumericAnswerStyleToStringWithStyle:(ORKNumericAnswerStyle)style;

+ (ORKNumericAnswerStyle)ORKNumericAnswerStyleFromString:(NSString *)string;

+ (id)tableMapForwardWithIndex:(NSInteger)index table:(NSArray *)table;

+ (NSInteger)tableMapReverseWithValue:(id)value table:(NSArray *)table;

+ (NSArray *)numberFormattingStyleTable;

+ (NSDictionary *)dictionaryFromRegularExpression:(NSRegularExpression *)regularExpression;

+ (NSArray *)arrayFromRegularExpressionOptions:(NSRegularExpressionOptions)regularExpressionOptions;

+ (NSRegularExpression *)regularExpressionsFromDictionary:(NSDictionary *)dict;

+ (NSRegularExpressionOptions)regularExpressionOptionsFromArray:(NSArray *)array;

+ (NSDictionary *)dictionaryFromPasswordRules:(UITextInputPasswordRules *)passwordRules;

+ (UITextInputPasswordRules *)passwordRulesFromDictionary:(NSDictionary *)dict;

+ (NSString *)ORKMeasurementSystemToString:(ORKMeasurementSystem)measurementSystem;

+ (NSArray *)ORKMeasurementSystemTable;

+ (ORKMeasurementSystem)ORKMeasurementSystemFromString:(NSString *)string;

+ (NSString *)ORKEStringFromDateISO8601:(NSDate *)date timeZone:(NSTimeZone *)timeZone;

+ (NSDictionary *)ORKEDateAndTimeZoneFromStringISO8601:(NSString *)string dateKey:(NSString *)dateKey timeZoneKey:(NSString *)timeZoneKey;

+ (NSDictionary *)dictionaryFromUIEdgeInsets:(UIEdgeInsets)insets;

+ (UIEdgeInsets)edgeInsetsFromDictionary:(NSDictionary *)dict;

+ (NSString *)ORKImageChoiceAnswerStyleToString:(ORKNumericAnswerStyle)style;

+ (NSArray *)ORKImageChoiceAnswerStyleTable;

+ (ORKNumericAnswerStyle)ORKImageChoiceAnswerStyleFromString:(NSString *)string;

+ (NSDictionary *)dictionaryFromPostalAddress:(CNPostalAddress *)address;

+ (nullable NSDictionary *)dictionaryFromColor:(UIColor *)color;

+ (nullable UIColor *)colorFromDictionary:(NSDictionary *)dict;

+ (nullable NSDictionary *)dictionaryFromP3Color:(UIColor *)color;

+ (nullable UIColor *)p3ColorFromDictionary:(NSDictionary *)dict;

+ (NSArray<NSString *> *)buttonIdentifierTable;

+ (NSDictionary *)dictionaryFromCGPoint:(CGPoint)p;

+ (CGPoint)pointFromDictionary:(NSDictionary *)dict;

+ (NSDictionary *)dictionaryFromCGSize:(CGSize)s;

+ (CGSize)sizeFromDictionary:(NSDictionary *)dict;

+ (NSDictionary *)dictionaryFromCGRect:(CGRect)r;

+ (CGRect)rectFromDictionary:(NSDictionary *)dict;

+ (NSArray *)memoryGameStatusTable;

#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION

+ (NSString *)identifierFromClinicalType:(HKClinicalType *)type;

+ (HKClinicalType *)typeFromIdentifier:(NSString *)identifier;

#endif

#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION

+ (CLLocationCoordinate2D)coordinateFromDictionary:(NSDictionary *)dict;

+ (NSDictionary *)dictionaryFromCircularRegion:(CLCircularRegion *)region;

+ (CLCircularRegion *)circularRegionFromDictionary:(NSDictionary *)dict;

+ (NSDictionary *)dictionaryFromCoordinate:(CLLocationCoordinate2D)coordinate;

+ (CNPostalAddress *)postalAddressFromDictionary:(NSDictionary *)dict;

#endif

+ (NSDictionary *)dictionaryForORKSpeechRecognitionResult;

+ (NSDictionary *)dictionaryFromSFTranscriptionSegment:(SFTranscriptionSegment *)segment;

+ (NSDictionary *)dictionaryFromSFTranscription:(SFTranscription *)transcription;

+ (NSDictionary *)dictionaryFromSFSpeechRecognitionMetadata:(SFSpeechRecognitionMetadata *)metadata;

+ (NSDictionary *)dictionaryFromSFVoiceAnalytics:(SFVoiceAnalytics *)voiceAnalytics;

+ (NSDictionary *)dictionaryFromNSRange:(NSRange)r;

+ (NSDictionary *)dictionaryFromSFAcousticFeature:(SFAcousticFeature *)acousticFeature;

@end

NS_ASSUME_NONNULL_END
