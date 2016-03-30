/*
 Copyright (c) 2015, Oliver Schaefer.
 
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
#import "ORKConsentSigningView.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKStep_Private.h"
#import "ORKResult.h"
#import "ORKHelpers.h"


@interface ORKSignatureStepViewController () <ORKSignatureViewDelegate>

@property (nonatomic, strong) ORKConsentSigningView *signingView;

@end

@implementation ORKSignatureStepViewController {
    ORKConsentSignature* signature;
}

- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result {
    self = [super initWithStep:step];
    if (step && [self signatureStep]) {
        signature = [[ORKConsentSignature alloc] init];
        signature.requiresName = NO;
        if (result && [result isKindOfClass:[ORKStepResult class]]) {
            ORKStepResult* stepResult = (ORKStepResult *)result;
            if (stepResult.results && stepResult.results.count > 0 && [stepResult.results.firstObject isKindOfClass: [ORKConsentSignatureResult class]]) {
                ORKConsentSignatureResult* consentSignatureResult = (ORKConsentSignatureResult *)stepResult.results.firstObject;
                signature = [consentSignatureResult.signature copy];
            }
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.taskViewController setRegisteredScrollView: _signingView];
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _signingView.continueSkipContainer.continueButtonItem = continueButtonItem;
}

- (void)setLearnMoreButtonItem:(UIBarButtonItem *)learnMoreButtonItem {
    [super setLearnMoreButtonItem:learnMoreButtonItem];
    _signingView.headerView.learnMoreButtonItem = self.learnMoreButtonItem;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    _signingView.continueSkipContainer.skipButtonItem = self.skipButtonItem;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    [_signingView removeFromSuperview];
    _signingView = nil;
    
    if ([self signatureStep]) {
        _signingView = [[ORKConsentSigningView alloc] initWithFrame:self.view.bounds];
        _signingView.wrapperView.signatureView.delegate = self;
        if (signature.signatureImage) {
            _signingView.wrapperView.signatureView.existingSignatureImage = signature.signatureImage;
        }
        _signingView.continueSkipContainer.continueEnabled = _signingView.wrapperView.signatureView.signatureExists;
        _signingView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_signingView.wrapperView.clearButton addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_signingView];
        
        _signingView.headerView.captionLabel.useSurveyMode = self.step.useSurveyMode;
        _signingView.headerView.captionLabel.text = [self signatureStep].title;
        _signingView.headerView.instructionLabel.text = [self signatureStep].text;
        _signingView.headerView.learnMoreButtonItem = self.learnMoreButtonItem;
        
        _signingView.continueSkipContainer.optional = [self signatureStep].optional;
        _signingView.continueSkipContainer.skipButtonItem = self.skipButtonItem;
        _signingView.continueSkipContainer.continueEnabled = NO;
        _signingView.continueSkipContainer.continueButtonItem = self.continueButtonItem;
        
        [_signingView setNeedsLayout];
    }
}

- (ORKSignatureStep *)signatureStep {
    return [self.step isKindOfClass:[ORKSignatureStep class]] ? (ORKSignatureStep *) self.step : nil;
}

- (void)clearAction:(id)sender {
    [_signingView.wrapperView.signatureView clear];
    _signingView.continueSkipContainer.continueEnabled = NO;
    [_signingView.wrapperView setClearButtonEnabled:NO];
}

- (void)signatureViewDidEditImage:(ORKSignatureView *)signatureView {
    _signingView.continueSkipContainer.continueEnabled = signatureView.signatureExists;
    signature.signatureImage = signatureView.signatureExists ? _signingView.wrapperView.signatureView.signatureImage : nil;
    signature.signatureDate = signatureView.signatureExists ? ORKSignatureStringFromDate([NSDate date]) : nil;
    [_signingView.wrapperView setClearButtonEnabled:YES];
}

- (ORKStepResult *)result {
    ORKStepResult* parentResult = [super result];
    ORKConsentSignatureResult *result = [[ORKConsentSignatureResult alloc] init];
    result.signature = signature;
    result.identifier = signature.identifier;
    result.consented = YES;
    if (signature.signatureDate) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        NSDate* date = [dateFormatter dateFromString:signature.signatureDate];
        if (date) {
            result.startDate = date;
            result.endDate = date;
        }
    }
    parentResult.results = @[result];
    return parentResult;
}

@end
