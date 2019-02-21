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

@import PDFKit;
#import "ORKPDFViewerStepView_Internal.h"
#import "ORKFreehandDrawingView.h"
#import "ORKHelpers_Internal.h"
#import "ORKBorderedButton.h"
#import "ORKSkin.h"

const CGFloat PDFSearchBarHeight = 40.0;
const CGFloat PDFActionViewHeight = 25.0;
const CGFloat PDFActionItemPadding = 1.0;
const CGFloat PDFThumbnailViewWidth = 60.0;
const CGFloat PDFActionsViewLeftRightPadding = 20.0;
const CGFloat PDFParentStackViewSpacing = 10.0;
const CGFloat PDFInactiveButtonAlpha = 0.5;

const CGFloat PDFhideViewAnimationDuration = 0.5;

@interface ORKPDFViewerActionsView: UIView
    
@property (nonatomic, nonnull) UIView *thumbnailActionView;
@property (nonatomic, nonnull) UIView *annotationActionView;
@property (nonatomic, nonnull) UIView *searchActionView;
@property (nonatomic, nonnull) UIView *shareActionView;
@property (nonatomic, nonnull) UIView *clearButtonView;
@property (nonatomic, nonnull) UIView *applyButtonView;
@property (nonatomic, nonnull) UIView *exitButtonView;

@property (nonatomic, nonnull) UIStackView *stackView;

@property (nonatomic, nonnull) UIButton *thumbnailActionButton;
@property (nonatomic, nonnull) UIButton *annotationActionButton;
@property (nonatomic, nonnull) UIButton *searchActionButton;
@property (nonatomic, nonnull) UIButton *shareActionButton;
@property (nonatomic, nonnull) ORKBorderedButton *clearAnnotationsButton;
@property (nonatomic, nonnull) ORKBorderedButton *applyAnnotationsButton;
@property (nonatomic, nonnull) UIButton *exitAnnotationsButton;



@end

@implementation ORKPDFViewerActionsView

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    [self setupStackView];
    [self setupConstraints];
    return self;
}

- (void)setupStackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc] init];
    }
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    _stackView.spacing = 0.0;
    _stackView.layoutMargins = UIEdgeInsetsMake(0.0, PDFActionsViewLeftRightPadding, 0.0, PDFActionsViewLeftRightPadding);
    [_stackView setLayoutMarginsRelativeArrangement:YES];
    _stackView.axis = UILayoutConstraintAxisHorizontal;
    _stackView.distribution = UIStackViewDistributionFillEqually;
    [self setupThumbnailAction];
    [self setupAnnotationAction];
    [self setupSearchAction];
    [self setupShareAction];
    [self setupClearAnnotationsButton];
    [self setupApplyAnnotationsButton];
    [self setupExitAnnotationsButton];
    [self addSubview:_stackView];
}

- (void)setupThumbnailAction {
    if (!_thumbnailActionButton) {
        _thumbnailActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    
    [_thumbnailActionButton setImage:[[UIImage imageNamed:@"pdfThumbnail" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _thumbnailActionView = [UIView new];
    _thumbnailActionView.translatesAutoresizingMaskIntoConstraints = NO;
    _thumbnailActionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_thumbnailActionView addSubview:_thumbnailActionButton];
    [_stackView insertArrangedSubview:_thumbnailActionView atIndex:0];
    [self activateConstraintsForButton:_thumbnailActionButton withView:_thumbnailActionView];
}

- (void)setupAnnotationAction {
    if (!_annotationActionButton) {
        _annotationActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    
    [_annotationActionButton setImage:[[UIImage imageNamed:@"annotation" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _annotationActionView = [UIView new];
    _annotationActionView.translatesAutoresizingMaskIntoConstraints = NO;
    _annotationActionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_annotationActionView addSubview:_annotationActionButton];
    [_stackView addArrangedSubview:_annotationActionView];
    [self activateConstraintsForButton:_annotationActionButton withView:_annotationActionView];
}

- (void)setupSearchAction {
    if (!_searchActionButton) {
        _searchActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    
    [_searchActionButton setImage:[[UIImage imageNamed:@"search" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _searchActionView = [UIView new];
    _searchActionView.translatesAutoresizingMaskIntoConstraints = NO;
    _searchActionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchActionView addSubview:_searchActionButton];
    [_stackView addArrangedSubview:_searchActionView];
    [self activateConstraintsForButton:_searchActionButton withView:_searchActionView];
}

- (void)setupShareAction {
    if (!_shareActionButton) {
        _shareActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    
    [_shareActionButton setImage:[[UIImage imageNamed:@"share" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _shareActionView = [UIView new];
    _shareActionView.translatesAutoresizingMaskIntoConstraints = NO;
    _shareActionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_shareActionView addSubview:_shareActionButton];
    [_stackView addArrangedSubview:_shareActionView];
    [self activateConstraintsForButton:_shareActionButton withView:_shareActionView];
}

- (void)setupClearAnnotationsButton {
    if (!_clearAnnotationsButton) {
        _clearAnnotationsButton = [ORKBorderedButton new];
    }
    _clearAnnotationsButton.contentEdgeInsets = (UIEdgeInsets){.left = 6, .right = 6};
    _clearAnnotationsButton.translatesAutoresizingMaskIntoConstraints = NO;
    _clearButtonView = [UIView new];
    _clearButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    [_clearAnnotationsButton setTitle:ORKLocalizedString(@"BUTTON_CLEAR", nil) forState:UIControlStateNormal];
    [_clearButtonView addSubview:_clearAnnotationsButton];
    [_stackView addArrangedSubview:_clearButtonView];
    [NSLayoutConstraint activateConstraints:@[
                                              [NSLayoutConstraint constraintWithItem:_clearAnnotationsButton
                                                                           attribute:NSLayoutAttributeCenterX
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_clearButtonView
                                                                           attribute:NSLayoutAttributeCenterX
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:_clearAnnotationsButton
                                                                           attribute:NSLayoutAttributeCenterY
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_clearButtonView
                                                                           attribute:NSLayoutAttributeCenterY
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:_clearAnnotationsButton
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_clearButtonView
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:1.0
                                                                            constant:0.0]
                                              ]];
}

- (void)setupApplyAnnotationsButton {
    if (!_applyAnnotationsButton) {
        _applyAnnotationsButton = [ORKBorderedButton new];
    }
    _applyAnnotationsButton.contentEdgeInsets = (UIEdgeInsets){.left = 6, .right = 6};
    _applyAnnotationsButton.translatesAutoresizingMaskIntoConstraints = NO;
    _applyButtonView = [UIView new];
    _applyButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    [_applyAnnotationsButton setTitle:ORKLocalizedString(@"BUTTON_APPLY", nil) forState:UIControlStateNormal];
    [_applyButtonView addSubview:_applyAnnotationsButton];
    [_stackView addArrangedSubview:_applyButtonView];
    [NSLayoutConstraint activateConstraints:@[
                                              [NSLayoutConstraint constraintWithItem:_applyAnnotationsButton
                                                                           attribute:NSLayoutAttributeCenterX
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_applyButtonView
                                                                           attribute:NSLayoutAttributeCenterX
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:_applyAnnotationsButton
                                                                           attribute:NSLayoutAttributeCenterY
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_applyButtonView
                                                                           attribute:NSLayoutAttributeCenterY
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:_applyAnnotationsButton
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_applyButtonView
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:1.0
                                                                            constant:0.0]
                                              ]];}

- (void)setupExitAnnotationsButton {
    if (!_exitAnnotationsButton) {
        _exitAnnotationsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    }
    [_exitAnnotationsButton setTitle:@"X" forState:UIControlStateNormal];
    [_exitAnnotationsButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [_exitAnnotationsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
    _exitAnnotationsButton.translatesAutoresizingMaskIntoConstraints = NO;
    _exitButtonView = [UIView new];
    _exitButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    [_exitButtonView addSubview:_exitAnnotationsButton];
    [_stackView addArrangedSubview:_exitButtonView];
    [self activateConstraintsForButton:_exitAnnotationsButton withView:_exitButtonView];
    [self setExitAnnotationsButtonStyle];
}

- (void)activateConstraintsForButton:(UIButton *)button withView:(UIView *)view {
    [NSLayoutConstraint activateConstraints:@[
                                              [NSLayoutConstraint constraintWithItem:button
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:PDFActionViewHeight],
                                              [NSLayoutConstraint constraintWithItem:button
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:PDFActionViewHeight],
                                              [NSLayoutConstraint constraintWithItem:button
                                                                           attribute:NSLayoutAttributeCenterX
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:view
                                                                           attribute:NSLayoutAttributeCenterX
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:button
                                                                           attribute:NSLayoutAttributeCenterY
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:view
                                                                           attribute:NSLayoutAttributeCenterY
                                                                          multiplier:1.0
                                                                            constant:0.0]]];
}

- (void)setExitAnnotationsButtonStyle {
    [_exitAnnotationsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_exitAnnotationsButton setBackgroundColor:[[self tintColor] colorWithAlphaComponent:PDFInactiveButtonAlpha]];

    [_exitAnnotationsButton.layer setCornerRadius:PDFActionViewHeight/2.0];
}

- (void)setupConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_stackView);
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_stackView]|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_stackView]|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    [NSLayoutConstraint activateConstraints:constraints];
}



@end

@interface ORKPDFViewerStepView () <UISearchBarDelegate, PDFDocumentDelegate, ORKFreehandDrawingViewDelegate>

@end

@implementation ORKPDFViewerStepView {
    
    UIStackView *_parentStackView, *_pdfStackView;
    UISearchBar *_searchBar;
    ORKPDFViewerActionsView *_pdfActionsView;

    PDFView *_pdfView;
    PDFThumbnailView *_pdfThumbnailView;
    ORKFreehandDrawingView *_freehandDrawingView;
    
    BOOL _isFreehandDrawingActive;
    BOOL _isShareActive;
    BOOL _annotationsAdded;
    UIView *_keyboardUnderlapView;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupParentStackView];
        [self setupSearchBar];
        [self setupPDFActionsView];
        [self setupPDFStackView];
        [self setupKeyboardUnderlapView];
        [self setupConstraints];

    }
    return self;
}

- (void)setupParentStackView {
    if (!_parentStackView) {
        _parentStackView = [[UIStackView alloc] init];
    }
    _parentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    _parentStackView.spacing = PDFParentStackViewSpacing;
    _parentStackView.axis = UILayoutConstraintAxisVertical;
    _parentStackView.distribution = UIStackViewDistributionFill;
    [self addSubview:_parentStackView];
}

- (void)setupSearchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
    }
    [NSLayoutConstraint constraintWithItem:_searchBar
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:PDFSearchBarHeight].active = YES;
    _searchBar.hidden = YES;
    _searchBar.delegate = self;
    _searchBar.barTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [_parentStackView insertArrangedSubview:_searchBar atIndex:0];
}

- (void)setupPDFActionsView {
    if (!_pdfActionsView) {
        _pdfActionsView = [ORKPDFViewerActionsView new];
    }
    [NSLayoutConstraint constraintWithItem:_pdfActionsView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:PDFActionViewHeight].active = YES;

    [self setupClearApplyExitButtons];
    
    [_pdfActionsView.thumbnailActionButton addTarget:self action:@selector(thumbnailButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_pdfActionsView.annotationActionButton addTarget:self action:@selector(annotationButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_pdfActionsView.searchActionButton addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_pdfActionsView.shareActionButton addTarget:self action:@selector(shareButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    _pdfActionsView.translatesAutoresizingMaskIntoConstraints = NO;
    [_parentStackView addArrangedSubview:_pdfActionsView];
    
    [self updateActionButtonAccessibilityLabels];
}

- (void)setupPDFStackView {
    if (!_pdfStackView) {
        [self setupPDFView];
        _pdfStackView = [[UIStackView alloc] initWithArrangedSubviews:@[_pdfThumbnailView, _pdfView]];
    }
    _pdfStackView.translatesAutoresizingMaskIntoConstraints = NO;
    _pdfStackView.spacing = 10.0;
    _pdfStackView.axis = UILayoutConstraintAxisHorizontal;
    _pdfStackView.distribution = UIStackViewDistributionFill;
    [_parentStackView addArrangedSubview:_pdfStackView];
}

- (void)setupPDFView {
    if (!_pdfView) {
        _pdfView = [PDFView new];
    }
    PDFDocument *document;
    if (_pdfURL) {
        document = [[PDFDocument alloc] initWithURL:_pdfURL];
        _pdfView.document = document;
        _pdfView.document.delegate = self;

    }
    if (document) {
        [self setEnableAllButtons:!document.isLocked];
    }
    else {
        [self setEnableAllButtons:document];
    }
    _pdfView.autoScales = YES;
    _pdfView.displayMode = kPDFDisplaySinglePageContinuous;
    _pdfView.translatesAutoresizingMaskIntoConstraints = NO;

    _pdfThumbnailView = [PDFThumbnailView new];
    _pdfThumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
    _pdfThumbnailView.thumbnailSize = CGSizeMake(40, 40);
    [NSLayoutConstraint constraintWithItem:_pdfThumbnailView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:PDFThumbnailViewWidth].active = YES;
    _pdfThumbnailView.layoutMode = PDFThumbnailLayoutModeVertical;
    _pdfThumbnailView.PDFView = _pdfView;
    _pdfThumbnailView.hidden = YES;

    [self updateActionButtonsAppearance];
}

- (void)setupClearApplyExitButtons {
    [_pdfActionsView.clearButtonView setHidden:YES];
    [_pdfActionsView.applyButtonView setHidden:YES];
    [_pdfActionsView.exitButtonView setHidden:YES];
    
    [self updateClearApplyAnnotationButtons];
    
    [_pdfActionsView.clearAnnotationsButton addTarget:self action:@selector(clearButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_pdfActionsView.applyAnnotationsButton addTarget:self action:@selector(applybuttonAction) forControlEvents:UIControlEventTouchUpInside];
    [_pdfActionsView.exitAnnotationsButton addTarget:self action:@selector(exitButtonAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateClearApplyAnnotationButtons {
    [_pdfActionsView.clearAnnotationsButton setEnabled:_freehandDrawingView.freehandDrawingExists];
    [_pdfActionsView.applyAnnotationsButton setEnabled:_freehandDrawingView.freehandDrawingExists];
}

- (void)thumbnailButtonAction {
    [self animateViews:@[_pdfThumbnailView] setHidden:!_pdfThumbnailView.isHidden];
    [self updateActionButtonsAppearance];
    [_pdfView setAutoScales:YES];
}

- (void)annotationButtonAction {

    [self setPDFViewDisplayModeSinglePage:_isFreehandDrawingActive];

    if (!_isFreehandDrawingActive && !_freehandDrawingView) {
        [self addFreehandDrawingView];
    }

    [self setIsScibbleActive:YES];
    [self updateActionButtonsAppearance];
}

- (void)addAnnotations: (PDFAnnotation *)annotations {
    [_pdfView.currentPage addAnnotation:annotations];
}

- (void)setPDFViewDisplayModeSinglePage:(BOOL) isContinuous {
    PDFPage *currentPage = _pdfView.currentPage;
    [_pdfView setScaleFactor:[_pdfView minScaleFactor]];
    [_pdfView setDisplayMode:isContinuous ? kPDFDisplaySinglePageContinuous : kPDFDisplaySinglePage];
    [_pdfView setScaleFactor:[_pdfView scaleFactorForSizeToFit]];
    [_pdfView goToPage:currentPage];
}

- (void)searchButtonAction {
    [UIView animateWithDuration:0.5 animations:^{
        if (!_searchBar.isHidden) {
            [self searchBarDismissKeyboard];
        }
        _searchBar.hidden = !_searchBar.isHidden;
    }];
    [self updateActionButtonsAppearance];
}

- (void)setEnableAllButtons:(BOOL)enable {
    [_pdfActionsView.thumbnailActionButton setEnabled:enable];
    [_pdfActionsView.annotationActionButton setEnabled:enable];
    [_pdfActionsView.searchActionButton setEnabled:enable];
    [_pdfActionsView.shareActionButton setEnabled:enable];
}

- (void)updateActionButtonsAppearance {
    _pdfActionsView.thumbnailActionButton.alpha = _pdfThumbnailView.isHidden ? PDFInactiveButtonAlpha : 1.0;
    _pdfActionsView.annotationActionButton.alpha = !_isFreehandDrawingActive ? PDFInactiveButtonAlpha : 1.0;
    _pdfActionsView.searchActionButton.alpha = _searchBar.isHidden ? PDFInactiveButtonAlpha : 1.0;
    _pdfActionsView.shareActionButton.alpha = PDFInactiveButtonAlpha;
    [self updateActionButtonAccessibilityLabels];
}

- (void)updateActionButtonAccessibilityLabels {
    _pdfActionsView.thumbnailActionButton.accessibilityLabel = _pdfThumbnailView.isHidden ?ORKLocalizedString(@"AX_BUTTON_SHOW_PDF_THUMBNAIL" , nil) : ORKLocalizedString(@"AX_BUTTON_HIDE_PDF_THUMBNAIL", nil);
    _pdfActionsView.annotationActionButton.accessibilityLabel = ORKLocalizedString(@"AX_BUTTON_ANNOTATE" , nil);
    _pdfActionsView.searchActionButton.accessibilityLabel = _searchBar.isHidden ? ORKLocalizedString(@"AX_BUTTON_SHOW_SEARCH", nil) : ORKLocalizedString(@"AX_BUTTON_HIDE_SEARCH", nil);
    _pdfActionsView.shareActionButton.accessibilityLabel = ORKLocalizedString(@"AX_BUTTON_SHARE", nil);
}

- (void)shareButtonAction {
    if (_isShareActive) {
        
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectShareButton:)]) {
            [self.delegate didSelectShareButton:_pdfActionsView.shareActionButton];
        }
    }
    _isShareActive = !_isShareActive;
    [self updateActionButtonsAppearance];
}

- (void)setPdfURL:(NSURL *)pdfURL {
    if (_pdfURL != pdfURL) {
        _pdfURL = pdfURL;
        _pdfView.document = nil;
        PDFDocument *document;
        if (pdfURL) {
            document = [[PDFDocument alloc] initWithURL:pdfURL];
            _pdfView.document = document;
            _pdfView.document.delegate = self;
        }
        if (document) {
            [self setEnableAllButtons:!document.isLocked];
            _annotationsAdded = NO;
        }
        else {
            [self setEnableAllButtons:document];
        }
    }
}

- (void)addFreehandDrawingView {
    if (!_freehandDrawingView) {
        _freehandDrawingView = [[ORKFreehandDrawingView alloc] initWithPDFView:_pdfView];
        _freehandDrawingView.translatesAutoresizingMaskIntoConstraints = NO;
        _freehandDrawingView.backgroundColor = [UIColor clearColor];
        _freehandDrawingView.opaque = NO;
        _freehandDrawingView.delegate = self;
        [self addSubview:_freehandDrawingView];
        [NSLayoutConstraint activateConstraints:@[
                                                  [NSLayoutConstraint constraintWithItem:_freehandDrawingView
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:_pdfView
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1.0
                                                                                constant:0.0],
                                                  [NSLayoutConstraint constraintWithItem:_freehandDrawingView
                                                                               attribute:NSLayoutAttributeLeft
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:_pdfView
                                                                               attribute:NSLayoutAttributeLeft
                                                                              multiplier:1.0
                                                                                constant:0.0],
                                                  [NSLayoutConstraint constraintWithItem:_freehandDrawingView
                                                                               attribute:NSLayoutAttributeRight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:_pdfView
                                                                               attribute:NSLayoutAttributeRight
                                                                              multiplier:1.0
                                                                                constant:0.0],
                                                  [NSLayoutConstraint constraintWithItem:_freehandDrawingView
                                                                               attribute:NSLayoutAttributeBottom
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:_pdfView
                                                                               attribute:NSLayoutAttributeBottom
                                                                              multiplier:1.0
                                                                                constant:0.0]
                                                  ]];
    }
}

- (void)setupKeyboardUnderlapView {
    if (!_keyboardUnderlapView) {
        _keyboardUnderlapView = [UIView new];
    }
    _keyboardUnderlapView.translatesAutoresizingMaskIntoConstraints = NO;
    _keyboardUnderlapView.hidden = YES;
    [_keyboardUnderlapView setBackgroundColor:[UIColor clearColor]];
    [_parentStackView addArrangedSubview:_keyboardUnderlapView];
}


- (void)setIsScibbleActive:(BOOL)isActive {
    _isFreehandDrawingActive = isActive;
    if (isActive) {
        [self searchBarDismissKeyboard];
        [_pdfActionsView.thumbnailActionButton setHidden:YES];
        [_pdfActionsView.annotationActionButton setHidden:YES];
        [_pdfActionsView.searchActionButton setHidden:YES];
        [_pdfActionsView.shareActionButton setHidden:YES];
        
        [_pdfActionsView.clearAnnotationsButton setHidden:NO];
        [_pdfActionsView.applyAnnotationsButton setHidden:NO];
        [_pdfActionsView.exitAnnotationsButton setHidden:NO];
        [self animateViews:@[
                             _pdfThumbnailView,
                             _pdfActionsView.thumbnailActionView,
                             _pdfActionsView.annotationActionView,
                             _searchBar,
                             _pdfActionsView.searchActionView,
                             _pdfActionsView.shareActionView
                             ]
                 setHidden:YES];
        [self animateViews:@[
                             _pdfActionsView.clearButtonView,
                             _pdfActionsView.applyButtonView,
                             _pdfActionsView.exitButtonView
                             ] setHidden:NO];
        
    }
    else {
        NSMutableArray *allowedViews = [[NSMutableArray alloc] init];
        [_pdfActionsView.thumbnailActionButton setHidden:NO];
        [_pdfActionsView.annotationActionButton setHidden:NO];
        [_pdfActionsView.clearAnnotationsButton setHidden:YES];
        [_pdfActionsView.applyAnnotationsButton setHidden:YES];
        [_pdfActionsView.exitAnnotationsButton setHidden:YES];

        [allowedViews addObjectsFromArray:@[_pdfActionsView.thumbnailActionView,
                                            _pdfActionsView.annotationActionView]];
        if (!_hideSearchButton) {
            
            [_pdfActionsView.searchActionButton setHidden:NO];
            [allowedViews addObject:_pdfActionsView.searchActionView];
        }
        if (!_hideShareButton) {
            [_pdfActionsView.shareActionButton setHidden:NO];
            [allowedViews addObject:_pdfActionsView.shareActionView];
        }
        [self animateViews:allowedViews setHidden:NO];
        [self animateViews:@[_pdfActionsView.clearButtonView,
                             _pdfActionsView.applyButtonView,
                             _pdfActionsView.exitButtonView]
                 setHidden:YES];
    }
    [self updateActionButtonsAppearance];
}

- (void)clearButtonAction {
    if (_freehandDrawingView.freehandDrawingPath && _freehandDrawingView.freehandDrawingExists) {
        [_freehandDrawingView clear];
    }
    [self updateClearApplyAnnotationButtons];
}

- (void)applybuttonAction {
    if (_freehandDrawingView.freehandDrawingPath && _freehandDrawingView.freehandDrawingExists) {
        CGRect annotationRect = _pdfView.documentView.bounds;
        PDFAnnotation *annotation = [[PDFAnnotation alloc] initWithBounds:annotationRect forType:PDFAnnotationSubtypeInk withProperties:nil];
        annotation.border.lineWidth = 2.0;

        for (UIBezierPath *path in _freehandDrawingView.freehandDrawingPath) {
            [annotation addBezierPath:path];
        }
        [_pdfView.currentPage addAnnotation:annotation];

        [_freehandDrawingView clear];
        _annotationsAdded = YES;
    }
    [self updateClearApplyAnnotationButtons];
}

- (void)exitButtonAction {
    [self setPDFViewDisplayModeSinglePage:_isFreehandDrawingActive];

    if (_isFreehandDrawingActive && _freehandDrawingView) {
        [_freehandDrawingView removeFromSuperview];
        _freehandDrawingView = nil;
        [self setIsScibbleActive:NO];
    }
}

- (void)setHideThumbnailButton:(BOOL)hideThumbnailButton {
    if (hideThumbnailButton) {
        [_pdfActionsView.thumbnailActionView setHidden:YES];
        [_pdfThumbnailView setHidden:YES];
    }
}

- (void)setHideAnnotationButton:(BOOL)hideAnnotationButton {
    if (hideAnnotationButton) {
        [_pdfActionsView.annotationActionView setHidden:YES];
        [_pdfActionsView.clearButtonView setHidden:YES];
        [_pdfActionsView.applyButtonView setHidden:YES];
        [_pdfActionsView.exitButtonView setHidden:YES];
    }
}

- (void)setHideSearchButton:(BOOL)hideSearchButton {
    if (hideSearchButton) {
        [_pdfActionsView.searchActionView setHidden:YES];
        [_searchBar setHidden:YES];
    }
}

- (void)setHideShareButton:(BOOL)hideShareButton {
    [_pdfActionsView.shareActionView setHidden:hideShareButton];
}

- (void)setupConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_parentStackView);
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_parentStackView]|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_parentStackView]|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)searchBarDismissKeyboard {
    [_searchBar resignFirstResponder];
    if (_keyboardUnderlapView) {
        _keyboardUnderlapView.hidden = YES;
    }
}

- (BOOL)pdfModified {
    return _annotationsAdded;
}

- (void)animateViews:(NSArray<UIView *> *)views setHidden:(BOOL)hidden {
    [UIView animateWithDuration:PDFhideViewAnimationDuration animations:^{
        for (UIView *view in views) {
            [view setHidden:hidden];
        }
    }];
}

- (PDFDocument *)getDocument {
    return _pdfView.document;
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_pdfView.document beginFindString:searchText withOptions:NSCaseInsensitiveSearch];
}

- (void)didMatchString:(PDFSelection *)instance {
    instance.color = [UIColor yellowColor];
    [_pdfView setCurrentSelection:instance animate:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_pdfView.document beginFindString:searchBar.text withOptions:NSCaseInsensitiveSearch];
    [self searchBarDismissKeyboard];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (_keyboardUnderlapView) {
        _keyboardUnderlapView.hidden = YES;
    }
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillAppear:(NSNotification *)aNotification {
    
    NSDictionary *userInfo = aNotification.userInfo;
    CGSize keyboardSize = ((NSValue *)userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue.size;
    //    Offset with assumed view controller's navigation container's height.
    keyboardSize.height = keyboardSize.height - 200.0;

    if (_keyboardUnderlapView && _keyboardUnderlapView.isHidden) {
        [_keyboardUnderlapView removeFromSuperview];
        [NSLayoutConstraint constraintWithItem:_keyboardUnderlapView
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:keyboardSize.height].active = YES;
        _keyboardUnderlapView.hidden = NO;
        [_parentStackView insertArrangedSubview:_keyboardUnderlapView atIndex:[[_parentStackView subviews] count]];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateShareButton {
    _isShareActive = NO;
    [self updateActionButtonsAppearance];
}

#pragma mark ORKFreehandDrawingViewDelegate

- (void)freehandDrawingViewDidEditImage:(ORKFreehandDrawingView *)freehandDrawingView {
    [self updateClearApplyAnnotationButtons];
}

#pragma mark PDFDocumentDelegate

- (void)documentDidUnlock:(NSNotification *)notification {
    [self setEnableAllButtons:YES];
}

@end
