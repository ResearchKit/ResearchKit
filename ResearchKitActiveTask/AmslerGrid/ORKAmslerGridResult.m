/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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


#import "ORKAmslerGridResult.h"
#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"

@implementation ORKAmslerGridResult


- (instancetype)initWithIdentifier:(NSString *)identifier
                             image:(UIImage *)image
                              path:(NSArray<UIBezierPath *> *)path
                           eyeSide:(ORKAmslerGridEyeSide)eyeSide{
    self = [super initWithIdentifier:identifier];
    if (self) {
        _image = [image copy];
        _path = ORKArrayCopyObjects(path);
        _eyeSide = eyeSide;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_IMAGE(aCoder, image);
    ORK_ENCODE_OBJ(aCoder, path);
    ORK_ENCODE_ENUM(aCoder, eyeSide);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_IMAGE(aDecoder, image);
        ORK_DECODE_OBJ_ARRAY(aDecoder, path, UIBezierPath);
        ORK_DECODE_ENUM(aDecoder, eyeSide);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSUInteger)hash {
    return super.hash ^ self.image.hash ^ self.path.hash;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.image, castObject.image) &&
            ORKEqualObjects(self.path, castObject.path) &&
            (self.eyeSide == castObject.eyeSide));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKAmslerGridResult *result = [super copyWithZone:zone];
    result->_image = [_image copy];
    result->_path = ORKArrayCopyObjects(_path);
    result->_eyeSide = _eyeSide;
    return result;
}

@end
