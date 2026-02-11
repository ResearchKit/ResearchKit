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

#import <ResearchKit/ORKFileResult.h>

@implementation ORKAmslerGridResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, path);
    ORK_ENCODE_ENUM(aCoder, eyeSide);
    ORK_ENCODE_OBJ(aCoder, imageFileResult);
    ORK_ENCODE_OBJ(aCoder, drawingPathFileResult);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, path, UIBezierPath);
        ORK_DECODE_ENUM(aDecoder, eyeSide);
        ORK_DECODE_OBJ_CLASS(aDecoder, imageFileResult, ORKFileResult);
        ORK_DECODE_OBJ_CLASS(aDecoder, drawingPathFileResult, ORKFileResult);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSUInteger)hash {
    return super.hash ^ self.path.hash ^ self.imageFileResult.hash ^ self.drawingPathFileResult.hash;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.path, castObject.path) &&
            ORKEqualObjects(self.imageFileResult, castObject.imageFileResult) &&
            ORKEqualObjects(self.drawingPathFileResult, castObject.drawingPathFileResult) &&
            (self.eyeSide == castObject.eyeSide));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKAmslerGridResult *result = [super copyWithZone:zone];
    result->_path = ORKArrayCopyObjects(_path);
    result->_eyeSide = _eyeSide;
    result->_imageFileResult = _imageFileResult;
    result->_drawingPathFileResult = _drawingPathFileResult;
    return result;
}

@end
