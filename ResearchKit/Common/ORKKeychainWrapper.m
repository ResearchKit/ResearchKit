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


#import "ORKKeychainWrapper.h"
#import "ORKDefines_Private.h"


static NSString *ORKKeychainWrapperDefaultService() {
    static NSString *defaultService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultService = [[NSBundle mainBundle] bundleIdentifier];
    });
    return defaultService;
}

@implementation ORKKeychainWrapper

#pragma mark - Public Methods

+ (BOOL)setObject:(id<NSSecureCoding>)object
           forKey:(NSString *)key
            error:(NSError **)error {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    return [self setData:data
                  forKey:key
                 service:ORKKeychainWrapperDefaultService()
             accessGroup:nil
                   error:error];
}

+ (id<NSSecureCoding>)objectForKey:(NSString *)key
             error:(NSError **)error {
    NSData *data = [self dataForKey:key
                            service:ORKKeychainWrapperDefaultService()
                        accessGroup:nil
                              error:error];
    return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

+ (BOOL)removeObjectForKey:(NSString *)key
                     error:(NSError **)error {
    return [self removeItemForKey:key
                          service:ORKKeychainWrapperDefaultService()
                      accessGroup:nil
                            error:error];
}

+ (BOOL)resetKeychainWithError:(NSError **)error {
    return [self removeAllItemsForService:ORKKeychainWrapperDefaultService()
                              accessGroup:nil
                                    error:error];
}

#pragma mark - Private Methods

+ (NSData *)dataForKey:(NSString *)key
               service:(NSString *)service
           accessGroup:(NSString *)accessGroup
                 error:(NSError **)error {
    NSData *returnValue = nil;
    if (key) {
        if (!service) {
            service = ORKKeychainWrapperDefaultService();
        }
        
        NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
        [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
        [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
        [query setObject:service forKey:(__bridge id)kSecAttrService];
        [query setObject:key forKey:(__bridge id)kSecAttrAccount];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        if (accessGroup) {
            [query setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
        }
#endif
        
        CFTypeRef data = nil;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &data);
        if (status != errSecSuccess) {
            if (error) {
                *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                             code:status
                                         userInfo:@{NSLocalizedDescriptionKey : ORKLocalizedString(@"KEYCHAIN_FIND_ERROR_MESSAGE", nil)}];
            }
        } else {
            returnValue = [NSData dataWithData:(__bridge NSData *)data];
            if (data) {
                CFRelease(data);
            }
        }
    }
    return returnValue;
}

+ (BOOL)setData:(NSData *)data
         forKey:(NSString *)key
        service:(NSString *)service
    accessGroup:(NSString *)accessGroup
          error:(NSError **)error {
    BOOL returnValue = YES;
    if (key) {
        if (!service) {
            service = ORKKeychainWrapperDefaultService();
        }
        
        NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
        [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [query setObject:service forKey:(__bridge id)kSecAttrService];
        [query setObject:key forKey:(__bridge id)kSecAttrAccount];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        if (accessGroup) {
            [query setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
        }
#endif
        
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
        if (status == errSecSuccess) {
            if (data) {
                NSMutableDictionary *attributesToUpdate = [[NSMutableDictionary alloc] init];
                [attributesToUpdate setObject:data forKey:(__bridge id)kSecValueData];
                
                status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
                if (status != errSecSuccess) {
                    if (error) {
                        *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                                     code:status
                                                 userInfo:@{NSLocalizedDescriptionKey : ORKLocalizedString(@"KEYCHAIN_UPDATE_ERROR_MESSAGE", nil)}];
                    }
                    returnValue = NO;
                }
            } else {
                [self removeItemForKey:key service:service accessGroup:accessGroup error:error];
            }
        } else if (status == errSecItemNotFound) {
            NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
            [attributes setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
            [attributes setObject:service forKey:(__bridge id)kSecAttrService];
            [attributes setObject:key forKey:(__bridge id)kSecAttrAccount];
#if TARGET_OS_IPHONE || (defined(MAC_OS_X_VERSION_10_9) && MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_9)
            [attributes setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlock forKey:(__bridge id)kSecAttrAccessible];
#endif
            [attributes setObject:data forKey:(__bridge id)kSecValueData];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
            if (accessGroup) {
                [attributes setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
            }
#endif
            
            status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
            if (status != errSecSuccess) {
                if (error) {
                    *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                                 code:status
                                             userInfo:@{NSLocalizedDescriptionKey : ORKLocalizedString(@"KEYCHAIN_ADD_ERROR_MESSAGE", nil)}];
                }
                returnValue = NO;
            }
        } else {
            returnValue = NO;
        }
    }
    return returnValue;
}

+ (BOOL)removeItemForKey:(NSString *)key
                 service:(NSString *)service
             accessGroup:(NSString *)accessGroup
                   error:(NSError **)error {
    BOOL returnValue = NO;
    if (key) {
        if (!service) {
            service = ORKKeychainWrapperDefaultService();
        }
        
        NSMutableDictionary *itemToDelete = [[NSMutableDictionary alloc] init];
        [itemToDelete setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [itemToDelete setObject:service forKey:(__bridge id)kSecAttrService];
        [itemToDelete setObject:key forKey:(__bridge id)kSecAttrAccount];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        if (accessGroup) {
            [itemToDelete setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
        }
#endif
        
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)itemToDelete);
        if (status != errSecSuccess && status != errSecItemNotFound) {
            if (error) {
                *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                             code:status
                                         userInfo:@{NSLocalizedDescriptionKey : ORKLocalizedString(@"KEYCHAIN_DELETE_ERROR_MESSAGE", nil)}];
            }
            returnValue = NO;
        } else {
            returnValue = YES;
        }
    }
    return returnValue;
}

+ (BOOL)removeAllItemsForService:(NSString *)service
                     accessGroup:(NSString *)accessGroup
                           error:(NSError **)error {
    NSArray *items = [self itemsForService:service accessGroup:accessGroup error:error];
    BOOL returnValue = NO;
    for (NSDictionary *item in items) {
        NSMutableDictionary *itemToDelete = [[NSMutableDictionary alloc] initWithDictionary:item];
        [itemToDelete setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)itemToDelete);
        if (status != errSecSuccess) {
            if (error) {
                *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                             code:status
                                         userInfo:@{NSLocalizedDescriptionKey : ORKLocalizedString(@"KEYCHAIN_DELETE_ERROR_MESSAGE", nil)}];
            }
            returnValue = NO;
        } else {
            returnValue = YES;
        }
    }
    return returnValue;
}

+ (NSArray *)itemsForService:(NSString *)service
                 accessGroup:(NSString *)accessGroup
                       error:(NSError **)error {
    if (!service) {
        service = ORKKeychainWrapperDefaultService();
    }
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    [query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [query setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
    [query setObject:service forKey:(__bridge id)kSecAttrService];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    if (accessGroup) {
        [query setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
#endif
    
    CFTypeRef result = nil;
    NSArray *returnValue = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess || status == errSecItemNotFound) {
        returnValue =  (__bridge NSArray *)(result);
    } else {
        if (error) {
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                         code:status
                                     userInfo:@{NSLocalizedDescriptionKey : ORKLocalizedString(@"KEYCHAIN_FIND_ERROR_MESSAGE", nil)}];
        }
        returnValue = nil;
    }
    
    if(result) {
         CFBridgingRelease(result);
    }
    
    return returnValue;
}

@end
