/*
 Copyright (c) 2015, Rugen Heidbuchel All rights reserved.
 
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

#import "ORKBodyShaderView.h"

@interface ORKBodyShaderView ()

@property (nonatomic, strong) ORKShaderView *frontShaderView, *backShaderView;
@property (nonatomic, strong) UIButton *drawButton, *eraseButton;

@end

@implementation ORKBodyShaderView {
    
    UIImage *_frontImage, *_backImage;
    int _frontShadedPixels, _frontTotalPixels, _backShadedPixels, _backTotalPixels;
    float _shadedPercentage;
}


#pragma mark - Init

- (nonnull instancetype)initWithDelegate:(nonnull id<ORKBodyShaderViewDelegate>)delegate {
    
    self = [super init];
    if (self) {
        
        self.delegate = delegate;
        [self setupLayout];
    }
    return self;
}

- (void) setupLayout {
    
    if (!_frontShaderView) {
        
        UIView *frontOverlayView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(200, 200)}];
        frontOverlayView.backgroundColor = [UIColor clearColor];
        
        _frontShaderView = [[ORKShaderView alloc] initWithSize:CGSizeMake(200, 200) overlayView:frontOverlayView delegate:self];
        
        [self addSubview:_frontShaderView];
    }
    
    if (!_backShaderView) {
        
        UIView *backOverlayView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(200, 200)}];
        backOverlayView.backgroundColor = [UIColor clearColor];
        
        _backShaderView = [[ORKShaderView alloc] initWithSize:CGSizeMake(200, 200) overlayView:backOverlayView delegate:self];
        
        [self addSubview:_backShaderView];
    }
    
//    NSDictionary *views = NSDictionaryOfVariableBindings(_frontShaderView, _backShaderView);
    
    _frontShaderView.translatesAutoresizingMaskIntoConstraints = NO;
    _backShaderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_frontShaderView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_backShaderView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_frontShaderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_backShaderView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_frontShaderView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_frontShaderView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
}



#pragma mark - Delegate

- (void)notifyDelegateOfResultsChange {
    
    if ([self.delegate respondsToSelector:@selector(bodyShaderView:drawingImageChangedTo:withShadedPercentage:)]) {
        
        UIImage *combinedImage = [self imageByCombiningImage:_frontImage withImage:_backImage];
        float shadedPercentage = (float)(_frontShadedPixels + _backShadedPixels) / (float)(_frontTotalPixels + _backTotalPixels);
        
        [self.delegate bodyShaderView:self drawingImageChangedTo:combinedImage withShadedPercentage:shadedPercentage];
    }
}



#pragma mark - ORKShaderViewDelegate

- (void)shaderView:(ORKShaderView * __nonnull)shaderView drawingImageChangedTo:(UIImage * __nullable)image withNumberOfShadedPixels:(int)numberOfShadedPixels onTotalNumberOnPixels:(int)totalNumberOfPixels {
    
    if ([shaderView isEqual:self.frontShaderView]) {
        
        _frontImage = image;
        _frontShadedPixels = numberOfShadedPixels;
        _frontTotalPixels = totalNumberOfPixels;
        
    } else {
        
        _backImage = image;
        _backShadedPixels = numberOfShadedPixels;
        _backTotalPixels = totalNumberOfPixels;
    }
}



#pragma mark - Helper Methods

- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    UIImage *image = nil;
    
    CGSize newImageSize = CGSizeMake(firstImage.size.width + secondImage.size.width, MAX(firstImage.size.height, secondImage.size.height));
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(newImageSize, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(newImageSize);
    }
    [firstImage drawAtPoint:CGPointZero];
    [secondImage drawAtPoint:CGPointMake(firstImage.size.width, 0)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
