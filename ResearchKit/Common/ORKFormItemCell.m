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


static const CGFloat kVMargin = 10.0;
static const CGFloat kHMargin = 15.0;

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

// If haveChangedAnswer, then a new defaultAnswer should not change the answer
@property (nonatomic, assign) BOOL haveChangedAnswer;

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

@property (nonatomic, strong) NSMutableArray *myConstraints;

- (void)showValidityAlertWithMessage:(NSString *)text;

@end


@implementation ORKFormItemCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
                               formItem:(ORKFormItem *)formItem
                                 answer:(id)answer
                          maxLabelWidth:(CGFloat)maxLabelWidth
                             screenType:(ORKScreenType)screenType {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _screenType = screenType;
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
    self.haveChangedAnswer = YES;
}

- (void)inputValueDidClear {
    // Subclasses should override this, and should call _setAnswer:
    self.haveChangedAnswer = YES;
}

- (void)answerDidChange {
}

- (BOOL)isAnswerValid {
    // Subclasses should override this if validation of the answer is required.
    return YES;
}

- (void)defaultAnswerDidChange {
    if (! self.haveChangedAnswer && ! self.answer) {
        if (self.answer != _defaultAnswer && _defaultAnswer && ! [self.answer isEqual:_defaultAnswer]) {
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
    self.haveChangedAnswer = NO;
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

@end


#pragma mark - ORKFormItemTextFieldBasedCell

@interface ORKFormItemTextFieldBasedCell ()

- (ORKUnitTextField *)textField;

@property (nonatomic, readonly) ORKTextFieldView *textFieldView;
@property (nonatomic, assign) BOOL editingHighlight;

@end


@implementation ORKFormItemTextFieldBasedCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier formItem:(ORKFormItem *)formItem answer:(id)answer maxLabelWidth:(CGFloat)maxLabelWidth screenType:(ORKScreenType)screenType {
    self = [super initWithReuseIdentifier:reuseIdentifier formItem:formItem answer:answer maxLabelWidth:maxLabelWidth screenType:screenType];
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
    
    NSLayoutConstraint *contentConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    contentConstraint.priority = UILayoutPriorityDefaultHigh;
    [self addConstraint:contentConstraint];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    CGFloat labelMinWidth = self.maxLabelWidth;
    CGFloat boundWidth = self.expectedLayoutWidth;
    
    id labelLabel = self.labelLabel, textFieldView = _textFieldView;
    NSDictionary *dictionary = NSDictionaryOfVariableBindings(labelLabel,textFieldView);
    ORKEnableAutoLayoutForViews([dictionary allValues]);
    
    NSDictionary *metrics = @{@"vMargin":@(10), @"hMargin":@(self.separatorInset.left), @"hSpacer":@(16), @"vSpacer":@(15), @"labelMinWidth": @(labelMinWidth)};
    
    [self.contentView removeConstraints:self.myConstraints];
    
    self.myConstraints = [NSMutableArray new];
    
    if ((labelMinWidth) >= 0.6*boundWidth) {

        [self.myConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hMargin-[labelLabel]-hMargin-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:dictionary]];
        
        [self.myConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hMargin-[textFieldView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:dictionary]];
        
        [self.myConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vMargin-[labelLabel]-vSpacer-[textFieldView]-vMargin-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:dictionary]];
        
    } else {
        
        [self.myConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hMargin-[labelLabel(==labelMinWidth)]-hSpacer-[textFieldView]|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:dictionary]];
        
        [self.myConstraints addObject:
         [NSLayoutConstraint constraintWithItem:labelLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        
        [self.myConstraints addObject:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                      toItem:labelLabel
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1.0 constant:0.0]];
        
        [self.myConstraints addObject:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                      toItem:textFieldView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1.0 constant:0.0]];
    }
    
    CGFloat height = ORKGetMetricForScreenType(ORKScreenMetricTableCellDefaultHeight, self.screenType);
    
    NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:height];
    // Lower the priority to avoid conflicts with system supplied UIView-Encapsulated-Layout-Height constraint.
    heightConstraint.priority = 999;
    [self.myConstraints addObject:heightConstraint];
    
    [self.contentView addConstraints:self.myConstraints];
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
    const CGFloat kMinInputTextFieldPaddingRight = 6.0;
    
    // Shorten if necessary
    if (formattedWidth > textField.frame.size.width - kMinInputTextFieldPaddingRight) {
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

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.editingHighlight = NO;
    [self.delegate formItemCellDidResignFirstResponder:self];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self inputValueDidClear];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    return YES;
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement {
    return NO;
}

@end


#pragma mark - ORKFormItemTextFieldCell

@implementation ORKFormItemTextFieldCell

- (void)cellInit {
    [super cellInit];
    self.textField.keyboardType = UIKeyboardTypeDefault;
    self.textField.allowsSelection = YES;
    ORKTextAnswerFormat *answerFormat = (ORKTextAnswerFormat *)[self.formItem impliedAnswerFormat];
    self.textField.autocorrectionType = answerFormat.autocorrectionType;
    self.textField.autocapitalizationType = answerFormat.autocapitalizationType;
    self.textField.spellCheckingType = answerFormat.spellCheckingType;

    [self answerDidChange];
}

- (void)inputValueDidChange {
    NSString *text = self.textField.text;
    [self ork_setAnswer:[text length] ? text : ORKNullAnswerValue()];
    
    [super inputValueDidChange];
}

- (void)answerDidChange {
    id answer = self.answer;
    
    ORKTextAnswerFormat *answerFormat = (ORKTextAnswerFormat *)[self.formItem impliedAnswerFormat];
    if (answer != ORKNullAnswerValue()) {
        NSString *text = (NSString *)answer;
        NSInteger maxLength = answerFormat.maximumLength;
        BOOL changedValue = NO;
        if (maxLength > 0 && [text length] > maxLength) {
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

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [super textFieldDidEndEditing:textField];
    [self inputValueDidChange];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    ORKTextAnswerFormat *answerFormat = (ORKTextAnswerFormat *)[self.formItem impliedAnswerFormat];
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (answerFormat.maximumLength > 0) {
        if ([text length] > answerFormat.maximumLength) {
            return NO;
        }
    }
    
    [self ork_setAnswer:[text length] ? text : ORKNullAnswerValue()];
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

- (BOOL)isAnswerValid {
    NSString *text = self.textField.text;
    BOOL isValid = YES;
    if ([text length]) {
        isValid = [[self.formItem impliedAnswerFormat] isAnswerValidWithString:text];
    }
    return isValid;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSString *text = textField.text;
    BOOL isValid = [self isAnswerValid];
    if (! isValid) {
        [self showValidityAlertWithMessage:[[self.formItem impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:text]];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [super textFieldDidEndEditing:textField];
    
    [self inputValueDidChange];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL isValid = [self isAnswerValid];
    
    if (! isValid) {
        [self showValidityAlertWithMessage:[[self.formItem impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:textField.text]];
        return NO;
    }
    
    [self.textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self inputValueDidClear];
    
    return YES;
}

- (void)valueFieldDidChange:(UITextField *)textField {
    ORKNumericAnswerFormat *answerFormat = (ORKNumericAnswerFormat *)[self.formItem impliedAnswerFormat];
    NSString *sanitizedText = [answerFormat sanitizedTextFieldText:[textField text] decimalSeparator:[_numberFormatter decimalSeparator]];
    textField.text = sanitizedText;
    
    [self inputValueDidChange];
}

- (void)setAnswerWithText:(NSString *)text {
    BOOL updateInput = NO;
    id answer = ORKNullAnswerValue();
    if ([text length]) {
        answer = [[NSDecimalNumber alloc] initWithString:text locale:[NSLocale currentLocale]];
        if (! answer) {
            answer = ORKNullAnswerValue();
            updateInput = YES;
        }
    }
    
    [self ork_setAnswer:answer];
    if (updateInput) {
        [self answerDidChange];
    }
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
    
    {
        NSDictionary *dictionary = @{@"textView":_textView};
        ORKEnableAutoLayoutForViews([dictionary allValues]);
        NSDictionary *metrics = @{@"vMargin":@(10), @"hMargin":@(self.separatorInset.left)};

        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hMargin-[textView]-hMargin-|"
                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                 metrics:metrics
                                                   views:dictionary]];
        
        [self.contentView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vMargin-[textView]-vMargin-|"
                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                 metrics:metrics
                                                   views:dictionary]];
        
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1.0
                                                                             constant:120.0];
        heightConstraint.priority = UILayoutPriorityDefaultHigh;
        [self.contentView addConstraint:heightConstraint];
    }
}

- (void)applyAnswerFormat {
    ORKAnswerFormat *answerFormat = [self.formItem impliedAnswerFormat];
    if ([answerFormat isKindOfClass:[ORKTextAnswerFormat class]]) {
        ORKTextAnswerFormat *textAnswerFormat = (ORKTextAnswerFormat *)answerFormat;
        _maxLength = [textAnswerFormat maximumLength];
        _textView.autocorrectionType = textAnswerFormat.autocorrectionType;
        _textView.autocapitalizationType = textAnswerFormat.autocapitalizationType;
        _textView.spellCheckingType = textAnswerFormat.spellCheckingType;
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
    [self ork_setAnswer:[text length] ? text : ORKNullAnswerValue()];
    [super inputValueDidChange];
}

- (UIColor *)placeholderColor {
    return [UIColor ork_midGrayTintColor];
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    NSInteger lineCount = [[textView.text componentsSeparatedByCharactersInSet:
                         [NSCharacterSet newlineCharacterSet]] count];
    
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
    if (_maxLength > 0) {
        NSUInteger oldLength = [textView.text length];
        NSUInteger replacementLength = [text length];
        NSUInteger rangeLength = range.length;
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        return (newLength <= _maxLength);
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
    
    self.contentView.layoutMargins = UIEdgeInsetsMake(kVMargin, kHMargin, kVMargin, kHMargin);
    
    [self.contentView addSubview:_selectionView];
    
    NSDictionary *dictionary = NSDictionaryOfVariableBindings(_selectionView);
    
    ORKEnableAutoLayoutForViews([dictionary allValues]);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_selectionView]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_selectionView]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
    
    [super cellInit];
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

@implementation ORKFormItemScaleCell {
    ORKScaleSliderView *_sliderView;
    id<ORKScaleAnswerFormatProvider> _formatProvider;
}

- (id<ORKScaleAnswerFormatProvider>)formatProvider {
    if(_formatProvider == nil){
        _formatProvider = (id<ORKScaleAnswerFormatProvider>)[self.formItem.answerFormat impliedAnswerFormat];
    }
    return _formatProvider;
}

- (void)cellInit {
    self.labelLabel.text = nil;
    
    _sliderView = [[ORKScaleSliderView alloc] initWithFormatProvider:(ORKScaleAnswerFormat *)self.formItem.answerFormat];
    [_sliderView.slider addTarget:self action:@selector(inputValueDidChange) forControlEvents:UIControlEventValueChanged];
    
    [self.contentView addSubview:_sliderView];
    
    NSDictionary *dictionary = NSDictionaryOfVariableBindings(_sliderView);
    
    ORKEnableAutoLayoutForViews([dictionary allValues]);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_sliderView]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:dictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_sliderView]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:dictionary]];
    
    [super cellInit];
}

#pragma mark recover answer

- (void)answerDidChange {
    [super answerDidChange];
    
    id<ORKScaleAnswerFormatProvider> formatProvider = self.formatProvider;
    id answer = self.answer;
    if (answer && answer != ORKNullAnswerValue()) {
        if (! [self.answer isKindOfClass:[NSNumber class]]) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"Answer should be NSNumber" userInfo:nil];
        }
        
        [_sliderView setCurrentValue:answer];
    } else {
        if (answer == nil && [formatProvider defaultNumber]) {
            [_sliderView setCurrentValue:[formatProvider defaultNumber]];
        } else {
            [_sliderView setCurrentValue:nil];
        }
    }
}

- (void)inputValueDidChange {
    [self ork_setAnswer:_sliderView.currentValue];
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
    
    if (! (!formItem ||
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
