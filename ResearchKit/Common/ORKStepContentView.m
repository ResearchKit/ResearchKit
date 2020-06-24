/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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


#import "ORKStepContentView_Private.h"
#import "ORKTitleLabel.h"
#import "ORKBodyLabel.h"
#import "ORKBodyItem.h"
#import "ORKCompletionCheckmarkView.h"
#import "ORKBodyContainerView.h"
#import "ORKSkin.h"


/*
 +_________________________+
 |                         |<-------------_stepContentView
 |       +-------+         |
 |       | _icon |         |
 |       |       |         |
 |       +-------+         |
 |                         |
 | +---------------------+ |
 | |    _titleLabel      | |
 | |_____________________| |
 |                         |
 | +---------------------+ |
 | |    _textLabel       | |
 | |_____________________| |
 |                         |
 | +---------------------+ |
 | |  _detailTextLabel   | |
 | |_____________________| |
 |                         |
 | +---------------------+ |
 | |                     |<-------------_bodyContainerView: UIstackView
 | | +-----------------+ | |
 | | |                 | | |
 | | |--Title          | | |
 | | |--Text           |<-------------- BodyItemStyleText
 | | |--LearnMore      | | |
 | | |_________________| | |
 | |                     | |
 | | +---+-------------+ | |
 | | |   |--Title      | | |
 | | | o |--Text       |<-------------- BodyItemStyleBullet
 | | |   |--LearnMore  | | |
 | | |___|_____________| | |
 | |_____________________| |
 |_________________________|
 */

static const CGFloat ORKStepContentIconImageViewToTitleLabelPadding = 15.0;
static const CGFloat ORKStepContentIconToBodyTopPaddingStandard = 20.0;
static const CGFloat ORKStepContentIconToBulletTopPaddingStandard = 20.0;
static const CGFloat ORKStepContentTagPaddingTop = 15.0;

typedef NS_CLOSED_ENUM(NSInteger, ORKUpdateConstraintSequence) {
    ORKUpdateConstraintSequenceTopContentImageView = 0,
    ORKUpdateConstraintSequenceIconImageView,
    ORKUpdateConstraintSequenceTitleLabel,
    ORKUpdateConstraintSequenceTextLabel,
    ORKUpdateConstraintSequenceDetailTextLabel,
    ORKUpdateConstraintSequenceBodyContainerView
} ORK_ENUM_AVAILABLE;


@interface ORKStepContentView()<ORKBodyContainerViewDelegate>

@end


@implementation ORKStepContentView {
    CGFloat _additionalTopPaddingForTopLabel;
    CGFloat _leftRightPadding;
    NSMutableArray<NSLayoutConstraint *> *_updatedConstraints;
    
    NSArray<NSLayoutConstraint *> *_topContentImageViewConstraints;
    NSArray<NSLayoutConstraint *> *_iconImageViewConstraints;
    NSArray<NSLayoutConstraint *> *_textLabelConstraints;
    NSArray<NSLayoutConstraint *> *_detailTextLabelConstraints;
    NSMutableArray<NSLayoutConstraint *> *_leftRightPaddingConstraints;
    
    NSLayoutConstraint *_iconImageViewTopConstraint;
    NSLayoutConstraint *_titleLabelTopConstraint;
    NSLayoutConstraint *_textLabelTopConstraint;
    NSLayoutConstraint *_detailTextLabelTopConstraint;
    NSLayoutConstraint *_bodyContainerViewTopConstraint;
    NSArray<NSLayoutConstraint *> *_bodyContainerLeftRightConstraints;
    NSLayoutConstraint *_stepContentBottomConstraint;
    ORKCompletionCheckmarkView *_completionCheckmarkView;

}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUpdatedConstraints];
        [self setStepContentViewBottomConstraint];
        _leftRightPadding = ORKStepContainerLeftRightPaddingForWindow(self.window);
    }
    return self;
}

// top content image

- (void)setStepTopContentImage:(UIImage *)stepTopContentImage {
    _stepTopContentImage = stepTopContentImage;

    //    1.) nil Image; updateConstraints
    if (!stepTopContentImage && _topContentImageView) {
        [_topContentImageView removeFromSuperview];
        _topContentImageView = nil;
        [self deactivateTopContentImageViewConstraints];
        [self updateViewConstraintsForSequence:ORKUpdateConstraintSequenceTopContentImageView];
        [self setNeedsUpdateConstraints];
    }

    //    2.) First Image; updateConstraints
    if (stepTopContentImage && !_topContentImageView) {
        [self setupTopContentImageView];
        _topContentImageView.image = [self topContentAndAuxiliaryImage];
        [self updateViewConstraintsForSequence:ORKUpdateConstraintSequenceTopContentImageView];
        [self setNeedsUpdateConstraints];
    }

    //    3.) >= second Image;
    if (stepTopContentImage && _topContentImageView) {
        _topContentImageView.image = [self topContentAndAuxiliaryImage];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ORKStepTopContentImageChangedKey object:nil];
}

- (void)setAuxiliaryImage:(UIImage *)auxiliaryImage {
    _auxiliaryImage = auxiliaryImage;
    if (_stepTopContentImage) {
        _topContentImageView.image = [self topContentAndAuxiliaryImage];
    }
}

- (UIImage *)topContentAndAuxiliaryImage {
    if (!_auxiliaryImage) {
        return _stepTopContentImage;
    }
    CGSize size = _auxiliaryImage.size;
    UIGraphicsBeginImageContext(size);

    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);

    [_auxiliaryImage drawInRect:rect];
    [_stepTopContentImage drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (void)setupTopContentImageView {
    if (!_topContentImageView) {
        _topContentImageView = [UIImageView new];
    }
    _topContentImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_topContentImageView setBackgroundColor:ORKColor(ORKTopContentImageViewBackgroundColorKey)];
    [self addSubview:_topContentImageView];
    [self setTopContentImageViewConstraints];
}

- (void)setTopContentImageViewConstraints {
    _topContentImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _topContentImageViewConstraints = @[
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_topContentImageView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:ORKStepContainerTopContentHeightForWindow(self.window)]
                                        ];
    [_updatedConstraints addObjectsFromArray:_topContentImageViewConstraints];
}

- (void)deactivateTopContentImageViewConstraints {
    [self deactivateConstraints:_topContentImageViewConstraints];
    _topContentImageViewConstraints = nil;
}


// icon image

- (void)setTitleIconImage:(UIImage *)titleIconImage {
    _titleIconImage = titleIconImage;
    
    if (!titleIconImage && _iconImageView) {
        [_iconImageView removeFromSuperview];
        _iconImageView = nil;
        [self deactivateIconImageViewConstraints];
        [self updateViewConstraintsForSequence:ORKUpdateConstraintSequenceIconImageView];
        [self setNeedsUpdateConstraints];
    }
    if (titleIconImage && !_iconImageView) {
        [self setupIconImageView];
        _iconImageView.image = titleIconImage;
        [self updateViewConstraintsForSequence:ORKUpdateConstraintSequenceIconImageView];
        [self setNeedsUpdateConstraints];
    }
    if (titleIconImage && _iconImageView) {
        _iconImageView.image = titleIconImage;
    }
}

- (void)updateTitleLabelTopConstraint {
    if (_titleLabelTopConstraint && _titleLabelTopConstraint.isActive) {
        [NSLayoutConstraint deactivateConstraints:@[_titleLabelTopConstraint]];
    }
    if ([_updatedConstraints containsObject:_titleLabelTopConstraint]) {
        [_updatedConstraints removeObject:_titleLabelTopConstraint];
    }
    [self setTitleLabelTopConstraint];
    if (_titleLabelTopConstraint) {
        [_updatedConstraints addObject:_titleLabelTopConstraint];
    }
}

- (void)setupIconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
    }
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;

    [self addSubview:_iconImageView];
    [self setIconImageViewConstraints];
}

- (void)setIconImageViewTopConstraint {
    if (_iconImageView) {
        _iconImageViewTopConstraint = [NSLayoutConstraint constraintWithItem:_iconImageView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_topContentImageView ? : self
                                                                   attribute:_topContentImageView ? NSLayoutAttributeBottom : NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:ORKStepContentIconImageViewToTitleLabelPadding]; // This needs to match what the text padding is
    }
}

- (void)updateIconImageViewTopConstraint {
    if (_iconImageViewTopConstraint) {
        [self deactivateConstraints:@[_iconImageViewTopConstraint]];
    }
    [self setIconImageViewTopConstraint];
    if (_iconImageViewTopConstraint) {
        [_updatedConstraints addObject:_iconImageViewTopConstraint];
    }
}

- (void)setIconImageViewConstraints {
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setIconImageViewTopConstraint];
    
    _iconImageViewConstraints = @[
                                _iconImageViewTopConstraint,
                                [NSLayoutConstraint constraintWithItem:_iconImageView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:ORKStepContentIconImageViewDimension],
                                [NSLayoutConstraint constraintWithItem:_iconImageView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:ORKStepContentIconImageViewDimension]];
    [_updatedConstraints addObjectsFromArray:_iconImageViewConstraints];
    [self setNeedsUpdateConstraints];
}

- (void)deactivateIconImageViewConstraints {
    [self deactivateConstraints:_iconImageViewConstraints];
    _iconImageViewConstraints = nil;
}

//  step title

- (void)setStepTitle:(NSString *)stepTitle {
    _stepTitle = stepTitle;
    if (!_titleLabel) {
        [self setupTitleLabel];
        [self updateViewConstraintsForSequence:ORKUpdateConstraintSequenceTitleLabel];
        [self setNeedsUpdateConstraints];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setHyphenationFactor:0.5];
    
    NSDictionary *hyphenAttribute = @{NSParagraphStyleAttributeName : paragraphStyle};
    
    NSAttributedString *attributedStepTitle = [[NSAttributedString alloc] initWithString:stepTitle ?: @"" attributes:hyphenAttribute];
    [_titleLabel setAttributedText:attributedStepTitle];
}

- (void)setupTitleLabel {
    if (!_titleLabel) {
        _titleLabel = [ORKTitleLabel new];
    }
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = _stepHeaderTextAlignment;
    [self addSubview:_titleLabel];
    [self setupTitleLabelConstraints];
    [self setContainerLeftRightConstraints];
}

- (void)setupTitleLabelConstraints {
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self setTitleLabelTopConstraint];
    [_updatedConstraints addObjectsFromArray:@[
                                               _titleLabelTopConstraint
                                               ]];
    [self setNeedsUpdateConstraints];
}

- (void)setTitleLabelTopConstraint {
    if (_titleLabel) {
        id topItem;
        NSLayoutAttribute attribute;
        CGFloat constant;
        
        if (_iconImageView) {
            topItem = _iconImageView;
            attribute = NSLayoutAttributeBottom;
            constant = ORKStepContentIconImageViewToTitleLabelPadding;
        }
        else if (_topContentImageView) {
            topItem = _topContentImageView;
            attribute = NSLayoutAttributeBottom;
            constant = ORKStepContentIconImageViewToTitleLabelPadding;
        }
        else {
            topItem = self;
            attribute = NSLayoutAttributeTop;
            constant = ORKStepContentIconImageViewToTitleLabelPadding;
        }
        
        _titleLabelTopConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:topItem
                                                                attribute:attribute
                                                               multiplier:1.0
                                                                 constant:constant];
    }
}


// step text

- (void)setStepText:(NSString *)stepText {
    _stepText = stepText;
    if (stepText && !_textLabel) {
        [self setupTextLabel];
        [self updateViewConstraintsForSequence:ORKUpdateConstraintSequenceTextLabel];
        [self setNeedsUpdateConstraints];
        [_textLabel setText:stepText];
    }
    else if (stepText && _textLabel) {
        [_textLabel setText:_stepText];
    }
    else if (!stepText) {
        [_textLabel removeFromSuperview];
        _textLabel = nil;
        [self deactivateTextLabelConstraints];
        [self updateViewConstraintsForSequence:ORKUpdateConstraintSequenceTextLabel];
        [self setNeedsUpdateConstraints];
    }
}

- (void)setupTextLabel {
    if (!_textLabel) {
        _textLabel = [ORKBodyLabel new];
    }
    _textLabel.textAlignment = _stepHeaderTextAlignment;
    _textLabel.numberOfLines = 0;
    _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:_textLabel];
    [self setupTextLabelConstraints];
    [self setContainerLeftRightConstraints];
}

- (void)setupTextLabelConstraints {
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self setTextLabelTopConstraint];
    _textLabelConstraints = @[_textLabelTopConstraint];
    
    [_updatedConstraints addObjectsFromArray:_textLabelConstraints];
    [self setNeedsUpdateConstraints];
}

- (void)setTextLabelTopConstraint {
    if (_textLabel) {
        id topItem;
        NSLayoutAttribute attribute;
        CGFloat constant;
        
        if (_titleLabel) {
            topItem = _titleLabel;
            attribute = NSLayoutAttributeBottom;
            constant = ORKStepContainerTitleToBodyTopPaddingForWindow(self.window);
        }
        else if (_iconImageView) {
            topItem = _iconImageView;
            attribute = NSLayoutAttributeBottom;
            constant = ORKStepContentIconToBodyTopPaddingStandard;
        }
        else if (_topContentImageView) {
            topItem = _topContentImageView;
            attribute = NSLayoutAttributeBottom;
            constant = ORKStepContainerFirstItemTopPaddingForWindow(self.window);
        }
        else {
            topItem = self;
            attribute = NSLayoutAttributeTop;
            constant = ORKStepContainerFirstItemTopPaddingForWindow(self.window) + _additionalTopPaddingForTopLabel;
        }
        
        _textLabelTopConstraint = [NSLayoutConstraint constraintWithItem:_textLabel
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:topItem
                                                                attribute:attribute
                                                               multiplier:1.0
                                                                 constant:constant];
    }
}

- (void)updateTextLabelTopConstraint {
    if (_textLabelTopConstraint) {
        [self deactivateConstraints:@[_textLabelTopConstraint]];
    }
    [self setTextLabelTopConstraint];
    if (_textLabelTopConstraint) {
        [_updatedConstraints addObject:_textLabelTopConstraint];
    }
}

- (void)deactivateTextLabelConstraints {
    [self deactivateConstraints:_textLabelConstraints];
    _textLabelConstraints = nil;
}


// step detail text

- (void)setStepDetailText:(NSString *)stepDetailText {
    _stepDetailText = stepDetailText;
    if (stepDetailText && !_detailTextLabel) {
        [self setupDetailTextLabel];
        [self updateViewConstraintsForSequence:ORKUpdateConstraintSequenceDetailTextLabel];
        [self setNeedsUpdateConstraints];
        [_detailTextLabel setText:stepDetailText];
    }
    else if (stepDetailText && _detailTextLabel) {
        [_detailTextLabel setText:_stepDetailText];
    }
    else if (!stepDetailText) {
        [_detailTextLabel removeFromSuperview];
        _detailTextLabel = nil;
        [self deactivateDetailTextLabelConstraints];
        [self updateViewConstraintsForSequence:ORKUpdateConstraintSequenceDetailTextLabel];
        [self setNeedsUpdateConstraints];
    }
}

- (void)setupDetailTextLabel {
    if (!_detailTextLabel) {
        _detailTextLabel = [ORKBodyLabel new];
    }
    _detailTextLabel.textAlignment = _stepHeaderTextAlignment;
    _detailTextLabel.numberOfLines = 0;
    _detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:_detailTextLabel];
    [self setupDetailTextLabelConstraints];
    [self setContainerLeftRightConstraints];
}

- (void)setStepHeaderTextAlignment:(NSTextAlignment)stepHeaderTextAlignment {
    _stepHeaderTextAlignment = stepHeaderTextAlignment;
    _titleLabel.textAlignment = _stepHeaderTextAlignment;
    _detailTextLabel.textAlignment = _stepHeaderTextAlignment;
    _textLabel.textAlignment = _stepHeaderTextAlignment;
}

- (void)setBodyTextAlignment:(NSTextAlignment)bodyTextAlignment {
    _bodyTextAlignment = bodyTextAlignment;
}

- (void)setUseExtendedPadding:(BOOL)useExtendedPadding {
    _useExtendedPadding = useExtendedPadding;
    _leftRightPadding = useExtendedPadding ? ORKStepContainerExtendedLeftRightPaddingForWindow(self.window) : ORKStepContainerLeftRightPaddingForWindow(self.window);
    [NSLayoutConstraint deactivateConstraints:_leftRightPaddingConstraints];
    [_updatedConstraints removeObjectsInArray:_leftRightPaddingConstraints];
    [self setContainerLeftRightConstraints];
}

- (void)setupDetailTextLabelConstraints {
    _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self setDetailTextLabelTopConstraint];
    _detailTextLabelConstraints = @[_detailTextLabelTopConstraint];
    
    [_updatedConstraints addObjectsFromArray:_detailTextLabelConstraints];
    [self setNeedsUpdateConstraints];
}

- (void)setDetailTextLabelTopConstraint {
    if (_detailTextLabel) {
        id topItem;
        NSLayoutAttribute attribute;
        CGFloat constant;
        if (_textLabel) {
            topItem = _textLabel;
            attribute = NSLayoutAttributeBottom;
            constant = ORKBodyToBodyPaddingStandard;
        }
        
        else if (_titleLabel) {
            topItem = _titleLabel;
            attribute = NSLayoutAttributeBottom;
            constant = ORKStepContainerTitleToBodyTopPaddingForWindow(self.window);
        }
        else if (_iconImageView) {
            topItem = _iconImageView;
            attribute = NSLayoutAttributeBottom;
            constant = ORKStepContentIconToBodyTopPaddingStandard;
        }
        else if (_topContentImageView) {
            topItem = _topContentImageView;
            attribute = NSLayoutAttributeBottom;
            constant = ORKStepContainerFirstItemTopPaddingForWindow(self.window);
        }
        else {
            topItem = self;
            attribute = NSLayoutAttributeTop;
            constant = ORKStepContainerFirstItemTopPaddingForWindow(self.window) + _additionalTopPaddingForTopLabel;
        }
        
        _detailTextLabelTopConstraint = [NSLayoutConstraint constraintWithItem:_detailTextLabel
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:topItem
                                                               attribute:attribute
                                                              multiplier:1.0
                                                                constant:constant];
    }
}

- (void)updateDetailTextLabelTopConstraint {
    if (_detailTextLabelTopConstraint) {
        [self deactivateConstraints:@[_detailTextLabelTopConstraint]];
    }
    [self setDetailTextLabelTopConstraint];
    if (_detailTextLabelTopConstraint) {
        [_updatedConstraints addObject:_detailTextLabelTopConstraint];
    }
}

- (void)deactivateDetailTextLabelConstraints {
    [self deactivateConstraints:_detailTextLabelConstraints];
    _detailTextLabelConstraints = nil;
}


//  body container

- (void)setBodyItems:(NSArray<ORKBodyItem *> *)bodyItems {
    _bodyItems = bodyItems;
    if (_bodyItems) {
        if (!_bodyContainerView) {
            [self setupBodyContainerView];
            [self updateStepContentViewBottomConstraint];
            [self setNeedsUpdateConstraints];
        }
        else {
            _bodyContainerView.bodyItems = _bodyItems;
        }
    }
}

- (void)setBuildsInBodyItems:(BOOL)buildsInBodyItems {
    _buildsInBodyItems = buildsInBodyItems;
    _bodyContainerView.buildsInBodyItems = _buildsInBodyItems;
}

- (void)setupBodyContainerView {
    __weak id<ORKBodyContainerViewDelegate> weakSelf = self;
    if (!_bodyContainerView) {
        _bodyContainerView = [[ORKBodyContainerView alloc] initWithBodyItems:_bodyItems
                                                               textAlignment:_bodyTextAlignment
                                                                    delegate:weakSelf];
    }
    [self addSubview:_bodyContainerView];
    [self setupBodyContainerViewConstraints];
}

- (void)updateBodyContainerViewTopConstraint {
    if (_bodyContainerView) {
        if (_bodyContainerViewTopConstraint) {
            [self deactivateConstraints:@[_bodyContainerViewTopConstraint]];
        }
        [self setBodyContainerViewTopConstraint];
        if (_bodyContainerViewTopConstraint) {
            [_updatedConstraints addObject:_bodyContainerViewTopConstraint];
        }
    }
}

- (void)setupBodyContainerViewConstraints {
    _bodyContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setBodyContainerViewTopConstraint];
    [_updatedConstraints addObjectsFromArray:@[
                                               _bodyContainerViewTopConstraint,
                                               ]];
    [self setNeedsUpdateConstraints];
}

- (void)setContainerLeftRightConstraints {
    [NSLayoutConstraint deactivateConstraints:_leftRightPaddingConstraints];
    [_updatedConstraints removeObjectsInArray:_leftRightPaddingConstraints];
    
    _leftRightPaddingConstraints = [[NSMutableArray alloc] init];
    if (_textLabel != nil) {
        [_leftRightPaddingConstraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_textLabel
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:_leftRightPadding],
            [NSLayoutConstraint constraintWithItem:_textLabel
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:-_leftRightPadding]
        ]];
    }
    
    if (_titleLabel != nil) {
        [_leftRightPaddingConstraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_titleLabel
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:_leftRightPadding],
            [NSLayoutConstraint constraintWithItem:_titleLabel
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:-_leftRightPadding]
        ]];
    }
    
    if (_detailTextLabel != nil) {
        [_leftRightPaddingConstraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_detailTextLabel
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:_leftRightPadding],
            [NSLayoutConstraint constraintWithItem:_detailTextLabel
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:-_leftRightPadding]
        ]];
    }
    
    if (_bodyContainerView != nil) {
        [_leftRightPaddingConstraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_bodyContainerView
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1.0
                                         constant:_leftRightPadding],
            [NSLayoutConstraint constraintWithItem:_bodyContainerView
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeRight
                                          multiplier:1.0
                                          constant:-_leftRightPadding]
        ]];
    }
    
    if (_iconImageView != nil) {
        if (_stepHeaderTextAlignment == NSTextAlignmentLeft) {
            [_leftRightPaddingConstraints addObjectsFromArray:@[
                [NSLayoutConstraint constraintWithItem:_iconImageView
                                             attribute:NSLayoutAttributeLeading
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self
                                             attribute:NSLayoutAttributeLeading
                                            multiplier:1.0
                                              constant:_leftRightPadding]
            ]];
        } else {
            [_leftRightPaddingConstraints addObjectsFromArray:@[
                [NSLayoutConstraint constraintWithItem:_iconImageView
                                             attribute:NSLayoutAttributeCenterX
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self
                                             attribute:NSLayoutAttributeCenterX
                                            multiplier:1.0
                                              constant:0.0]
            ]];
        }
    }

    [_updatedConstraints addObjectsFromArray:_leftRightPaddingConstraints];
    [self setNeedsUpdateConstraints];
}

- (void)setBodyContainerViewTopConstraint {
    id topItem;
    CGFloat topPadding;
    NSLayoutAttribute attribute;

    // Checking empty string as we have an odd case where the label gets created because the text
    // is an empty string. This causes the layout to be bigger than expected as the label is given
    // some amount of height and we are calculating vertical padding based off a label that is not
    // visible. TODO - rework the labels so they do not get created with empty text.
    if (_detailTextLabel && ![_stepDetailText isEqualToString:@""]) {
        topItem = _detailTextLabel;
        topPadding = ORKBodyToBodyPaddingStandard;
        attribute = NSLayoutAttributeBottom;
    }
    
    else if (_textLabel && ![_stepText isEqualToString:@""]) {
        topItem = _textLabel;
        topPadding = ORKBodyToBodyPaddingStandard;
        attribute = NSLayoutAttributeBottom;
    }
    
    else if (_titleLabel) {
        topItem = _titleLabel;
        
        if (_bodyItems.firstObject.bodyItemStyle == ORKBodyItemStyleTag) {
            topPadding = ORKStepContentTagPaddingTop;
        } else {
            topPadding = _bodyItems.firstObject.bodyItemStyle == ORKBodyItemStyleText ? ORKStepContainerTitleToBodyTopPaddingForWindow(self.window) : ORKStepContainerTitleToBulletTopPaddingForWindow(self.window);
        }
        
        attribute = NSLayoutAttributeBottom;
    }
    else if (_iconImageView) {
        topItem = _iconImageView;
        topPadding = _bodyItems.firstObject.bodyItemStyle == ORKBodyItemStyleText ? ORKStepContentIconToBodyTopPaddingStandard : ORKStepContentIconToBulletTopPaddingStandard;
        attribute = NSLayoutAttributeBottom;
    }
    
    else if (_topContentImageView) {
        topItem = _topContentImageView;
        topPadding = ORKStepContainerFirstItemTopPaddingForWindow(self.window);
        attribute = NSLayoutAttributeBottom;
    }
    else {
        topItem = self;
        topPadding = ORKStepContainerFirstItemTopPaddingForWindow(self.window);
        attribute = NSLayoutAttributeTop;
    }


    _bodyContainerViewTopConstraint = [NSLayoutConstraint constraintWithItem:_bodyContainerView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:topItem
                                                                   attribute:attribute
                                                                  multiplier:1.0
                                                                    constant:topPadding];
}


//  Variable constraints methods

- (void)updateViewConstraintsForSequence:(ORKUpdateConstraintSequence)sequence {
    switch (sequence) {
        case ORKUpdateConstraintSequenceTopContentImageView:
            [self updateIconImageViewTopConstraint];
        case ORKUpdateConstraintSequenceIconImageView:
            [self updateTitleLabelTopConstraint];
        case ORKUpdateConstraintSequenceTitleLabel:
            [self updateTextLabelTopConstraint];
        case ORKUpdateConstraintSequenceTextLabel:
            [self updateDetailTextLabelTopConstraint];
        case ORKUpdateConstraintSequenceDetailTextLabel:
            [self updateBodyContainerViewTopConstraint];
            
        default:
            break;
    }
    [self updateStepContentViewBottomConstraint];
}

- (void)updateStepContentViewBottomConstraint {
    [self deactivateConstraints:@[_stepContentBottomConstraint]];
    [self setStepContentViewBottomConstraint];
    [_updatedConstraints addObject:_stepContentBottomConstraint];
}

- (void)setStepContentViewBottomConstraint {
    id bottomItem;
    NSLayoutAttribute attribute;
    CGFloat constant;
    
    if (_bodyContainerView) {
        bottomItem = _bodyContainerView;
        attribute = NSLayoutAttributeBottom;
        constant = 0.0;
    }
    else if (_detailTextLabel && ![_stepDetailText isEqualToString:@""]) {
        bottomItem = _detailTextLabel;
        attribute = NSLayoutAttributeBottom;
        constant = 0.0;
    }
    else if (_textLabel && ![_stepText isEqualToString:@""]) {
        bottomItem = _textLabel;
        attribute = NSLayoutAttributeBottom;
        constant = 0.0;
    }
    else if (_titleLabel) {
        bottomItem = _titleLabel;
        attribute = NSLayoutAttributeBottom;
        constant = 0.0;
    }
    else if (_iconImageView) {
        bottomItem = _iconImageView;
        attribute = NSLayoutAttributeBottom;
        constant = 0.0;
    }
    else {
        bottomItem = nil;
        attribute = NSLayoutAttributeNotAnAttribute;
        constant = 0.0;
    }
    
    _stepContentBottomConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                attribute:bottomItem ? NSLayoutAttributeBottom : NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:bottomItem
                                                                attribute:attribute
                                                               multiplier:1.0
                                                                 constant:constant];
}

- (void)setupUpdatedConstraints {
    _updatedConstraints = [[NSMutableArray alloc] init];
}

- (void)deactivateConstraints:(nullable NSArray<NSLayoutConstraint *> *)constraints {
    if (constraints) {
        [NSLayoutConstraint deactivateConstraints:constraints];
    }
    [self updatedConstraintsWithdrawConstraints:constraints];
    [self setNeedsUpdateConstraints];
}

- (void)updatedConstraintsWithdrawConstraints:(nullable NSArray<NSLayoutConstraint *> *)constraints {
    if (constraints && constraints.count > 0) {
        for (NSLayoutConstraint *constraint in constraints) {
            if ([_updatedConstraints containsObject:constraint]) {
                [_updatedConstraints removeObject:constraint];
            }
        }
    }
}

- (void)updateContentConstraints {
    [NSLayoutConstraint activateConstraints:_updatedConstraints];
    [_updatedConstraints removeAllObjects];
}

- (void)updateConstraints {
    [self updateContentConstraints];
    [super updateConstraints];
}


//  Private methods

- (void)setAdditionalTopPaddingForTopLabel:(CGFloat)padding {
    _additionalTopPaddingForTopLabel = padding;
    if (!_topContentImageView && !_iconImageView) {
        if (_titleLabel) {
            [self updateTitleLabelTopConstraint];
        }
        else if (_textLabel) {
            [self updateTextLabelTopConstraint];
        }
        else if (_detailTextLabel) {
            [self updateDetailTextLabelTopConstraint];
        }
    }
}

- (nullable ORKCompletionCheckmarkView *)completionCheckmarkView {
    if (!_completionCheckmarkView) {
        _completionCheckmarkView = [[ORKCompletionCheckmarkView alloc] initWithDefaultDimension];
        [self addSubview:_completionCheckmarkView];
        self.titleIconImage = [UIImage new];
        [_iconImageView setHidden:YES];
        _completionCheckmarkView.translatesAutoresizingMaskIntoConstraints = NO;
        [self setContainerLeftRightConstraints];
        [_updatedConstraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_completionCheckmarkView
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_iconImageView
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:_completionCheckmarkView
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_iconImageView
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:_completionCheckmarkView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_iconImageView
                                         attribute:NSLayoutAttributeWidth
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:_completionCheckmarkView
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_iconImageView
                                         attribute:NSLayoutAttributeHeight
                                        multiplier:1.0
                                          constant:0.0]
        ]];
    }
    return _completionCheckmarkView;
}

#pragma mark - ORKBodycontainerViewDelegate

- (void)bodyContainerLearnMoreButtonPressed:(ORKLearnMoreInstructionStep *)learnMoreStep {
    [_delegate stepContentLearnMoreButtonPressed:learnMoreStep];
}

@end
