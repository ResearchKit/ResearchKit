/*
 Copyright (c) 2015, James Cox. All rights reserved.
 Copyright (c) 2015, Ricardo Sánchez-Sáez.

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


#import "ORKPieChartLegendCell.h"
#import "ORKSkin.h"


const CGFloat DotViewSize = 10.0;
const CGFloat DotToLabelPadding = 6.0;

@implementation ORKPieChartLegendCell

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    _titleLabel = [UILabel new];
    _titleLabel.textColor = ORKColor(ORKChartDefaultTextColorKey);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.isAccessibilityElement = NO;
    _dotView = [UIView new];
    _dotView.translatesAutoresizingMaskIntoConstraints = NO;
    _dotView.layer.cornerRadius = DotViewSize * 0.5;
    _dotView.layer.masksToBounds = YES;
    [self.contentView addSubview:_titleLabel];
    [self.contentView addSubview:_dotView];
    
    [self setUpConstraints];
}

#pragma mark - Layout

- (void)setUpConstraints {
    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray new];
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _dotView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_titleLabel]-(>=0)-|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_dotView]-(>=0)-|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_dotView]-DotToLabelPadding-[_titleLabel]|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:@{@"DotToLabelPadding": @(DotToLabelPadding)}
                                                                               views:views]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_dotView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:0
                                                       multiplier:1.0
                                                         constant:DotViewSize]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_dotView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_dotView
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_dotView
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_titleLabel
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    return _titleLabel.accessibilityLabel;
}

@end
