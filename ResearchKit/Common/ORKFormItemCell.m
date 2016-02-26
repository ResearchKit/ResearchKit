/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Bruce Duncan.
 
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


#import "ORKFormItemCell.h"
#import "ORKHelpers.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKFormItem_Internal.h"
#import "ORKImageSelectionView.h"
#import "ORKResult_Private.h"
#import "ORKTextFieldView.h"
#import "ORKSkin.h"
#import "ORKTableContainerView.h"
#import "ORKCaption1Label.h"
#import "ORKFormTextView.h"
#import "ORKAccessibility.h"
#import "ORKPicker.h"
#import "ORKScaleSliderView.h"
#import "ORKSubheadlineLabel.h"
#import "ORKLocationSelectionView.h"
#import <MapKit/MapKit.h>


static const CGFloat VerticalMargin = 10.0;
static const CGFloat HorizontalMargin = 15.0;

@interface ORKFormItemCell ()

- (void)cellInit NS_REQUIRES_SUPER;
- (void)inputValueDidChange NS_REQUIRES_SUPER;
- (void)inputValueDidClear NS_REQUIRES_SUPER;
- (void)defaultAnswerDidChange NS_REQUIRES_SUPER;
- (void)answerDidChange;

// For use when setting the answer in response to user action
- (void)ork_setAnswer:(id)answer;

@property (nonatomic, strong) ORKCaption1Label *labelLabel;
@property (nonatomic, weak) UITableView *_parentTableView;

// If hasChangedAnswer, then a new defaultAnswer should not change the answer
@property (nonatomic, assign) BOOL hasChangedAnswer;

@end


@interface ORKSegmentedControl : UISegmentedControl

@end


@implementation ORKSegmentedControl

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSInteger previousSelectedSegmentIndex = self.selectedSegmentIndex;
    [super touchesEnded:touches withEvent:event];
    if (previousSelectedSegmentIndex == self.selectedSegmentIndex) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end


#pragma mark - ORKFormItemCell

@interface ORKFormItemCell ()

- (void)showValidityAlertWithMessage:(NSString *)text;

@end


@implementation ORKFormItemCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
                               formItem:(ORKFormItem *)formItem
                                 answer:(id)answer
                          maxLabelWidth:(CGFloat)maxLabelWidth
                               delegate:(id<ORKFormItemCellDelegate>)delegate {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // Setting the 'delegate' on init is required, as some questions (such as the scale questions)
        // need it when they wish to report their default answers to 'ORKFormStepViewController'.
        _delegate = delegate;
        
        _maxLabelWidth = maxLabelWidth;
        _answer = [answer copy];
        self.formItem = formItem;
        _labelLabel = [[ORKCaption1Label alloc] init];
        _labelLabel.text = formItem.text;
        _labelLabel.numberOfLines = 0;
        [self.contentView addSubview:_labelLabel];
        
        [self cellInit];
        [self setAnswer:_answer];
    }
    return self;
}

- (void)setExpectedLayoutWidth:(CGFloat)newWidth {
    if (newWidth != _expectedLayoutWidth) {
        _expectedLayoutWidth = newWidth;
        [self setNeedsUpdateConstraints];
    }
}

- (UITableView *)parentTableView {
    if (nil == __parentTableView) {
        id view = [self superview];
        
        while (view && [view isKindOfClass:[UITableView class]] == NO) {
            view = [view superview];
        }
        __parentTableView = (UITableView *)view;
    }
    return __parentTableView;
}

- (void)cellInit {
    // Subclasses should override this
}

- (void)inputValueDidChange {
    // Subclasses should override this, and should call _setAnswer:
    self.hasChangedAnswer = YES;
}

- (void)inputValueDidClear {
    // Subclasses should override this, and should call _setAnswer:
    self.hasChangedAnswer = YES;
}

- (void)answerDidChange {
}

- (BOOL)isAnswerValid {
    // Subclasses should override this if validation of the answer is required.
    return YES;
}

- (void)defaultAnswerDidChange {
    if (!self.hasChangedAnswer && !self.answer) {
        if (self.answer != _defaultAnswer && _defaultAnswer && ![self.answer isEqual:_defaultAnswer]) {
            self.answer = _defaultAnswer;
            
            // Inform delegate of the change too
            [self ork_setAnswer:_answer];
        }
    }
}

- (void)setDefaultAnswer:(id)defaultAnswer {
    _defaultAnswer = [defaultAnswer copy];
    [self defaultAnswerDidChange];
}

- (void)setSavedAnswers:(NSDictionary *)savedAnswers {
    _savedAnswers = savedAnswers;

    if (!_savedAnswers) {
        @throw [NSException exceptionWithName:NSGenericException
                                       reason:@"Saved answers cannot be nil."
                                     userInfo:nil];
    }
    
}

- (BOOL)becomeFirstResponder {
    // Subclasses should override this
    return YES;
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    // Subclasses should override this
    return YES;
}

- (void)prepareForReuse {
    self.hasChangedAnswer = NO;
}

// Inform delegate of the change
- (void)ork_setAnswer:(id)answer {
    _answer = [answer copy];
    [_delegate formItemCell:self answerDidChangeTo:answer];
}

// Receive change from outside
- (void)setAnswer:(id)answer {
    _answer = [answer copy];
    [self answerDidChange];
}

- (void)showValidityAlertWithMessage:(NSString *)text {
    [self.delegate formItemCell:self invalidInputAlertWithMessage:text];
}

- (void)showErrorAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self.delegate formItemCell:self invalidInputAlertWithTitle:title message:message];
}

@end


#pragma mark - ORKFormItemTextFieldBasedCell

@interface ORKFormItemTextFieldBasedCell ()

- (ORKUnitTextField *)textField;

@property (nonatomic, readonly) ORKTextFieldView *textFieldView;
@property (nonatomic, assign) BOOL editingHighlight;

@end


@implementation ORKFormItemTextFieldBasedCell {
    NSMutableArray *_variableConstraints;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
                               formItem:(ORKFormItem *)formItem
                                 answer:(id)answer
                          maxLabelWidth:(CGFloat)maxLabelWidth
                               delegate:(id<ORKFormItemCellDelegate>)delegate{
    self = [super initWithReuseIdentifier:reuseIdentifier
                                 formItem:formItem
                                   answer:answer
                            maxLabelWidth:maxLabelWidth
                                 delegate:delegate];
    if (self != nil) {
        UILabel *label = self.labelLabel;
        label.isAccessibilityElement = NO;
        UITextField *textField = self.textFieldView.textField;
        textField.isAccessibilityElement = YES;
        textField.accessibilityLabel = label.text;
    }
    return self;
}

- (ORKUnitTextField *)textField {
    return _textFieldView.textField;
}

- (void)cellInit {
    [super cellInit];
    
    _textFieldView = [[ORKTextFieldView alloc] init];
    
    ORKUnitTextField *textField = _textFieldView.textField;
    textField.delegate = self;
    textField.placeholder = self.formItem.placeholder;
    
    [self.contentView addSubview:_textFieldView];
    
    self.labelLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textFieldView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self setUpContentConstraint];
    [self setNeedsUpdateConstraints];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self setNeedsUpdateConstraints];
}

- (void)setUpContentConstraint {
    NSLayoutConstraint *contentConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:1.0
                                                                          constant:0.0];
    contentConstraint.priority = UILayoutPriorityDefaultHigh;
    contentConstraint.active = YES;
}

- (void)updateConstraints {
    [NSLayoutConstraint deactivateConstraints:_variableConstraints];
    [_variableConstraints removeAllObjects];
    
    if (!_variableConstraints) {
        _variableConstraints = [NSMutableArray new];
    }
    
    CGFloat labelWidth = self.maxLabelWidth;
    CGFloat boundWidth = self.expectedLayoutWidth;
    
    NSDictionary *metrics = @{@"vMargin":@(10),
                              @"hMargin":@(self.separatorInset.left),
                              @"hSpacer":@(16), @"vSpacer":@(15),
                              @"labelWidth": @(labelWidth)};
    
    id labelLabel = self.labelLabel;
    id textFieldView = _textFieldView;
    NSDictionary *views = NSDictionaryOfVariableBindings(labelLabel,textFieldView);
    
    CGFloat fieldWidth = _textFieldView.estimatedWidth;
    
    // Leave half space for field, and also to be able to display placeholder in full.
    if ( labelWidth >= 0.5 * boundWidth || (fieldWidth + labelWidth) > 0.9 * boundWidth ) {
        [_variableConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hMargin-[labelLabel]-hMargin-|"
                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                 metrics:metrics
                                                   views:views]];
        
        [_variableConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hMargin-[textFieldView]|"
                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                 metrics:metrics
                                                   views:views]];
        
        [_variableConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vMargin-[labelLabel]-vSpacer-[textFieldView]-vMargin-|"
                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                 metrics:metrics
                                                   views:views]];
        
    } else {
        [_variableConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hMargin-[labelLabel(==labelWidth)]-hSpacer-[textFieldView]|"
                                                 options:NSLayoutFormatAlignAllCenterY
                                                 metrics:metrics
                                                   views:views]];
        
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:labelLabel
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0]];
        
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                        toItem:labelLabel
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:1.0
                                                                      constant:0.0]];
        
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                        toItem:textFieldView
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:1.0
                                                                      constant:0.0]];
    }
    
    CGFloat defaultTableCelltHeight = ORKGetMetricForWindow(ORKScreenMetricTableCellDefaultHeight, self.window);
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:defaultTableCelltHeight];
    // Lower the priority to avoid conflicts with system supplied UIView-Encapsulated-Layout-Height constraint.
    heightConstraint.priority = 999;
    [_variableConstraints addObject:heightConstraint];
    
    [NSLayoutConstraint activateConstraints:_variableConstraints];
    [super updateConstraints];
}

- (void)setEditingHighlight:(BOOL)editingHighlight {
    _editingHighlight = editingHighlight;
    self.labelLabel.textColor = _editingHighlight ? [self tintColor] : [UIColor blackColor];
    [self textField].textColor = _editingHighlight ? [self tintColor] : [UIColor blackColor];
}

- (void)dealloc {
    [self textField].delegate = nil;
}

- (void)setLabel:(NSString *)label {
    self.labelLabel.text = label;
    self.textField.accessibilityLabel = label;
}

- (NSString *)label {
    return self.labelLabel.text;
}

- (NSString *)formattedValue {
    return nil;
}

- (NSString *)shortenedFormattedValue {
    return [self formattedValue];
}

- (void)updateValueLabel {
    ORKUnitTextField *textField = [self textField];
    
    if (textField == nil) {
        return;
    }
    
    NSString *formattedValue = [self formattedValue];
    CGFloat formattedWidth = [formattedValue sizeWithAttributes:@{ NSFontAttributeName : textField.font }].width;
    const CGFloat MinInputTextFieldPaddingRight = 6.0;
    
    // Shorten if necessary
    if (formattedWidth > textField.frame.size.width - MinInputTextFieldPaddingRight) {
        formattedValue = [self shortenedFormattedValue];
    }
    
    textField.text = formattedValue;
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    BOOL resign = [super resignFirstResponder];
    resign = [self.textField resignFirstResponder] || resign;
    return resign;
}

- (void)inputValueDidClear {
    [self ork_setAnswer:ORKNullAnswerValue()];
    [super inputValueDidClear];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // Ask table view to adjust scrollview's position
    self.editingHighlight = YES;
    [self.delegate formItemCellDidBecomeFirstResponder:self];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (![[self.formItem impliedAnswerFormat] isAnswerValidWithString:textField.text]) {
        [self showValidityAlertWithMessage:[[self.formItem impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:textField.text]];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.editingHighlight = NO;
    [self.delegate formItemCellDidResignFirstResponder:self];
    [self inputValueDidChange];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self inputValueDidClear];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (!  [[self.formItem impliedAnswerFormat] isAnswerValidWithString:textField.text]) {
        [self showValidityAlertWithMessage:[[self.formItem impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:textField.text]];
        return NO;
    }
    
    [textField resignFirstResponder];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    return YES;
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement {
    return NO;
}

@end


#pragma mark - ORKFormItemConfirmTextCell

@implementation ORKFormItemConfirmTextCell

- (void)setSavedAnswers:(NSDictionary *)savedAnswers {
    [super setSavedAnswers:savedAnswers];
    
    [savedAnswers addObserver:self
                   forKeyPath:[self originalItemIdentifier]
                      options:0
                      context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqual:[self originalItemIdentifier]]) {
        self.textField.text = nil;
        if (self.answer) {
            [self inputValueDidClear];
        }
    }
}

- (BOOL)isAnswerValidWithString:(NSString *)string {
    BOOL isValid = NO;
    if (string.length > 0) {
        NSString *originalItemAnswer = self.savedAnswers[[self originalItemIdentifier]];
        if (!ORKIsAnswerEmpty(originalItemAnswer) && [originalItemAnswer isEqualToString:string]) {
            isValid = YES;
        }
    }
    return isValid;
}

- (NSString *)originalItemIdentifier {
    ORKConfirmTextAnswerFormat *answerFormat = (ORKConfirmTextAnswerFormat *)self.formItem.answerFormat;
    return [answerFormat.originalItemIdentifier copy];
}

- (void)dealloc {
    [self.savedAnswers removeObserver:self forKeyPath:[self originalItemIdentifier]];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self ork_setAnswer:([self isAnswerValidWithString:text] ? text : @"")];

    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [super textFieldShouldEndEditing:textField];
    if (![self isAnswerValidWithString:textField.text] && textField.text.length > 0) {
        textField.text = nil;
        if (self.answer) {
            [self inputValueDidClear];
        }
        [self showValidityAlertWithMessage:[self.formItem.answerFormat localizedInvalidValueStringWithAnswerString:textField.text]];
    }
    return YES;
}

@end


#pragma mark - ORKFormItemTextFieldCell

@implementation ORKFormItemTextFieldCell

- (void)cellInit {
    [super cellInit];
    self.textField.allowsSelection = YES;
    ORKTextAnswerFormat *answerFormat = (ORKTextAnswerFormat *)[self.formItem impliedAnswerFormat];
    self.textField.autocorrectionType = answerFormat.autocorrectionType;
    self.textField.autocapitalizationType = answerFormat.autocapitalizationType;
    self.textField.spellCheckingType = answerFormat.spellCheckingType;
    self.textField.keyboardType = answerFormat.keyboardType;
    self.textField.secureTextEntry = answerFormat.secureTextEntry;
    
    [self answerDidChange];
}

- (void)inputValueDidChange {
    NSString *text = self.textField.text;
    [self ork_setAnswer:text.length ? text : ORKNullAnswerValue()];
    
    [super inputValueDidChange];
}

- (void)answerDidChange {
    id answer = self.answer;
    
    ORKTextAnswerFormat *answerFormat = (ORKTextAnswerFormat *)[self.formItem impliedAnswerFormat];
    if (answer != ORKNullAnswerValue()) {
        NSString *text = (NSString *)answer;
        NSInteger maxLength = answerFormat.maximumLength;
        BOOL changedValue = NO;
        if (maxLength > 0 && text.length > maxLength) {
            text = [text substringToIndex:maxLength];
            changedValue = YES;
        }
        self.textField.text = text;
        if (changedValue) {
            [self inputValueDidChange];
        }
    } else {
        self.textField.text = nil;
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    ORKTextAnswerFormat *answerFormat = (ORKTextAnswerFormat *)[self.formItem impliedAnswerFormat];
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Only need to validate the text if the user enters a character other than a backspace.
    // For example, if the `textField.text = researchki` and the `text = researchkit`.
    if (textField.text.length < text.length) {
        
        text = [[text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
        
        NSInteger maxLength = answerFormat.maximumLength;
        
        if (maxLength > 0 && text.length > maxLength) {
            [self showValidityAlertWithMessage:[answerFormat localizedInvalidValueStringWithAnswerString:text]];
            return NO;
        }
    }
    
    [self ork_setAnswer:text.length ? text : ORKNullAnswerValue()];
    [super inputValueDidChange];
    
    return YES;
}

@end


#pragma mark - ORKFormItemNumericCell

@implementation ORKFormItemNumericCell {
    NSNumberFormatter *_numberFormatter;
}

- (void)cellInit {
    [super cellInit];
    ORKQuestionType questionType = [self.formItem questionType];
    self.textField.keyboardType = (questionType == ORKQuestionTypeInteger)?UIKeyboardTypeNumberPad:UIKeyboardTypeDecimalPad;
    [self.textField addTarget:self action:@selector(valueFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.textField.allowsSelection = YES;
    
    ORKNumericAnswerFormat *answerFormat = (ORKNumericAnswerFormat *)[self.formItem impliedAnswerFormat];
    
    self.textField.manageUnitAndPlaceholder = YES;
    self.textField.unit = answerFormat.unit;
    self.textField.placeholder = self.formItem.placeholder;
    
    _numberFormatter = [(ORKNumericAnswerFormat *)answerFormat makeNumberFormatter];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChange:) name:NSCurrentLocaleDidChangeNotification object:nil];
    
    [self answerDidChange];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)localeDidChange:(NSNotification *)note {
    // On a locale change, re-format the value with the current locale
    _numberFormatter.locale = [NSLocale currentLocale];
    [self answerDidChange];
}

- (void)inputValueDidChange {
    
    NSString *text = self.textField.text;
    [self setAnswerWithText:text];
    
    [super inputValueDidChange];
}

- (void)answerDidChange {
    id answer = self.answer;
    if (answer && answer != ORKNullAnswerValue()) {
        NSString *displayValue = answer;
        if ([answer isKindOfClass:[NSNumber class]]) {
            displayValue = [_numberFormatter stringFromNumber:answer];
        }
        self.textField.text = displayValue;
    } else {
        self.textField.text = nil;
    }
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

#pragma mark UITextFieldDelegate

- (void)valueFieldDidChange:(UITextField *)textField {
    ORKNumericAnswerFormat *answerFormat = (ORKNumericAnswerFormat *)[self.formItem impliedAnswerFormat];
    NSString *sanitizedText = [answerFormat sanitizedTextFieldText:[textField text] decimalSeparator:[_numberFormatter decimalSeparator]];
    textField.text = sanitizedText;
    
    [self inputValueDidChange];
}

@end


#pragma mark - ORKFormItemTextCell

@implementation ORKFormItemTextCell {
    ORKFormTextView *_textView;
    CGFloat _lastSeenLineCount;
    NSInteger _maxLength;
}

- (void)cellInit {
    [super cellInit];
    
    _lastSeenLineCount = 1;
    self.labelLabel.text = nil;
    _textView = [[ORKFormTextView alloc] init];
    _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    _textView.delegate = self;
    _textView.contentInset = UIEdgeInsetsMake(-5.0, -4.0, -5.0, 0.0);
    _textView.textAlignment = NSTextAlignmentNatural;
    _textView.scrollEnabled = NO;
    
    [self applyAnswerFormat];
    [self answerDidChange];
    
    [self.contentView addSubview:_textView];
    [self setUpConstraints];
}

- (void)setUpConstraints {
    NSDictionary *views = @{ @"textView": _textView };
    ORKEnableAutoLayoutForViews(views.allValues);
    NSDictionary *metrics = @{ @"vMargin":@(10), @"hMargin":@(self.separatorInset.left) };
    
    NSMutableArray *constraints = [NSMutableArray new];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hMargin-[textView]-hMargin-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:metrics
                                               views:views]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vMargin-[textView]-vMargin-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:metrics
                                               views:views]];
    
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.0
                                                                         constant:120.0];
    heightConstraint.priority = UILayoutPriorityDefaultHigh;
    [constraints addObject:heightConstraint];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)applyAnswerFormat {
    ORKAnswerFormat *answerFormat = [self.formItem impliedAnswerFormat];
    if ([answerFormat isKindOfClass:[ORKTextAnswerFormat class]]) {
        ORKTextAnswerFormat *textAnswerFormat = (ORKTextAnswerFormat *)answerFormat;
        _maxLength = [textAnswerFormat maximumLength];
        _textView.autocorrectionType = textAnswerFormat.autocorrectionType;
        _textView.autocapitalizationType = textAnswerFormat.autocapitalizationType;
        _textView.spellCheckingType = textAnswerFormat.spellCheckingType;
        _textView.keyboardType = textAnswerFormat.keyboardType;
        _textView.secureTextEntry = textAnswerFormat.secureTextEntry;
    } else {
        _maxLength = 0;
    }
}

- (void)setFormItem:(ORKFormItem *)formItem {
    [super setFormItem:formItem];
    [self applyAnswerFormat];
}

- (void)answerDidChange {
    id answer = self.answer;
    if (answer == ORKNullAnswerValue()) {
        answer = nil;
    }
    _textView.text = (NSString *)answer;
    _textView.textColor = [UIColor blackColor];
    
    if (_textView.text.length == 0) {
        if ([_textView isFirstResponder]) {
            _textView.text = nil;
            _textView.textColor = [UIColor blackColor];
        } else {
            _textView.text = self.formItem.placeholder;
            _textView.textColor = [self placeholderColor];
        }
    }
}

- (BOOL)becomeFirstResponder {
    return [_textView becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    BOOL resign = [super resignFirstResponder];
    return [_textView resignFirstResponder] || resign;
}

- (void)inputValueDidChange {
    NSString *text = _textView.text;
    [self ork_setAnswer:text.length ? text : ORKNullAnswerValue()];
    [super inputValueDidChange];
}

- (UIColor *)placeholderColor {
    return [UIColor ork_midGrayTintColor];
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    NSInteger lineCount = [textView.text componentsSeparatedByCharactersInSet:
                           [NSCharacterSet newlineCharacterSet]].count;
    
    if (_lastSeenLineCount != lineCount) {
        _lastSeenLineCount = lineCount;
        
        UITableView *tableView = [self parentTableView];
        
        [tableView beginUpdates];
        [tableView endUpdates];
        
        CGRect visibleRect = [textView caretRectForPosition:textView.selectedTextRange.start];
        CGRect convertedVisibleRect = [tableView convertRect:visibleRect fromView:_textView];
        [tableView scrollRectToVisible:convertedVisibleRect animated:YES];
    }
    
    [self inputValueDidChange];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.textColor == [self placeholderColor]) {
        textView.text = nil;
        textView.textColor = [UIColor blackColor];
    }
    // Ask table view to adjust scrollview's position
    [self.delegate formItemCellDidBecomeFirstResponder:self];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = self.formItem.placeholder;
        textView.textColor = [self placeholderColor];
    }
    [self.delegate formItemCellDidResignFirstResponder:self];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    // Only need to validate the text if the user enters a character other than a backspace.
    // For example, if the `textView.text = researchki` and the `string = researchkit`.
    if (textView.text.length < string.length) {
        
        string = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
        
        if (_maxLength > 0 && string.length > _maxLength) {
            [self showValidityAlertWithMessage:[[self.formItem impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:string]];
            return NO;
        }
    }
    
    return YES;
}

@end


#pragma mark - ORKFormItemImageSelectionCell

@interface ORKFormItemImageSelectionCell () <ORKImageSelectionViewDelegate>

@end


@implementation ORKFormItemImageSelectionCell {
    ORKImageSelectionView *_selectionView;
}

- (void)cellInit {
    // Subclasses should override this
    
    self.labelLabel.text = nil;
    
    _selectionView = [[ORKImageSelectionView alloc] initWithImageChoiceAnswerFormat:(ORKImageChoiceAnswerFormat *)self.formItem.answerFormat
                                                                             answer:self.answer];
    _selectionView.delegate = self;
    
    self.contentView.layoutMargins = UIEdgeInsetsMake(VerticalMargin, HorizontalMargin, VerticalMargin, HorizontalMargin);
    
    [self.contentView addSubview:_selectionView];
    [self setUpConstraints];
    
    [super cellInit];
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = @{@"selectionView": _selectionView };
    ORKEnableAutoLayoutForViews(views.allValues);
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[selectionView]-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:views]];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[selectionView]-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:views]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

#pragma mark ORKImageSelectionViewDelegate

- (void)selectionViewSelectionDidChange:(ORKImageSelectionView *)view {
    [self ork_setAnswer:view.answer];
    [self inputValueDidChange];
}

#pragma mark recover answer

- (void)answerDidChange {
    [super answerDidChange];
    [_selectionView setAnswer:self.answer];
}

@end


#pragma mark - ORKFormItemScaleCell

@interface ORKFormItemScaleCell () <ORKScaleSliderViewDelegate>

@end


@implementation ORKFormItemScaleCell {
    ORKScaleSliderView *_sliderView;
    id<ORKScaleAnswerFormatProvider> _formatProvider;
}

- (id<ORKScaleAnswerFormatProvider>)formatProvider {
    if (_formatProvider == nil) {
        _formatProvider = (id<ORKScaleAnswerFormatProvider>)[self.formItem.answerFormat impliedAnswerFormat];
    }
    return _formatProvider;
}

- (void)cellInit {
    self.labelLabel.text = nil;
    
    _sliderView = [[ORKScaleSliderView alloc] initWithFormatProvider:(ORKScaleAnswerFormat *)self.formItem.answerFormat delegate:self];
    
    [self.contentView addSubview:_sliderView];
    [self setUpConstraints];
    
    [super cellInit];
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = @{ @"sliderView": _sliderView };
    ORKEnableAutoLayoutForViews(views.allValues);
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sliderView]|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:views]];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sliderView]|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:views]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

#pragma mark recover answer

- (void)answerDidChange {
    [super answerDidChange];
    
    id<ORKScaleAnswerFormatProvider> formatProvider = self.formatProvider;
    id answer = self.answer;
    if (answer && answer != ORKNullAnswerValue()) {
        
        [_sliderView setCurrentAnswerValue:answer];

    } else {
        if (answer == nil && [formatProvider defaultAnswer]) {
            [_sliderView setCurrentAnswerValue:[formatProvider defaultAnswer]];
            [self ork_setAnswer:_sliderView.currentAnswerValue];
        } else {
            [_sliderView setCurrentAnswerValue:nil];
        }
    }
}

- (void)scaleSliderViewCurrentValueDidChange:(ORKScaleSliderView *)sliderView {
    
    [self ork_setAnswer:sliderView.currentAnswerValue];
    [super inputValueDidChange];
}

@end


#pragma mark - ORKFormItemPickerCell

@interface ORKFormItemPickerCell () <ORKPickerDelegate>

@end


@implementation ORKFormItemPickerCell {
    id<ORKPicker> _picker;
}


- (void)setFormItem:(ORKFormItem *)formItem {
    ORKAnswerFormat *answerFormat = formItem.impliedAnswerFormat;
    
    if (!(!formItem ||
          [answerFormat isKindOfClass:[ORKDateAnswerFormat class]] ||
          [answerFormat isKindOfClass:[ORKTimeOfDayAnswerFormat class]] ||
          [answerFormat isKindOfClass:[ORKTimeIntervalAnswerFormat class]] ||
          [answerFormat isKindOfClass:[ORKValuePickerAnswerFormat class]])) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"formItem.answerFormat should be an ORKDateAnswerFormat or ORKTimeOfDayAnswerFormat or ORKTimeIntervalAnswerFormat or ORKValuePicker instance" userInfo:nil];
    }
    [super setFormItem:formItem];
}

- (void)setDefaultAnswer:(id)defaultAnswer {
    ORK_Log_Debug(@"%@", defaultAnswer);
    [super setDefaultAnswer:defaultAnswer];
}

- (void)answerDidChange {
    self.picker.answer = self.answer;
    self.textField.text = self.picker.selectedLabelText;
}

- (id<ORKPicker>)picker {
    if (_picker == nil) {
        ORKAnswerFormat *answerFormat = (ORKDateAnswerFormat *)[self.formItem impliedAnswerFormat];
        _picker = [ORKPicker pickerWithAnswerFormat:answerFormat answer:self.answer delegate:self];
    }
    
    return _picker;
}

- (void)inputValueDidChange {
    if (!_picker) {
        return;
    }
    
    self.textField.text = [_picker selectedLabelText];
    
    [self ork_setAnswer:_picker.answer];
    
    [self.textField setSelectedTextRange:nil];
    
    [super inputValueDidChange];
}

#pragma mark ORKPickerDelegate

- (void)picker:(id)picker answerDidChangeTo:(id)answer {
    
    [self inputValueDidChange];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // hide keyboard
        [textField resignFirstResponder];
        
        // clear value
        [self inputValueDidClear];
        
        // reset picker
        [self answerDidChange];
    });
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL shouldBeginEditing = [super textFieldShouldBeginEditing:textField];
    
    if (shouldBeginEditing) {
        if (self.textFieldView.inputView == nil) {
            self.textField.inputView = self.picker.pickerView;
        }
        
        [self.picker pickerWillAppear];
    }
    
    return shouldBeginEditing;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return NO;
}

@end


#pragma mark - ORKFormItemLocationCell

@interface ORKFormItemLocationCell () <ORKLocationSelectionViewDelegate>

@property (nonatomic, assign) BOOL editingHighlight;

@end


@implementation ORKFormItemLocationCell {
    ORKLocationSelectionView *_selectionView;
    NSLayoutConstraint *_heightConstraint;
    NSLayoutConstraint *_bottomConstraint;
}

- (void)cellInit {
    [super cellInit];
    
    _selectionView = [[ORKLocationSelectionView alloc] initWithFormMode:YES
                                                     useCurrentLocation:((ORKLocationAnswerFormat *)self.formItem.answerFormat).useCurrentLocation
                                                          leadingMargin:self.separatorInset.left];
    _selectionView.delegate = self;
    
    [self.contentView addSubview:_selectionView];

    if (self.formItem.placeholder != nil) {
        [_selectionView setPlaceholderText:self.formItem.placeholder];
    }
    
    [self setUpConstraints];
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *dictionary = @{@"_selectionView":_selectionView};
    ORKEnableAutoLayoutForViews([dictionary allValues]);
    NSDictionary *metrics = @{@"verticalMargin":@(VerticalMargin), @"horizontalMargin":@(self.separatorInset.left), @"verticalMarginBottom":@(VerticalMargin - (1.0 / [UIScreen mainScreen].scale))};
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_selectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:dictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_selectionView]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:dictionary]];
    _bottomConstraint = [NSLayoutConstraint constraintWithItem:_selectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [constraints addObject:_bottomConstraint];
    _heightConstraint = [NSLayoutConstraint constraintWithItem:_selectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_selectionView.intrinsicContentSize.height];
    _heightConstraint.priority = UILayoutPriorityDefaultHigh;
    [constraints addObject:_heightConstraint];
    
    [self.contentView addConstraints:constraints];
}

- (void)setFormItem:(ORKFormItem *)formItem {
    [super setFormItem:formItem];
    
    if (_selectionView) {
        [_selectionView setPlaceholderText:formItem.placeholder];
    }
}

- (void)answerDidChange {
    _selectionView.answer = self.answer;
}

- (void)setEditingHighlight:(BOOL)editingHighlight {
    _editingHighlight = editingHighlight;
    [_selectionView setTextColor:( _editingHighlight ? [self tintColor] : [UIColor blackColor])];
}

- (void)locationSelectionViewDidBeginEditing:(ORKLocationSelectionView *)view {
    self.editingHighlight = YES;
    [_selectionView showMapViewIfNecessary];
    [self.delegate formItemCellDidBecomeFirstResponder:self];
}

- (void)locationSelectionViewDidEndEditing:(ORKLocationSelectionView *)view {
    self.editingHighlight = NO;
    [self.delegate formItemCellDidResignFirstResponder:self];
}

- (void)locationSelectionViewDidChange:(ORKLocationSelectionView *)view {
    [self inputValueDidChange];
}

- (void)locationSelectionViewNeedsResize:(ORKLocationSelectionView *)view {
    UITableView *tableView = [self parentTableView];
    
    _heightConstraint.constant = _selectionView.intrinsicContentSize.height;
    _bottomConstraint.constant = -(VerticalMargin - (1.0 / [UIScreen mainScreen].scale));
    
    [tableView beginUpdates];
    [tableView endUpdates];

}

- (void)locationSelectionView:(ORKLocationSelectionView *)view didFailWithErrorTitle:(NSString *)title message:(NSString *)message {
    [self showErrorAlertWithTitle:title message:message];
}

- (void)inputValueDidChange {
    [self ork_setAnswer:_selectionView.answer];
    [super inputValueDidChange];
}

- (BOOL)becomeFirstResponder {
    return [_selectionView becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [_selectionView resignFirstResponder];
}

@end
