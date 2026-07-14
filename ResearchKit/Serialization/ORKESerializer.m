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

#import "ORKESerializer.h"

#import "ORKESerialization+Helpers.h"
#import "ORKSerializationEntryProvider.h"

#import <ResearchKit/ResearchKit.h>


static NSString *_ClassKey = @"_class";

@implementation ORKESerializer {
    NSArray<ORKSerializationEntryProvider *> *_entryProviders;
    NSDictionary<NSString *, ORKESerializableTableEntry *> *_encodingTable;
}

// MARK: initializer

- (instancetype)initWithEntryProviders:(NSArray<ORKSerializationEntryProvider *> *)entryProviders {
    self = [super init];
    
    if (self) {
        _entryProviders = [entryProviders copy];
        _encodingTable = nil;
    }
    
    return self;
}

// MARK: instance methods

- (id)objectFromJSONData:(NSData *)data error:(NSError * __autoreleasing *)error {
    id json = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:error];
    id ret = nil;
    
    if (json != nil) {
        ret = [self objectForJsonObject:json
                          expectedClass:nil
                         converterBlock:nil
                twoParamsConverterBlock:nil
                                context:[[ORKESerializationContext alloc] initWithLocalizer:nil
                                                                              imageProvider:[[ORKESerializationBundleImageProvider alloc] initWithBundle:[NSBundle mainBundle]]
                                                                         stringInterpolator:nil
                                                                           propertyInjector:nil]];
    }
    return ret;
}

- (NSData *)JSONDataForObject:(id)object
                      options:(NSJSONWritingOptions)options
                        error:(NSError * __autoreleasing *)error {
    id json = [self jsonObjectForObject:object context:[[ORKESerializationContext alloc] initWithLocalizer:nil
                                                                                             imageProvider:nil
                                                                                        stringInterpolator:nil
                                                                                          propertyInjector:nil]];
    return [NSJSONSerialization dataWithJSONObject:json options:options error:error];
}

- (NSData *)JSONDataForObject:(id)object error:(NSError * __autoreleasing *)error {
    return [self JSONDataForObject:object options:NSJSONWritingSortedKeys error:error];
}

- (NSDictionary *)JSONObjectForObject:(id)object error:(__unused NSError * __autoreleasing *)error {
    return [self JSONObjectForObject:object
                             context:[[ORKESerializationContext alloc] initWithLocalizer:nil
                                                                           imageProvider:nil
                                                                      stringInterpolator:nil
                                                                        propertyInjector:nil]
                               error:error];
}

- (NSDictionary *)JSONObjectForObject:(id)object
                              context:(ORKESerializationContext *)context
                                error:(__unused NSError * __autoreleasing *)error {
    id json = [self jsonObjectForObject:object context:context];
    return json;
}

- (id)objectFromJSONObject:(NSDictionary *)object error:(__unused NSError * __autoreleasing *)error {
    return [self objectForJsonObject:object
                       expectedClass:nil
                      converterBlock:nil
             twoParamsConverterBlock:nil
                             context:[[ORKESerializationContext alloc] initWithLocalizer:nil
                                                                           imageProvider:[[ORKESerializationBundleImageProvider alloc] initWithBundle:[NSBundle mainBundle]]
                                                                      stringInterpolator:nil
                                                                        propertyInjector:nil]];
}

- (id)objectFromJSONObject:(NSDictionary *)object
                   context:(ORKESerializationContext *)context
                     error:(__unused NSError * __autoreleasing *)error {
    return [self objectForJsonObject:object
                       expectedClass:nil
                      converterBlock:nil
             twoParamsConverterBlock:nil
                             context:context];
}

- (NSArray<NSString *> *)serializableClasses {
    NSMutableArray *a = [NSMutableArray array];
    NSDictionary *table = [self _getEncodingTable];
    for (NSString *key in [table allKeys]) {
        [a addObject:key];
    }
    return a;
}

- (NSArray<NSString *> *)serializedPropertiesForClass:(Class)c {
    NSArray<ORKESerializableTableEntry *> *entries = [self _classEncodingsForClass:c];
    NSMutableArray *properties = [NSMutableArray array];
    for (ORKESerializableTableEntry *entry in entries) {
        [properties addObjectsFromArray:[entry.properties allKeys]];
    }
    return properties;
}

// MARK: helpers

- (id)objectForJsonObject:(id)input 
            expectedClass:(Class)expectedClass
           converterBlock:(ORKESerializationJSONToObjectBlock)converterBlock
           twoParamsConverterBlock:(ORKESerializationJSONToObjectsBlock)twoParamsConverterBlock
                  context:(ORKESerializationContext *)context {
    id output = nil;
    
    if (converterBlock != nil) {
        input = converterBlock(input, context);
    } else if (twoParamsConverterBlock != nil) {
        input = twoParamsConverterBlock(input, context);
    }
    
    if (input == nil) {
        return nil;
    }

    id<ORKESerializationLocalizer> localizer = context.localizer;
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
        
        NSArray *classEncodings = [self _classEncodingsForClass:NSClassFromString(className)];
        NSCAssert([classEncodings count] > 0, @"Expected serializable class but got %@", className);

        // The NSCAssert above is compiled out in Release builds, so it cannot be relied on as a
        // guard. Without this check an unregistered class name from the JSON payload would fall
        // through to a bare [[class alloc] init] below. Return nil instead so deserialization only
        // ever instantiates classes registered in the encoding table.
        if (classEncodings.count == 0) {
            return nil;
        }

        ORKESerializableTableEntry *leafClassEncoding = classEncodings.firstObject;
        ORKESerializationInitBlock initBlock = leafClassEncoding.initBlock;
        BOOL writeAllProperties = YES;
        if (initBlock != nil) {
            output = initBlock(dict, ^id(NSDictionary *propDict, NSString *param) {
                return   [self _propFromDict:propDict propName:param context:context];
            });
            
            writeAllProperties = NO;
        } else {
            Class class = NSClassFromString(className);
            output = [[class alloc] init];
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
                        if (propertyEntry.secondPropertyName != nil) {
                            if (propertyEntry.jsonToObjectsBlock!= nil) {
                                NSDictionary *valuesDict = propertyEntry.jsonToObjectsBlock(dict[key],
                                                                                           context);
                                for (NSString *dictKey in valuesDict.allKeys) {
                                    id propertyValue = valuesDict[dictKey];
                                    [output setValue:propertyValue forKey:dictKey];
                                }
                            }
                        } else {
                            id property = [self _propFromDict:dict propName:key context:context];
                            if ([property isKindOfClass: [NSString class]] && ![key isEqualToString:@"identifier"]) {
                                if (localizer != nil) {
                                    property = [localizer localizedStringForKey:property];
                                }

                                if (stringInterpolator != nil) {
                                    property = [stringInterpolator interpolatedStringForString:property];
                                }
                            }
                            [output setValue:property forKey:key];
                        }
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

- (id)jsonObjectForObject:(id)object context:(ORKESerializationContext *)context {
    if (object == nil) {
        // Leaf: nil
        return nil;
    }
    
    id jsonOutput = nil;
    Class c = [object class];
    
    NSArray *classEncodings = [self _classEncodingsForClass:c];
    
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
                
                ORKESerializationObjectsToJSONBlock twoParamsConverter = propertyEntry.objectsToJSONBlock;
                ORKESerializationObjectToJSONBlock converter = propertyEntry.objectToJSONBlock;
                
                Class containerClass = propertyEntry.containerClass;
                id valueForKey = [object valueForKey:propertyName];
                if (valueForKey != nil) {
                    if ([containerClass isSubclassOfClass:[NSArray class]]) {
                        NSMutableArray *a = [NSMutableArray array];
                        for (id valueItem in valueForKey) {
                            id outputItem;
                            if (converter != nil) {
                                outputItem = converter(valueItem, context);
                                NSCAssert(isValid(outputItem), @"Expected valid JSON object");
                            } else {
                                // Recurse for each property
                                outputItem = [self jsonObjectForObject:valueItem context:context];
                            }
                            [a addObject:outputItem];
                        }
                        valueForKey = a;
                    } else {
                        if (twoParamsConverter != nil) {
                            id secondValueItem = [object valueForKey:propertyEntry.secondPropertyName];
                            valueForKey = twoParamsConverter(valueForKey, secondValueItem, context);
                            NSCAssert((valueForKey == nil) || isValid(valueForKey), @"Expected valid JSON object");
                        } else if (converter != nil) {
                            valueForKey = converter(valueForKey, context);
                            NSCAssert((valueForKey == nil) || isValid(valueForKey), @"Expected valid JSON object");
                        } else {
                            // Recurse for each property
                            valueForKey = [self jsonObjectForObject:valueForKey context:context];
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
            [encodedArray addObject:[self jsonObjectForObject:input context:context]];
        }
        jsonOutput = encodedArray;
    } else if ([c isSubclassOfClass:[NSDictionary class]]) {
        NSDictionary *inputDict = (NSDictionary *)object;
        NSMutableDictionary *encodedDictionary = [NSMutableDictionary dictionaryWithCapacity:[inputDict count]];
        for (NSString *key in [inputDict allKeys] ) {
            // Recurse for each dictionary value
            encodedDictionary[key] = [self jsonObjectForObject:inputDict[key] context:context];
        }
        jsonOutput = encodedDictionary;
    } else if (![c isSubclassOfClass:[NSPredicate class]]) {  // Ignore NSPredicate which cannot be easily serialized for now
        NSCAssert(isValid(object), @"Expected valid JSON object");
        // Leaf: native JSON object
        jsonOutput = object;
    }
    
    return jsonOutput;
}

static BOOL isValid(id object) {
    return [NSJSONSerialization isValidJSONObject:object] || [object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNull class]] || [object isKindOfClass:[ORKNoAnswer class]];
}

- (NSMutableDictionary<NSString *,ORKESerializableTableEntry *> *)_getEncodingTable {
    if (!_encodingTable) {
        NSMutableDictionary<NSString *,ORKESerializableTableEntry *> *encodingTable = [NSMutableDictionary new];
        for (ORKSerializationEntryProvider *entryProvider in _entryProviders) {
            [encodingTable addEntriesFromDictionary:[entryProvider serializationEncodingTable]];
        }
        
        NSMutableDictionary *staticEncodingTable = ORKESerializationEncodingTable();
        [encodingTable addEntriesFromDictionary:staticEncodingTable];
        
        _encodingTable = encodingTable;
    }
    
    return [_encodingTable copy];
}

- (NSArray<ORKESerializableTableEntry *> *)_classEncodingsForClass:(Class)class {
    NSDictionary<NSString *, ORKESerializableTableEntry *> *encodingTable = [self _getEncodingTable];
    
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

- (id)_propFromDict:(NSDictionary *)dict
           propName:(NSString *)propName
            context:(ORKESerializationContext *)context {
    Class class = NSClassFromString(dict[_ClassKey]);


    NSArray *classEncodings =  [self _classEncodingsForClass:class];
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
    ORKESerializationJSONToObjectsBlock twoParamsConverterBlock = propertyEntry.jsonToObjectsBlock;

    id input = dict[propName];
    id output = nil;
    if (input != nil) {
        if ([containerClass isSubclassOfClass:[NSArray class]]) {
            NSMutableArray *outputArray = [NSMutableArray array];
            for (id value in DYNAMICCAST(input, NSArray)) {
                id convertedValue = [self objectForJsonObject:value
                                                expectedClass:propertyClass
                                               converterBlock:converterBlock
                                      twoParamsConverterBlock:twoParamsConverterBlock
                                                      context:context];
                NSCAssert(convertedValue != nil, @"Could not convert to object of class %@", propertyClass);
                [outputArray addObject:convertedValue];
            }
            output = outputArray;
        } else if ([containerClass isSubclassOfClass:[NSDictionary class]]) {
            NSMutableDictionary *outputDictionary = [NSMutableDictionary dictionary];
            for (NSString *key in [DYNAMICCAST(input, NSDictionary) allKeys]) {
                id convertedValue = [self
                                     objectForJsonObject:DYNAMICCAST(input, NSDictionary)[key]
                                     expectedClass:propertyClass
                                     converterBlock:converterBlock
                                     twoParamsConverterBlock:twoParamsConverterBlock
                                     context:nil];
                NSCAssert(convertedValue != nil, @"Could not convert to object of class %@", propertyClass);
                outputDictionary[key] = convertedValue;
            }
            output = outputDictionary;
        } else {
            NSCAssert(containerClass == [NSObject class], @"Unexpected container class %@", containerClass);
            output = [self objectForJsonObject:input
                                 expectedClass:propertyClass
                                converterBlock:converterBlock
                       twoParamsConverterBlock:twoParamsConverterBlock
                                       context:context];

            // Edge case for ORKAnswerFormat options. Certain formats (e.g. ORKTextChoiceAnswerFormat) contain
            // text strings (e.g. 'Yes', 'No') that need to be localized but are already of the expected type.
            //
            // Remaining localization/interpolication is done in `objectForJsonObject`.
            if ([output isKindOfClass:[NSString class]] && ![propName isEqualToString:@"identifier"]) {
                id<ORKESerializationLocalizer> localizer = context.localizer;
                id<ORKESerializationStringInterpolator> stringInterpolator = context.stringInterpolator;

                if (localizer != nil) {
                    output =  [localizer localizedStringForKey:output];
                }

                if (stringInterpolator != nil) {
                    output = [stringInterpolator interpolatedStringForString:output];
                }
            }
        }
    }
    return output;
}

static NSMutableDictionary<NSString *, ORKESerializableTableEntry *> *ORKESerializationEncodingTable(void) {
    static dispatch_once_t onceToken;
    static NSMutableDictionary<NSString *, ORKESerializableTableEntry *> *internalEncodingTable = nil;
    dispatch_once(&onceToken, ^{
        internalEncodingTable =
        [@{} mutableCopy];
    });
    return internalEncodingTable;
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
                                                       secondPropertyName:secondPropertyName
                                                         secondValueClass:secondValueClass
                                                     secondContainerClass:secondContainerClass
                                                           writeAfterInit:writeAfterInit
                                                       objectsToJSONBlock:objectsToJSON
                                                       jsonToObjectsBlock:jsonToObjectsBlock
                                                        skipSerialization:skipSerialization];
        entry.properties[propertyName] = property;
    } else {
        property.propertyName = propertyName;
        property.valueClass = valueClass;
        property.containerClass = containerClass;
        property.secondPropertyName = secondPropertyName;
        property.secondValueClass = secondValueClass;
        property.secondContainerClass = secondContainerClass;
        property.writeAfterInit = writeAfterInit;
        property.objectsToJSONBlock = objectsToJSON;
        property.jsonToObjectsBlock = jsonToObjectsBlock;
        property.skipSerialization = skipSerialization;
    }

}
@end
