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

#import "ORKESerializer+ActiveTaskSerializationEntryProvider.h"

#import "ORKActiveTaskSerializationEntryProvider.h"

#import <ResearchKit/ORKCoreSerializationEntryProvider.h>


@implementation ORKESerializer (SerializationEntryProvider)

+ (id)activeTask_objectFromJSONData:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error {
    ORKESerializer *serializer = [self _getInitializedSerializer];
    return [serializer objectFromJSONData:data error:error];
}

+ (NSData *)activeTask_JSONDataForObject:(id)object error:(NSError *__autoreleasing  _Nullable *)error {
    ORKESerializer *serializer = [self _getInitializedSerializer];
    return [serializer JSONDataForObject:object error:error];
}

+ (NSDictionary *)activeTask_JSONObjectForObject:(id)object error:(NSError *__autoreleasing  _Nullable *)error {
    ORKESerializer *serializer = [self _getInitializedSerializer];
    return [serializer JSONObjectForObject:object error:error];
}

+ (NSDictionary *)activeTask_JSONObjectForObject:(id)object
                                         context:(ORKESerializationContext *)context
                                           error:(NSError *__autoreleasing  _Nullable *)error {
    ORKESerializer *serializer = [self _getInitializedSerializer];
    return [serializer JSONObjectForObject:object context:context error:error];
}

+ (id)activeTask_objectFromJSONObject:(NSDictionary *)object error:(NSError *__autoreleasing  _Nullable *)error {
    ORKESerializer *serializer = [self _getInitializedSerializer];
    return [serializer objectFromJSONObject:object error:error];
}

+ (id)activeTask_objectFromJSONObject:(NSDictionary *)object
                              context:(ORKESerializationContext *)context
                                error:(NSError *__autoreleasing  _Nullable *)error {
    ORKESerializer *serializer = [self _getInitializedSerializer];
    return [serializer objectFromJSONObject:object context:context error:error];
}

+ (ORKESerializer *)_getInitializedSerializer {
    ORKCoreSerializationEntryProvider *coreEntryProvider = [ORKCoreSerializationEntryProvider new];
    ORKActiveTaskSerializationEntryProvider *activeTaskEntryProvider = [ORKActiveTaskSerializationEntryProvider new];
    ORKESerializer *serializer = [[ORKESerializer alloc] initWithEntryProviders:@[coreEntryProvider, activeTaskEntryProvider]];
    return serializer;
}

@end
