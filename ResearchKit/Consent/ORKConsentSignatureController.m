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


#import "ORKConsentSignatureController.h"
#import "ORKTextButton.h"
#import "ORKSkin.h"
#import "ORKHelpers.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKNavigationContainerView_Internal.h"


@interface ORKConsentSignatureWrapperView : UIView

@property (nonatomic, strong) ORKSignatureView *signatureView;

@property (nonatomic, strong) ORKTextButton *clearButton;

@property (nonatomic, assign) BOOL clearButtonEnabled;

@end


@implementation ORKConsentSignatureWrapperView {
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    _signatureView.layoutMargins = (UIEdgeInsets){.top = ORKGetMetricForWindow(ORKScreenMetricLearnMoreBaselineToStepViewTopWithNoLearnMore, newWindow) - ABS([ORKTextButton defaultFont].descender) - 1};
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
            
            // This allows us to layout the signature view sticking up a bit past the top of the superview,
            // so drawing can extend higher
            _signatureView.layoutMargins = (UIEdgeInsets){.top=36};
            
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
    
    /*
     Using top margin here is a hack to get the drawable area of the signature view to poke up
     a bit past the top of this view. Doing anything else would be a layering violation, so...
     we do this.
     */
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_signatureView
                                                        attribute:NSLayoutAttributeTopMargin
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


@interface ORKConsentSigningView : ORKVerticalContainerView

@property (nonatomic, strong) ORKConsentSignatureWrapperView *wrapperView;

@end


@implementation ORKConsentSigningView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _wrapperView = [ORKConsentSignatureWrapperView new];
        _wrapperView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.stepView = _wrapperView;
        
        self.headerView.captionLabel.text = ORKLocalizedString(@"CONSENT_SIGNATURE_TITLE", nil);
        self.headerView.instructionLabel.text = ORKLocalizedString(@"CONSENT_SIGNATURE_INSTRUCTION", nil);
        self.continueSkipContainer.optional = NO;
        
        [self.continueSkipContainer updateContinueAndSkipEnabled];
    }
    return self;
}

@end


@interface ORKConsentSignatureController ()

@property (nonatomic, strong) ORKConsentSigningView *signingView;

@end


@implementation ORKConsentSignatureController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.localizedContinueButtonTitle = ORKLocalizedString(@"BUTTON_NEXT", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _signingView = [ORKConsentSigningView new];
    _signingView.wrapperView.signatureView.delegate = self;
    _signingView.continueSkipContainer.continueEnabled = NO;
    _signingView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _signingView.frame = self.view.bounds;
    
    [_signingView.wrapperView.clearButton addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateContinueButtonItem];
    
    [self.view addSubview:_signingView];
}

- (void)updateContinueButtonItem {
    _signingView.continueSkipContainer.continueButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.localizedContinueButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(done)];
}

- (void)setLocalizedContinueButtonTitle:(NSString *)localizedContinueButtonTitle {
    _localizedContinueButtonTitle = localizedContinueButtonTitle;
    [self updateContinueButtonItem];
}

- (ORKSignatureView *)signatureView {
    return _signingView.wrapperView.signatureView;
}

- (IBAction)done {
    if (self.delegate && [self.delegate respondsToSelector:@selector(consentSignatureControllerDidSign:)]) {
        [self.delegate consentSignatureControllerDidSign:self];
    }
}

- (void)clearAction:(id)sender {
    [_signingView.wrapperView.signatureView clear];
    _signingView.continueSkipContainer.continueEnabled = NO;
    [_signingView.wrapperView setClearButtonEnabled:NO];
}

- (void)signatureViewDidEditImage:(ORKSignatureView *)signatureView {
    _signingView.continueSkipContainer.continueEnabled = signatureView.signatureExists;
    [_signingView.wrapperView setClearButtonEnabled:YES];
}

@end
