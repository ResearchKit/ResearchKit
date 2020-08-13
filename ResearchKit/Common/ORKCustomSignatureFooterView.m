/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import "ORKCustomSignatureFooterView_Private.h"
#import "ORKSignatureView.h"
#import "ORKWebViewStep.h"
#import "ORKSignatureResult_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKTextButton.h"
#import "ORKResult_Private.h"

static const CGFloat ORKSignatureToClearPadding = 15.0;

@implementation ORKCustomSignatureFooterView {
    NSMutableArray<NSLayoutConstraint *> *_constraints;
    ORKSignatureView *_signatureView;
    ORKTextButton *_clearButton;
    UIView<ORKCustomSignatureAccessoryViewProtocol> *_customFooterView;
    UIView<ORKCustomSignatureAccessoryViewProtocol> *_customHeaderView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)configure {
    if (!_signatureView) {
        _signatureView = [[ORKSignatureView alloc] initWithoutDefaultWidth];
        [self addSubview:_signatureView];
    }
    
    if (!_clearButton) {
        _clearButton = [[ORKTextButton alloc] init];
        [_clearButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
        [_clearButton setTitle:ORKLocalizedString(@"BUTTON_CLEAR_SIGNATURE", nil) forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_clearButton];
    }
    
    if (_customViewProvider && [_customViewProvider respondsToSelector:@selector(customHeaderViewForSignatureContent)]) {
        _customHeaderView = [_customViewProvider customHeaderViewForSignatureContent];
        _customHeaderView.customViewDelegate = self;
        [self addSubview:_customHeaderView];
    }
    
    if (_customViewProvider && [_customViewProvider respondsToSelector:@selector(customFooterViewForSignatureContent)]) {
        _customFooterView = [_customViewProvider customFooterViewForSignatureContent];
        _customFooterView.customViewDelegate = self;
        [self addSubview:_customFooterView];
    }
    
    [self configureConstraints];
}

- (void)configureConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
        _constraints = nil;
    }
    
    _signatureView.translatesAutoresizingMaskIntoConstraints = NO;
    _clearButton.translatesAutoresizingMaskIntoConstraints = NO;

    _constraints = [[NSMutableArray alloc] initWithArray:@[
        [NSLayoutConstraint constraintWithItem:_signatureView
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_signatureView
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_clearButton
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_signatureView
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:ORKSignatureToClearPadding],
        [NSLayoutConstraint constraintWithItem:_clearButton
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_clearButton
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                      constant:0.0]
    ]];
    
    if (_customHeaderView) {
        _customHeaderView.translatesAutoresizingMaskIntoConstraints = NO;

        [_constraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_signatureView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_customHeaderView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:ORKSignatureToClearPadding],

            [NSLayoutConstraint constraintWithItem:_customHeaderView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:_customHeaderView
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:_customHeaderView
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:0.0]
        ]];
    } else {
        [_constraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_signatureView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:0.0]
        ]];
    }
    
    if (_customFooterView) {
        _customFooterView.translatesAutoresizingMaskIntoConstraints = NO;

        [_constraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_customFooterView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_clearButton
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:ORKSignatureToClearPadding / 2.0],

            [NSLayoutConstraint constraintWithItem:_customFooterView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:_customFooterView
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:_customFooterView
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:0.0]
        ]];
    } else {
        [_constraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_clearButton
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:0]
        ]];
    }
    
    [NSLayoutConstraint activateConstraints:_constraints];
    [self setNeedsLayout];
}

- (void)setEnabled:(BOOL)enabled {
    [_signatureView setEnabled:enabled];
}

- (void)setSignatureViewDelegate:(id<ORKSignatureViewDelegate>)signatureViewDelegate {
    _signatureViewDelegate = signatureViewDelegate;
    _signatureView.delegate = signatureViewDelegate;
}

- (void)setCustomViewProvider:(id<ORKCustomSignatureAccessoryViewProvider> _Nullable)customViewProvider {
    _customViewProvider = customViewProvider;
    [self configure];
}

- (BOOL)isComplete {
    BOOL complete = _signatureView.signatureExists;
    
    if (_customFooterView) {
        complete = complete && [_customFooterView isComplete];
    }
    
    if (_customHeaderView) {
        complete = complete && [_customHeaderView isComplete];
    }
    
    return complete;
}

- (void)updateIsComplete {
    if (self.delegate && [self.delegate respondsToSelector:@selector(signatureFooterView:didChangeCompletedStatus:)]) {
        [self.delegate signatureFooterView:self didChangeCompletedStatus:[self isComplete]];
    }
}

- (ORKSignatureResult * _Nullable)result {
    if (![self isComplete]) {
        return nil;
    }
    
    ORKSignatureResult *parentResult = [[ORKSignatureResult alloc] initWithSignatureImage:_signatureView.signatureImage signaturePath:_signatureView.signaturePath];
    if (_customHeaderView || _customFooterView) {
        NSMutableDictionary *userInfo = [parentResult.userInfo mutableCopy];
        if (!userInfo) {
            userInfo = [[NSMutableDictionary alloc] init];
        }
        [userInfo addEntriesFromDictionary: [_customHeaderView resultUserInfo]];
        [userInfo addEntriesFromDictionary: [_customFooterView resultUserInfo]];
        parentResult.userInfo = userInfo;
    }
    
    return parentResult;
}

- (void)clear {
    [_signatureView clear];
    [self updateIsComplete];
}

- (void)cancelAutoScrollTimer {
    [_signatureView cancelAutoScrollTimer];
}

// MARK: ORKCustomSignatureAccessoryViewDelegate
- (void)customViewDidChangeCompletedState:(UIView<ORKCustomSignatureAccessoryViewProtocol> *)customView {
    [self updateIsComplete];
}

- (CGRect)rectInFooterViewForRect:(CGRect)rect {
    return [_customFooterView convertRect:rect toView:self];
}

- (CGRect)rectInHeaderViewForRect:(CGRect)rect {
    return [_customHeaderView convertRect:rect toView:self];
}

@end
