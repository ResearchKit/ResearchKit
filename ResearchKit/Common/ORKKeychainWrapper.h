 /**
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


#import <Foundation/Foundation.h>
#import "ORKDefines.h"


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKKeychainWrapper` class is an abstraction layer for the iOS keychain
 communication.
 */
ORK_CLASS_AVAILABLE
@interface ORKKeychainWrapper : NSObject

/**
 Sets the given object in the keychain for the provided key.
 
 @param object      The data to be stored in the keychain.
 @param key         The key used to set the data in the keychain.
 @param error       If failure occurred, an `NSError` object indicating the reason for the
                    failure. The value of this parameter is `nil` if `result` does not
                    indicate failure.
 
 @return A boolean with a value `YES` if the object was saved; otherwise `NO'.
 */
+ (BOOL)setObject:(id<NSSecureCoding>)object forKey:(NSString *)key error:(NSError * _Nullable *)error;


/**
 Returns the object in the keychain for the provided key.
 
 @param key         The key used to set the data in the keychain.
 @param error       If failure occurred, an `NSError` object indicating the reason for the
                    failure. The value of this parameter is `nil` if `result` does not
                    indicate failure.
 
 @return An object or `nil` if key is not valid.
 */
+ (id<NSSecureCoding>)objectForKey:(NSString *)key error:(NSError * _Nullable *)error;

/**
 Removes the object in the keychain for the provided key.
 
 @param key         The key used to set the value in the keychain.
 @param error       If failure occurred, an `NSError` object indicating the reason for the
                    failure. The value of this parameter is `nil` if `result` does not
                    indicate failure.
 
 @return A boolean with a value `YES` if the object was removed; otherwise `NO'.
*/
+ (BOOL)removeObjectForKey:(NSString *)key error:(NSError * _Nullable *)error;

/**
 Removes all values stored in the keychain for the app.

 @param error       If failure occurred, an `NSError` object indicating the reason for the
                    failure. The value of this parameter is `nil` if `result` does not
                    indicate failure.
 
 @return A boolean with a value `YES` if the keychain was reset; otherwise `NO'.
*/
+ (BOOL)resetKeychainWithError:(NSError * _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
