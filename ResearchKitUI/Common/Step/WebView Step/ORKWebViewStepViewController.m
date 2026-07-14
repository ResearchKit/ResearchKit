/*
 Copyright (c) 2017, CareEvolution, Inc.
 
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

#import "ORKWebViewStepViewController.h"

#import <ResearchKitUI/ResearchKitUI-Swift.h>

#import "ORKCollectionResult_Private.h"
#import "ORKCustomSignatureFooterView_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKResult_Private.h"
#import "ORKSignatureFormatter.h"
#import "ORKSignatureResult_Private.h"
#import "ORKSkin.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKWebViewStep.h"
#import "ORKWebViewStepResult.h"
#import "ORKWebViewStepResult_Private.h"

NSString * const ORKWebViewStepViewAccessibilityIdentifier = @"ORKWebViewStepView";

static const CGFloat ORKSignatureTopPadding = 37.0;

// This view controller will hide it's view until the HTML finishes loading.
// That way, the entire view is rendered at once. For a snappier UX, the HTML
// can be preloaded using the `preloadHTML` method.

@implementation ORKWebViewStepViewController {
    UIScrollView *_scrollView;
    WKWebView *_webView;
    NSString *_receivedMessageBody;
    NSMutableArray<NSLayoutConstraint *> *_constraints;
    NSLayoutConstraint *_webViewHeightConstraint;
    CGFloat _baseWebViewHeight;
    BOOL _isObservingContentSize;

    ORKCustomSignatureFooterView *_signatureFooterView;
    
    CGFloat _bottomOffset;

    BOOL _isHTMLRendered;
}

- (ORKWebViewStep *)webViewStep {
    return (ORKWebViewStep *)self.step;
}

- (void)setupSubviews {
    if (ORKLiquidGlassSupportEnabled()) {
        self.view.directionalLayoutMargins = ORKLargeContentLayoutMargins;
    }
    [self setupScrollView];
    [self setupNavigationBarView];
    [self setupNavigationFooterView];
    [self setupWebView];
    [self setupSignatureIfNeeded];
}

- (void)didFinishLoadingHTML {
    // Height is now settled enough to display — stop KVO so that the layout
    // passes triggered by addSubviews/setupConstraints below (and any future
    // scroll-driven viewport shifts) cannot fire further height updates.
    [self stopObservingContentSize];

    // Now that the HTML is loaded we can display the subviews
    [self addSubviews];
    [self setupConstraints];

    // Notify the delegate that the view controller has finished loading
    if (
        _webViewDelegate != nil &&
        [_webViewDelegate respondsToSelector:@selector(didFinishLoadingWebStepViewController:)]
    ) {
        [_webViewDelegate didFinishLoadingWebStepViewController:self];
    }
}

// Refresh the HTML in the web view and hide subviews until it's finished loading.
// This helps to remove flashing behavior in the UI.
- (void)refreshHTML {
    // Remove the subviews while the HTML loads
    [self removeSubviews];
    [NSLayoutConstraint deactivateConstraints:_constraints];

    // Reset height tracking so KVO starts fresh for the new HTML load
    _baseWebViewHeight = 0;

    // Reset the webview to a 1pt-tall viewport before loading new HTML.
    // Without this, the previous height constraint is still in effect when
    // the HTML loads. A tall viewport from a large-font render causes
    // document.documentElement.scrollHeight to return the viewport height
    // rather than the actual content height when the new content is shorter,
    // inflating the measurement and producing excess whitespace.
    _webViewHeightConstraint.constant = 1.0;
    CGRect frame = _webView.frame;
    frame.size.height = 1.0;
    _webView.frame = frame;

    // Re-enable KVO so the new load's growing content height is tracked.
    // It will be stopped again in didFinishLoadingHTML.
    [self startObservingContentSize];

    // Generate the CSS for the HTML

    NSString *css = [self webViewStep].customCSS;

    if (!css) {
        UIColor *backgroundColor = ORKColor(ORKBackgroundColorKey);
        UIColor *textColor = [UIColor labelColor];

        NSString *backgroundColorString = [self hexStringForColor:backgroundColor];
        NSString *textColorString = [self hexStringForColor:textColor];

        CGFloat horizontalPadding = [self horizontalPadding];

        CGFloat bodyFontSize = [UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize;

        // padding-bottom only needs to be non-zero to break CSS margin-collapse on
        // the last child element. Without any padding-bottom, the last element's
        // bottom margin collapses into the body's zero margin and is excluded from
        // scrollHeight, causing the webview frame to be too short. 1px is enough
        // to break the collapse; the constraint between webview and signature view
        // provides the visible gap below the content.
        css = [NSString stringWithFormat:@"body { margin: 0px; font-size: %.0fpx; font-family: \"-apple-system\"; padding-left: %fpx; padding-right: %fpx; padding-bottom: 1px; background-color: %@; color: %@; }",
               bodyFontSize,
               horizontalPadding,
               horizontalPadding,
               backgroundColorString,
               textColorString];
    }

    // Apply the CSS to the HTML using JS

    NSString *js = @"var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style);";
    NSString *formattedString = [NSString stringWithFormat:js, css];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:formattedString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:true];

    WKUserContentController *controller = _webView.configuration.userContentController;
    [controller removeAllUserScripts];      // Clear the previous script and CSS
    [controller addUserScript:userScript];

    // Kick off loading the HTML. Once it's completed, make sure to call `didFinishLoadingHTML`.
    NSString *rawHtml = [self webViewStep].html;
    NSString *html = rawHtml ? [self htmlByDisablingZoom:rawHtml] : nil;
    [_webView loadHTMLString:html baseURL:nil];
}

/// Rewrites or injects a viewport meta tag that disables user scaling.
/// WebKit's smart-zoom (double-tap) is driven by the viewport, not by `maximumZoomScale`,
/// so this is the only reliable way to disable it.
- (NSString *)htmlByDisablingZoom:(NSString *)html {
    static NSRegularExpression *viewportRegex = nil;
    static NSRegularExpression *headTagRegex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        viewportRegex = [NSRegularExpression
            regularExpressionWithPattern:@"<meta[^>]*name=['\"]viewport['\"][^>]*/?>|<meta[^>]*name=viewport[^>]*/?>"
                                 options:NSRegularExpressionCaseInsensitive
                                   error:nil];
        headTagRegex = [NSRegularExpression
            regularExpressionWithPattern:@"<head[^>]*>"
                                 options:NSRegularExpressionCaseInsensitive
                                   error:nil];
    });

    NSString *noScaleViewport = @"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, user-scalable=no, maximum-scale=1\">";
    NSRange fullRange = NSMakeRange(0, html.length);
    if ([viewportRegex firstMatchInString:html options:0 range:fullRange]) {
        return [viewportRegex stringByReplacingMatchesInString:html options:0 range:fullRange withTemplate:noScaleViewport];
    }

    // Insert the viewport meta tag after <head>
    NSTextCheckingResult *headMatch = [headTagRegex firstMatchInString:html options:0 range:fullRange];
    if (headMatch) {
        NSUInteger insertAt = NSMaxRange(headMatch.range);
        return [html stringByReplacingCharactersInRange:NSMakeRange(insertAt, 0) withString:noScaleViewport];
    }

    // No <head> found; prepend the viewport meta tag to the whole document as a last resort.
    return [noScaleViewport stringByAppendingString:html];
}

- (CGFloat)horizontalPadding {
    return self.step.useExtendedPadding ?
        ORKStepContainerExtendedLeftRightPaddingForWindow(self.view.window) :
        ORKStepContainerLeftRightPaddingForWindow(self.view.window);
}

- (void)setupWebView {
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.allowsInlineMediaPlayback = true;
    if ([config respondsToSelector:@selector(mediaTypesRequiringUserActionForPlayback)]) {
        config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    }

    WKUserContentController *controller = [[WKUserContentController alloc] init];
    [controller addScriptMessageHandler:self name:@"ResearchKit"];
    config.userContentController = controller;

    // Use a 1 pt height so the viewport is minimal when HTML loads (the webview
    // is not yet in the view hierarchy at that point). A full-screen height
    // viewport causes document.documentElement.scrollHeight to return the
    // viewport height instead of the content height when content is shorter
    // than the screen, inflating the measurement for small fonts. With a 1 pt
    // viewport all content overflows, so both KVO contentSize and
    // document.body.scrollHeight accurately reflect the actual content height.
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)
                                  configuration:config];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _webView.navigationDelegate = self;
    _webView.scrollView.scrollEnabled = NO;
    _webView.scrollView.delegate = self;

    // Set an initial height constraint of 1.0 to avoid unsatisfiable
    // constraint warnings before the content height is known
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webViewHeightConstraint = [_webView.heightAnchor constraintEqualToConstant:1.0];
    _webViewHeightConstraint.active = YES;

    [self startObservingContentSize];
}

- (void)setupScrollView {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [_scrollView setDelegate:self];
}

- (void)setupSignatureIfNeeded {
    if (![self webViewStep].showSignatureAfterContent) {
        return;
    }
    _signatureFooterView = [[ORKCustomSignatureFooterView alloc] init];
    _signatureFooterView.signatureViewDelegate = self;
    _signatureFooterView.delegate = self;
    _signatureFooterView.customViewProvider = [self webViewStep].customViewProvider;

    if ([_signatureFooterView.customViewProvider respondsToSelector:@selector(keyboardDismissModeForCustomView)]) {
        [_scrollView setKeyboardDismissMode:[_signatureFooterView.customViewProvider keyboardDismissModeForCustomView]];
    }
}

- (void)setupNavigationBarView {
    UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
    [navBarAppearance configureWithOpaqueBackground];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.standardAppearance = navBarAppearance;
    navigationBar.scrollEdgeAppearance = navBarAppearance;
}

- (void)setupNavigationFooterView {
    _navigationFooterView = [ORKNavigationContainerView new];
    _navigationFooterView.continueButtonItem = self.continueButtonItem;
    _navigationFooterView.continueEnabled = YES;
    _navigationFooterView.optional = [self webViewStep].isOptional;
    [_navigationFooterView updateContinueAndSkipEnabled];
    [_navigationFooterView setUseExtendedPadding:[self.step useExtendedPadding]];
    
    if ([self webViewStep].showSignatureAfterContent) {
        _navigationFooterView.continueEnabled = NO;
    }
}

- (void)addSubviews {
    [self.view addSubview:_scrollView];
    [_scrollView addSubview:_navigationFooterView];

    if (_signatureFooterView) {
        [_scrollView addSubview:_signatureFooterView];
    }

    // Add the web view last so it sits on top in the z-order. The signature
    // and nav footer views are positioned below it by layout constraints, but
    // floating-point rounding can produce a sub-pixel overlap at the boundary.
    // With the web view on top, its content is never painted over by the
    // opaque background of the signature view during scrolling.
    [_scrollView addSubview:_webView];
}

- (void)removeSubviews {
    [_scrollView removeFromSuperview];
    [_navigationFooterView removeFromSuperview];
    [_webView removeFromSuperview];

    if (_signatureFooterView) {
        [_signatureFooterView removeFromSuperview];
    }
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    _navigationFooterView.skipButtonItem = self.skipButtonItem;
}

- (void)setupConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }

    UIView *viewForiPad = [self viewForiPadLayoutConstraints];

    _constraints = nil;
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _navigationFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _signatureFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    
    id topReferenceItem = ORKLiquidGlassSupportEnabled() ? self.view : self.view.safeAreaLayoutGuide;
    
    _constraints = [[NSMutableArray alloc] initWithArray:@[
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : topReferenceItem
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view.safeAreaLayoutGuide
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:0.0],
        
        [NSLayoutConstraint constraintWithItem:_webView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_scrollView
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_webView
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_webView
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_webView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view
                                     attribute:ORKLiquidGlassSupportEnabled() ?
                                                NSLayoutAttributeLeftMargin :
                                                NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0],
        [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:viewForiPad ? : self.view
                                     attribute:ORKLiquidGlassSupportEnabled() ?
                                                NSLayoutAttributeRightMargin :
                                                NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0]
    ]];
    
    if ([[self webViewStep] showSignatureAfterContent]) {
        CGFloat horizontalPadding = [self horizontalPadding];

        [_constraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_signatureFooterView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_webView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:ORKSignatureTopPadding / 2.0],
            [NSLayoutConstraint constraintWithItem:_signatureFooterView
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.view
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:horizontalPadding],
            [NSLayoutConstraint constraintWithItem:_signatureFooterView
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.view
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:-horizontalPadding],
            [NSLayoutConstraint constraintWithItem:_signatureFooterView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.view
                                         attribute:NSLayoutAttributeWidth
                                        multiplier:1.0
                                          constant:-2*horizontalPadding],
            [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_signatureFooterView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:ORKSignatureTopPadding / 2.0],
        ]];
    } else {
        [_constraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_webView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:ORKSignatureTopPadding / 2.0],
        ]];
    }

    // Anchor the last content view's bottom to contentLayoutGuide so Auto Layout
    // computes contentSize automatically. This replaces all manual contentSize
    // management and eliminates the timing/re-entrancy issues that caused the
    // signature view to jump during scrolling.
    [_constraints addObject:
        [_scrollView.contentLayoutGuide.bottomAnchor constraintEqualToAnchor:_navigationFooterView.bottomAnchor]];

    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.accessibilityIdentifier = ORKWebViewStepViewAccessibilityIdentifier;

    // Note, the subviews will not be added to the view hierarchy
    // until the HTML is loaded
    [self setupSubviews];
    [self refreshHTML];
    
    [self.taskViewController setNavigationBarColor:[self.view backgroundColor]];
    
    [self.view addMagicPocketIfNecessaryFor:_scrollView];

    [self registerForTraitChanges:@[UITraitUserInterfaceStyle.class, UITraitPreferredContentSizeCategory.class] withHandler:^(ORKWebViewStepViewController *traitChangeView, UITraitCollection *previousTraitCollection) {
        [traitChangeView refreshHTML];
    }];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    // To prevent zooming
    scrollView.pinchGestureRecognizer.enabled = NO;
}

/**
 This will modify the `contentOffset` on `_scrollView` so the bottom of the provided rect aligns with the provided endPoint.
 
 @param rect                     A rect in `_signatureView` used as a reference point for the scroll.
 @param endPoint            The point the bottom of the rect should be scrolled to.
 @param animated            A boolean value indicating wether the scroll should be animated or not.
 */
- (void)scrollSignatureViewRect:(CGRect)rect toPoint:(CGPoint)endPoint animated:(BOOL)animated {
    CGRect rectInView = [_signatureFooterView convertRect:rect toView:self.view];
    
    CGFloat offset = endPoint.y - (rectInView.origin.y + rectInView.size.height);
    
    if (offset < 0) {
        CGFloat xOffset = _scrollView.contentOffset.x;
        CGFloat yOffset = _scrollView.contentOffset.y - offset;
    
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^{
                [_scrollView setContentOffset:CGPointMake(xOffset, yOffset)];
            }];
        } else {
            [_scrollView setContentOffset:CGPointMake(xOffset, yOffset)];
        }
    }
}

- (void)setBottomOffset:(CGFloat)bottomOffset {
    _bottomOffset = bottomOffset;
    [_scrollView setContentInset:UIEdgeInsetsMake(0, 0, bottomOffset, 0)];
}

- (CGFloat)bottomOffset {
    return _bottomOffset;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // When LiquidGlass is enabled the scroll view extends behind the nav bar.
    // Use contentInset.top to offset the content so it starts below the nav bar.
    CGFloat topInset = ORKLiquidGlassSupportEnabled() ? self.view.safeAreaInsets.top : 0;
    UIEdgeInsets newInsets = UIEdgeInsetsMake(topInset, 0, _bottomOffset, 0);
    if (!UIEdgeInsetsEqualToEdgeInsets(_scrollView.contentInset, newInsets)) {
        [_scrollView setContentInset:newInsets];
    }
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _navigationFooterView.continueButtonItem = continueButtonItem;
}

- (void)startPreload {
    if (self.viewLoaded) {
        [self didFinishLoadingHTML];
    } else {
        [self loadViewIfNeeded];
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.body isKindOfClass:[NSString class]]){
        _receivedMessageBody = ORKDynamicCast(message.body, NSString);
        [self goForward];
    }
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    if (stepResult) {
        NSString *webViewResultIdentifier = @"WebView";
        ORKWebViewStepResult *webViewResult = [[ORKWebViewStepResult alloc] initWithIdentifier:webViewResultIdentifier];
        webViewResult.result = _receivedMessageBody;
        webViewResult.endDate = stepResult.endDate;
        stepResult.results = [stepResult.results arrayByAddingObject:webViewResult] ? : @[webViewResult];
        
        if ([[self webViewStep] showSignatureAfterContent] && [_signatureFooterView isComplete]) {
            NSString *signatureResultIdentifier = @"Signature";
            ORKSignatureResult *signatureResult = [_signatureFooterView resultWithIdentifier: signatureResultIdentifier];
            stepResult.results = [stepResult.results arrayByAddingObject:signatureResult] ? : @[signatureResult];
            
            ORKSignatureFormatter *signatureFormatter = [ORKSignatureFormatter new];
            NSString *htmlWithSignature = [signatureFormatter appendSignatureToHTML:[self webViewStep].html signatureResult:signatureResult];
            webViewResult.userInfo = @{[ORKWebViewStepResult getHTMLKey]: [self webViewStep].html, [ORKWebViewStepResult getHTMLWithDictionaryKey]: htmlWithSignature};
        } else {
            webViewResult.userInfo = @{[ORKWebViewStepResult getHTMLKey]: [self webViewStep].html};
        }
    }
    return stepResult;
}

// MARK: KVO

- (void)startObservingContentSize {
    if (!_isObservingContentSize) {
        [_webView.scrollView addObserver:self
                              forKeyPath:@"contentSize"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
        _isObservingContentSize = YES;
    }
}

- (void)stopObservingContentSize {
    if (_isObservingContentSize) {
        [_webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
        _isObservingContentSize = NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGSize newSize = [change[NSKeyValueChangeNewKey] CGSizeValue];

        // Use the raw contentSize height — do not add ORKSignatureTopPadding
        // here as it is already accounted for by the layout constraints
        // between the web view and the elements below it
        CGFloat newHeight = newSize.height;

        // Only update if the height has meaningfully changed to avoid
        // unnecessary layout passes from sub-pixel contentSize fluctuations
        if (fabs(newHeight - _baseWebViewHeight) > 1.0) {
            _baseWebViewHeight = newHeight;
            [self updateWebViewHeight:newHeight];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updateWebViewHeight:(CGFloat)height {
    _webViewHeightConstraint.constant = height;

    // Force an immediate layout pass so the content size (now managed by
    // Auto Layout via the contentLayoutGuide.bottom constraint) updates before
    // any scroll animation begins. Safe to call here because updateWebViewHeight:
    // is only invoked outside of a layout pass.
    [self.view layoutIfNeeded];
}

// MARK: WKWebViewDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.readyState" completionHandler:^(id complete, NSError *readyError) {
        if (complete != nil) {
            // Use the more reliable combination of height properties
            // as an initial estimate before KVO kicks in
            [webView evaluateJavaScript:
                @"Math.max("
                 "document.body.scrollHeight,"
                 "document.body.offsetHeight,"
                 "document.documentElement.scrollHeight,"
                 "document.documentElement.offsetHeight"
                 ")"
                      completionHandler:^(id result, NSError *error) {
                if (result != nil) {
                    // Use the raw height — padding is handled by layout constraints
                    CGFloat height = [result floatValue];

                    // Only apply the JS estimate if KVO hasn't already
                    // reported a larger, more accurate value
                    if (height > _baseWebViewHeight) {
                        _baseWebViewHeight = height;
                        [self updateWebViewHeight:height];
                    }
                }

                [self didFinishLoadingHTML];
            }];
        } else {
            [self didFinishLoadingHTML];
        }
    }];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [self refreshHTML];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    // Clean up and surface the failure gracefully
    [self stopObservingContentSize];
    [self didFinishLoadingHTML];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        if (_webViewDelegate != nil && [_webViewDelegate respondsToSelector:@selector(handleLinkNavigationWithURL:)]) {
            NSURL *documentURL = [navigationAction.request mainDocumentURL];
            if (documentURL != nil) {
                decisionHandler([_webViewDelegate handleLinkNavigationWithURL:documentURL]);
            } else {
                decisionHandler(WKNavigationActionPolicyCancel);
            }
            return;
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

// MARK: UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _webView.scrollView) {
        // When the outer UIScrollView scrolls, WebKit adjusts the webview's
        // internal contentOffset to track the on-screen viewport shift. This
        // makes the HTML content appear to drift upward within the webview's
        // fixed frame, causing the last lines of text to be obscured by the
        // signature view. Reset to zero to keep the HTML anchored to the top
        // of the webview's frame at all times.
        if (!CGPointEqualToPoint(scrollView.contentOffset, CGPointZero)) {
            scrollView.contentOffset = CGPointZero;
        }
        return;
    }

    BOOL enabled = [self shouldEnableSignatureView] && scrollView.isDecelerating;
    [_signatureFooterView setEnabled:enabled];

    if ([_scrollView.panGestureRecognizer translationInView:_scrollView.superview].y > 0) {
        // Scrolling upward
        [_signatureFooterView cancelAutoScrollTimer];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView != _scrollView) { return; }

    // KVO was stopped at didFinishLoadingHTML to prevent layout-pass and
    // scroll-driven fluctuations. However, for the largest accessibility font
    // sizes WebKit's CSS-triggered reflow can finish slightly after navigation
    // completes. By the time the user is about to scroll, that reflow is done,
    // so a single direct read of contentSize here catches any remaining
    // discrepancy without re-enabling KVO.
    CGFloat currentHeight = _webView.scrollView.contentSize.height;
    if (currentHeight > _baseWebViewHeight + 1.0) {
        _baseWebViewHeight = currentHeight;
        [self updateWebViewHeight:currentHeight];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_signatureFooterView setEnabled:[self shouldEnableSignatureView]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_signatureFooterView setEnabled:[self shouldEnableSignatureView]];
}

- (BOOL)shouldEnableSignatureView {
    CGFloat bottomOfSignature = _signatureFooterView.frame.origin.y + _signatureFooterView.signatureViewFrame.origin.y + _signatureFooterView.signatureViewFrame.size.height;
    CGFloat signaturePosition = _scrollView.contentOffset.y + _scrollView.frame.size.height;
    return (bottomOfSignature <= signaturePosition);
}

// MARK: Signature

- (void)signatureViewDidEditImage:(nonnull ORKSignatureView *)signatureView {
    _navigationFooterView.continueEnabled = [_signatureFooterView isComplete];
}

- (void)signatureViewDidEndEditingWithTimeInterval {
    if (_shouldScrollAfterSignature) {
        CGPoint bottom = CGPointMake(0, _scrollView.contentSize.height - _scrollView.bounds.size.height + _scrollView.contentInset.bottom);
        [_scrollView setContentOffset:bottom animated:YES];
    }
}

// MARK: Color

- (NSString *)hexStringForColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    size_t count = CGColorGetNumberOfComponents(color.CGColor);
    
    CGFloat r = components[0];
    
    if (count == 2) {
        return [NSString stringWithFormat:@"#%02lX%02lX%02lX", lroundf(r * 255), lroundf(r * 255), lroundf(r * 255)];
    }
    
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255)];
}

// MARK: ORKCustomSignatureFooterViewStatusDelegate

- (void)signatureFooterView:(nonnull ORKCustomSignatureFooterView *)footerView didChangeCompletedStatus:(BOOL)isComplete {
    _navigationFooterView.continueEnabled = isComplete;
}

// MARK: Dealloc

- (void)dealloc {
    [self stopObservingContentSize];
}

@end
