/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
 
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


#import "ORKTimedWalkContentView.h"

#import "ORKActiveStepQuantityView.h"
#import "ORKProgressView.h"
#import "ORKTintedImageView.h"

#import "ORKSkin.h"


@interface ORKTimedWalkContentView ()

@property (nonatomic, strong) ORKProgressView *progressView;
@property (nonatomic, strong) ORKTintedImageView *imageView;
@property (nonatomic, strong) NSLayoutConstraint *imageRatioConstraint;
@property (nonatomic, copy) NSArray *constraints;

@end


@implementation ORKTimedWalkContentView

- (instancetype)init {
    self = [super init];
    if (self) {
        _progressView = [ORKProgressView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_progressView];
        
        _imageView = [ORKTintedImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.shouldApplyTint = YES;
        _imageView.isAccessibilityElement = NO;
        [self addSubview:_imageView];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setNeedsUpdateConstraints];
    }
    
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
    
    self.imageRatioConstraint.active = NO;
    
    CGSize size = image.size;
    if (size.width > 0 && size.height > 0) {
        self.imageRatioConstraint = [NSLayoutConstraint constraintWithItem:_imageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_imageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:size.height/size.width
                                                                  constant:0];
        self.imageRatioConstraint.active = YES;
    }
}

- (void)updateConstraints {
    [NSLayoutConstraint deactivateConstraints:self.constraints];
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_progressView, _imageView);
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_progressView
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_progressView]-(>=10)-[_imageView]-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil views:views]];
    
    [NSLayoutConstraint activateConstraints:constraints];
    [super updateConstraints];
}

@end
