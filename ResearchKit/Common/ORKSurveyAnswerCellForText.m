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
#import "ORKSkin.h"
#import "ORKHelpers.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKQuestionStep_Internal.h"
#import "ORKAnswerTextField.h"
#import "ORKAnswerTextView.h"


@interface ORKSurveyAnswerCellForText () <UITextViewDelegate>

@property (nonatomic, strong) ORKAnswerTextView *textView;
@property (nonatomic, strong) UILabel *placeHolder;

@end


@implementation ORKSurveyAnswerCellForText {
    NSInteger _maxLength;
}

- (void)applyAnswerFormat {
    ORKAnswerFormat *answerFormat = [self.step.answerFormat impliedAnswerFormat];
    
    if ([answerFormat isKindOfClass:[ORKTextAnswerFormat class]]) {
        ORKTextAnswerFormat *textAnswerFormat = (ORKTextAnswerFormat *)answerFormat;
        _maxLength = [textAnswerFormat maximumLength];
        self.textView.autocorrectionType = textAnswerFormat.autocorrectionType;
        self.textView.autocapitalizationType = textAnswerFormat.autocapitalizationType;
        self.textView.spellCheckingType = textAnswerFormat.spellCheckingType;
        self.textView.keyboardType = textAnswerFormat.keyboardType;
        self.textView.secureTextEntry = textAnswerFormat.secureTextEntry;
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
    if (self.textView == nil ) {
        self.preservesSuperviewLayoutMargins = NO;
        self.layoutMargins = ORKStandardLayoutMarginsForTableViewCell(self);
        
        self.textView = [[ORKAnswerTextView alloc] initWithFrame:CGRectZero];
        
        self.textView.delegate = self;
        self.textView.editable = YES;
        
        [self addSubview:self.textView];
        
        self.placeHolder = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0, self.bounds.size.width, 36)];
        self.textView.placeHolder = self.placeHolder;
        self.placeHolder.text = self.step.placeholder? :ORKLocalizedString(@"PLACEHOLDER_LONG_TEXT", nil);
        self.placeHolder.textColor = [UIColor lightGrayColor];
        self.placeHolder.userInteractionEnabled = NO;
        [self addSubview:self.placeHolder];
        
        ORKEnableAutoLayoutForViews(@[_placeHolder, _textView]);
        
        [self setUpConstraints];
        
        [self applyAnswerFormat];
        
        [self answerDidChange];
    }
    [super prepareView];
}

- (void)answerDidChange {
    id answer = self.answer;
    self.textView.text = (answer == ORKNullAnswerValue()) ? nil : self.answer;
    self.placeHolder.hidden = (self.textView.text.length > 0) && ![self.textView isFirstResponder];
    
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray array];

    NSDictionary *views = NSDictionaryOfVariableBindings(_textView, _placeHolder);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_textView]-|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textView]-|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_placeHolder
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_textView
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_placeHolder
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:_textView
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_placeHolder
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:_textView
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_placeHolder
                                                        attribute:NSLayoutAttributeTopMargin
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_textView
                                                        attribute:NSLayoutAttributeTopMargin
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

+ (BOOL)shouldDisplayWithSeparators {
    return YES;
}

- (void)textDidChange {
    [self ork_setAnswer:(self.textView.text.length > 0)? self.textView.text : ORKNullAnswerValue()];
}

- (BOOL)shouldContinue {
    ORKTextAnswerFormat *answerFormat = (ORKTextAnswerFormat *)[self.step impliedAnswerFormat];
    if (![answerFormat isAnswerValidWithString:self.textView.text]) {
        [self showValidityAlertWithMessage:[[self.step impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:self.answer]];
        return NO;
    }
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [self textDidChange];
    self.placeHolder.hidden = (self.textView.text.length > 0);
}

- (void)textViewDidBeginEditing:(UITextView *)textView {

    self.placeHolder.hidden = YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];

    // Only need to validate the text if the user enters a character other than a backspace.
    // For example, if the `textView.text = researchki` and the `string = researchkit`.
    if (textView.text.length < string.length) {
    
        string = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
    
        if (_maxLength > 0 && string.length > _maxLength) {
            [self showValidityAlertWithMessage:[[self.step impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:string]];
            return NO;
        }
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self textDidChange];
}

+ (CGFloat)suggestedCellHeightForView:(UIView *)view {
    return 180.0;
}

@end


@interface ORKSurveyAnswerCellForTextField ()

@property (nonatomic, strong) ORKAnswerTextField *textField;

@end


@implementation ORKSurveyAnswerCellForTextField

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

- (void)textFieldCell_initialize {
    _textField = [[ORKAnswerTextField alloc] initWithFrame:CGRectZero];
    _textField.text = @"";
    
    _textField.placeholder = self.step.placeholder? : ORKLocalizedString(@"PLACEHOLDER_TEXT_OR_NUMBER", nil);
    _textField.textAlignment = NSTextAlignmentNatural;
    _textField.delegate = self;
    _textField.keyboardType = UIKeyboardTypeDefault;

    [self.contentView addSubview:_textField];
    ORKEnableAutoLayoutForViews(@[_textField]);
    
    [self setUpConstraints];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    self.contentView.layoutMargins = ORKStandardLayoutMarginsForTableViewCell(self);
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    NSDictionary *views = NSDictionaryOfVariableBindings(_textField);
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_textField]-|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textField]-|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    [NSLayoutConstraint activateConstraints:constraints];
}

+ (BOOL)shouldDisplayWithSeparators {
    return YES;
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
        [self showValidityAlertWithMessage:[[self.step impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:self.answer]];
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
    }
    NSString *displayValue = (answer && answer != ORKNullAnswerValue()) ? answer : nil;
    
    self.textField.text = displayValue;
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
            [self showValidityAlertWithMessage:[[self.step impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:text]];
            return NO;
        }
    }
    
    [self ork_setAnswer:text.length ? text : ORKNullAnswerValue()];
    
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
    [self ork_setAnswer:text.length ? text : ORKNullAnswerValue()];
}

@end

