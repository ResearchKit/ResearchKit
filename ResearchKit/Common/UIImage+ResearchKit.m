/*
 Copyright (c) 2015, Sage Bionetworks
 
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


#import "UIImage+ResearchKit.h"


@implementation UIImage (ResearchKit)

- (UIImage *)ork_flippedImage:(UIImageOrientation)orientation {
    
    if (self.images.count > 0) {
        NSMutableArray <UIImage *> *images = [self.images mutableCopy];
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop __unused) {
            [images replaceObjectAtIndex:idx
                              withObject:[image ork_flippedImage:orientation]];
        }];
        return [UIImage animatedImageWithImages:images duration:self.duration];
    } else {
        // [UIImage imageWithCGImage:self.CGImage scale:self.scale orientation:orientation] doesn't seem
        // to work with images that are vector PDF rather than PNG, so...
        CGRect bounds = CGRectMake(0., 0., self.size.width, self.size.height);
        CGAffineTransform transform = CGAffineTransformIdentity;
        switch(orientation) {
            case UIImageOrientationUp: {
                transform = CGAffineTransformIdentity;
            } break;
                
            case UIImageOrientationUpMirrored: {
                transform = CGAffineTransformMakeTranslation(self.size.width, 0.);
                transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
            } break;
                
            case UIImageOrientationDown: {
                transform = CGAffineTransformMakeTranslation(self.size.width, self.size.height);
                transform = CGAffineTransformRotate(transform, M_PI);
            } break;
                
            case UIImageOrientationDownMirrored: {
                transform = CGAffineTransformMakeTranslation (0., self.size.height);
                transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
            } break;
                
            case UIImageOrientationLeftMirrored: {
                CGFloat boundHeight = bounds.size.height;
                bounds.size.height = bounds.size.width;
                bounds.size.width = boundHeight;
                transform = CGAffineTransformMakeTranslation (self.size.height, self.size.width);
                transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
                transform = CGAffineTransformRotate(transform, 3.0f * M_PI/ 2.0f);
            } break;
                
            case UIImageOrientationLeft: {
                CGFloat boundHeight = bounds.size.height;
                bounds.size.height = bounds.size.width;
                bounds.size.width = boundHeight;
                transform = CGAffineTransformMakeTranslation (0.0f, self.size.width);
                transform = CGAffineTransformRotate(transform, 3.0f * M_PI / 2.0f);
            } break;
                
            case UIImageOrientationRightMirrored: {
                CGFloat boundHeight = bounds.size.height;
                bounds.size.height = bounds.size.width;
                bounds.size.width = boundHeight;
                transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
                transform = CGAffineTransformRotate(transform, M_PI / 2.0f);
            } break;
                
            case UIImageOrientationRight: {
                CGFloat boundHeight = bounds.size.height;
                bounds.size.height = bounds.size.width;
                bounds.size.width = boundHeight;
                transform = CGAffineTransformMakeTranslation(self.size.height, 0.0f);
                transform = CGAffineTransformRotate(transform, M_PI  / 2.0f);
            } break;
        }

        UIGraphicsBeginImageContext(self.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextConcatCTM(context, transform);

        [self drawInRect:CGRectMake(0.f, 0.f, self.size.width, self.size.height)];
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}

@end
