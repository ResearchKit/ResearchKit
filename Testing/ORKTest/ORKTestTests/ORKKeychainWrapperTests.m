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


@import XCTest;
@import ResearchKit.Private;


@interface ORKKeychainWrapperTests : XCTestCase

@end


static NSString *const inObject = @"RK object";
static NSString *const key = @"RK key";
static NSString *const invalidKey = @"RK invalid key";

@implementation ORKKeychainWrapperTests

- (void)testSetObjectInKeychain {
    NSError *error;

    // Test that the object is set without error.
    BOOL success = [ORKKeychainWrapper setObject:inObject
                                          forKey:key
                                           error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(success);
    
    // Test that the object set is equal to the object retrieved.
    NSString *outObject = (NSString *) [ORKKeychainWrapper objectForKey:key
                                                                  error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(inObject, outObject);
    
}

- (void)testGetObjectFromKeychain {
    NSError *error;
    
    // Set an object in the keychain.
    BOOL success = [ORKKeychainWrapper setObject:inObject
                           forKey:key
                            error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(success);
    
    // Test that the object set is equal to the object retrieved.
    NSString *outObject = (NSString *) [ORKKeychainWrapper objectForKey:key
                                                                  error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(inObject, outObject);
    
    // Test that there is an error for invalid key.
    id object = [ORKKeychainWrapper objectForKey:invalidKey
                               error:&error];
    XCTAssertNotNil(error);
    XCTAssertNil(object);
}

- (void)testRemoveObjectFromKeychain {
    NSError *error;
    
    // Set an object in the keychain.
    BOOL success = [ORKKeychainWrapper setObject:inObject
                           forKey:key
                            error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(success);
    
    // Remove the object from the keychain.
    success = [ORKKeychainWrapper removeObjectForKey:key
                                               error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(success);
    
    // Test that there is no object for the key.
    id object = [ORKKeychainWrapper objectForKey:key
                                           error:&error];
    XCTAssertNotNil(error);
    XCTAssertNil(object);
}

- (void)testResetKeychain {
    NSError *error;
    
    // Set an object in the keychain.
    BOOL success = [ORKKeychainWrapper setObject:inObject
                                          forKey:key
                                           error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(success);
    
    // Reset the keychain.
    success = [ORKKeychainWrapper resetKeychainWithError:&error];
    XCTAssertNil(error);
    XCTAssertTrue(success);
    
    // Test that there is no object for the key.
    id object = [ORKKeychainWrapper objectForKey:key
                                           error:&error];
    XCTAssertNotNil(error);
    XCTAssertNil(object);
}

@end
