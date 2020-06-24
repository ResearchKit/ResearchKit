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


#import "ORKSignatureStepViewController.h"

#import "ORKSignatureView.h"

#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKStepContainerView_Private.h"
#import "ORKStepView_Private.h"

#import "ORKResult_Private.h"
#import "ORKCollectionResult_Private.h"
#import "ORKSignatureResult_Private.h"
#import "ORKStep.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


@interface ORKSignatureWrapperView : UIView

@property (nonatomic, strong) ORKSignatureView *signatureView;

@property (nonatomic, strong) ORKTextButton *clearButton;

@property (nonatomic, assign) BOOL clearButtonEnabled;

@end


@implementation ORKSignatureWrapperView

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self setNeedsLayout];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        {
            _clearButton = [ORKTextButton new];
            _clearButton.contentEdgeInsets = (UIEdgeInsets){12,10,8,10}; // insets adjusted to get correct vertical height from bottom of screen when aligned to margin
            _clearButton.exclusiveTouch = YES;
            [_clearButton setTitle:ORKLocalizedString(@"BUTTON_CLEAR", nil) forState:UIControlStateNormal];
            _clearButton.translatesAutoresizingMaskIntoConstraints = NO;
            _clearButton.alpha = 0;
            [self addSubview:_clearButton];
        }
        
        {
            _signatureView = [ORKSignatureView new];
            [_signatureView setClipsToBounds:YES];
            
            _signatureView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:_signatureView];
        }
        
        [self setUpConstraints];
    }
    return self;
}

- (void)updateLayoutMargins {
    CGFloat margin = ORKStandardHorizontalMarginForView(self);
    self.layoutMargins = (UIEdgeInsets){.left = margin, .right = margin };
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updateLayoutMargins];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateLayoutMargins];
}

- (void)setClearButtonEnabled:(BOOL)clearButtonEnabled {
    _clearButtonEnabled = clearButtonEnabled;
    
    if (clearButtonEnabled) {
        NSTimeInterval duration = (UIAccessibilityIsVoiceOverRunning() ? 0 : 0.2);
        [UIView animateWithDuration:duration delay:0 options:(UIViewAnimationOptions)UIViewAnimationOptionBeginFromCurrentState animations:^{
            _clearButton.alpha = 1;
        } completion:^(BOOL finished) {
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
        }];
    } else {
        _clearButton.alpha = 0;
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, _signatureView);
    }
}

- (void)setUpConstraints {
    // Static constraints
    NSMutableArray *constraints = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_clearButton, _signatureView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_signatureView]-(>=0)-[_clearButton]|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_signatureView
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_clearButton]-(>=0)-|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_signatureView
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_clearButton
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_clearButton
                                                        attribute:NSLayoutAttributeBaseline
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_signatureView
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:30.0]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

@end


@interface ORKConsentSigningView : ORKStepContainerView

@property (nonatomic, strong) ORKSignatureWrapperView *wrapperView;

@end


@implementation ORKConsentSigningView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupWrapperView];
    }
    return self;
}

- (void)setupWrapperView {
    _wrapperView = [ORKSignatureWrapperView new];
    _wrapperView.translatesAutoresizingMaskIntoConstraints = NO;
    self.customContentView = _wrapperView;
}

@end


@interface ORKSignatureStepViewController () <ORKSignatureViewDelegate>

@property (nonatomic, strong, readonly, nullable) ORKSignatureView *signatureView;
@property (nonatomic, strong) ORKConsentSigningView *signingView;
@property (nonatomic, strong) NSArray <UIBezierPath *> *originalPath;

@end


@implementation ORKSignatureStepViewController {
    NSArray<NSLayoutConstraint *> *_constraints;
}

- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result {
    self = [super initWithStep:step result:result];
    if (self && step) {
        if ([result isKindOfClass:[ORKStepResult class]]) {
            [[(ORKStepResult *)result results] enumerateObjectsUsingBlock:^(ORKResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[ORKSignatureResult class]]) {
                    _originalPath = [(ORKSignatureResult*)obj signaturePath];
                    *stop = YES;
                }
            }];

        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // set the original path and update state
    self.signatureView.signaturePath = self.originalPath;
    [self updateButtonStates];
}

- (ORKStepResult *)result {
    ORKStepResult *parentResult = [super result];
    
    if (self.signatureView.signatureExists) {
        ORKSignatureResult *sigResult = [[ORKSignatureResult alloc] initWithSignatureImage:self.signatureView.signatureImage
                                                                             signaturePath:self.signatureView.signaturePath];
        parentResult.results = @[sigResult];
    }
    
    return parentResult;
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _navigationFooterView.continueButtonItem = continueButtonItem;
    [self updateButtonStates];
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    _navigationFooterView.skipButtonItem = skipButtonItem;
    [self updateButtonStates];
}

- (void)updateButtonStates {
    BOOL hasSigned = self.signatureView.signatureExists;
    _navigationFooterView.continueEnabled = hasSigned;
    _navigationFooterView.optional = self.step.optional;
    [_signingView.wrapperView setClearButtonEnabled:hasSigned];
}

- (void)stepDidChange {
    [super stepDidChange];
    
    [_signingView removeFromSuperview];
    _signingView.wrapperView.signatureView.delegate = nil;
    
    _signingView = [ORKConsentSigningView new];
    [_signingView placeNavigationContainerInsideScrollView];
    _signingView.wrapperView.signatureView.delegate = self;
    _signingView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _signingView.frame = self.view.bounds;
    _signingView.stepTitle = self.step.title;
    _signingView.stepText = self.step.text;
    _signingView.stepDetailText = self.step.detailText;
    _signingView.stepHeaderTextAlignment = self.step.headerTextAlignment;
    _signingView.stepTopContentImage = self.step.image;
    _signingView.stepTopContentImageContentMode = self.step.imageContentMode;
    _signingView.bodyItems = self.step.bodyItems;
    [self setupNavigationFooterView];

    [self updateButtonStates];
    
    [_signingView.wrapperView.clearButton addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_signingView];
    [self setupConstraints];
}

- (void)setupNavigationFooterView {
    if (!_navigationFooterView && _signingView) {
        _navigationFooterView = _signingView.navigationFooterView;
    }
    _navigationFooterView.skipButtonItem = self.skipButtonItem;
    _navigationFooterView.continueButtonItem = self.continueButtonItem;
    
    _navigationFooterView.optional = NO;
    [_navigationFooterView updateContinueAndSkipEnabled];
}

- (void)setupConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    _constraints = nil;
    _signingView.translatesAutoresizingMaskIntoConstraints = NO;
    _constraints = @[
                     [NSLayoutConstraint constraintWithItem:_signingView
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_signingView
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_signingView
                                                  attribute:NSLayoutAttributeRight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_signingView
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0
                                                   constant:0.0]
                     ];
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (ORKSignatureView *)signatureView {
    return _signingView.wrapperView.signatureView;
}

- (void)clearAction:(id)sender {
    [_signingView.wrapperView.signatureView clear];
    [self updateButtonStates];
    [self notifyDelegateOnResultChange];
}

- (void)signatureViewDidEditImage:(ORKSignatureView *)signatureView {
    [self updateButtonStates];
    [self notifyDelegateOnResultChange];
}

@end
