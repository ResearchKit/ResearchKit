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


#import "ORKCustomStepView.h"
#import "ORKCustomStepView_Internal.h"

#import "ORKSurveyAnswerCell.h"
#import "ORKSurveyCardHeaderView.h"

#import "ORKStepViewController.h"

#import "ORKSkin.h"


@implementation ORKActiveStepCustomView

- (void)resetStep:(ORKStepViewController *)viewController {
}

- (void)startStep:(ORKStepViewController *)viewController {
}

- (void)suspendStep:(ORKStepViewController *)viewController {
}

- (void)resumeStep:(ORKStepViewController *)viewController {
}

- (void)finishStep:(ORKStepViewController *)viewController {
}

- (void)updateDisplay:(ORKActiveStepViewController *)viewController {
}

@end


@implementation ORKQuestionStepCustomView

@end


@implementation ORKQuestionStepCellHolderView {
    CGFloat _leftRightMargin;
    CAShapeLayer *_contentMaskLayer;
    
    ORKSurveyCardHeaderView * _cardHeaderView;
    UIView *_containerView;
    BOOL _useCardView;
    NSArray<NSLayoutConstraint *> *_containerConstraints;
    NSString *_title;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:recognizer];
        _leftRightMargin = 0.0;
        [self setupContainerView];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setupConstraints];
    }
    return self;
}

- (void)setupContainerView {
    if (!_containerView) {
        _containerView = [UIView new];
    }
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_containerView];
}

- (void)setupHeaderViewWithTitle:(NSString *)title {
    if (!_cardHeaderView) {
        _cardHeaderView = [[ORKSurveyCardHeaderView alloc] initWithTitle:title];
    }
    _cardHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_cardHeaderView];
    if (!title) {
        [_cardHeaderView removeFromSuperview];
        _cardHeaderView = nil;
    }
}

- (void)tapAction {
    [_cell becomeFirstResponder];
}

- (void)setCell:(ORKSurveyAnswerCell *)cell {
    // Removing old cell from superview automatically removes its constraints
    [_cell removeFromSuperview];
    _cell = cell;
    
    _cell.translatesAutoresizingMaskIntoConstraints = NO;
    
    if ([[_cell class] shouldDisplayWithSeparators]) {
        _cell.showTopSeparator = YES;
        _cell.showBottomSeparator = YES;
    }
    
    [_containerView addSubview:_cell];
    [self setUpCellConstraints];
}

-(void)useCardViewWithTitle:(NSString *)title {
    _title = title;
    _useCardView = YES;
    _leftRightMargin = ORKCardLeftRightMargin;
    [self setBackgroundColor:[UIColor clearColor]];
    [self setupHeaderViewWithTitle:title];
    [self setupConstraints];
}

- (void)setupConstraints {
    
    if (_containerConstraints) {
        [NSLayoutConstraint deactivateConstraints:_containerConstraints];
    }
    NSArray<NSLayoutConstraint *> *topViewConstraints;
    
    if (_cardHeaderView) {
        topViewConstraints = @[
                                  [NSLayoutConstraint constraintWithItem:_cardHeaderView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:0.0],
                                  [NSLayoutConstraint constraintWithItem:_cardHeaderView
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1.0
                                                                constant:0.0],
                                  [NSLayoutConstraint constraintWithItem:_cardHeaderView
                                                               attribute:NSLayoutAttributeRight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeRight
                                                              multiplier:1.0
                                                                constant:0.0],
                                  [NSLayoutConstraint constraintWithItem:_containerView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_cardHeaderView
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0
                                                                constant:0.0]
                                  ];
    }
    else {
        topViewConstraints = @[
                                  [NSLayoutConstraint constraintWithItem:_containerView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:0.0]
                                  ];
    }
    
    _containerConstraints = [topViewConstraints arrayByAddingObjectsFromArray:@[
                                                                                [NSLayoutConstraint constraintWithItem:_containerView
                                                                                                             attribute:NSLayoutAttributeLeft
                                                                                                             relatedBy:NSLayoutRelationEqual
                                                                                                                toItem:self
                                                                                                             attribute:NSLayoutAttributeLeft
                                                                                                            multiplier:1.0
                                                                                                              constant:_leftRightMargin],
                                                                                [NSLayoutConstraint constraintWithItem:_containerView
                                                                                                             attribute:NSLayoutAttributeRight
                                                                                                             relatedBy:NSLayoutRelationEqual
                                                                                                                toItem:self
                                                                                                             attribute:NSLayoutAttributeRight
                                                                                                            multiplier:1.0
                                                                                                              constant:-_leftRightMargin]
                                                                                ]];
    
    [NSLayoutConstraint activateConstraints:_containerConstraints];
}

- (void)setUpCellConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_cell
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_containerView
                                                        attribute:NSLayoutAttributeTopMargin
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_cell
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeBottomMargin
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_cell
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_containerView
                                                        attribute:NSLayoutAttributeLeftMargin
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_cell
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_containerView
                                                        attribute:NSLayoutAttributeRightMargin
                                                       multiplier:1.0
                                                         constant:0.0]];
     [constraints addObject:[NSLayoutConstraint constraintWithItem:_containerView
                                                         attribute:NSLayoutAttributeBottomMargin
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_cell
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:0.0]];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
}

-(void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self setMaskLayers];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setMaskLayers];
}

- (void)setMaskLayers {
    if (_useCardView) {
        if (_contentMaskLayer) {
            for (CALayer *sublayer in [_contentMaskLayer.sublayers mutableCopy]) {
                [sublayer removeFromSuperlayer];
            }
            [_contentMaskLayer removeFromSuperlayer];
            _contentMaskLayer = nil;
        }
        _contentMaskLayer = [[CAShapeLayer alloc] init];
        
        UIColor *fillColor = [UIColor ork_borderGrayColor];
        [_contentMaskLayer setFillColor:[fillColor CGColor]];
        
        CAShapeLayer *foreLayer = [CAShapeLayer layer];
        [foreLayer setFillColor:[[UIColor whiteColor] CGColor]];
        foreLayer.zPosition = 0.0f;
        
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        
        NSUInteger rectCorners = _title ? UIRectCornerBottomLeft | UIRectCornerBottomRight : UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight | UIRectCornerTopLeft;
            
        _contentMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect: _containerView.bounds
                                                       byRoundingCorners: rectCorners
                                                             cornerRadii: (CGSize){ORKCardDefaultCornerRadii, ORKCardDefaultCornerRadii}].CGPath;
        
        CGRect foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, 0, _containerView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, _containerView.bounds.size.height - ORKCardDefaultBorderWidth);
        
        CGFloat foreLayerCornerRadii = ORKCardDefaultCornerRadii >= ORKCardDefaultBorderWidth ? ORKCardDefaultCornerRadii - ORKCardDefaultBorderWidth : ORKCardDefaultCornerRadii;
        
        foreLayer.path = [UIBezierPath bezierPathWithRoundedRect: foreLayerBounds byRoundingCorners: rectCorners cornerRadii: (CGSize){foreLayerCornerRadii, foreLayerCornerRadii}].CGPath;
            
        

        [_contentMaskLayer addSublayer:foreLayer];
        [_contentMaskLayer addSublayer:lineLayer];
        
        [_containerView.layer insertSublayer:_contentMaskLayer atIndex:0];
    }
}

- (NSArray *)accessibilityElements
{
    // Needed to support the "Edit Transcript" view for speech recognition pages
    // This works around an issue with navigating table view cells outside of a table view using VoiceOver
    return self.cell.accessibilityElements;
}

@end
