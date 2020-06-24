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


#import "ORKSurveyAnswerCellForText.h"

#import "ORKAnswerTextField.h"
#import "ORKAnswerTextView.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKQuestionStep_Internal.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

static const CGFloat TextViewTopPadding = 8.0;
static const CGFloat TextViewBottomPadding = 16.0;
static const CGFloat TextViewMinimumHeight = 140.0;
static const CGFloat ClearTextButtonMinimumHeight = 20.0;
static const CGFloat ErrorLabelTopPadding = 4.0;
static const CGFloat ErrorLabelBottomPadding = 10.0;
static const CGFloat StandardSpacing = 8.0;
static const CGFloat CellBottomPadding = 5.0;

@interface ORKSurveyAnswerCellForText () <UITextViewDelegate>

@property (nonatomic, strong) ORKAnswerTextView *textView;
@property (nonatomic, strong) UILabel *errorLabel;

@end


@implementation ORKSurveyAnswerCellForText {
    NSInteger _maxLength;
    NSString *_defaultTextAnswer;
    UILabel *_textCountLabel;
    UIButton *_clearTextViewButton;
    UIView *_bottomSeperatorView;
    NSMutableArray *_constraints;
    BOOL _hideClearButton;
    BOOL _hideCharacterCountLabel;
}

- (void)applyAnswerFormat {
    ORKAnswerFormat *answerFormat = [self.step.answerFormat impliedAnswerFormat];
    
    if ([answerFormat isKindOfClass:[ORKTextAnswerFormat class]]) {
        ORKTextAnswerFormat *textAnswerFormat = (ORKTextAnswerFormat *)answerFormat;
        _maxLength = [textAnswerFormat maximumLength];
        _hideClearButton = [textAnswerFormat hideClearButton];
        _hideCharacterCountLabel = [textAnswerFormat hideCharacterCountLabel];
        _defaultTextAnswer = textAnswerFormat.defaultTextAnswer;
        self.textView.autocorrectionType = textAnswerFormat.autocorrectionType;
        self.textView.autocapitalizationType = textAnswerFormat.autocapitalizationType;
        self.textView.spellCheckingType = textAnswerFormat.spellCheckingType;
        self.textView.keyboardType = textAnswerFormat.keyboardType;
        self.textView.secureTextEntry = textAnswerFormat.secureTextEntry;
        self.textView.textContentType = textAnswerFormat.textContentType;
        
        if (@available(iOS 12.0, *)) {
            self.textView.passwordRules = textAnswerFormat.passwordRules;
        }
    } else {
        _maxLength = 0;
    }
}

- (BOOL)becomeFirstResponder {
    return [self.textView becomeFirstResponder];
}

- (void)setStep:(ORKQuestionStep *)step {
    [super setStep:step];
    [self applyAnswerFormat];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    self.layoutMargins = ORKStandardLayoutMarginsForTableViewCell(self);
}

- (void)prepareView {
    
    NSMutableArray *accessibilityElements = [NSMutableArray new];
    
    if (self.textView == nil ) {
        self.preservesSuperviewLayoutMargins = NO;
        self.layoutMargins = ORKStandardLayoutMarginsForTableViewCell(self);
        
        self.textView = [[ORKAnswerTextView alloc] initWithFrame:CGRectZero];
        
        self.textView.delegate = self;
        self.textView.editable = YES;
        if (@available(iOS 13.0, *)) {
            self.textView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        }
        
        [self addSubview:self.textView];
        
        self.textView.placeholder = self.step.placeholder;
        
        ORKEnableAutoLayoutForViews(@[_textView]);
        
        [self applyAnswerFormat];
        
        [self answerDidChange];
        
        // Avoid exposing both this cell and its inner text view as elements to accessibility
        // See also ORKCustomStepView -accessibilityElements
        [accessibilityElements addObject:self.textView];
    }
    
    if (_bottomSeperatorView == nil) {
        _bottomSeperatorView = [UIView new];
        
        if (@available(iOS 13.0, *)) {
            [_bottomSeperatorView setBackgroundColor:[UIColor separatorColor]];
        } else {
            [_bottomSeperatorView setBackgroundColor:[UIColor lightGrayColor]];
        }
        _bottomSeperatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_bottomSeperatorView];
    }
    
    if (_textCountLabel == nil && _maxLength > 0) {
        _textCountLabel = [UILabel new];
        if (@available(iOS 13.0, *)) {
            [_textCountLabel setTextColor:[UIColor labelColor]];
        } else {
            [_textCountLabel setTextColor:[UIColor grayColor]];
        }
        
        if (!_hideCharacterCountLabel) {
            [accessibilityElements addObject:_textCountLabel];
            [self updateTextCountLabel];
        }
        
        [_textCountLabel setHidden: _hideCharacterCountLabel];
        
        _textCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview: _textCountLabel];
    }
    
    if (_clearTextViewButton == nil && !_hideClearButton) {
        _clearTextViewButton = [UIButton new];
        [_clearTextViewButton setTitle:ORKLocalizedString(@"BUTTON_CLEAR", nil) forState:UIControlStateNormal];
        [_clearTextViewButton setBackgroundColor:[UIColor clearColor]];
        [_clearTextViewButton setTitleColor:self.tintColor forState:UIControlStateNormal];
        [_clearTextViewButton addTarget:self action:@selector(clearTextView) forControlEvents:UIControlEventTouchUpInside];
        _clearTextViewButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview: _clearTextViewButton];
        
        [accessibilityElements addObject:_clearTextViewButton];
    }
    
    if (_errorLabel == nil) {
        _errorLabel = [UILabel new];
        [_errorLabel setTextColor: [UIColor orangeColor]];
        [self.errorLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
        _errorLabel.numberOfLines = 0;
        _errorLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_errorLabel setAdjustsFontForContentSizeCategory:YES];
        _errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_errorLabel];
    }
    
    self.accessibilityElements = [accessibilityElements copy];
    accessibilityElements = nil;
    
    [self setUpConstraints];
    [super prepareView];
}

- (void)assignDefaultAnswer {
    if (_defaultTextAnswer) {
        [self ork_setAnswer:_defaultTextAnswer];
        if (self.textView) {
            self.textView.text = _defaultTextAnswer;
        }
    }
}

- (void)answerDidChange {
    id answer = self.answer;
    self.textView.text = (answer == ORKNullAnswerValue()) ? nil : self.answer;
    [self assignDefaultAnswer];
}

- (void)setUpConstraints {

    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    
    _constraints = [NSMutableArray array];
    
    //TextView Constraints
    [_constraints addObject:[_textView.topAnchor constraintEqualToAnchor:self.topAnchor constant:TextViewTopPadding]];
    [_constraints addObject:[_textView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:StandardSpacing]];
    [_constraints addObject:[_textView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-StandardSpacing]];
    NSLayoutConstraint *heightConstraint = [_textView.heightAnchor constraintGreaterThanOrEqualToConstant:TextViewMinimumHeight];
    [heightConstraint setPriority:UILayoutPriorityRequired];
    [_constraints addObject:heightConstraint];
    
    UIView *bottomMostElement;
    
    if (_textCountLabel && !_textCountLabel.isHidden) {
        bottomMostElement = _textCountLabel;
    }
    
    if (_clearTextViewButton && !_clearTextViewButton.isHidden) {
        bottomMostElement = _clearTextViewButton;
    }
    
    if (_errorLabel.attributedText && (!_textCountLabel || _textCountLabel.isHidden)) {
        bottomMostElement = _errorLabel;
    }
    
    BOOL createEmptySpaceForPossibleErrorMessage = NO;
    if (!bottomMostElement && _textCountLabel) {
        bottomMostElement = _bottomSeperatorView;
        createEmptySpaceForPossibleErrorMessage = YES;
    }
    
    if (_bottomSeperatorView && (bottomMostElement || createEmptySpaceForPossibleErrorMessage)) {
        //SeperatorView Constraints
        [_constraints addObject:[_bottomSeperatorView.topAnchor constraintEqualToAnchor:_textView.bottomAnchor constant:TextViewTopPadding]];
        [_constraints addObject:[_bottomSeperatorView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]];
        [_constraints addObject:[_bottomSeperatorView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]];
        [_constraints addObject:[_bottomSeperatorView.heightAnchor constraintEqualToConstant:1.0 / [UIScreen mainScreen].scale]];
    }
    
    if (bottomMostElement && !createEmptySpaceForPossibleErrorMessage) {
        //TextCountLabel Constraints
        if (_textCountLabel && !_textCountLabel.isHidden) {
            [_constraints addObject:[_textCountLabel.topAnchor constraintEqualToAnchor:_bottomSeperatorView.bottomAnchor constant:TextViewBottomPadding]];
            [_constraints addObject:[_textCountLabel.leadingAnchor constraintEqualToAnchor:_textView.leadingAnchor]];
            [_constraints addObject:[_textCountLabel.heightAnchor constraintGreaterThanOrEqualToConstant:ClearTextButtonMinimumHeight]];
        }
        
        //ClearTextViewButton Constraints
        if (_clearTextViewButton) {
            [_constraints addObject:[_clearTextViewButton.topAnchor constraintEqualToAnchor:_bottomSeperatorView.bottomAnchor constant:TextViewBottomPadding]];
            [_constraints addObject:[_clearTextViewButton.trailingAnchor constraintEqualToAnchor:_textView.trailingAnchor]];
            [_constraints addObject:[_clearTextViewButton.heightAnchor constraintGreaterThanOrEqualToConstant:ClearTextButtonMinimumHeight]];
        }
        
        //ErrorLabel Constraints
        if (_errorLabel.attributedText && (_textCountLabel && _textCountLabel.isHidden)) {
            [_constraints addObject:[_errorLabel.leadingAnchor constraintEqualToAnchor:_textView.leadingAnchor]];
            [_constraints addObject:[_errorLabel.topAnchor constraintEqualToAnchor:_bottomSeperatorView.bottomAnchor constant:TextViewBottomPadding]];
            [_errorLabel setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisVertical];
            [_constraints addObject:[_errorLabel.heightAnchor constraintGreaterThanOrEqualToConstant:ClearTextButtonMinimumHeight]];
            
            if (_clearTextViewButton) {
                [_constraints addObject:[_errorLabel.trailingAnchor constraintEqualToAnchor:_clearTextViewButton.leadingAnchor constant: -5.0]];
                [_clearTextViewButton setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
            } else {
                [_constraints addObject:[_errorLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]];
            }
        }
    } else if (!createEmptySpaceForPossibleErrorMessage) {
        bottomMostElement = _textView;
    }
    
    if (createEmptySpaceForPossibleErrorMessage) {
        [_constraints addObject:[self.bottomAnchor constraintGreaterThanOrEqualToAnchor:bottomMostElement.bottomAnchor constant:CellBottomPadding + TextViewBottomPadding + ClearTextButtonMinimumHeight]];
    } else {
        [_constraints addObject:[self.bottomAnchor constraintGreaterThanOrEqualToAnchor:bottomMostElement.bottomAnchor constant:CellBottomPadding]];
    }

    // Get full width layout
    [_constraints addObject:[self.class fullWidthLayoutConstraint:_textView]];
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

+ (BOOL)shouldDisplayWithSeparators {
    return NO;
}

- (void)textDidChange {
    [self ork_setAnswer:(self.textView.text.length > 0) ? self.textView.text : ORKNullAnswerValue()];
}

- (void)updateTextCountLabel {
    if (_maxLength > 0) {
        NSString *text = [[self.textView.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
        NSString *textCountLabelText = [[NSString alloc] initWithFormat:@"%lu/%li", (unsigned long)text.length, (long)_maxLength];
        _textCountLabel.text = textCountLabelText;
        
        if (_errorLabel && _errorLabel.attributedText) {
            [self removeErrorMessage];
        }
    }
}

- (void)clearTextView {
    self.textView.text = @"";
    [self textDidChange];
    [self updateTextCountLabel];
}

- (BOOL)shouldContinue {
    ORKTextAnswerFormat *answerFormat = (ORKTextAnswerFormat *)[self.step impliedAnswerFormat];
    if (![answerFormat isAnswerValidWithString:self.textView.text]) {
        [self showValidityAlertWithMessage:[[self.step impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:self.answer]];
        return NO;
    }
    return YES;
}

- (void)updateErrorLabelWithMessage:(NSString *)message {
    NSString *separatorString = @":";
    NSString *stringtoParse = message ? : ORKLocalizedString(@"RANGE_ALERT_TITLE", @"");
    NSString *parsedString = [stringtoParse componentsSeparatedByString:separatorString].firstObject;
    
    if (![self.accessibilityElements containsObject:self.errorLabel]) {
        self.accessibilityElements = [self.accessibilityElements arrayByAddingObject:self.errorLabel];
    }
    
    if (@available(iOS 13.0, *)) {
        
        NSString *errorMessage = [NSString stringWithFormat:@" %@", parsedString];
        NSMutableAttributedString *fullString = [[NSMutableAttributedString alloc] initWithString:errorMessage];
        NSTextAttachment *imageAttachment = [NSTextAttachment new];
        
        UIImage *exclamationMarkImage = [UIImage systemImageNamed:@"exclamationmark.circle.fill"];
        
        UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleFootnote];
        UIImage *configuredImage = [exclamationMarkImage imageByApplyingSymbolConfiguration:imageConfig];
        
        imageAttachment.image = [configuredImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        
        [fullString insertAttributedString:imageString atIndex:0];
        
        self.errorLabel.attributedText = fullString;
    } else {
        NSMutableAttributedString *fullString = [[NSMutableAttributedString alloc] initWithString:parsedString];
        self.errorLabel.attributedText = fullString;
    }
    
    [self setUpConstraints];
}

- (void)removeErrorMessage {
    self.errorLabel.attributedText = nil;
    if ([self.accessibilityElements containsObject:self.errorLabel]) {
        NSMutableArray *tempArray = [self.accessibilityElements mutableCopy];
        [tempArray removeObject:self.errorLabel];
        self.accessibilityElements = [tempArray copy];
    }
    [self setUpConstraints];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self textDidChange];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    // Only need to validate the text if the user enters a character other than a backspace.
    // For example, if the `textView.text = researchki` and the `string = researchkit`.
    if (textView.text.length < string.length) {
        
        string = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
        
        if (_maxLength > 0 && string.length > _maxLength) {
            
            if (_textCountLabel.isHidden) {
                [self updateErrorLabelWithMessage:ORKLocalizedString(@"MAX_WORD_COUNT_ERROR", @"")];
            } else {
                [self showValidityAlertWithMessage:[[self.step impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:string]];
            }
           
            return NO;
        } else if (_errorLabel.attributedText) {
            [self removeErrorMessage];
        }
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self textDidChange];
    [self updateTextCountLabel];
}

+ (CGFloat)suggestedCellHeightForView:(UIView *)view {
    return 180.0;
}

@end


@interface ORKSurveyAnswerCellForTextField ()

@property (nonatomic, strong) ORKAnswerTextField *textField;
@property (nonatomic, strong) UILabel *errorLabel;

@end


@implementation ORKSurveyAnswerCellForTextField {
    NSMutableArray *constraints;
    NSString *_defaultTextAnswer;
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

- (void)textFieldCell_initialize {
    ORKAnswerFormat *answerFormat = [self.step impliedAnswerFormat];
    ORKTextAnswerFormat *textAnswerFormat = ORKDynamicCast(answerFormat, ORKTextAnswerFormat);
    
    _defaultTextAnswer = textAnswerFormat.defaultTextAnswer;
    
    _textField = [[ORKAnswerTextField alloc] initWithFrame:CGRectZero];
    _textField.text = @"";
    
    NSString *placeholder = textAnswerFormat.placeholder ? :
        (self.step.placeholder ? : ORKLocalizedString(@"PLACEHOLDER_TEXT_OR_NUMBER", nil));
    _textField.placeholder = placeholder;
    _textField.textAlignment = NSTextAlignmentNatural;
    _textField.delegate = self;
    _textField.keyboardType = UIKeyboardTypeDefault;
    
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.accessibilityElements = @[_textField];
    
    [self addSubview:_textField];
    ORKEnableAutoLayoutForViews(@[_textField]);
    
    if (_errorLabel == nil) {
        _errorLabel = [UILabel new];
        [_errorLabel setTextColor: [UIColor redColor]];
        [self.errorLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
        _errorLabel.numberOfLines = 0;
        _errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_errorLabel];
    }
    
    
    [self setUpConstraints];
}

- (void)assignDefaultAnswer {
    if (_defaultTextAnswer) {
        [self ork_setAnswer:_defaultTextAnswer];
        if (self.textField) {
            self.textField.text = _defaultTextAnswer;
        }
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    self.contentView.layoutMargins = ORKStandardLayoutMarginsForTableViewCell(self);
}

- (void)setUpConstraints {
    if (constraints != nil) {
        [NSLayoutConstraint deactivateConstraints:constraints];
    }
    
    constraints = [NSMutableArray new];

    [[_textField.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:StandardSpacing] setActive:YES];
    [[_textField.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-StandardSpacing] setActive:YES];
    [[_textField.topAnchor constraintEqualToAnchor:self.topAnchor constant:0.0] setActive:YES];
    [[_textField.bottomAnchor constraintEqualToAnchor:_errorLabel.topAnchor constant:ErrorLabelTopPadding] setActive:YES];
    
    [[_errorLabel.leadingAnchor constraintEqualToAnchor:_textField.leadingAnchor constant:0.0] setActive:YES];
    [[_errorLabel.trailingAnchor constraintEqualToAnchor:_textField.trailingAnchor constant:0.0] setActive:YES];
    
    [[self.bottomAnchor constraintEqualToAnchor:_errorLabel.bottomAnchor constant:ErrorLabelBottomPadding] setActive:YES];
    
    // Get a full width layout
    [constraints addObject:[self.class fullWidthLayoutConstraint:_textField]];
    [NSLayoutConstraint activateConstraints:constraints];
}

+ (BOOL)shouldDisplayWithSeparators {
    return NO;
}

- (void)prepareView {
    if (self.textField == nil ) {
        [self textFieldCell_initialize];
    }
    
    [self answerDidChange];
    
    [super prepareView];
}

- (BOOL)shouldContinue {
    ORKTextAnswerFormat *answerFormat = (ORKTextAnswerFormat *)[self.step impliedAnswerFormat];
    if (![answerFormat isAnswerValidWithString:self.textField.text]) {
        [self updateErrorLabelWithMessage:[[self.step impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:self.textField.text]];
        return NO;
    }
    
    return YES;
}

- (void)answerDidChange {
    id answer = self.answer;
    ORKAnswerFormat *answerFormat = [self.step impliedAnswerFormat];
    ORKTextAnswerFormat *textFormat = (ORKTextAnswerFormat *)answerFormat;
    if (textFormat) {
        self.textField.autocorrectionType = textFormat.autocorrectionType;
        self.textField.autocapitalizationType = textFormat.autocapitalizationType;
        self.textField.spellCheckingType = textFormat.spellCheckingType;
        self.textField.keyboardType = textFormat.keyboardType;
        self.textField.secureTextEntry = textFormat.secureTextEntry;
        self.textField.textContentType = textFormat.textContentType;
        
        if (@available(iOS 12.0, *)) {
            self.textField.passwordRules = textFormat.passwordRules;
        }
    }
    NSString *displayValue = (answer && answer != ORKNullAnswerValue()) ? answer : nil;
    
    if (displayValue == nil && _defaultTextAnswer) {
        [self assignDefaultAnswer];
    } else {
        self.textField.text = displayValue;
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    [self checkTextAndSetAnswer];
}

- (void)checkTextAndSetAnswer {
    NSString *text = self.textField.text;
    ORKTextAnswerFormat *answerFormat = (ORKTextAnswerFormat *)[self.step impliedAnswerFormat];
    
    if (text.length && [answerFormat isAnswerValidWithString:text]) {
        [self ork_setAnswer:text];
    } else {
        [self ork_setAnswer:ORKNullAnswerValue()];
        [self removeErrorMessage];
    }
}

- (void)updateErrorLabelWithMessage:(NSString *)message {
    NSString *separatorString = @":";
    NSString *stringtoParse = message ? : ORKLocalizedString(@"RANGE_ALERT_TITLE", @"");
    NSString *parsedString = [stringtoParse componentsSeparatedByString:separatorString].firstObject;
    
    if (![self.accessibilityElements containsObject:self.errorLabel]) {
        self.accessibilityElements = [self.accessibilityElements arrayByAddingObject:self.errorLabel];
    }
    
    if (@available(iOS 13.0, *)) {
        
        NSString *errorMessage = [NSString stringWithFormat:@" %@", parsedString];
        NSMutableAttributedString *fullString = [[NSMutableAttributedString alloc] initWithString:errorMessage];
        NSTextAttachment *imageAttachment = [NSTextAttachment new];
        
        UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationWithPointSize:12 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium];
        UIImage *exclamationMarkImage = [UIImage systemImageNamed:@"exclamationmark.circle"];
        UIImage *configuredImage = [exclamationMarkImage imageByApplyingSymbolConfiguration:imageConfig];
        
        imageAttachment.image = [configuredImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        
        [fullString insertAttributedString:imageString atIndex:0];
        
        self.errorLabel.attributedText = fullString;
    } else {
        NSMutableAttributedString *fullString = [[NSMutableAttributedString alloc] initWithString:parsedString];
        self.errorLabel.attributedText = fullString;
    }
    
    [self setUpConstraints];
}

- (void)removeErrorMessage {
    self.errorLabel.attributedText = nil;
    if ([self.accessibilityElements containsObject:self.errorLabel]) {
        NSMutableArray *tempArray = [self.accessibilityElements mutableCopy];
        [tempArray removeObject:self.errorLabel];
        self.accessibilityElements = [tempArray copy];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    ORKAnswerFormat *impliedFormat = [self.step impliedAnswerFormat];
    NSAssert([impliedFormat isKindOfClass:[ORKTextAnswerFormat class]], @"answerFormat should be ORKTextAnswerFormat type instance.");
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Only need to validate the text if the user enters a character other than a backspace.
    // For example, if the `textField.text = researchki` and the `text = researchkit`.
    if (textField.text.length < text.length) {
        
        text = [[text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
        
        NSInteger maxLength = [(ORKTextAnswerFormat *)impliedFormat maximumLength];
        
        if (maxLength > 0 && text.length > maxLength) {
            [self updateErrorLabelWithMessage:[[self.step impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:text]];
            return NO;
        }
    }
    
    [self checkTextAndSetAnswer];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *text = self.textField.text;
    ORKTextAnswerFormat *answerFormat = (ORKTextAnswerFormat *)[self.step impliedAnswerFormat];
    
    if (text.length && ![answerFormat isAnswerValidWithString:text]) {
        [self updateErrorLabelWithMessage:[[self.step impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:self.textField.text]];
    }
}

@end

