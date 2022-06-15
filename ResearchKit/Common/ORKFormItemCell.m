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

#import "ORKCaption1Label.h"
#import "ORKFormTextView.h"
#import "ORKImageSelectionView.h"
#import "ORKLocationSelectionView.h"
#import "ORKSESSelectionView.h"
#import "ORKPicker.h"
#import "ORKScaleSliderView.h"
#import "ORKTableContainerView.h"
#import "ORKTextFieldView.h"
#import "ORKDontKnowButton.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKFormItem_Internal.h"
#import "ORKResult_Private.h"

#import "ORKAccessibility.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

@import MapKit;


static const CGFloat VerticalMargin = 10.0;
static const CGFloat StandardSpacing = 8.0;
static const CGFloat ErrorLabelTopPadding = 4.0;
static const CGFloat ErrorLabelBottomPadding = 10.0;
static const CGFloat DontKnowButtonTopBottomPadding = 16.0;
static const CGFloat DividerViewTopPadding = 10.0;
static const CGFloat InlineFormItemLabelToTextFieldPadding = 3.0;

@interface ORKFormItemCell ()

- (void)cellInit NS_REQUIRES_SUPER;
- (void)inputValueDidChange NS_REQUIRES_SUPER;
- (void)inputValueDidClear NS_REQUIRES_SUPER;
- (void)defaultAnswerDidChange NS_REQUIRES_SUPER;
- (void)answerDidChange;
- (void)cellNeedsToResize;
- (void)updateErrorLabelWithMessage:(NSString *)message;

// For use when setting the answer in response to user action
- (void)ork_setAnswer:(id)answer;

@property (nonatomic, strong) ORKCaption1Label *labelLabel;
@property (nonatomic, strong) UILabel *errorLabel;
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

@property (nonatomic, copy) UIView *containerView;
- (void)showValidityAlertWithMessage:(NSString *)text;

@end


@implementation ORKFormItemCell {
    CGFloat _leftRightMargin;
    CAShapeLayer *_contentMaskLayer;
    NSLayoutConstraint *contentViewBottomConstraint;
    NSArray<NSLayoutConstraint *> *_containerConstraints;
}

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
        [self setBackgroundColor:[UIColor clearColor]];
        _containerView = [UIView new];
        [_containerView addSubview:_labelLabel];
        [self.contentView addSubview:_containerView];
        [self setupConstraints];
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

- (void)setupConstraints {
    if (_containerConstraints) {
        [NSLayoutConstraint deactivateConstraints:_containerConstraints];
    }
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _containerConstraints = @[
        [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
        [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:_leftRightMargin],
        [NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-_leftRightMargin]
    ];
    
    contentViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    
    _containerConstraints = [_containerConstraints arrayByAddingObject:contentViewBottomConstraint];
    
    [NSLayoutConstraint activateConstraints:_containerConstraints];
}

-(void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self setMaskLayers];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setMaskLayers];
}

- (void)setMaskLayers {
    if (_useCardView) {
        if (_contentMaskLayer) {
            for (CALayer *sublayer in [_contentMaskLayer.sublayers mutableCopy]) {
                [sublayer removeFromSuperlayer];
            }
            [_contentMaskLayer removeFromSuperlayer];
            _contentMaskLayer = nil;
        }
        _contentMaskLayer = [[CAShapeLayer alloc] init];

        UIColor *fillColor;
        UIColor *borderColor;
        if (@available(iOS 13.0, *)) {
            fillColor = [UIColor secondarySystemGroupedBackgroundColor];
            borderColor = UIColor.separatorColor;
        } else {
            fillColor = [UIColor ork_borderGrayColor];
            borderColor = [UIColor ork_midGrayTintColor];
        }
        [_contentMaskLayer setFillColor:[fillColor CGColor]];
        
        CAShapeLayer *foreLayer = [CAShapeLayer layer];
        [foreLayer setFillColor:[fillColor CGColor]];
        foreLayer.zPosition = 0.0f;
        
        CAShapeLayer *lineLayer = [CAShapeLayer layer];

        if (_isLastItem || _isFirstItemInSectionWithoutTitle) {
            CGRect foreLayerBounds;
            NSUInteger rectCorners;
            if (_isLastItem && !_isFirstItemInSectionWithoutTitle) {
                rectCorners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
                foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, 0, self.containerView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, self.containerView.bounds.size.height - ORKCardDefaultBorderWidth);
            }
            else if (!_isLastItem && _isFirstItemInSectionWithoutTitle) {
                rectCorners = UIRectCornerTopLeft | UIRectCornerTopRight;
                foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, ORKCardDefaultBorderWidth, self.containerView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, self.containerView.bounds.size.height - 2 * ORKCardDefaultBorderWidth);
            }
            else {
                foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, ORKCardDefaultBorderWidth, self.containerView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, self.containerView.bounds.size.height - 2 * ORKCardDefaultBorderWidth);
                rectCorners = UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight;
            }
            
            
            _contentMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.containerView.bounds
                                                           byRoundingCorners: rectCorners
                                                                 cornerRadii: (CGSize){ORKCardDefaultCornerRadii, ORKCardDefaultCornerRadii}].CGPath;
            
            CGFloat foreLayerCornerRadii = ORKCardDefaultCornerRadii >= ORKCardDefaultBorderWidth ? ORKCardDefaultCornerRadii - ORKCardDefaultBorderWidth : ORKCardDefaultCornerRadii;
            
            foreLayer.path = [UIBezierPath bezierPathWithRoundedRect: foreLayerBounds
                                                   byRoundingCorners: rectCorners
                                                         cornerRadii: (CGSize){foreLayerCornerRadii, foreLayerCornerRadii}].CGPath;
        }
        else {
            CGRect foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, 0, self.containerView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, self.containerView.bounds.size.height);
            foreLayer.path = [UIBezierPath bezierPathWithRect:foreLayerBounds].CGPath;
            _contentMaskLayer.path = [UIBezierPath bezierPathWithRect:self.containerView.bounds].CGPath;
            CGRect lineBounds = CGRectMake(0.0, self.containerView.bounds.size.height - 1.0, self.containerView.bounds.size.width, 0.5);
            lineLayer.path = [UIBezierPath bezierPathWithRect:lineBounds].CGPath;
            lineLayer.zPosition = 0.0f;
        }
        
        [lineLayer setFillColor:[borderColor CGColor]];
        if (_cardViewStyle == ORKCardViewStyleBordered) {
            _contentMaskLayer.fillColor = borderColor.CGColor;
        }
        
        [_contentMaskLayer addSublayer:foreLayer];
        [_contentMaskLayer addSublayer:lineLayer];
        [_containerView.layer insertSublayer:_contentMaskLayer atIndex:0];
    }
}

- (void)setUseCardView:(bool)useCardView {
    _useCardView = useCardView;
    _leftRightMargin = ORKCardLeftRightMarginForWindow(self.window);
    [self setupConstraints];
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
    [super prepareForReuse];
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

- (void)cellNeedsToResize {
    UITableView *tableView = [self parentTableView];
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (void)updateErrorLabelWithMessage:(NSString *)message {
    NSString *separatorString = @":";
    NSString *stringtoParse = message ? : ORKLocalizedString(@"RANGE_ALERT_TITLE", @"");
    NSString *parsedString = [stringtoParse componentsSeparatedByString:separatorString].firstObject;
    
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
    
    [self updateConstraints];
    [self cellNeedsToResize];
}

@end


#pragma mark - ORKFormItemTextFieldBasedCell

@protocol ORKDontKnowButtonResponder <NSObject>

- (void)dontKnowButtonWasPressed;

@end

@interface ORKFormItemTextFieldBasedCell () <ORKDontKnowButtonResponder>

- (ORKUnitTextField *)textField;

@property (nonatomic, readonly) ORKTextFieldView *textFieldView;
@property (nonatomic) ORKDontKnowButton *dontKnowButton;
@property (nonatomic, assign) BOOL editingHighlight;
@property (nonatomic) BOOL doneButtonWasPressed;

@end


@implementation ORKFormItemTextFieldBasedCell {
    BOOL _shouldShowDontKnow;
    NSString *_customDontKnowString;
    UIView *_dividerView;
    UIView *_dontKnowBackgroundView;
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
        _doneButtonWasPressed = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orkDoneButtonPressed:)
                                                     name:ORKDoneButtonPressedKey
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resetDoneButton:)
                                                     name:ORKResetDoneButtonKey
                                                   object:nil];
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
    
    [self.containerView addSubview:_textFieldView];
    
    self.errorLabel = [UILabel new];
    [self.errorLabel setTextColor: [UIColor redColor]];
    [self.errorLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
    self.errorLabel.numberOfLines = 0;
    
    [self.containerView addSubview:self.errorLabel];
    
    self.labelLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.labelLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    _textFieldView.translatesAutoresizingMaskIntoConstraints = NO;
    [_textFieldView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    self.errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    _shouldShowDontKnow = NO;
    _customDontKnowString = nil;
    if ([self.formItem.answerFormat shouldShowDontKnowButton]) {
        _shouldShowDontKnow = YES;
        _customDontKnowString = self.formItem.answerFormat.customDontKnowButtonText;
        [self setupDontKnowButton];
    }
    
    [self setUpContentConstraint];
    [self setNeedsUpdateConstraints];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self setNeedsUpdateConstraints];
}

- (void)setupDontKnowButton {
    if(!_dontKnowBackgroundView) {
        _dontKnowBackgroundView = [UIView new];
        _dontKnowBackgroundView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
        [_dontKnowBackgroundView addGestureRecognizer:tapGesture1];
        _dontKnowBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    if (!_dontKnowButton) {
        _dontKnowButton = [ORKDontKnowButton new];
        _dontKnowButton.customDontKnowButtonText = self.formItem.answerFormat.customDontKnowButtonText;
        _dontKnowButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_dontKnowButton addTarget:self action:@selector(dontKnowButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_dividerView) {
        _dividerView = [UIView new];
        _dividerView.translatesAutoresizingMaskIntoConstraints = NO;
        if (@available(iOS 13.0, *)) {
            [_dividerView setBackgroundColor:[UIColor separatorColor]];
        } else {
            [_dividerView setBackgroundColor:[UIColor lightGrayColor]];
        }
    }
    
    [self.containerView addSubview:_dontKnowBackgroundView];
    [self.containerView addSubview:_dontKnowButton];
    [self.containerView addSubview:_dividerView];
    
    if (self.answer == [ORKDontKnowAnswer answer]) {
        [self dontKnowButtonWasPressed];
    }
}

- (void)dontKnowButtonWasPressed {
    if (![_dontKnowButton isDontKnowButtonActive]) {
        [_dontKnowButton setButtonActive];
        [_textFieldView.textField setText:nil];
        
        if (![_textFieldView.textField isFirstResponder]) {
            [self inputValueDidChange];
        } else {
            [self textFieldShouldClear:_textFieldView.textField];
            [_textFieldView.textField endEditing:YES];
        }
        
        if (self.errorLabel.attributedText) {
            self.errorLabel.attributedText = nil;
            [self updateConstraints];
            [self cellNeedsToResize];
        }
    }
}

- (void)tapGesture: (id)sender {
    //this tap gesture is here to avoid the cell being selected if the user missed the dont know button
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
    CGFloat labelWidth = self.maxLabelWidth;

    NSString *contentSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
    NSArray *largeSizes = @[
        UIContentSizeCategoryExtraExtraLarge,
        UIContentSizeCategoryExtraExtraExtraLarge,
        UIContentSizeCategoryAccessibilityLarge,
        UIContentSizeCategoryAccessibilityExtraLarge,
        UIContentSizeCategoryAccessibilityExtraExtraLarge,
        UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];

    if (self.labelLabel.text) {
        [[self.labelLabel.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:StandardSpacing] setActive:YES];
        [[self.labelLabel.leftAnchor constraintEqualToAnchor:self.containerView.leftAnchor constant:ORKSurveyItemMargin] setActive:YES];
    }

    if ([largeSizes containsObject:contentSize]) {
        //stack label and textfieldview when the content size is large
        if (self.labelLabel.text) {
            [[self.labelLabel.rightAnchor constraintEqualToAnchor:self.containerView.rightAnchor constant:-ORKSurveyItemMargin] setActive:YES];
        }
        [[self.textFieldView.topAnchor constraintEqualToAnchor:self.labelLabel.text ? self.labelLabel.bottomAnchor : self.containerView.topAnchor
                                                      constant:self.labelLabel.text ? StandardSpacing : ORKSurveyItemMargin] setActive:YES];
        [[self.textFieldView.leftAnchor constraintEqualToAnchor:self.containerView.leftAnchor constant:ORKSurveyItemMargin] setActive:YES];

        [[self.errorLabel.topAnchor constraintEqualToAnchor:self.textFieldView.bottomAnchor constant:ErrorLabelTopPadding] setActive:YES];
    } else {
        if (self.labelLabel.text) {
            [[self.labelLabel.widthAnchor constraintLessThanOrEqualToConstant:labelWidth] setActive:YES];
            [[self.textFieldView.centerYAnchor constraintEqualToAnchor:self.labelLabel.centerYAnchor constant:0.0] setActive:YES];
            [[self.textFieldView.leftAnchor constraintEqualToAnchor:self.labelLabel.rightAnchor constant:InlineFormItemLabelToTextFieldPadding] setActive:YES];
            [[self.errorLabel.topAnchor constraintEqualToAnchor:self.labelLabel.bottomAnchor constant:ErrorLabelTopPadding] setActive:YES];
        } else {
            [[self.textFieldView.topAnchor constraintEqualToAnchor:self.containerView.topAnchor
            constant:ORKSurveyItemMargin] setActive:YES];
            [[self.textFieldView.leftAnchor constraintEqualToAnchor:self.containerView.leftAnchor constant:ORKSurveyItemMargin] setActive:YES];
            [[self.errorLabel.topAnchor constraintEqualToAnchor:self.textFieldView.bottomAnchor constant:ErrorLabelTopPadding] setActive:YES];
        }
    }

    [[self.textFieldView.rightAnchor constraintEqualToAnchor:self.containerView.rightAnchor constant:0.0] setActive:YES];

    [[self.errorLabel.rightAnchor constraintEqualToAnchor:self.containerView.rightAnchor] setActive:YES];
    [[self.errorLabel.leftAnchor constraintEqualToAnchor:self.containerView.leftAnchor constant:ORKSurveyItemMargin] setActive:YES];

    if (_shouldShowDontKnow) {
        [[_dontKnowBackgroundView.topAnchor constraintEqualToAnchor:_dividerView.topAnchor] setActive:YES];
        [[_dontKnowBackgroundView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor] setActive:YES];
        [[_dontKnowBackgroundView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor] setActive:YES];
        [[_dontKnowBackgroundView.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor] setActive:YES];
        
        CGFloat separatorHeight = 1.0 / [UIScreen mainScreen].scale;
        [[_dividerView.topAnchor constraintEqualToAnchor:self.errorLabel.bottomAnchor constant:DividerViewTopPadding] setActive:YES];
        [[_dividerView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor] setActive:YES];
        [[_dividerView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor] setActive:YES];
        NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:_dividerView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:separatorHeight];
        constraint1.priority = UILayoutPriorityRequired - 1;
        constraint1.active = YES;
        [[_dontKnowButton.topAnchor constraintEqualToAnchor:_dividerView.bottomAnchor constant:DontKnowButtonTopBottomPadding] setActive:YES];
        [[_dontKnowButton.centerXAnchor constraintEqualToAnchor:self.containerView.centerXAnchor] setActive:YES];
        NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:self.containerView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:_dontKnowButton
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0
                                                                       constant:DontKnowButtonTopBottomPadding];
        constraint2.priority = UILayoutPriorityRequired - 1;
        constraint2.active = YES;
    } else {
        [[self.containerView.bottomAnchor constraintEqualToAnchor:self.errorLabel.bottomAnchor constant:ErrorLabelBottomPadding] setActive:YES];
    }

    [super updateConstraints];
}

- (void)setEditingHighlight:(BOOL)editingHighlight {
    _editingHighlight = editingHighlight;
    UIColor *defaultColor;
    if (@available(iOS 13.0, *)) {
        defaultColor = [UIColor labelColor];
    } else {
        defaultColor = [UIColor blackColor];
    }
    self.labelLabel.textColor = _editingHighlight ? [self tintColor] : defaultColor;
    [self textField].textColor = _editingHighlight ? [self tintColor] : defaultColor;
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
    if ([_dontKnowButton isDontKnowButtonActive]) {
        [self ork_setAnswer:[ORKDontKnowAnswer answer]];
    } else {
        [self ork_setAnswer:ORKNullAnswerValue()];
    }
    [super inputValueDidClear];
}

- (void)inputValueDidChange {
    [super inputValueDidChange];
    
    if (_dontKnowButton && [_dontKnowButton isDontKnowButtonActive] && self.answer != [ORKDontKnowAnswer answer]) {
        [self ork_setAnswer:[ORKDontKnowAnswer answer]];
        self.textField.text = @"";
    }
    
    if (self.errorLabel.attributedText != nil) {
        self.errorLabel.attributedText = nil;
        [self setupConstraints];
    }
}

- (void)removeEditingHighlight {
    self.editingHighlight = NO;
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
    
    if (_dontKnowButton && [_dontKnowButton isDontKnowButtonActive]) {
        [_dontKnowButton setButtonInactive];
        [self ork_setAnswer:ORKNullAnswerValue()];
        [self inputValueDidChange];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    BOOL wasDoneButtonPressed = _doneButtonWasPressed;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:ORKResetDoneButtonKey
     object:self];
    
    if (textField.text.length > 0 && ![[self.formItem impliedAnswerFormat] isAnswerValidWithString:textField.text]) {
        [self updateErrorLabelWithMessage:[[self.formItem impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:@""]];
        return YES;
    } else {
        self.errorLabel.attributedText = nil;
        [self updateConstraints];
        [self cellNeedsToResize];
    }
    
    if (self.delegate && wasDoneButtonPressed && ![self.delegate formItemCellShouldDismissKeyboard:self]) {
        self.editingHighlight = NO;
        [self inputValueDidChange];
        
        return NO;
    }

    return YES;
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
    if (![[self.formItem impliedAnswerFormat] isAnswerValidWithString:textField.text]) {
        [self updateErrorLabelWithMessage:[[self.formItem impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:@""]];
    } else {
        self.errorLabel.attributedText = nil;
        [self updateConstraints];
        [self cellNeedsToResize];
    }
    
    [textField resignFirstResponder];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    return YES;
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement {
    return NO;
}

#pragma mark NSNotification Methods

- (void) orkDoneButtonPressed:(NSNotification *) notification {
    if ([[notification name] isEqualToString:ORKDoneButtonPressedKey]) {
        _doneButtonWasPressed = YES;
    }
}

- (void) resetDoneButton:(NSNotification *) notification {
    if ([[notification name] isEqualToString:ORKResetDoneButtonKey]) {
        _doneButtonWasPressed = NO;
    }
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
        [self updateErrorLabelWithMessage:[[self.formItem impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:@""]];
    }
    return YES;
}

@end


#pragma mark - ORKFormItemTextFieldCell

@implementation ORKFormItemTextFieldCell {
    NSString *_defaultTextAnswer;
}

- (void)cellInit {
    [super cellInit];
    self.textField.allowsSelection = YES;
    ORKTextAnswerFormat *answerFormat = (ORKTextAnswerFormat *)[self.formItem impliedAnswerFormat];
    _defaultTextAnswer = answerFormat.defaultTextAnswer;
    self.textField.autocorrectionType = answerFormat.autocorrectionType;
    self.textField.autocapitalizationType = answerFormat.autocapitalizationType;
    self.textField.spellCheckingType = answerFormat.spellCheckingType;
    self.textField.keyboardType = answerFormat.keyboardType;
    self.textField.secureTextEntry = answerFormat.secureTextEntry;
    self.textField.textContentType = answerFormat.textContentType;
    
    if (@available(iOS 12.0, *)) {
        self.textField.passwordRules = answerFormat.passwordRules;
    }
    
    [self answerDidChange];
}

- (void)inputValueDidChange {
    NSString *text = self.textField.text;
    [self ork_setAnswer:text.length ? text : ORKNullAnswerValue()];
    
    [super inputValueDidChange];
}

- (void)assignDefaultAnswer {
    if (_defaultTextAnswer) {
        [self ork_setAnswer:_defaultTextAnswer];
        if (self.textField) {
            self.textField.text = _defaultTextAnswer;
        }
    }
}

- (void)answerDidChange {
    id answer = self.answer;
    
    ORKTextAnswerFormat *answerFormat = (ORKTextAnswerFormat *)[self.formItem impliedAnswerFormat];
    if (answer == [ORKDontKnowAnswer answer]) {
        [self.dontKnowButton setButtonActive];
        self.textField.text = nil;
    } else if (answer != ORKNullAnswerValue()) {
        if (!answer) {
            [self assignDefaultAnswer];
        }
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
            [self updateErrorLabelWithMessage:[[self.formItem impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:@""]];
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
    NSNumber *_defaultNumericAnswer;
}

- (void)cellInit {
    [super cellInit];
    ORKQuestionType questionType = [self.formItem questionType];
    self.textField.keyboardType = (questionType == ORKQuestionTypeInteger) ? UIKeyboardTypeNumberPad : UIKeyboardTypeDecimalPad;
    [self.textField addTarget:self action:@selector(valueFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.textField.allowsSelection = YES;
    
    ORKNumericAnswerFormat *answerFormat = (ORKNumericAnswerFormat *)[self.formItem impliedAnswerFormat];
    _defaultNumericAnswer = answerFormat.defaultNumericAnswer;
    
    self.textField.manageUnitAndPlaceholder = YES;
    self.textField.unit = answerFormat.unit;
    self.textField.placeholder = self.formItem.placeholder;
    
    _numberFormatter = ORKDecimalNumberFormatter();
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChange:) name:NSCurrentLocaleDidChangeNotification object:nil];
    
    [self answerDidChange];

}

- (void) assignDefaultAnswer {
    if (_defaultNumericAnswer) {
        [self ork_setAnswer:_defaultNumericAnswer];
        if (self.textField) {
            self.textField.text = [_numberFormatter stringFromNumber:_defaultNumericAnswer];
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

- (void)inputValueDidChange {
    
    NSString *text = self.textField.text;
    [self setAnswerWithText:text];
    
    [super inputValueDidChange];
}

- (void)answerDidChange {
    id answer = self.answer;
    if (answer == [ORKDontKnowAnswer answer]) {
        [self.dontKnowButton setButtonActive];
        self.textField.text = nil;
    } else if (answer != ORKNullAnswerValue()) {
        if (!answer) {
            [self assignDefaultAnswer];
        }
        else {
            NSString *displayValue = answer;
            if ([answer isKindOfClass:[NSNumber class]]) {
                displayValue = [_numberFormatter stringFromNumber:answer];
            }
            self.textField.text = displayValue;
        }
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
    NSString *_defaultTextAnswer;
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
    _textView.placeholder = self.formItem.placeholder;
    
    [self applyAnswerFormat];
    [self answerDidChange];
    
    [self.containerView addSubview:_textView];
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
        _defaultTextAnswer = textAnswerFormat.defaultTextAnswer;
        _maxLength = [textAnswerFormat maximumLength];
        _textView.autocorrectionType = textAnswerFormat.autocorrectionType;
        _textView.autocapitalizationType = textAnswerFormat.autocapitalizationType;
        _textView.spellCheckingType = textAnswerFormat.spellCheckingType;
        _textView.keyboardType = textAnswerFormat.keyboardType;
        _textView.secureTextEntry = textAnswerFormat.secureTextEntry;
        _textView.textContentType = textAnswerFormat.textContentType;
        
        if (@available(iOS 12.0, *)) {
            _textView.passwordRules = textAnswerFormat.passwordRules;
        }
    } else {
        _maxLength = 0;
    }
}

- (void)setFormItem:(ORKFormItem *)formItem {
    [super setFormItem:formItem];
    [self applyAnswerFormat];
}

- (void)assignDefaultAnswer {
    if (_defaultTextAnswer) {
        [self ork_setAnswer:_defaultTextAnswer];
        if (_textView) {
            _textView.text = _defaultTextAnswer;
        }
    }
}

- (void)answerDidChange {
    id answer = self.answer;
    if (answer == ORKNullAnswerValue()) {
        answer = nil;
    }
    _textView.text = (NSString *)answer;
    [self assignDefaultAnswer];
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
        if (@available(iOS 13.0, *)) {
            textView.textColor = [UIColor labelColor];
        } else {
            textView.textColor = [UIColor blackColor];
        }
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
    
    self.contentView.layoutMargins = UIEdgeInsetsMake(VerticalMargin, ORKSurveyItemMargin, VerticalMargin, ORKSurveyItemMargin);
    
    [self.containerView addSubview:_selectionView];
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
    
    [self.containerView addSubview:_sliderView];
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
          [answerFormat isKindOfClass:[ORKValuePickerAnswerFormat class]] ||
          [answerFormat isKindOfClass:[ORKMultipleValuePickerAnswerFormat class]] ||
          [answerFormat isKindOfClass:[ORKHeightAnswerFormat class]] ||
          [answerFormat isKindOfClass:[ORKWeightAnswerFormat class]])) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"formItem.answerFormat should be an ORKDateAnswerFormat, ORKTimeOfDayAnswerFormat, ORKTimeIntervalAnswerFormat, ORKValuePicker, ORKMultipleValuePickerAnswerFormat, ORKHeightAnswerFormat, or ORKWeightAnswerFormat instance" userInfo:nil];
    }
    [super setFormItem:formItem];
}

- (void)setDefaultAnswer:(id)defaultAnswer {
    ORK_Log_Debug("%@", defaultAnswer);
    [super setDefaultAnswer:defaultAnswer];
}

- (void)answerDidChange {
    
    self.picker.answer = (self.answer == [ORKDontKnowAnswer answer]) ? nil : self.answer;
    self.textField.text = self.picker.selectedLabelText;
}

- (id<ORKPicker>)picker {
    if (_picker == nil) {
        ORKAnswerFormat *answerFormat = [self.formItem impliedAnswerFormat];
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    BOOL shouldEndEditing = [super textFieldShouldEndEditing:textField];
    
    [self inputValueDidChange];
    
    return shouldEndEditing;
}

- (void)dontKnowButtonWasPressed
{
    [super dontKnowButtonWasPressed];
    
    [self.textFieldView.textField setText:nil];
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
    
    [self.containerView addSubview:_selectionView];

    if (self.formItem.placeholder != nil) {
        [_selectionView setPlaceholderText:self.formItem.placeholder];
    }
    
    [self setUpConstraints];
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *dictionary = @{@"_selectionView":_selectionView};
    ORKEnableAutoLayoutForViews([dictionary allValues]);
    NSDictionary *metrics = @{@"verticalMargin":@(VerticalMargin), @"horizontalMargin":@(ORKSurveyItemMargin), @"verticalMarginBottom":@(VerticalMargin - (1.0 / [UIScreen mainScreen].scale))};
    
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
    if (_editingHighlight) {
        [_selectionView setTextColor:[self tintColor]];
    } else {
        if (@available(iOS 13.0, *)) {
            [_selectionView setTextColor:[UIColor labelColor]];
        } else {
            [_selectionView setTextColor:[UIColor blackColor]];
        }
    }
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
    _heightConstraint.constant = _selectionView.intrinsicContentSize.height;
    _bottomConstraint.constant = -(VerticalMargin - (1.0 / [UIScreen mainScreen].scale));
    
    [self cellNeedsToResize];
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
    BOOL didResign = [super resignFirstResponder];
    didResign = [_selectionView resignFirstResponder] || didResign;
    return didResign;
}

@end


@interface ORKFormItemSESCell()<ORKSESSelectionViewDelegate>

@end

@implementation ORKFormItemSESCell {
    ORKSESSelectionView *_selectionView;
    NSLayoutConstraint *_heightConstraint;
    NSLayoutConstraint *_bottomConstraint;
}

- (void)cellInit {
    [super cellInit];
    
    _selectionView = [[ORKSESSelectionView alloc] initWithAnswerFormat:(ORKSESAnswerFormat *)self.formItem.answerFormat answer:self.answer];
    _selectionView.delegate = self;
    [self.containerView addSubview:_selectionView];
    
    [self setUpConstraints];
}

- (void)setUpConstraints {
    
    NSMutableArray *constraints = [NSMutableArray new];

    NSDictionary *dictionary = @{@"_selectionView":_selectionView};
    ORKEnableAutoLayoutForViews([dictionary allValues]);

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_selectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_selectionView]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
    _bottomConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_selectionView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0];
    _heightConstraint = [NSLayoutConstraint constraintWithItem:_selectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_selectionView.intrinsicContentSize.height];
    _heightConstraint.priority = UILayoutPriorityDefaultHigh;
    [constraints addObject:_heightConstraint];
    [constraints addObject:_bottomConstraint];

    [self.contentView addConstraints:constraints];
}

- (void)buttonPressedAtIndex:(NSInteger)index {
    _selectionView.answer = [NSNumber numberWithInteger:index];
    [self inputValueDidChange];
}

- (void)inputValueDidChange {
    [self ork_setAnswer:_selectionView.answer];
    [super inputValueDidChange];
}

@end
