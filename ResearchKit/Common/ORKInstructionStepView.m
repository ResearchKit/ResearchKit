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


#import "ORKInstructionStepView.h"
#import "ORKInstructionStep.h"
#import "ORKHelpers.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKCompletionStep.h"
#import "ORKStep_Private.h"
#import "ORKSkin.h"
#import "ORKTintedImageView.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKNavigationContainerView_Internal.h"


@implementation ORKInstructionStepView {
    ORKTintedImageView *_instructionImageView;
    BOOL _isCompletionStep;
    NSLayoutConstraint *_instructionImageHeightConstraint;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _instructionImageView = [ORKTintedImageView new];
        _instructionImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _instructionImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.stepView = _instructionImageView;
    }
    return self;
}

- (void)setInstructionStep:(ORKInstructionStep *)instructionStep {
    _instructionStep = instructionStep;
    UIImage *image = _instructionStep.image;
    BOOL hasImage = (image != nil);
    
    _isCompletionStep = [_instructionStep isKindOfClass:[ORKCompletionStep class]];
    
    self.verticalCenteringEnabled = !hasImage;
    self.continueHugsContent = !hasImage;
    self.stepViewFillsAvailableSpace = (hasImage && !_isCompletionStep);
    
    _instructionImageView.image = image;
    _instructionImageView.shouldApplyTint = instructionStep.shouldTintImages;
    CGSize imageSize = image.size;
    if (imageSize.width > 0 && imageSize.height > 0) {
        [NSLayoutConstraint deactivateConstraints:[_instructionImageView constraints]];
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_instructionImageView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationLessThanOrEqual
                                                               toItem:_instructionImageView
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:imageSize.height / imageSize.width
                                                             constant:0.0]];
        
        _instructionImageHeightConstraint = [NSLayoutConstraint constraintWithItem:_instructionImageView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1.0
                                                                          constant:300.0];
        
        [constraints addObject:_instructionImageHeightConstraint];
        [NSLayoutConstraint activateConstraints:constraints];
        
        _instructionImageView.isAccessibilityElement = YES;
        _instructionImageView.accessibilityLabel = [NSString stringWithFormat:ORKLocalizedString(@"AX_IMAGE_ILLUSTRATION", nil), _instructionStep.title];
    } else {
        _instructionImageView.isAccessibilityElement = NO;
    }
    
    self.headerView.captionLabel.text = _instructionStep.title;
    
    NSMutableAttributedString *attributedInstruction = [[NSMutableAttributedString alloc] init];
    NSString *detail = _instructionStep.detailText;
    NSString *text = _instructionStep.text;
    detail = detail.length ? detail : nil;
    text = text.length ? text : nil;
    
    if (detail && text) {
        [attributedInstruction appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", text] attributes:nil]];

        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setParagraphSpacingBefore:self.headerView.instructionLabel.font.lineHeight * 0.5];
        [style setAlignment:NSTextAlignmentCenter];
        
        NSAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:detail
                                                                               attributes:@{NSParagraphStyleAttributeName: style}];
        [attributedInstruction appendAttributedString:attString];
        
    } else if (detail || text) {
        [attributedInstruction appendAttributedString:[[NSAttributedString alloc] initWithString:detail ? : text attributes:nil]];
    }
    
    self.headerView.instructionLabel.attributedText = attributedInstruction;
    
    [self.continueSkipContainer updateContinueAndSkipEnabled];
    
    [self tintColorDidChange];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraintConstantsForWindow:(UIWindow *)window {
    [super updateConstraintConstantsForWindow:window];
    
    const CGFloat IllustrationHeight = ORKGetMetricForWindow(ORKScreenMetricInstructionImageHeight, window);
    _instructionImageHeightConstraint.constant = (_instructionImageView.image ? IllustrationHeight : 0);
}

@end
