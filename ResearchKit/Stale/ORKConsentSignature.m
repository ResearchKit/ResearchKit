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


#import "ORKConsentSignature.h"

#import "ORKHelpers_Internal.h"


@implementation ORKConsentSignature

+ (ORKConsentSignature *)signatureForPersonWithTitle:(NSString *)title
                                   dateFormatString:(NSString *)dateFormatString
                                         identifier:(NSString *)identifier
                                          givenName:(NSString *)givenName
                                           familyName:(NSString *)familyName
                                     signatureImage:(UIImage *)signatureImage
                                         dateString:(NSString *)signatureDate {
    ORKConsentSignature *sig = [ORKConsentSignature new];
    sig.title = title;
    sig.givenName = givenName;
    sig.familyName = familyName;
    sig.signatureImage = signatureImage;
    sig.signatureDate = signatureDate;
    sig.identifier = identifier;
    sig.signatureDateFormatString = dateFormatString;
    
    return sig;
}

+ (ORKConsentSignature *)signatureForPersonWithTitle:(NSString *)title
                                   dateFormatString:(NSString *)dateFormatString
                                         identifier:(NSString *)identifier {
    ORKConsentSignature *sig = [ORKConsentSignature signatureForPersonWithTitle:title dateFormatString:dateFormatString identifier:identifier givenName:nil familyName:nil signatureImage:nil dateString:nil ];
    return sig;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requiresName = YES;
        _requiresSignatureImage = YES;
        self.identifier = [NSUUID UUID].UUIDString;
    }
    return self;
}

- (void)setIdentifier:(NSString *)identifier {
    ORKThrowInvalidArgumentExceptionIfNil(identifier);
    
    _identifier = identifier;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, identifier, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, title, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, givenName, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, familyName, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, signatureDate, NSString);
        ORK_DECODE_BOOL(aDecoder, requiresName);
        ORK_DECODE_BOOL(aDecoder, requiresSignatureImage);
        ORK_DECODE_IMAGE(aDecoder, signatureImage);
        ORK_DECODE_OBJ_CLASS(aDecoder, signatureDateFormatString, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, identifier);
    ORK_ENCODE_OBJ(aCoder, title);
    ORK_ENCODE_OBJ(aCoder, givenName);
    ORK_ENCODE_OBJ(aCoder, familyName);
    ORK_ENCODE_OBJ(aCoder, signatureDate);
    ORK_ENCODE_BOOL(aCoder, requiresName);
    ORK_ENCODE_BOOL(aCoder, requiresSignatureImage);
    ORK_ENCODE_IMAGE(aCoder, signatureImage);
    ORK_ENCODE_OBJ(aCoder, signatureDateFormatString);
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.identifier, castObject.identifier)
            && ORKEqualObjects(self.title, castObject.title)
            && ORKEqualObjects(self.givenName, castObject.givenName)
            && ORKEqualObjects(self.familyName, castObject.familyName)
            && ORKEqualObjects(self.signatureDate, castObject.signatureDate)
            && ORKEqualObjects(self.signatureImage, castObject.signatureImage)
            && ORKEqualObjects(self.signatureDateFormatString, castObject.signatureDateFormatString)
            && (self.requiresName == castObject.requiresName)
            && (self.requiresSignatureImage == castObject.requiresSignatureImage));
}

- (NSUInteger)hash {
    return _identifier.hash ^ _title.hash ^ _givenName.hash ^ _familyName.hash ^ _signatureDate.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKConsentSignature *sig = [[[self class] allocWithZone:zone] init];
    sig.identifier = [_identifier copy];
    sig.title = [_title copy];
    sig.givenName = [_givenName copy];
    sig.familyName = [_familyName copy];
    sig->_requiresName = _requiresName;
    sig->_requiresSignatureImage = _requiresSignatureImage;
    sig.signatureImage = _signatureImage;
    sig.signatureDateFormatString = [_signatureDateFormatString copy];
    sig.signatureDate = [_signatureDate copy];
    return sig;
}

@end
