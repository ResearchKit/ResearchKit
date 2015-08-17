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


#import "ORKStepHeaderView_Internal.h"
#import "ORKSkin.h"
#import "ORKHelpers.h"


ORKDefineStringKey(_IllustrationToCaptionBaselineKey);
ORKDefineStringKey(_IllustrationToCaptionTopKey);
ORKDefineStringKey(_CaptionToInstructionKey);
ORKDefineStringKey(_InstructionToLearnMoreKey);
ORKDefineStringKey(_LearnMoreToStepViewKey);

ORKDefineStringKey(_InstructionMinBottomSpacingKey);
ORKDefineStringKey(_CaptionMinBottomSpacingKey);
ORKDefineStringKey(_HeaderZeroHeightKey);

#define ORKVerticalContainerLog(...)

static const CGFloat AssumedNavBarHeight = 44;
static const CGFloat AssumedStatusBarHeight = 20;

@implementation ORKStepHeaderView {
    NSDictionary *_adjustableConstraints;
    NSArray *_myConstraints;
    ORKScreenType _screenType;
}

- (void)updateCaptionLabelPreferredWidth {
    CGFloat sideMargin = ORKGetMetricForScreenType(ORKScreenMetricHeadlineSideMargin, _screenType);
    UIEdgeInsets layoutMargins = self.layoutMargins;
    
    // If we don't do this, sometimes the label doesn't split onto two lines properly.
    CGFloat maxLabelLayoutWidth = MAX(self.bounds.size.width - sideMargin*2 - layoutMargins.left - layoutMargins.right, 0);
    
    _captionLabel.preferredMaxLayoutWidth = maxLabelLayoutWidth;
    _instructionLabel.preferredMaxLayoutWidth = maxLabelLayoutWidth;
    [self setNeedsUpdateConstraints];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateCaptionLabelPreferredWidth];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updateCaptionLabelPreferredWidth];
}

- (void)setLayoutMargins:(UIEdgeInsets)layoutMargins {
    [super setLayoutMargins:layoutMargins];
    [self updateCaptionLabelPreferredWidth];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _screenType = ORKGetScreenTypeForWindow(nil);
        // Text Label
        {
            _captionLabel = [ORKHeadlineLabel new];
            _captionLabel.numberOfLines = 0;
            _captionLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_captionLabel];
        }
        
        {
            _learnMoreButton = [ORKTextButton new];
            _learnMoreButton.contentEdgeInsets = (UIEdgeInsets){10,10,10,10};
            [_learnMoreButton setTitle:nil forState:UIControlStateNormal];
            [_learnMoreButton addTarget:self action:@selector(learnMoreAction:) forControlEvents:UIControlEventTouchUpInside];
            _learnMoreButton.exclusiveTouch = YES;
            _learnMoreButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _learnMoreButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_learnMoreButton];
            self.learnMoreButtonItem = nil;
        }
        
        {
            _instructionLabel = [ORKSubheadlineLabel new];
            _instructionLabel.numberOfLines = 0;
            _instructionLabel.textAlignment = NSTextAlignmentCenter;
            
            [self addSubview:_instructionLabel];
        }
        
        [_learnMoreButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [_learnMoreButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
#ifdef LAYOUT_DEBUG
        _captionLabel.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.2];
        _captionLabel.layer.borderColor = [UIColor yellowColor].CGColor;
        _captionLabel.layer.borderWidth = 1.0;
        _learnMoreButton.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.2];
        _learnMoreButton.layer.borderColor = [UIColor blueColor].CGColor;
        _learnMoreButton.layer.borderWidth = 1.0;
        _instructionLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
        _instructionLabel.layer.borderColor = [UIColor greenColor].CGColor;
        _instructionLabel.layer.borderWidth = 1.0;
        self.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.2];
#endif
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    _screenType = ORKGetScreenTypeForWindow(newWindow);
    [self updateConstraintConstants];
    [self updateCaptionLabelPreferredWidth];
}

- (void)learnMoreAction:(id)sender {
    ORKSuppressPerformSelectorWarning(
                                      (void)[_learnMoreButtonItem.target performSelector:_learnMoreButtonItem.action withObject:self];
                                      );
}

- (void)setLearnMoreButtonItem:(UIBarButtonItem *)learnMoreButtonItem {
    _learnMoreButtonItem = learnMoreButtonItem;
    [_learnMoreButton setTitle:learnMoreButtonItem.title forState:UIControlStateNormal];
    _learnMoreButton.alpha = ([learnMoreButtonItem.title length] > 0) ? 1 : 0;
    [self updateConstraintConstants];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGRect insetBounds = UIEdgeInsetsInsetRect(bounds, self.layoutMargins);
    
    ORKScreenType screenType = ORKGetScreenTypeForWindow(self.window);
    CGFloat sideMargin = ORKGetMetricForScreenType(ORKScreenMetricLearnMoreButtonSideMargin, screenType);
    _learnMoreButton.titleLabel.preferredMaxLayoutWidth = insetBounds.size.width - sideMargin*2;
}

- (void)updateConstraintConstants {
    ORKScreenType screenType = _screenType;
    
    const CGFloat IllustrationToCaptionBaseline = ORKGetMetricForScreenType(ORKScreenMetricIllustrationToCaptionBaseline, screenType);
    const CGFloat TopToCaptionBaseline = (ORKGetMetricForScreenType(ORKScreenMetricTopToCaptionBaseline, screenType) - AssumedStatusBarHeight - AssumedNavBarHeight);
    const CGFloat CaptionBaselineToInstructionBaseline_WithInstruction = ORKGetMetricForScreenType(ORKScreenMetricCaptionBaselineToInstructionBaseline, screenType);
    const CGFloat CaptionBaselineToInstructionBaseline_NoInstruction = MIN(26, CaptionBaselineToInstructionBaseline_WithInstruction); // Not part of spec
    const CGFloat InstructionBaselineToLearnMoreBaseline = ORKGetMetricForScreenType(ORKScreenMetricInstructionBaselineToLearnMoreBaseline, screenType);
    const CGFloat LearnMoreBaselineToStepViewTop = ORKGetMetricForScreenType(ORKScreenMetricLearnMoreBaselineToStepViewTop, screenType);
    const CGFloat InstructionBaselineToStepViewTopWithNoLearnMore = ORKGetMetricForScreenType(ORKScreenMetricLearnMoreBaselineToStepViewTopWithNoLearnMore, screenType);
    
    BOOL haveCaption = [_captionLabel.text length] > 0;
    BOOL haveInstruction = [_instructionLabel.text length] > 0;
    BOOL haveLearnMore = (_learnMoreButton.alpha > 0);
    ORKVerticalContainerLog(@"haveCaption=%@ haveInstruction=%@ haveLearnMore=%@", @(haveCaption), @(haveInstruction), @(haveLearnMore));
    
    // If one label is empty and the other is not, then allow the empty label to shrink to nothing
    // and the other label to grow to fill
    UILayoutPriority captionVerticalHugging = haveCaption && !haveInstruction ? UILayoutPriorityDefaultLow - 1 : UILayoutPriorityDefaultLow;
    UILayoutPriority instructionVerticalHugging = haveInstruction && !haveCaption ? UILayoutPriorityDefaultLow - 1 : UILayoutPriorityDefaultLow;
    [_captionLabel setContentHuggingPriority:captionVerticalHugging forAxis:UILayoutConstraintAxisVertical];
    [_instructionLabel setContentHuggingPriority:instructionVerticalHugging forAxis:UILayoutConstraintAxisVertical];
    
    {
        NSLayoutConstraint *constraint = _adjustableConstraints[_HeaderZeroHeightKey];
        constraint.active = ! (haveCaption || haveInstruction || haveLearnMore);
    }
    
    {
        NSLayoutConstraint *constraint = _adjustableConstraints[_IllustrationToCaptionBaselineKey];
        NSLayoutConstraint *constraint2 = _adjustableConstraints[_IllustrationToCaptionTopKey];
        constraint.constant = _hasContentAbove ? IllustrationToCaptionBaseline : TopToCaptionBaseline;
        constraint2.constant = 0;
        constraint.active = haveCaption;
        constraint2.active = !haveCaption;
    }
    
    {
        NSLayoutConstraint *constraint = _adjustableConstraints[_CaptionToInstructionKey];
        constraint.constant = haveInstruction ? CaptionBaselineToInstructionBaseline_WithInstruction : CaptionBaselineToInstructionBaseline_NoInstruction;
    }
    
    {
        NSLayoutConstraint *constraint = _adjustableConstraints[_InstructionToLearnMoreKey];
        constraint.constant = haveLearnMore ? InstructionBaselineToLearnMoreBaseline : 0;
    }
    
    {
        NSLayoutConstraint *constraint = _adjustableConstraints[_LearnMoreToStepViewKey];
        constraint.constant = LearnMoreBaselineToStepViewTop;
        constraint.active = haveLearnMore;
    }
    
    {
        NSLayoutConstraint *constraint = _adjustableConstraints[_CaptionMinBottomSpacingKey];
        constraint.active = haveCaption && !(haveLearnMore || haveInstruction);
    }
    
    {
        NSLayoutConstraint *constraint = _adjustableConstraints[_InstructionMinBottomSpacingKey];
        constraint.constant = InstructionBaselineToStepViewTopWithNoLearnMore;
        constraint.active = haveInstruction && !(haveLearnMore);
    }
}

- (void)setHasContentAbove:(BOOL)hasContentAbove {
    _hasContentAbove = hasContentAbove;
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    if (!_myConstraints) {
        NSMutableArray *constraints = [NSMutableArray array];
        
        // Request that the width grow
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:ORKScreenMetricMaxDimension];
        constraint.priority = UILayoutPriorityDefaultLow-1;
        [constraints addObject:constraint];
        
        NSArray *views = @[_captionLabel, _instructionLabel, _learnMoreButton];
        [_captionLabel setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        [_instructionLabel setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        [_learnMoreButton setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        ORKEnableAutoLayoutForViews(views);
        
        NSMutableDictionary *adjustableConstraintsTable = [NSMutableDictionary dictionary];
        NSMutableArray *otherConstraints = [NSMutableArray array];
        
        adjustableConstraintsTable[_CaptionToInstructionKey] =
        [NSLayoutConstraint constraintWithItem:_instructionLabel
                                     attribute:NSLayoutAttributeFirstBaseline
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_captionLabel
                                     attribute:NSLayoutAttributeLastBaseline
                                    multiplier:1 constant:36];
        
        adjustableConstraintsTable[_InstructionToLearnMoreKey] =
        [NSLayoutConstraint constraintWithItem:_learnMoreButton
                                     attribute:NSLayoutAttributeFirstBaseline
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_instructionLabel
                                     attribute:NSLayoutAttributeLastBaseline
                                    multiplier:1 constant:30];
        
        {
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_captionLabel
                                                                          attribute:NSLayoutAttributeFirstBaseline
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1 constant:44];
            [constraint setPriority:UILayoutPriorityRequired-1];
            adjustableConstraintsTable[_IllustrationToCaptionBaselineKey] = constraint;
        }
        {
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_captionLabel
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1 constant:0];
            constraint.priority = UILayoutPriorityRequired-1;
            adjustableConstraintsTable[_IllustrationToCaptionTopKey] = constraint;
        }
        {
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:_learnMoreButton
                                                                          attribute:NSLayoutAttributeLastBaseline
                                                                         multiplier:1 constant:44];
            constraint.priority = UILayoutPriorityRequired-1;
            adjustableConstraintsTable[_LearnMoreToStepViewKey] = constraint;
        }
        {
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:_captionLabel
                                                                          attribute:NSLayoutAttributeLastBaseline
                                                                         multiplier:1 constant:44];
            constraint.priority = UILayoutPriorityDefaultHigh-1;
            adjustableConstraintsTable[_CaptionMinBottomSpacingKey] = constraint;
        }
        {
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:_instructionLabel
                                                                          attribute:NSLayoutAttributeLastBaseline
                                                                         multiplier:1 constant:44];
            constraint.priority = UILayoutPriorityDefaultHigh-2;
            adjustableConstraintsTable[_InstructionMinBottomSpacingKey] = constraint;
        }
        
        for (UIView *view in views) {
            [otherConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeftMargin multiplier:1 constant:0]];
            [otherConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRightMargin multiplier:1 constant:0]];
            
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                                attribute:NSLayoutAttributeBottom
                                                                                relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1 constant:0];
            bottomConstraint.priority = UILayoutPriorityDefaultHigh;
            // All views must fit inside, vertically
            [otherConstraints addObject:bottomConstraint];
            [otherConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1 constant:0]];
            
        }
        {
            // This constraint will only be set active if there is no content.
            // Priority is less than required, so that if it is temporarily active it doesn't cause an
            // exception.
            NSLayoutConstraint *zeroHeight = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1 constant:0];
            zeroHeight.priority = UILayoutPriorityRequired-1;
            adjustableConstraintsTable[_HeaderZeroHeightKey] = zeroHeight;
        }
        
        [constraints addObjectsFromArray:otherConstraints];
        [constraints addObjectsFromArray:[adjustableConstraintsTable allValues]];
        
        for (NSString *key in [adjustableConstraintsTable allKeys]) {
            [adjustableConstraintsTable[key] setIdentifier:key];
        }
        _myConstraints = constraints;
        _adjustableConstraints = adjustableConstraintsTable;
        [self addConstraints:constraints];
    }
        
    [self updateConstraintConstants];
    [super updateConstraints];
}

@end
