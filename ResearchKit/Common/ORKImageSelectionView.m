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
#import "ORKHelpers.h"
#import "ORKSkin.h"
#import "ORKImageChoiceLabel.h"
#import "ORKChoiceAnswerFormatHelper.h"


@interface ORKChoiceButtonView : UIView

- (instancetype)initWithImageOption:(ORKImageChoice *)option;

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy) NSString *labelText;

@end


@implementation ORKChoiceButtonView

- (instancetype)initWithImageOption:(ORKImageChoice *)option {
    self = [super init];
    if (self) {
        _labelText = option.text.length > 0? option.text: @" ";
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.exclusiveTouch = YES;
       
        if (option.selectedStateImage) {
            [_button setImage:option.selectedStateImage forState:UIControlStateSelected];
        }
        
        [_button setImage:option.normalStateImage forState:UIControlStateNormal];
        
        _button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:_button];
        
        UIView *imageView = _button.imageView;
        NSDictionary *dictionary = NSDictionaryOfVariableBindings(_button, imageView);
        ORKEnableAutoLayoutForViews([dictionary allValues]);
        
        {
            // Add rules for button
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_button]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_button]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
            
        }
        
        {
            if (option.normalStateImage.size.height > 0 && option.normalStateImage.size.width > 0) {
                // Keep Aspect ratio
                [self addConstraint:[NSLayoutConstraint constraintWithItem:_button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeWidth multiplier:option.normalStateImage.size.height/option.normalStateImage.size.width constant:0]];
                // button's height <= image
                [self addConstraint:[NSLayoutConstraint constraintWithItem:_button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:option.normalStateImage.size.height]];
            } else {
                // Keep Aspect ratio
                [self addConstraint:[NSLayoutConstraint constraintWithItem:_button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
                ORK_Log_Oops(@"The size of imageChoice's normal image should not be zero. %@",  option.normalStateImage);
            }
        }
        
        // Accessibility
        NSString *trimmedText = [self.labelText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( trimmedText.length == 0 ) {
            self.button.accessibilityLabel = ORKLocalizedString(@"AX_UNLABELED_IMAGE", nil);
        } else {
            self.button.accessibilityLabel = self.labelText;
        }
    }
    return self;
}

@end


static const CGFloat kSpacerWidth = 10.0;

@implementation ORKImageSelectionView {
    ORKChoiceAnswerFormatHelper *_helper;
    NSArray *_buttonViews;
    ORKImageChoiceLabel *_choiceLabel;
    ORKImageChoiceLabel *_placeHolderLabel;
    ORKImageChoiceLabel *_invisibleLabel; // Hold tallest text to make sure this view allocate enough space to accommodate _choiceLabel
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
        
        NSArray *choices = answerFormat.imageChoices;
        
        _placeHolderLabel = [self makeLabel];
        _placeHolderLabel.text = [ORKLocalizedString(@"PLACEHOLDER_IMAGE_CHOICES", nil) stringByAppendingString:@""];
        _placeHolderLabel.textColor = [UIColor ork_midGrayTintColor];
        
        _choiceLabel = [self makeLabel];
        
        _invisibleLabel = [self makeLabel];
        _invisibleLabel.hidden = YES;
        
        [self resetLabelText];
        
        [self addSubview:_choiceLabel];
        [self addSubview:_placeHolderLabel];
        [self addSubview:_invisibleLabel];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_choiceLabel]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil  views:@{@"_choiceLabel": _choiceLabel}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_placeHolderLabel]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"_placeHolderLabel": _placeHolderLabel}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_invisibleLabel]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"_invisibleLabel": _invisibleLabel}]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_choiceLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_invisibleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0 ]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_placeHolderLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_invisibleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0 ]];
        
        ORKChoiceButtonView *previousView;
        NSMutableArray *buttonViews = [NSMutableArray new];
        NSMutableArray *labelTextArray = [NSMutableArray new];
        for (ORKImageChoice *option in choices) {
            if (option.text) {
                [labelTextArray addObject:option.text];
            }
            
            ORKChoiceButtonView *buttonView = [[ORKChoiceButtonView alloc] initWithImageOption:option];
            [buttonView.button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [buttonViews addObject:buttonView];
            
            [self addSubview:buttonView];
            NSDictionary *dictionary = NSDictionaryOfVariableBindings(buttonView, _placeHolderLabel, _choiceLabel, _invisibleLabel);
            ORKEnableAutoLayoutForViews([dictionary allValues]);
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[buttonView]-30-[_invisibleLabel]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
            
            if (previousView) {
                
                // ButtonView left trailing
                [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:previousView attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSpacerWidth]];
                
                // All ButtonViews has equal width
                [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:previousView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
                
            } else {
                // ButtonView left trailing
                [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSpacerWidth]];
            }
            previousView = buttonView;
        }
        
        _invisibleLabel.textArray = labelTextArray;
        
        if (previousView) {
            // ButtonView right trailing
            [self addConstraint:[NSLayoutConstraint constraintWithItem:previousView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-kSpacerWidth]];
        }
        
        _buttonViews = buttonViews;
        
        for (UILabel *label in @[_choiceLabel, _invisibleLabel, _placeHolderLabel]) {
            label.isAccessibilityElement = NO;
        }
    }
    return self;
}

- (void)setAnswer:(id)answer {
    _answer = answer;
    
    NSArray *selectedIndexes = [_helper selectedIndexesForAnswer:answer];
    
    [self setSelectedIndexes:selectedIndexes];
}

- (void)resetLabelText {
    _placeHolderLabel.hidden = NO;
    _choiceLabel.hidden = !_placeHolderLabel.hidden;
    
}

- (void)setLabelText:(NSString *)text {
    _choiceLabel.text = text;
    _choiceLabel.textColor = [UIColor blackColor];
    
    _choiceLabel.hidden = NO;
    _placeHolderLabel.hidden = !_choiceLabel.hidden;
    
}

- (IBAction)buttonTapped:(UIButton *)button {
    button.selected = !button.selected;
    
    if (button.selected) {
        [_buttonViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             ORKChoiceButtonView *buttonView = obj;
             if (buttonView.button != button) {
                 buttonView.button.selected = NO;
             } else {
                 [self setLabelText:buttonView.labelText];
             }
             
         }];
        
    } else {
        [self resetLabelText];
    }
    
    _answer = [_helper answerForSelectedIndexes:[self selectedIndexes]];
    
    if ([_delegate respondsToSelector:@selector(selectionViewSelectionDidChange:)]) {
        [_delegate selectionViewSelectionDidChange:self];
    }
}

- (NSArray *)selectedIndexes {
    NSMutableArray *array = [NSMutableArray new];
    
    [_buttonViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
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
        if ([object unsignedIntegerValue] < [_buttonViews count]) {
            ORKChoiceButtonView *buttonView = _buttonViews[[object unsignedIntegerValue]];
            [buttonView button].selected = YES;
            [self setLabelText:buttonView.labelText];
        }
    }];
}

- (BOOL)isAccessibilityElement {
    return NO;
}

@end
