/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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


#import "ORKPDFViewerStepViewController.h"

#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepHeaderView_Internal.h"

#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"

#import "ORKPDFViewerStep.h"
#import "ORKPDFViewerStepView_Internal.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

@interface ORKPDFViewerStepViewController() <ORKPDFViewerStepViewDelegate>

@end

@implementation ORKPDFViewerStepViewController {
    NSArray<NSLayoutConstraint *> *_constraints;
    ORKPDFViewerStepView *_pdfView;
    ORKNavigationContainerView *_navigationFooterView;
    
    NSString *_newFilename;
}

- (ORKPDFViewerStep *)pdfViewerStep {
    return (ORKPDFViewerStep *)self.step;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    [_pdfView removeFromSuperview];
    _pdfView = nil;
    
    if (self.step && [self isViewLoaded]) {
        _pdfView = [ORKPDFViewerStepView new];
        [self hidePDFViewerButtons];
        _pdfView.delegate = self;
        [self.view addSubview:_pdfView];
        [self setNavigationFooterView];
        [self setupConstraints];
    }
}

- (void)hidePDFViewerButtons {
    ORKPDFViewerStep *pdfStep = [self pdfViewerStep];
    
    _pdfView.hideThumbnailButton = ((pdfStep.actionBarOption & ORKPDFViewerActionBarOptionExcludeThumbnail) == ORKPDFViewerActionBarOptionExcludeThumbnail);
    _pdfView.hideAnnotationButton = ((pdfStep.actionBarOption & ORKPDFViewerActionBarOptionExcludeAnnotation) == ORKPDFViewerActionBarOptionExcludeAnnotation);
    _pdfView.hideSearchButton = ((pdfStep.actionBarOption & ORKPDFViewerActionBarOptionExcludeSearch) == ORKPDFViewerActionBarOptionExcludeSearch);
    _pdfView.hideShareButton = ((pdfStep.actionBarOption & ORKPDFViewerActionBarOptionExcludeShare) == ORKPDFViewerActionBarOptionExcludeShare);
}

- (void)setNavigationFooterView {
    if (!_navigationFooterView) {
        _navigationFooterView = [ORKNavigationContainerView new];
    }
    _navigationFooterView.continueButtonItem = self.continueButtonItem;
    _navigationFooterView.continueEnabled = YES;
    _navigationFooterView.cancelButtonItem = self.cancelButtonItem;
    _navigationFooterView.hidden = self.isBeingReviewed;
    [_navigationFooterView updateContinueAndSkipEnabled];
    [self.view addSubview:_navigationFooterView];
}

- (void)setupConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    _pdfView.translatesAutoresizingMaskIntoConstraints = NO;
    _navigationFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    _constraints = nil;

    UIView *viewForiPad = [self viewForiPadLayoutConstraints];

    _constraints = @[
                     [NSLayoutConstraint constraintWithItem:_pdfView
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:viewForiPad ? : self.view.safeAreaLayoutGuide
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_pdfView
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:viewForiPad ? : self.view.safeAreaLayoutGuide
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_pdfView
                                                  attribute:NSLayoutAttributeRight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:viewForiPad ? : self.view.safeAreaLayoutGuide
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:viewForiPad ? : self.view
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:viewForiPad ? : self.view
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                                  attribute:NSLayoutAttributeRight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:viewForiPad ? : self.view
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_pdfView
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:_navigationFooterView
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0.0]
                     ];
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self stepDidChange];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_pdfView) {
        _pdfView.pdfURL = [self pdfViewerStep].pdfURL;
    }
}

- (void)createNewPDFFile {
    NSURL *fileURL = [self.outputDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", _newFilename]];
    NSData *pdfData = [[_pdfView getDocument] dataRepresentation];
    [[NSFileManager defaultManager] createFileAtPath:[fileURL path] contents:pdfData attributes:nil];
}


- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    if ([_pdfView pdfModified]) {
        if (!_newFilename) {
            _newFilename = [[NSUUID UUID] UUIDString];
            [self createNewPDFFile];
        }
        NSURL *fileURL = [self.outputDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", _newFilename]];
        
        NSDate *now = stepResult.endDate;
    
        NSMutableArray *results = [NSMutableArray arrayWithArray:stepResult.results];
        ORKFileResult *fileResult = [[ORKFileResult alloc] initWithIdentifier:self.step.identifier];
        fileResult.startDate = stepResult.startDate;
        fileResult.endDate = now;
        fileResult.contentType = @"document/pdf";
        fileResult.fileURL = fileURL;
        [results addObject:fileResult];
        stepResult.results = [results copy];
    }
    return stepResult;
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _navigationFooterView.continueButtonItem = continueButtonItem;
}

- (void)setCancelButtonItem:(UIBarButtonItem *)cancelButtonItem {
    [super setCancelButtonItem:cancelButtonItem];
    _navigationFooterView.cancelButtonItem = cancelButtonItem;
}

#pragma mark ORKPDFViewerStepViewDelegate

- (void)didSelectShareButton:(id)sender {
    NSData *pdfData = [[_pdfView getDocument] dataRepresentation];

    UIActivityViewController * activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"sendPDF", pdfData] applicationActivities:nil];
    [activityViewController setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        [_pdfView updateShareButton];
    }];
    
    if ( [activityViewController respondsToSelector:@selector(popoverPresentationController)] ) {
        activityViewController.popoverPresentationController.sourceView = sender;
        UIView *shareButtonView = (UIView *)sender;
        activityViewController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(shareButtonView.bounds), CGRectGetMidY(shareButtonView.bounds),0,0);

    }
    [self presentViewController:activityViewController animated:YES completion:nil];
}


@end
