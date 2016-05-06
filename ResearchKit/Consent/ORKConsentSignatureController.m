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
#import "ORKConsentSignatureView.h"


@interface ORKConsentSignatureController ()

@property (nonatomic, strong) ORKConsentSignatureView *consentSignatureView;

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
    
    _consentSignatureView = [ORKConsentSignatureView new];
    _consentSignatureView.wrapperView.signatureView.delegate = self;
    _consentSignatureView.continueSkipContainer.continueEnabled = NO;
    _consentSignatureView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _consentSignatureView.frame = self.view.bounds;
    
    [_consentSignatureView.wrapperView.clearButton addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateContinueButtonItem];
    
    [self.view addSubview:_consentSignatureView];
}

- (void)updateContinueButtonItem {
    _consentSignatureView.continueSkipContainer.continueButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.localizedContinueButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(done)];
}

- (void)setLocalizedContinueButtonTitle:(NSString *)localizedContinueButtonTitle {
    _localizedContinueButtonTitle = localizedContinueButtonTitle;
    [self updateContinueButtonItem];
}

- (ORKSignatureView *)signatureView {
    return _consentSignatureView.wrapperView.signatureView;
}

- (IBAction)done {
    if (self.delegate && [self.delegate respondsToSelector:@selector(consentSignatureControllerDidSign:)]) {
        [self.delegate consentSignatureControllerDidSign:self];
    }
}

- (void)clearAction:(id)sender {
    [_consentSignatureView.wrapperView.signatureView clear];
    _consentSignatureView.continueSkipContainer.continueEnabled = NO;
    [_consentSignatureView.wrapperView setClearButtonEnabled:NO];
}

- (void)signatureViewDidEditImage:(ORKSignatureView *)signatureView {
    _consentSignatureView.continueSkipContainer.continueEnabled = signatureView.signatureExists;
    [_consentSignatureView.wrapperView setClearButtonEnabled:YES];
}

@end
