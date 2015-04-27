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


#import "ORKTintedImageView.h"


static UIImage *ORKImageByTintingImage(UIImage *image, UIColor *tintColor, CGFloat scale) {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, scale);
    CGContextRef context     = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetAlpha(context, 1);
    
    CGRect r = (CGRect){{0,0},image.size};
    CGContextBeginTransparencyLayerWithRect(context, r, NULL);
    [tintColor setFill];
    [image drawInRect:r];
    UIRectFillUsingBlendMode(r, kCGBlendModeSourceIn);
    CGContextEndTransparencyLayer(context);
    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

@implementation ORKTintedImageView {
    UIImage *_originalImage;
}

- (void)setShouldApplyTint:(BOOL)shouldApplyTint {
    _shouldApplyTint = shouldApplyTint;
    
    [self setImage:self.image];
}

- (UIImage *)imageByTintingImage:(UIImage *)image {
    UIImageRenderingMode renderMode = [image renderingMode];
    BOOL isAnimatedImage = [[image images] count] > 1;
    if (isAnimatedImage) {
        renderMode = UIImageRenderingModeAutomatic;
    }
    if (_shouldApplyTint != (renderMode == UIImageRenderingModeAlwaysTemplate) ) {
        if (! isAnimatedImage) {
            image = [image imageWithRenderingMode:(_shouldApplyTint ? UIImageRenderingModeAlwaysTemplate : UIImageRenderingModeAutomatic)];
        } else {
            // Have to manually apply the tint to the input images if it's an animated sequence.
            // <rdar://problem/19792197>
            NSMutableArray *images = [NSMutableArray array];
            UIColor *tintColor = [self tintColor];
            for (UIImage *im in image.images) {
                [images addObject:ORKImageByTintingImage(im, tintColor, self.contentScaleFactor)];
            }
            image = [UIImage animatedImageWithImages:images duration:image.duration];
        }
    }
    return image;
}

- (void)setImage:(UIImage *)image {
    _originalImage = image;
    image = [self imageByTintingImage:image];
    [super setImage:image];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    // If we're an animated, image we have to recompute for the new tint color
    if ([[_originalImage images] count] > 1) {
        self.image = _originalImage;
    }
}

@end
