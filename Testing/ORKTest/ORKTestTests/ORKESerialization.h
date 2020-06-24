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


@import Foundation;
@import UIKit;


NS_ASSUME_NONNULL_BEGIN

@interface ORKESerializationLocalizer : NSObject

- (instancetype)initWithBundle:(NSBundle *)bundle tableName:(NSString *)tableName;

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, copy) NSString *tableName;

- (NSString *)localizedStringForString:(NSString *)string;

@end

@protocol ORKESerializationImageProvider

- (UIImage *)imageForReference:(NSDictionary *)reference;
- (nullable NSDictionary *)referenceBySavingImage:(UIImage *)image;

@end

typedef NS_ENUM(NSInteger, ORKESerializationPropertyModifierType) {
    ORKESerializationPropertyModifierTypePath
} ORK_ENUM_AVAILABLE;

@interface ORKESerializationPropertyModifier: NSObject

- (instancetype)initWithKeypath:(NSString *)keypath value:(id)value type:(ORKESerializationPropertyModifierType)type;

@property (nonatomic, copy, readonly) NSString *keypath;
@property (nonatomic, copy, readonly) id value;
@property (nonatomic, assign, readonly) ORKESerializationPropertyModifierType type;

@end

@interface ORKESerializationPropertyInjector : NSObject

- (instancetype)initWithBundle:(NSBundle *)bundle modifiers:(nullable NSArray<ORKESerializationPropertyModifier *> *)modifiers;

@property (nonatomic, strong, readonly) NSBundle *bundle;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *propertyValues;

@end

@protocol ORKESerializationStringInterpolator

- (NSString *)interpolatedStringForString:(NSString *)string;

@end

@interface ORKESerializationContext : NSObject

- (instancetype)initWithLocalizer:(nullable ORKESerializationLocalizer *)localizer
                    imageProvider:(nullable id<ORKESerializationImageProvider>)imageProvider
               stringInterpolator:(nullable id<ORKESerializationStringInterpolator>)stringInterpolator
                 propertyInjector:(nullable ORKESerializationPropertyInjector *)propertyInjector;

- (instancetype)initWithBundle:(NSBundle *)bundle
         localizationTableName:(NSString *)localizationTableName
             propertyModifiers:(nullable NSArray<ORKESerializationPropertyModifier *> *)modifiers;

@property (nonatomic, strong, nullable) ORKESerializationLocalizer *localizer;
@property (nonatomic, strong, nullable) id<ORKESerializationImageProvider> imageProvider;
@property (nonatomic, strong, nullable) id<ORKESerializationStringInterpolator> stringInterpolator;
@property (nonatomic, strong, nullable) ORKESerializationPropertyInjector *propertyInjector;

@end

typedef _Nullable id (^ORKESerializationPropertyGetter)(NSDictionary *dict, NSString *property);
typedef _Nullable id (^ORKESerializationInitBlock)(NSDictionary *dict, ORKESerializationPropertyGetter getter);
typedef _Nullable id (^ORKESerializationObjectToJSONBlock)(id object, ORKESerializationContext *context);
typedef _Nullable id (^ORKESerializationJSONToObjectBlock)(id jsonObject, ORKESerializationContext *context);




@interface ORKESerializationBundleImageProvider : NSObject<ORKESerializationImageProvider>

- (instancetype)initWithBundle:(NSBundle *)bundle;

@property (nonatomic, strong, readonly) NSBundle *bundle;

@end

@interface ORKESerializer : NSObject

+ (nullable NSDictionary *)JSONObjectForObject:(id)object error:(NSError **)error;

+ (nullable NSData *)JSONDataForObject:(id)object error:(NSError **)error;

+ (nullable id)objectFromJSONObject:(NSDictionary *)object error:(NSError **)error;

+ (nullable id)objectFromJSONObject:(NSDictionary *)object context:(ORKESerializationContext *)context error:(NSError **)error;

+ (NSDictionary *)JSONObjectForObject:(id)object context:(ORKESerializationContext *)context error:(__unused NSError **)error;

+ (nullable id)objectFromJSONData:(NSData *)data error:(NSError **)error;

+ (NSArray *)serializableClasses;

+ (NSArray<NSString *> *)serializedPropertiesForClass:(Class)c;

@end


@interface ORKESerializer (Registration)

+ (void)registerSerializableClass:(Class)serializableClass
                        initBlock:(nullable ORKESerializationInitBlock)initBlock;

+ (void)registerSerializableClassPropertyName:(NSString *)propertyName
                                     forClass:(Class)serializableClass
                                   valueClass:(Class)valueClass
                               containerClass:(nullable Class)containerClass
                               writeAfterInit:(BOOL)writeAfterInit
                            objectToJSONBlock:(nullable ORKESerializationObjectToJSONBlock)objectToJSON
                            jsonToObjectBlock:(nullable ORKESerializationJSONToObjectBlock)jsonToObjectBlock
                            skipSerialization:(BOOL)skipSerialization;

@end


NS_ASSUME_NONNULL_END

