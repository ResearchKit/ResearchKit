/*
 Copyright (c) 2025, Apple Inc. All rights reserved.
 
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

#import <ResearchKit/ORKESerialization+Helpers.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A serializer that converts ResearchKit objects to and from JSON representations.

 Use `ORKESerializer` to encode ResearchKit tasks, steps, and results to JSON for storage or transmission,
 and to decode JSON back into ResearchKit objects. The serializer requires entry providers that define
 which classes can be serialized and how their properties are handled.
 */
@interface ORKESerializer : NSObject

/**
 Initializes a serializer with the specified entry providers.

 @param entryProviders An array of entry providers that register serializable classes and define their serialization behavior.
 @return An initialized serializer instance.
 */
- (instancetype)initWithEntryProviders:(NSArray<ORKSerializationEntryProvider *> *)entryProviders;

/**
 Deserializes a ResearchKit object from JSON data.

 @param data The JSON data to deserialize.
 @param error On output, contains an error object that describes the problem, or `nil` if no error occurred.
 @return The deserialized ResearchKit object, or `nil` if an error occurred.
 */
- (nullable id)objectFromJSONData:(NSData *)data error:(NSError **)error;

/**
 Serializes a ResearchKit object to JSON data with the specified writing options.

 @param object The ResearchKit object to serialize.
 @param options Options for generating the JSON data.
 @param error On output, contains an error object that describes the problem, or `nil` if no error occurred.
 @return The JSON data representation, or `nil` if an error occurred.
 */
- (nullable NSData *)JSONDataForObject:(id)object options:(NSJSONWritingOptions)options error:(NSError **)error;

/**
 Serializes a ResearchKit object to JSON data.

 @param object The ResearchKit object to serialize.
 @param error On output, contains an error object that describes the problem, or `nil` if no error occurred.
 @return The JSON data representation, or `nil` if an error occurred.
 */
- (nullable NSData *)JSONDataForObject:(id)object error:(NSError **)error;

/**
 Serializes a ResearchKit object to a JSON dictionary.

 @param object The ResearchKit object to serialize.
 @param error On output, contains an error object that describes the problem, or `nil` if no error occurred.
 @return A dictionary representation of the object, or `nil` if an error occurred.
 */
- (nullable NSDictionary *)JSONObjectForObject:(id)object error:(NSError **)error;

/**
 Serializes a ResearchKit object to a JSON dictionary with the specified context.

 @param object The ResearchKit object to serialize.
 @param context The serialization context.
 @param error On output, contains an error object that describes the problem, or `nil` if no error occurred.
 @return A dictionary representation of the object.
 */
- (NSDictionary *)JSONObjectForObject:(id)object
                              context:(ORKESerializationContext *)context
                                error:(__unused NSError **)error;

/**
 Deserializes a ResearchKit object from a JSON dictionary.

 @param object The JSON dictionary to deserialize.
 @param error On output, contains an error object that describes the problem, or `nil` if no error occurred.
 @return The deserialized ResearchKit object, or `nil` if an error occurred.
 */
- (nullable id)objectFromJSONObject:(NSDictionary *)object error:(NSError **)error;

/**
 Deserializes a ResearchKit object from a JSON dictionary with the specified context.

 @param object The JSON dictionary to deserialize.
 @param context The serialization context.
 @param error On output, contains an error object that describes the problem, or `nil` if no error occurred.
 @return The deserialized ResearchKit object, or `nil` if an error occurred.
 */
- (nullable id)objectFromJSONObject:(NSDictionary *)object
                            context:(ORKESerializationContext *)context
                              error:(NSError **)error;

/**
 Returns an array of class names that can be serialized.

 @return An array of serializable class names.
 */
- (NSArray<NSString *> *)serializableClasses;

/**
 Returns an array of property names that are serialized for the specified class.

 @param c The class to query.
 @return An array of serialized property names.
 */
- (NSArray<NSString *> *)serializedPropertiesForClass:(Class)c;


@end

/**
 Methods for registering custom serializable classes.

 Use these methods to extend serialization support to custom ResearchKit subclasses.
 */
@interface ORKESerializer (Registration)

/**
 Registers a class as serializable.

 @param serializableClass The class to register.
 @param initBlock An optional initialization block for custom initialization logic.
 */
+ (void)registerSerializableClass:(Class)serializableClass
                        initBlock:(nullable ORKESerializationInitBlock)initBlock;

/**
 Registers a property for serialization on a specific class.

 @param propertyName The name of the property to serialize.
 @param serializableClass The class that owns the property.
 @param valueClass The type of the property value.
 @param containerClass The container class if the property is a collection, or `nil` for scalar properties.
 @param writeAfterInit Whether to write the property after initialization.
 @param objectToJSON An optional block for custom object-to-JSON conversion.
 @param jsonToObjectBlock An optional block for custom JSON-to-object conversion.
 @param skipSerialization Whether to skip serialization of this property.
 */
+ (void)registerSerializableClassPropertyName:(NSString *)propertyName
                                     forClass:(Class)serializableClass
                                   valueClass:(Class)valueClass
                               containerClass:(nullable Class)containerClass
                               writeAfterInit:(BOOL)writeAfterInit
                            objectToJSONBlock:(nullable ORKESerializationObjectToJSONBlock)objectToJSON
                            jsonToObjectBlock:(nullable ORKESerializationJSONToObjectBlock)jsonToObjectBlock
                            skipSerialization:(BOOL)skipSerialization;

+ (void)registerSerializableClassPropertyName:(NSString *)propertyName
                                     forClass:(Class)serializableClass
                                   valueClass:(Class)valueClass
                               containerClass:(nullable Class)containerClass
                           secondPropertyName:(NSString *)secondPropertyName
                               forSecondClass:(Class)secondClass
                             secondValueClass:(Class)secondValueClass
                         secondContainerClass:(nullable Class)secondContainerClass
                               writeAfterInit:(BOOL)writeAfterInit
                            objectsToJSONBlock:(nullable ORKESerializationObjectsToJSONBlock)objectsToJSON
                            jsonToObjectsBlock:(nullable ORKESerializationJSONToObjectsBlock)jsonToObjectsBlock
                            skipSerialization:(BOOL)skipSerialization;
@end

NS_ASSUME_NONNULL_END
