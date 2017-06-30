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


#import "ORKSurveyAnswerCellForNumber.h"

#import "ORKTextFieldView.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKQuestionStep_Internal.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


@interface ORKSurveyAnswerCellForNumber ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) ORKTextFieldView *textFieldView;

@end


@implementation ORKSurveyAnswerCellForNumber {
    NSNumberFormatter *_numberFormatter;
}

- (ORKUnitTextField *)textField {
    return _textFieldView.textField;
}

- (void)numberCell_initialize {
    ORKQuestionType questionType = self.step.questionType;
    _numberFormatter = ORKDecimalNumberFormatter();
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChange:) name:NSCurrentLocaleDidChangeNotification object:nil];
    
    _textFieldView = [[ORKTextFieldView alloc] init];
    ORKUnitTextField *textField =  _textFieldView.textField;
    
    textField.delegate = self;
    textField.allowsSelection = YES;
    
    if (questionType == ORKQuestionTypeDecimal) {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    } else if (questionType == ORKQuestionTypeInteger) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    [self addPlusMinusAccessoryToField:textField];
    [textField addTarget:self action:@selector(valueFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    _containerView = [[UIView alloc] init];
    _containerView.backgroundColor = textField.backgroundColor;
    [_containerView addSubview: _textFieldView];

    [self addSubview:_containerView];
    
    self.layoutMargins = ORKStandardLayoutMarginsForTableViewCell(self);
    ORKEnableAutoLayoutForViews(@[_containerView, _textFieldView]);
    [self setUpConstraints];
}

- (void)addPlusMinusAccessoryToField:(UITextField*) field {
    UIView *inputAccesoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 42)];
    // It´s good idea a view under the button in order to change the color...more custom option
    inputAccesoryView.backgroundColor = [UIColor clearColor];
    UIImage *minusImage = [UIImage imageNamed:@"numberPadMinus" inBundle:ORKBundle() compatibleWithTraitCollection:nil];
    UIImage *plusImage = [UIImage imageNamed:@"numberPadPlus" inBundle:ORKBundle() compatibleWithTraitCollection:nil];

    UIButton *minusButton = [[UIButton alloc] initWithFrame:CGRectMake(inputAccesoryView.frame.size.width/2, 0, inputAccesoryView.frame.size.width/2, inputAccesoryView.frame.size.height)];
    [minusButton setImage:minusImage forState:UIControlStateNormal];
    [minusButton setBackgroundColor:[UIColor colorWithRed:187.0f/255.0f green:194.0f/255.0f blue:187.0f/255.0f alpha:1]];
    [minusButton addTarget:self action:@selector(addNegativeSign) forControlEvents:UIControlEventTouchUpInside];
    [inputAccesoryView addSubview:minusButton];
    
    UIButton *plusButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, inputAccesoryView.frame.size.width/2, inputAccesoryView.frame.size.height)];
    [plusButton setImage:plusImage forState:UIControlStateNormal];
    [plusButton setBackgroundColor:[UIColor colorWithRed:209.0f/255.0f green:213.0f/255.0f blue:219.0f/255.0f alpha:1]];
    [plusButton addTarget:self action:@selector(removeNegativeSign) forControlEvents:UIControlEventTouchUpInside];
    [inputAccesoryView addSubview:plusButton];
    
    field.inputAccessoryView = inputAccesoryView;
}

- (void)addNegativeSign {
    ORKUnitTextField *textField =  _textFieldView.textField;
    
    if (![textField.text hasPrefix:@"-"])
    {
        textField.text = [NSString stringWithFormat:@"-%@",textField.text];
        if (textField.text.length > 1) {
            [self valueFieldDidChange:textField];
        }
    }
}
    
- (void)removeNegativeSign {
    ORKUnitTextField *textField =  _textFieldView.textField;
    
    if ([textField.text hasPrefix:@"-"])
    {
        textField.text = [textField.text substringFromIndex:1];
        textField.text = [NSString stringWithFormat:@" %@",textField.text];
        if (textField.text.length > 1) {
            [self valueFieldDidChange:textField];
        }
    }
}
    
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)localeDidChange:(NSNotification *)note {
    // On a locale change, re-format the value with the current locale
    _numberFormatter.locale = [NSLocale currentLocale];
    [self answerDidChange];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    self.layoutMargins = ORKStandardLayoutMarginsForTableViewCell(self);
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    NSDictionary *views = NSDictionaryOfVariableBindings(_containerView, _textFieldView);
    
    // Get a full width layout
    [constraints addObject:[self.class fullWidthLayoutConstraint:_containerView]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_containerView]-|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_containerView(>=0)]-|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textFieldView]|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textFieldView]|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (BOOL)becomeFirstResponder {
    return [[self textField] becomeFirstResponder];
}

- (void)prepareView {
    if (self.textField == nil ) {
        [self numberCell_initialize];
    }
    
    [self answerDidChange];
    
    [super prepareView];
}

- (BOOL)isAnswerValid {
    id answer = self.answer;
    
    if (answer == ORKNullAnswerValue()) {
        return YES;
    }
    
    ORKAnswerFormat *answerFormat = [self.step impliedAnswerFormat];
    ORKNumericAnswerFormat *numericFormat = (ORKNumericAnswerFormat *)answerFormat;
    return [numericFormat isAnswerValidWithString:self.textField.text];
}

- (BOOL)shouldContinue {
    BOOL isValid = [self isAnswerValid];

    if (!isValid) {
        [self showValidityAlertWithMessage:[[self.step impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:self.textField.text]];
    }
    
    return isValid;
}

- (void)answerDidChange {
    id answer = self.answer;
    ORKAnswerFormat *answerFormat = [self.step impliedAnswerFormat];
    ORKNumericAnswerFormat *numericFormat = (ORKNumericAnswerFormat *)answerFormat;
    NSString *displayValue = (answer && answer != ORKNullAnswerValue()) ? answer : nil;
    if ([answer isKindOfClass:[NSNumber class]]) {
        displayValue = [_numberFormatter stringFromNumber:answer];
    }
   
    NSString *placeholder = self.step.placeholder ? : ORKLocalizedString(@"PLACEHOLDER_TEXT_OR_NUMBER", nil);

    self.textField.manageUnitAndPlaceholder = YES;
    self.textField.unit = numericFormat.unit;
    self.textField.placeholder = placeholder;
    self.textField.text = displayValue;
}

#pragma mark - UITextFieldDelegate

- (void)valueFieldDidChange:(UITextField *)textField {
    ORKNumericAnswerFormat *answerFormat = (ORKNumericAnswerFormat *)[self.step impliedAnswerFormat];
    NSString *sanitizedText = [answerFormat sanitizedTextFieldText:[textField text] decimalSeparator:[_numberFormatter decimalSeparator]];
    textField.text = sanitizedText;
    [self setAnswerWithText:textField.text];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self ork_setAnswer:ORKNullAnswerValue()];
    return YES;
}

- (void)setAnswerWithText:(NSString *)text {
    BOOL updateInput = NO;
    id answer = ORKNullAnswerValue();
    if (text.length) {
        answer = [[NSDecimalNumber alloc] initWithString:text locale:[NSLocale currentLocale]];
        if (!answer) {
            answer = ORKNullAnswerValue();
            updateInput = YES;
        }
    }
    
    [self ork_setAnswer:answer];
    if (updateInput) {
        [self answerDidChange];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    BOOL isValid = [self isAnswerValid];
    if (!isValid) {
        [self showValidityAlertWithMessage:[[self.step impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:textField.text]];
    }
    
    return YES;
}

+ (BOOL)shouldDisplayWithSeparators {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL isValid = [self isAnswerValid];
    
    if (!isValid) {
        [self showValidityAlertWithMessage:[[self.step impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:textField.text]];
        return NO;
    }
    
    [self.textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *text = self.textField.text;
    [self setAnswerWithText:text];
}

@end
