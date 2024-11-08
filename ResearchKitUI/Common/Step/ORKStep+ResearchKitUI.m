/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
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

#import <ResearchKit/ResearchKit.h>
#import "ResearchKitUI.h"
#import "ResearchKitUI_Private.h"

#import "ORKViewControllerProviding.h"

@implementation ORKCompletionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKCompletionStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKConsentReviewStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKConsentReviewStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKConsentSharingStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKConsentSharingStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKCustomStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKCustomStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKFamilyHistoryStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKFamilyHistoryStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKFormStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKFormStepViewController alloc] initWithStep:self result:result];
}

@end

#if !TARGET_OS_VISION
@implementation ORKImageCaptureStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKImageCaptureStepViewController alloc] initWithStep:self result:result];
}

@end
#endif

@implementation ORKInstructionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKInstructionStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKLearnMoreInstructionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKLearnMoreStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKLoginStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    NSAssert([self.loginViewControllerClass isSubclassOfClass:ORKLoginStepViewController.class], @"loginViewControllerClass should be subclass of ORKLoginStepViewController!");
    return [[self.loginViewControllerClass alloc] initWithStep:self result:result];
}

@end

// ORKNavigablePageStep is intentionally omitted, as it didn't have its own `stepViewControllerClass implementation`.

#if !TARGET_OS_VISION
@implementation ORKPDFViewerStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKPDFViewerStepViewController alloc] initWithStep:self result:result];
}

@end
#endif

@implementation ORKPageStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKPageStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKPasscodeStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKPasscodeStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKQuestionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKQuestionStepViewController alloc] initWithStep:self result:result];
}

@end

// ORKRegistrationStep is intentionally omitted, as it didn't have its own `stepViewControllerClass implementation`.

#if !TARGET_OS_VISION
@implementation ORKRequestPermissionsStep(ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKRequestPermissionsStepViewController alloc] initWithStep:self result:result];
}

@end
#endif

@implementation ORKReviewStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKReviewStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKSecondaryTaskStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKSecondaryTaskStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKSignatureStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKSignatureStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKTableStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKTableStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKVerificationStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    NSAssert([self.verificationViewControllerClass isSubclassOfClass:ORKVerificationStepViewController.class], @"verificationViewControllerClass should be subclass of ORKVerificationStepViewController!");
    return (ORKStepViewController *)[[self.verificationViewControllerClass alloc] initWithStep:self result:result];
}

@end

#if !TARGET_OS_VISION
@implementation ORKVideoCaptureStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKVideoCaptureStepViewController alloc] initWithStep:self result:result];
}

@end
#endif

@implementation ORKVideoInstructionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKVideoInstructionStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKWaitStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKWaitStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKWebViewStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKWebViewStepViewController alloc] initWithStep:self result:result];
}

@end
