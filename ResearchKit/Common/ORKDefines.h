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

#if defined(__cplusplus)
#  define ORK_EXTERN extern "C" __attribute__((visibility("default")))
#else
#  define ORK_EXTERN extern __attribute__((visibility("default")))
#endif

#define ORK_CLASS_AVAILABLE __attribute__((visibility("default")))
#define ORK_ENUM_AVAILABLE
#define ORK_AVAILABLE_DECL

#define ORK_IOS_10_WATCHOS_3_AVAILABLE (NSClassFromString(@"HKWorkoutConfiguration") != nil)

#define ORK_TO_BE_DEPRECATED(message) \
__deprecated_msg(message)

// For Serializer

#define ESTRINGIFY2(x) #x
#define ESTRINGIFY(x) ESTRINGIFY2(x)

#define NUMTOSTRINGBLOCK(table) ^id(id num, __unused ORKESerializationContext *context) { return table[((NSNumber *)num).unsignedIntegerValue]; }

#define STRINGTONUMBLOCK(table) ^id(id string, __unused ORKESerializationContext *context) { NSUInteger index = [table indexOfObject:string]; \
NSCAssert(index != NSNotFound, @"Expected valid entry from table %@", table); \
return @(index); \
}

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

#define PROPERTY_TIED_TO_OTHER_PROPERTY(propertyName, mValueClass, mContainerClass, mSecondPropertyName, mSecondValueClass, mSecondContainerClass, mWriteAfterInit, mObjectsToJSONBlock, mJsonToObjectsBlock) \
    @ESTRINGIFY(propertyName) : ([[ORKESerializableProperty alloc] initWithPropertyName: @ESTRINGIFY(propertyName) \
                                                                             valueClass: [mValueClass class] \
                                                                         containerClass: [mContainerClass class] \
                                                                     secondPropertyName: @ESTRINGIFY(mSecondPropertyName) \
                                                                       secondValueClass: [mSecondValueClass class] \
                                                                   secondContainerClass: [mSecondContainerClass class] \
                                                                         writeAfterInit: mWriteAfterInit \
                                                                      objectsToJSONBlock: mObjectsToJSONBlock \
                                                                      jsonToObjectsBlock: mJsonToObjectsBlock \
                                                                      skipSerialization: NO])

#define SKIP_PROPERTY(propertyName, mValueClass, mContainerClass, mWriteAfterInit, mObjectToJSONBlock, mJsonToObjectBlock) \
@ESTRINGIFY(propertyName) : ([[ORKESerializableProperty alloc] initWithPropertyName: @ESTRINGIFY(propertyName) \
                                                                         valueClass: [mValueClass class] \
                                                                     containerClass: [mContainerClass class] \
                                                                     writeAfterInit: mWriteAfterInit \
                                                                  objectToJSONBlock: mObjectToJSONBlock \
                                                                  jsonToObjectBlock: mJsonToObjectBlock \
                                                                  skipSerialization: YES])


#define IMAGEPROPERTY(propertyName, mContainerClass, mWriteAfterInit) \
    @ESTRINGIFY(propertyName) : [[ORKESerializableProperty alloc] imagePropertyObjectWithPropertyName: @ESTRINGIFY(propertyName) \
                                                                                       containerClass: [mContainerClass class] \
                                                                                       writeAfterInit: mWriteAfterInit \
                                                                                    skipSerialization: YES]

#define GETPROP(d,x) getter(d, @ESTRINGIFY(x))

#define DYNAMICCAST(x, c) ((c *) ([x isKindOfClass:[c class]] ? x : nil))
