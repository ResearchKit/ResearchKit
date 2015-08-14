/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, James Cox.

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

 
#import "ORKAxisView.h"


static const CGFloat LastLabelPadding = 10.0;

@implementation ORKAxisView {
    NSMutableArray *_titleLabels;
    NSMutableArray *_variableConstraints;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    _titleLabels = [NSMutableArray new];
    _variableConstraints = [NSMutableArray new];
}

- (void)setUpConstraints {
    [NSLayoutConstraint deactivateConstraints:_variableConstraints];
    [_variableConstraints removeAllObjects];
    
    CGFloat segmentWidth = CGRectGetWidth(self.bounds) / (_titleLabels.count - 1);
    
    for (NSUInteger i = 0; i < _titleLabels.count; i++) {
        UILabel *label = _titleLabels[i];
        CGFloat offset = i * segmentWidth;
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:label.superview
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0.0]];
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:label.superview
                                                                     attribute:NSLayoutAttributeLeading
                                                                    multiplier:1.0
                                                                      constant:offset]];
        if (i == _titleLabels.count - 1) {
            [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:label
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:label.superview
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:1.0
                                                                          constant:-LastLabelPadding]];
            [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:label
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:label.superview
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:1.0
                                                                          constant:-LastLabelPadding]];
        }
    }
    [NSLayoutConstraint activateConstraints:_variableConstraints];
}

- (void)setUpTitles:(NSArray *)titles {
    [_titleLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_titleLabels removeAllObjects];
    
    NSUInteger numberOfTitleLabels = titles.count;
    for (NSUInteger i = 0; i < numberOfTitleLabels; i++) {
        UILabel *label = [UILabel new];
        label.text = titles[i];
        label.font = [UIFont systemFontOfSize:12.0];
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.7;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (i < (numberOfTitleLabels - 1)) {
            label.textColor = self.tintColor;
        } else {
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = self.tintColor;
            label.layer.cornerRadius = (self.bounds.size.height - LastLabelPadding) * 0.5;
            label.layer.masksToBounds = YES;
        }
        
        [self addSubview:label];
        [_titleLabels addObject:label];
    }
    [self setUpConstraints];
}

- (void)tintColorDidChange {
    NSUInteger numberOfTitleLabels = _titleLabels.count;
    for (NSUInteger i = 0; i < numberOfTitleLabels; i++) {
        UILabel *label = _titleLabels[i];
        if (i < (numberOfTitleLabels - 1)) {
            label.textColor = self.tintColor;
        } else {
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = self.tintColor;
        }
    }
}

@end
