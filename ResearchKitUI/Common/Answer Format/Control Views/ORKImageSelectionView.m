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


#import "ORKImageSelectionView.h"

#import "ORKImageChoiceLabel.h"

#import "ORKChoiceAnswerFormatHelper.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "UIImageView+ResearchKit.h"

@interface ORKChoiceButtonView : UIView

- (instancetype)initWithImageChoice:(ORKImageChoice *)choice;

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy) NSString *labelText;
@property (nonatomic, copy) ORKImageChoice *choice;

@end


@implementation ORKChoiceButtonView

- (instancetype)initWithImageChoice:(ORKImageChoice *)choice {
    self = [super init];
    if (self) {
        _choice = [choice copy];
        _labelText = choice.text.length > 0 ? choice.text: @" ";
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.exclusiveTouch = YES;
        [self setupButtonImagesFromImageChoice:choice];
        _button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:_button];
        ORKEnableAutoLayoutForViews(@[_button, _button.imageView]);
        [self setUpConstraints];
        
        // Accessibility
        NSString *trimmedText = [self.labelText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( trimmedText.length == 0 ) {
            self.button.accessibilityLabel = ORKLocalizedString(@"AX_UNLABELED_IMAGE", nil);
        } else {
            self.button.accessibilityLabel = self.labelText;
        }
        [self updateViewColors];

        [self registerForTraitChanges:@[UITraitUserInterfaceStyle.class] withHandler:^(ORKChoiceButtonView *traitChangeView, UITraitCollection *previousTraitCollection) {
            [traitChangeView updateViewColors];
        }];
    }
    return self;
}

- (void)setupButtonImagesFromImageChoice:(ORKImageChoice *)choice {
    if (choice.selectedStateImage) {
        [_button setImage:choice.selectedStateImage forState:UIControlStateSelected];
    }

    [_button setImage:choice.normalStateImage forState:UIControlStateNormal];
}

- (void)updateViewColors {
    UIImage *image = _button.imageView.image;
    BOOL imageIsTemplate = image.isSymbolImage || image.renderingMode == UIImageRenderingModeAlwaysTemplate;
    BOOL isDarkMode = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
    _button.imageView.tintColor = (imageIsTemplate && isDarkMode) ? [UIColor whiteColor] : nil;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = @{ @"button": _button };
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    
    UIImage *image = [_button imageForState:UIControlStateNormal];
    if (image.size.height > 0 && image.size.width > 0) {
        // Keep Aspect ratio
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_button
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_button.imageView
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:image.size.height / image.size.width
                                                             constant:0.0]];
        // button's height <= image
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_button
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationLessThanOrEqual
                                                               toItem:nil attribute:NSLayoutAttributeHeight
                                                           multiplier:1.0
                                                             constant:image.size.height]];
    } else {
        // Keep Aspect ratio
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_button
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_button.imageView
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0
                                                             constant:0.0]];
        ORK_Log_Info("The size of imageChoice's normal image should not be zero. %@", image);
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
}

@end


static const CGFloat SpacerWidth = 10.0;
static const CGFloat SpacerHeight = 5.0;
static const CGFloat MaxImageChoiceButtonHeight = 150.0;
static const CGFloat SelectionBorderWidth = 2.0;
static const CGFloat ChoiceLabelTopSpacing = 30.0;

@implementation ORKImageSelectionView {
    ORKChoiceAnswerFormatHelper *_helper;
    NSArray *_buttonViews;
    ORKImageChoiceLabel *_choiceLabel;
    ORKImageChoiceLabel *_placeHolderLabel;
    BOOL _isVertical;
    BOOL _singleChoice;
}

- (ORKImageChoiceLabel *)makeLabel {
    ORKImageChoiceLabel *label = [[ORKImageChoiceLabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    return label;
}

- (instancetype)initWithImageChoiceAnswerFormat:(ORKImageChoiceAnswerFormat *)answerFormat answer:(id)answer {
    self = [self init];
    if (self) {
        
        NSAssert([answerFormat isKindOfClass:[ORKImageChoiceAnswerFormat class]], @"answerFormat should be an instance of ORKImageChoiceAnswerFormat");
        
        _helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
        _isVertical = answerFormat.isVertical;
        
        _singleChoice = answerFormat.style == ORKChoiceAnswerStyleSingleChoice;
        
        _placeHolderLabel = [self makeLabel];
        _placeHolderLabel.text = [ORKLocalizedString(@"PLACEHOLDER_IMAGE_CHOICES", nil) stringByAppendingString:@""];
        _placeHolderLabel.textColor = [UIColor secondaryLabelColor];
        
        _choiceLabel = [self makeLabel];
        
        [self resetLabelText];
        
        [self addSubview:_choiceLabel];
        [self addSubview:_placeHolderLabel];
        
        NSMutableArray *buttonViews = [NSMutableArray new];
        NSMutableArray *labelTextArray = [NSMutableArray new];
        
        NSArray *imageChoices = answerFormat.imageChoices;
        for (ORKImageChoice *imageChoice in imageChoices) {
            if (imageChoice.text) {
                [labelTextArray addObject:imageChoice.text];
            }
            
            ORKChoiceButtonView *buttonView = [[ORKChoiceButtonView alloc] initWithImageChoice:imageChoice];
            [buttonView.button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            buttonView.button.imageView.layer.cornerRadius = ORKImageChoiceButtonCornerRadii;
            buttonView.button.imageView.clipsToBounds = YES;
            [buttonViews addObject:buttonView];
            [self addSubview:buttonView];
        }
        
        _choiceLabel.textArray = labelTextArray;
        _buttonViews = buttonViews;
        
        for (UILabel *label in @[_choiceLabel, _placeHolderLabel]) {
            label.isAccessibilityElement = NO;
        }
        
        ORKEnableAutoLayoutForViews(@[_placeHolderLabel, _choiceLabel]);
        ORKEnableAutoLayoutForViews(_buttonViews);
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_choiceLabel]-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:@{@"_choiceLabel": _choiceLabel}]];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_placeHolderLabel]-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:@{@"_placeHolderLabel": _placeHolderLabel}]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_placeHolderLabel
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_choiceLabel
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0.0]];

    ORKChoiceButtonView *previousView = nil;
    for (ORKChoiceButtonView *buttonView in _buttonViews) {

        if (!_isVertical) {
            NSDictionary *views = NSDictionaryOfVariableBindings(buttonView, _choiceLabel);
            NSDictionary *metrics = @{@"topPadding": @(ORKSurveyItemMargin), @"choiceLabelTopSpacing": @(ChoiceLabelTopSpacing)};
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topPadding-[buttonView]-choiceLabelTopSpacing-[_choiceLabel]"
                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                     metrics:metrics
                                                       views:views]];

            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_choiceLabel
                                                                               attribute:NSLayoutAttributeBottom
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self
                                                                               attribute:NSLayoutAttributeBottom
                                                                              multiplier:1.0
                                                                                constant:-ORKSurveyItemMargin];
            bottomConstraint.priority = UILayoutPriorityRequired - 1;
            [constraints addObject:bottomConstraint];

            NSLayoutConstraint *maxHeight = [NSLayoutConstraint constraintWithItem:buttonView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:1.0
                                                                          constant:MaxImageChoiceButtonHeight];
            maxHeight.priority = UILayoutPriorityDefaultHigh;
            [constraints addObject:maxHeight];

            if (previousView) {
                // ButtonView left trailing
                [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:previousView
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1.0
                                                                     constant:SpacerWidth]];

                // All ButtonViews has equal width
                [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:previousView
                                                                    attribute:NSLayoutAttributeWidth
                                                                   multiplier:1.0
                                                                     constant:0.0]];

            } else {
                // ButtonView left trailing
                [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1.0
                                                                     constant:SpacerWidth]];
            }
        } else {
            // Max height cap for vertical images
            NSLayoutConstraint *maxHeight = [NSLayoutConstraint constraintWithItem:buttonView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:1.0
                                                                          constant:MaxImageChoiceButtonHeight];
            maxHeight.priority = UILayoutPriorityDefaultHigh;
            [constraints addObject:maxHeight];

            if (previousView) {
                // ButtonView top spacing
                [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:previousView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:SpacerHeight]];

                // All ButtonViews has equal height
                [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:previousView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:1.0
                                                                     constant:0.0]];

                // All ButtonViews has equal width
                [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:previousView
                                                                    attribute:NSLayoutAttributeWidth
                                                                   multiplier:1.0
                                                                     constant:0.0]];

            } else {
                // ButtonView top spacing
                [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:ORKSurveyItemMargin]];
            }
            // Center horizontally instead of pinning left+right
            [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0.0]];
            // Don't exceed container width
            [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationLessThanOrEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1.0
                                                                 constant:-(2 * SpacerWidth)]];
        }
        previousView = buttonView;
    }

    if (!_isVertical) {
        if (previousView) {
            // ButtonView right trailing
            [constraints addObject:[NSLayoutConstraint constraintWithItem:previousView
                                                                attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeRight
                                                               multiplier:1.0
                                                                 constant:-SpacerWidth]];
        }
    } else {
        if (previousView) {
            // ButtonView bottom spacing
            [constraints addObject:[NSLayoutConstraint constraintWithItem:previousView
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_choiceLabel
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:-ChoiceLabelTopSpacing]];

            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_choiceLabel
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:-ORKSurveyItemMargin];
            bottomConstraint.priority = UILayoutPriorityRequired - 1;
            [constraints addObject:bottomConstraint];
        }
    }
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setAnswer:(id)answer {
    _answer = answer;

    // Deselect all buttons before applying the new selection state
    [_buttonViews enumerateObjectsUsingBlock:^(ORKChoiceButtonView *buttonView, NSUInteger idx, BOOL *stop) {
        buttonView.button.selected = NO;
        buttonView.button.imageView.layer.borderWidth = 0.0;
    }];
    [self resetLabelText];

    NSArray *selectedIndexes = [_helper selectedIndexesForAnswer:answer];

    [self setSelectedIndexes:selectedIndexes];
}

- (void)resetLabelText {
    _placeHolderLabel.hidden = NO;
    _choiceLabel.hidden = !_placeHolderLabel.hidden;
}

- (void)resetButtonSelection:(UIButton *)button {
    [_buttonViews enumerateObjectsUsingBlock:^(ORKChoiceButtonView *buttonView, NSUInteger idx, BOOL *stop) {
        if (_singleChoice) {
            buttonView.button.imageView.layer.borderWidth = 0.0;
        } else if ([buttonView.button isEqual: button]) {
            buttonView.button.imageView.layer.borderWidth = 0.0;
        }
    }];
}

- (void)setLabelText:(NSString *)text {
    if (_singleChoice || [text length] > 0) {
        _choiceLabel.text = text;
        _choiceLabel.textColor = [UIColor labelColor];
        _choiceLabel.hidden = NO;
        _placeHolderLabel.hidden = !_choiceLabel.hidden;
    } else {
        [self resetLabelText];
    }
}

- (IBAction)buttonTapped:(UIButton *)button {
    button.selected = !button.selected;
    
    if (button.selected) {
        [_buttonViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             ORKChoiceButtonView *buttonView = obj;
             if (buttonView.button != button) {
                 if (_singleChoice) {
                     buttonView.button.selected = NO;
                     buttonView.button.imageView.layer.borderWidth = 0.0;
                 }
             } else {
                 if (_singleChoice) {
                     [self setLabelText:buttonView.labelText];
                 } else {
                     [self setLabelText:[_helper labelForChoiceAnswer:[_helper answerForSelectedIndexes:[self selectedIndexes]]]];
                 }
                 buttonView.button.imageView.layer.borderWidth = SelectionBorderWidth;
                 buttonView.button.imageView.layer.borderColor = self.tintColor.CGColor;
             }
             
         }];
        
    } else {
        if (_singleChoice) {
            [self resetLabelText];
        } else {
            [self setLabelText:[_helper labelForChoiceAnswer:[_helper answerForSelectedIndexes:[self selectedIndexes]]]];
        }
        [self resetButtonSelection:button];
    }
    
    _answer = [_helper answerForSelectedIndexes:[self selectedIndexes]];
    
    if ([_delegate respondsToSelector:@selector(selectionViewSelectionDidChange:)]) {
        [_delegate selectionViewSelectionDidChange:self];
    }
}

- (NSArray *)selectedIndexes {
    NSMutableArray *array = [NSMutableArray new];
    
    [_buttonViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         ORKChoiceButtonView *buttonView = obj;
         if (buttonView.button.selected)
         {
             [array addObject:@(idx)];
         }
     }];
    
    return [array copy];
}

- (void)setSelectedIndexes:(NSArray *)selectedIndexes {
    [selectedIndexes enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        if (![object isKindOfClass:[NSNumber class]]) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"selectedIndexes should only containt objects of the NSNumber kind" userInfo:nil];
        }
        NSNumber *number = object;
        if (number.unsignedIntegerValue < _buttonViews.count) {
            ORKChoiceButtonView *buttonView = _buttonViews[number.unsignedIntegerValue];
            [buttonView button].selected = YES;
            buttonView.button.imageView.layer.borderWidth = SelectionBorderWidth;
            buttonView.button.imageView.layer.borderColor = self.tintColor.CGColor;
            if (_singleChoice) {
                [self setLabelText:buttonView.labelText];
            }
        }
    }];
    
    if (!_singleChoice) {
        [self setLabelText:[_helper labelForChoiceAnswer:[_helper answerForSelectedIndexes:[self selectedIndexes]]]];
    }
}

- (BOOL)isAccessibilityElement {
    return NO;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    for (ORKChoiceButtonView *buttonView in _buttonViews) {
        if (buttonView.button.selected) {
            buttonView.button.imageView.layer.borderColor = self.tintColor.CGColor;
        }
    }
}

@end
