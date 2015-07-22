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
#import "ORKSkin.h"
#import "ORKProgressView.h"
#import "ORKActiveStepQuantityView.h"
#import "ORKTintedImageView.h"

@interface ORKTimedWalkContentView ()

@property (nonatomic, strong) ORKProgressView *progressView;
@property (nonatomic, strong) ORKQuantityLabel *distanceLabel;
@property (nonatomic, strong) ORKTintedImageView *imageView;
@property (nonatomic, strong) NSLayoutConstraint *imageRatioConstraint;
@property (nonatomic, assign) double distanceInMeters;
@property (nonatomic, strong) NSLengthFormatter *lengthFormatter;
@property (nonatomic, strong) NSArray *constraints;

@end

@implementation ORKTimedWalkContentView

- (instancetype)init {
    self = [super init];
    if (self) {
        _progressView = [ORKProgressView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_progressView];
        
        _distanceLabel = [ORKQuantityLabel new];
        _distanceLabel.textAlignment = NSTextAlignmentCenter;
        _distanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_distanceLabel];
        
        _imageView = [ORKTintedImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.shouldApplyTint = YES;
        _imageView.isAccessibilityElement = NO;
        [self addSubview:_imageView];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setNeedsUpdateConstraints];
        
        [self updateLengthFormatter];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(localeDidChange:)
                                                     name:NSCurrentLocaleDidChangeNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateLengthFormatter {
    self.lengthFormatter = [NSLengthFormatter new];
    self.lengthFormatter.numberFormatter.maximumFractionDigits = 1;
    self.lengthFormatter.numberFormatter.maximumSignificantDigits = 3;
}

- (void)localeDidChange:(NSNotification *)notification {
    [self updateLengthFormatter];
    [self setDistanceInMeters:self.distanceInMeters];
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


- (void)setDistanceInMeters:(double)distanceInMeters visible:(BOOL)isVisible {
    if (isVisible) {
        _distanceInMeters = distanceInMeters;
        self.progressView.hidden = YES;
        self.distanceLabel.text = [self.lengthFormatter stringFromMeters:distanceInMeters];
    } else {
        self.progressView.hidden = NO;
        self.distanceLabel.text = nil;
    }
}

- (void)updateConstraints {
    if ([self.constraints count]) {
        [NSLayoutConstraint deactivateConstraints:self.constraints];
        self.constraints = nil;
    }
    
    NSMutableArray *constraintsArray = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_progressView, _distanceLabel, _imageView);
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_progressView]|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil views:views]];
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_progressView]-(>=10)-[_imageView]-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil views:views]];
    
    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.distanceLabel
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.progressView
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1
                                                              constant:0]];
    
    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.distanceLabel
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.progressView
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1
                                                              constant:0]];
    
    self.constraints = constraintsArray;
    [self addConstraints:self.constraints];
    
    [NSLayoutConstraint activateConstraints:self.constraints];
    [super updateConstraints];
}

@end
