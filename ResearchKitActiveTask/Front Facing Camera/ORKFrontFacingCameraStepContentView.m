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

#import "ORKFrontFacingCameraStepContentView.h"
#import "ORKUnitLabel.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKBorderedButton.h"
#import "ORKTitleLabel.h"
#import "ORKBodyLabel.h"
#import "ORKIconButton.h"
#import "ORKStepHeaderView_Internal.h"

#import <AVFoundation/AVFoundation.h>

@interface ORKFrontFacingCameraStepOptionsView : UIVisualEffectView

@property (nonatomic, strong) UIButton *reviewVideoButton;
@property (nonatomic, strong) UIButton *deleteAndRetryVideoButton;
@property (nonatomic, strong) UIButton *submitVideoButton;
@property (nonatomic, strong) ORKTitleLabel *titleLabel;

@end

@implementation ORKFrontFacingCameraStepOptionsView {
    NSMutableArray *_constraints;
}

- (instancetype)initWithEffect:(UIVisualEffect *)effect {
    self = [super initWithEffect:effect];
    
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.layer.cornerRadius = 10.0;
    self.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.clipsToBounds = YES;
}

- (void)applyDefaultConfiguration:(UIButtonConfiguration *)configuration API_AVAILABLE(ios(15.0)) {
    configuration.buttonSize = UIButtonConfigurationSizeLarge;
    configuration.titleAlignment = UIButtonConfigurationTitleAlignmentLeading;
    configuration.imagePlacement = NSDirectionalRectEdgeTrailing;
    configuration.cornerStyle = UIButtonConfigurationCornerStyleDynamic;
    NSDirectionalEdgeInsets contentInsets = configuration.contentInsets;
    contentInsets.leading = ORKSmallContentLayoutMargins.leading;
    contentInsets.trailing = ORKSmallContentLayoutMargins.trailing;
    configuration.contentInsets = contentInsets;
}

- (UIButtonConfiguration *)buttonConfigurationWithForegroundColor:(UIColor *)foregroundColor API_AVAILABLE(ios(15.0)) {
    if (ORKLiquidGlassSupportEnabled()) {
        if (@available(iOS 26.0, *)) {
            UIButtonConfiguration *configuration = [UIButtonConfiguration glassButtonConfiguration];
            configuration.baseForegroundColor = foregroundColor;
            [self applyDefaultConfiguration:configuration];
            return configuration;
        }
    }
    return [UIButtonConfiguration plainButtonConfiguration];
}

- (UIButtonConfiguration *)prominentButtonConfigurationWithForegroundColor:(UIColor *)foregroundColor API_AVAILABLE(ios(15.0)) {
    if (ORKLiquidGlassSupportEnabled()) {
        if (@available(iOS 26.0, *)) {
            UIButtonConfiguration *configuration = [UIButtonConfiguration prominentGlassButtonConfiguration];
            configuration.baseForegroundColor = foregroundColor;
            [self applyDefaultConfiguration:configuration];
            return configuration;
        }
    }
    return [UIButtonConfiguration borderedProminentButtonConfiguration];
}

- (UIButton *)deleteAndRetryVideoButton {
    if (_deleteAndRetryVideoButton == nil) {
        UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationPreferringMulticolor];
        UIImage *deleteAndRetryButtonIcon = [[UIImage systemImageNamed:@"trash.fill"] imageByApplyingSymbolConfiguration:imageConfig];
        _deleteAndRetryVideoButton = [UIButton buttonWithConfiguration:[self buttonConfigurationWithForegroundColor:[UIColor systemRedColor]] primaryAction:nil];
        [_deleteAndRetryVideoButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
        [_deleteAndRetryVideoButton setTitle:ORKLocalizedString(@"FRONT_FACING_CAMERA_RETRY_VIDEO", nil) forState:UIControlStateNormal];
        [_deleteAndRetryVideoButton setImage:deleteAndRetryButtonIcon forState:UIControlStateNormal];
        _deleteAndRetryVideoButton.tag = 1;
        _deleteAndRetryVideoButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _deleteAndRetryVideoButton;
}

- (UIButton *)reviewVideoButton  {
    if (_reviewVideoButton == nil) {
        UIImage *reviewButtonIcon = [UIImage systemImageNamed:@"video.fill"];
        UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationPreferringMulticolor];
        reviewButtonIcon = [reviewButtonIcon imageByApplyingSymbolConfiguration:imageConfig];
        _reviewVideoButton = [UIButton buttonWithConfiguration:[self buttonConfigurationWithForegroundColor:[UIColor labelColor]] primaryAction:nil];
        [_reviewVideoButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
        [_reviewVideoButton setTitle:ORKLocalizedString(@"FRONT_FACING_CAMERA_REVIEW_VIDEO", nil) forState:UIControlStateNormal];
        [_reviewVideoButton setImage:reviewButtonIcon forState:UIControlStateNormal];
        _reviewVideoButton.tag = 0;
        _reviewVideoButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _reviewVideoButton;
}

- (UIButton *)submitVideoButton {
    if (_submitVideoButton == nil) {
        _submitVideoButton = [UIButton buttonWithConfiguration:[self prominentButtonConfigurationWithForegroundColor:[UIColor labelColor]] primaryAction:nil];
        _submitVideoButton.tag = 2;
        _submitVideoButton.translatesAutoresizingMaskIntoConstraints = NO;
        _submitVideoButton.layer.cornerRadius = 10.0;
        _submitVideoButton.clipsToBounds = YES;
        _submitVideoButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
        [_submitVideoButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_submitVideoButton setBackgroundColor:[UIColor systemBlueColor]];
        [_submitVideoButton setTitle:ORKLocalizedString(@"FRONT_FACING_CAMERA_SUBMIT_VIDEO", nil) forState:UIControlStateNormal];
    }
    return _submitVideoButton;
}

- (ORKTitleLabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [ORKTitleLabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_titleLabel setTextColor:[UIColor whiteColor]];
        _titleLabel.text = ORKLocalizedString(@"FRONT_FACING_CAMERA_REVIEW_OPTIONS_TITLE", nil);
    }
    return _titleLabel;
}

- (void)setupSubviews {
    const CGFloat verticalSpaceBetweenTitleLabelAndContent = 40.0;
    const CGFloat verticalContentOffset = 40.0; // Prior to this minor refactor to UIStackView,
                                                // this value was to move the titleLabel vertically
                                                // appear to simulate it's location in the hidden Navigation Bar.

    UIStackView *contentStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.titleLabel,
        self.reviewVideoButton,
        self.deleteAndRetryVideoButton,
        [UIView new],
        self.submitVideoButton
    ]];
    contentStack.spacing = 15;
    contentStack.axis = UILayoutConstraintAxisVertical;
    contentStack.distribution = UIStackViewDistributionFill;
    contentStack.alignment = UIStackViewAlignmentFill;
    contentStack.layoutMarginsRelativeArrangement = YES;
    contentStack.translatesAutoresizingMaskIntoConstraints = NO;
    [contentStack setCustomSpacing:verticalSpaceBetweenTitleLabelAndContent afterView:self.titleLabel];
    contentStack.directionalLayoutMargins = ORKBottomSafeAreaDirectionalEdgeInsetsFrom(ORKLargeContentLayoutMargins);

    [self.contentView addSubview:contentStack];
    self.contentView.preservesSuperviewLayoutMargins = NO;

    [NSLayoutConstraint activateConstraints:@[
        [self.contentView.topAnchor constraintEqualToAnchor:contentStack.topAnchor constant:verticalContentOffset],
        [self.contentView.layoutMarginsGuide.bottomAnchor constraintEqualToAnchor:contentStack.bottomAnchor],
        [self.contentView.layoutMarginsGuide.leadingAnchor constraintEqualToAnchor:contentStack.leadingAnchor],
        [self.contentView.layoutMarginsGuide.trailingAnchor constraintEqualToAnchor:contentStack.trailingAnchor],
    ]];
}

@end

typedef NS_CLOSED_ENUM(NSInteger, ORKStartStopButtonState) {
    ORKStartStopButtonStateStartRecording = 0,
    ORKStartStopButtonStateStopRecording,
} ORK_ENUM_AVAILABLE;


@interface ORKBlurFooterView : UIVisualEffectView
- (instancetype)initWithTitleText:(nullable NSString *)titleText detailText:(nullable NSString *)detailText;

@property (nonatomic) UIButton *startStopButton;
@property (nonatomic) ORKStartStopButtonState startStopButtonState;
@property (nonatomic) UILabel *timerLabel;

@end

@implementation ORKBlurFooterView {
    NSMutableArray<NSLayoutConstraint *> *_heightConstraints;
    NSLayoutConstraint *_blurViewTopConstraint;
    
    NSString *_titleText;
    NSString *_detailText;
    
    ORKTitleLabel *_titleLabel;
    ORKBodyLabel *_detailTextLabel;
    
    UIButton *_collapseButton;
    
    BOOL _isTextCollapsed;
}

- (instancetype)initWithTitleText:(nullable NSString *)titleText detailText:(nullable NSString *)detailText {
    self = [super initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    if (self) {
        _titleText = titleText;
        _detailText = detailText;
        _isTextCollapsed = NO;
        _startStopButtonState = ORKStartStopButtonStateStartRecording;
        [self setupSubviews];
        [self setupConstraints];
        [self setStartStopButtonState:ORKStartStopButtonStateStartRecording];
    }
    return self;
}

- (UIButton *)startStopButton {
    if (_startStopButton == nil) {
        UIButtonConfiguration *configuration;
        if (ORKLiquidGlassSupportEnabled()) {
            if (@available(iOS 26.0, *)) {
                configuration = [UIButtonConfiguration prominentGlassButtonConfiguration];
            } else {
                configuration = [UIButtonConfiguration plainButtonConfiguration];
            }
        } else {
            configuration = [UIButtonConfiguration plainButtonConfiguration];
        }
        configuration.contentInsets = NSDirectionalEdgeInsetsMake(0, 6, 0, 6);
        _startStopButton = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
        _startStopButton.layer.cornerRadius = 14.0;
        _startStopButton.clipsToBounds = YES;
        UIFontDescriptor *descriptorOne = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
        _startStopButton.titleLabel.font = [UIFont boldSystemFontOfSize:[[descriptorOne objectForKey: UIFontDescriptorSizeAttribute] doubleValue] + 1.0];

    }
    return _startStopButton;
}

- (void)setupSubviews {
    [self.contentView addSubview:self.startStopButton];

    _timerLabel = [UILabel new];
    _timerLabel.font = [UIFont systemFontOfSize:15.0];
    _timerLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_timerLabel];
    
    if (_titleText) {
        _titleLabel = [ORKTitleLabel new];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        [_titleLabel setTextColor:[UIColor whiteColor]];
        _titleLabel.text = _titleText;
        [self.contentView addSubview:_titleLabel];
    }
    
    if (_detailText) {
        _detailTextLabel = [ORKBodyLabel new];
        _detailTextLabel.textAlignment = NSTextAlignmentLeft;
        _detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _detailTextLabel.numberOfLines = 0;
        [_detailTextLabel setTextColor:[UIColor whiteColor]];
        _detailTextLabel.text = _detailText ? : @"";
        [self.contentView addSubview:_detailTextLabel];
    }
    
    if (_titleText || _detailText) {
        _collapseButton = [UIButton new];
        _collapseButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_collapseButton setTintColor:[UIColor whiteColor]];
        [_collapseButton setBackgroundImage:[UIImage systemImageNamed:@"chevron.down"] forState:UIControlStateNormal];
        [_collapseButton addTarget:self
                            action:@selector(collapseButtonPressed)
                  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_collapseButton];
    }
}

- (void)setupConstraints {
    _startStopButton.translatesAutoresizingMaskIntoConstraints = NO;
    _timerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [[_startStopButton.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor constant:20.0] setActive:YES];
    [[_startStopButton.trailingAnchor constraintEqualToAnchor:_timerLabel.leadingAnchor constant:-15.0] setActive:YES];
    [[_startStopButton.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor constant:-20.0] setActive:YES];
    [[_startStopButton.heightAnchor constraintGreaterThanOrEqualToConstant:50.0] setActive:YES];
    
    [[_timerLabel.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor constant:-20.0] setActive:YES];
    [[_timerLabel.centerYAnchor constraintEqualToAnchor:_startStopButton.centerYAnchor] setActive:YES];
    [[_timerLabel.widthAnchor constraintEqualToConstant:40.0] setActive:YES];
    
    if (_titleLabel || _detailTextLabel) {
        
        if (_detailTextLabel) {
            [[_detailTextLabel.leadingAnchor constraintEqualToAnchor:_startStopButton.leadingAnchor] setActive:YES];
            [[_detailTextLabel.trailingAnchor constraintEqualToAnchor:_timerLabel.trailingAnchor] setActive:YES];
            [[_detailTextLabel.bottomAnchor constraintEqualToAnchor:_startStopButton.topAnchor constant:-20.0] setActive:YES];
        }
        
        if (_titleLabel) {
            [[_titleLabel.leadingAnchor constraintEqualToAnchor:_startStopButton.leadingAnchor] setActive:YES];
            [[_titleLabel.trailingAnchor constraintEqualToAnchor:_collapseButton.leadingAnchor constant: -10.0] setActive:YES];
            [[_titleLabel.bottomAnchor constraintEqualToAnchor:_detailTextLabel ? _detailTextLabel.topAnchor : _startStopButton.topAnchor constant: -15.0] setActive:YES];
            
            [[_collapseButton.topAnchor constraintEqualToAnchor:_titleLabel.topAnchor] setActive:YES];
            
            _blurViewTopConstraint = [self.contentView.topAnchor constraintEqualToAnchor:_titleLabel.topAnchor constant:-20.0];
        } else {
            [[_collapseButton.bottomAnchor constraintEqualToAnchor:_detailTextLabel.topAnchor constant:-15.0] setActive:YES];
            _blurViewTopConstraint = [self.contentView.topAnchor constraintEqualToAnchor:_collapseButton.topAnchor constant:-20.0];
        }
        
        [[_collapseButton.trailingAnchor constraintEqualToAnchor:_timerLabel.trailingAnchor] setActive:YES];
        [[_collapseButton.heightAnchor constraintEqualToConstant:25.0] setActive:YES];
        [[_collapseButton.widthAnchor constraintEqualToConstant:25.0] setActive:YES];
        
        [_blurViewTopConstraint setActive:YES];
    } else {
        [[self.contentView.topAnchor constraintEqualToAnchor:_startStopButton.topAnchor constant:-20.0] setActive:YES];
    }
    
}

- (void)setStartStopButtonState:(ORKStartStopButtonState)startStopButtonState
{
    _startStopButtonState = startStopButtonState;
    
    if (startStopButtonState == ORKStartStopButtonStateStartRecording)
    {
        [_startStopButton setTitle:ORKLocalizedString(@"FRONT_FACING_CAMERA_START_TITLE", nil) forState:UIControlStateNormal];
        [_startStopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_startStopButton setBackgroundColor:self.tintColor];
        
        [_timerLabel setText:ORKLocalizedString(@"FRONT_FACING_CAMERA_START_TIME", nil)];
        [_timerLabel setTextColor:[UIColor darkGrayColor]];
    }
    else
    {
        [_startStopButton setTitle:ORKLocalizedString(@"FRONT_FACING_CAMERA_STOP_TITLE", nil) forState:UIControlStateNormal];
        [_startStopButton setTitleColor:self.tintColor forState:UIControlStateNormal];
        [_startStopButton setBackgroundColor:[UIColor systemGrayColor]];
        
        [_timerLabel setTextColor:[UIColor whiteColor]];
    }
}

- (void)collapseButtonPressed {
    if (_isTextCollapsed) {
        [_blurViewTopConstraint setActive:NO];
        _blurViewTopConstraint = [self.contentView.topAnchor constraintEqualToAnchor:_titleLabel.topAnchor constant:-20.0];
        [_blurViewTopConstraint setActive:YES];
        
        [NSLayoutConstraint deactivateConstraints:_heightConstraints];
        _heightConstraints = nil;
    } else {
        [_blurViewTopConstraint setActive:NO];
        _blurViewTopConstraint = [self.contentView.topAnchor constraintEqualToAnchor:_collapseButton.topAnchor constant:-20.0];
        [_blurViewTopConstraint setActive:YES];
        
        _heightConstraints = [NSMutableArray new];
        [_heightConstraints addObject:[_titleLabel.heightAnchor constraintEqualToConstant:0.0]];
        [_heightConstraints addObject:[_detailTextLabel.heightAnchor constraintEqualToConstant:0.0]];
        
        [NSLayoutConstraint activateConstraints:_heightConstraints];
    }
    
    UIImage *collapseButtonImage =  _isTextCollapsed ? [UIImage systemImageNamed:@"chevron.down"] : [UIImage systemImageNamed:@"chevron.up"];
    
    [_collapseButton setBackgroundImage:collapseButtonImage forState:UIControlStateNormal];
    _isTextCollapsed = !_isTextCollapsed;
}

- (void)didMoveToWindow {
    self.tintColor = ORKWindowTintcolor(self.window) ? : [UIColor systemBlueColor];
    [self setStartStopButtonState:_startStopButtonState];
}

@end

@interface ORKFrontFacingCameraStepContentView ()
@property (nonatomic, copy, nullable) ORKFrontFacingCameraStepContentViewEventHandler viewEventhandler;
@end

@implementation ORKFrontFacingCameraStepContentView {
    ORKStepHeaderView *_headerView;
    UIView *_cameraView;
    AVCaptureVideoPreviewLayer *_previewLayer;
    ORKBlurFooterView *_blurFooterView;
    
    NSTimer *_timer;
    NSTimeInterval _maxRecordingTime;
    CGFloat _recordingTime;
    NSDateComponentsFormatter *_dateComponentsFormatter;
    
    ORKFrontFacingCameraStepOptionsView *_optionsView;
    
    NSString *_titleText;
    NSString *_bodyText;
}

- (instancetype)initWithTitle:(nullable NSString *)title text:(NSString *)text {
    self = [super initWithFrame:CGRectZero];
    self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
    
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _titleText = title;
        _bodyText = text;
        
        [self setUpSubviews];
        [self setUpConstraints];
    }
    
    return self;
}

- (void)setUpSubviews {
    _cameraView = [UIView new];
    _cameraView.alpha = 1.0;
     [self addSubview:_cameraView];
    
    _blurFooterView = [[ORKBlurFooterView alloc] initWithTitleText:_titleText detailText:_bodyText];
    _blurFooterView.layer.cornerRadius = 10.0;
    _blurFooterView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    _blurFooterView.clipsToBounds = YES;
    
    [_blurFooterView.startStopButton addTarget:self
                                action:@selector(startStopButtonPressed)
                      forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:_blurFooterView];
}

- (void)layoutSubviews {
    
    if (_previewLayer && _previewLayer.frame.size.height == 0 && _cameraView.frame.size.height != 0) {
        _previewLayer.position = CGPointMake(_cameraView.frame.size.width / 2, _cameraView.frame.size.height / 2);
        _previewLayer.bounds = CGRectMake(0, 0, _cameraView.frame.size.width, _cameraView.frame.size.height);
    }
}

- (void)setUpConstraints {
    _cameraView.translatesAutoresizingMaskIntoConstraints = NO;
    _blurFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[_cameraView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_cameraView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[_cameraView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[_cameraView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
    
    [[_blurFooterView.leadingAnchor constraintEqualToAnchor:_cameraView.leadingAnchor] setActive:YES];
    [[_blurFooterView.trailingAnchor constraintEqualToAnchor:_cameraView.trailingAnchor] setActive:YES];
    [[_blurFooterView.bottomAnchor constraintEqualToAnchor:_cameraView.bottomAnchor] setActive:YES];
}

- (void)setViewEventHandler:(ORKFrontFacingCameraStepContentViewEventHandler)handler
{
    self.viewEventhandler = [handler copy];
}

- (void)invokeViewEventHandlerWithEvent:(ORKFrontFacingCameraStepContentViewEvent)event
{
    if (self.viewEventhandler)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.viewEventhandler(event);
        });
    }
}

- (void)setPreviewLayerWithSession:(AVCaptureSession *)session {
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.needsDisplayOnBoundsChange = YES;
    
    [_cameraView.layer addSublayer:_previewLayer];
}

- (void)handleError:(NSError *)error
{
    [_optionsView removeFromSuperview];
    [_cameraView removeFromSuperview];
    [_blurFooterView removeFromSuperview];
    [_previewLayer removeFromSuperlayer];
    
    _optionsView = nil;
    _cameraView = nil;
    _blurFooterView = nil;
    _previewLayer = nil;
    
    if (_headerView)
    {
        [_headerView removeFromSuperview];
        _headerView = nil;
    }
    
    _headerView = [[ORKStepHeaderView alloc] init];
    _headerView.instructionLabel.text = error.localizedDescription;
    [_headerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_headerView];
    [NSLayoutConstraint activateConstraints:@[
        [_headerView.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor],
        [_headerView.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor],
        [_headerView.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor],
    ]];
    
    [self invokeViewEventHandlerWithEvent:ORKFrontFacingCameraStepContentViewEventError];
}

- (void)startStopButtonPressed
{
    if (_blurFooterView.startStopButtonState == ORKStartStopButtonStateStartRecording)
    {
        [_blurFooterView setStartStopButtonState:ORKStartStopButtonStateStopRecording];
        [self invokeViewEventHandlerWithEvent:ORKFrontFacingCameraStepContentViewEventStartRecording];
    }
    else
    {
        [_blurFooterView setStartStopButtonState:ORKStartStopButtonStateStartRecording];
        [self invokeViewEventHandlerWithEvent:ORKFrontFacingCameraStepContentViewEventStopRecording];
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)startTimerWithMaximumRecordingLimit:(NSTimeInterval)maximumRecordingLimit
{
    if (_timer) {
        [_timer invalidate];
    }
    
    _maxRecordingTime = maximumRecordingLimit;
    _recordingTime = 0.0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(updateRecordingTime)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)updateRecordingTime {
    _recordingTime += _timer.timeInterval;
    
    if (_recordingTime >= _maxRecordingTime) {
        [_timer invalidate];
        [_blurFooterView setStartStopButtonState:ORKStartStopButtonStateStartRecording];
        [self invokeViewEventHandlerWithEvent:ORKFrontFacingCameraStepContentViewEventStopRecording];
    } else {
        _blurFooterView.timerLabel.text = [self formattedTimeFromSeconds:_recordingTime];
    }
}

- (NSString *)formattedTimeFromSeconds:(CGFloat)seconds {
    if (!_dateComponentsFormatter) {
        _dateComponentsFormatter = [NSDateComponentsFormatter new];
        _dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        _dateComponentsFormatter.allowedUnits =  NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond;
    }
    return [_dateComponentsFormatter stringFromTimeInterval:seconds];
}

- (void)presentReviewOptionsAllowingReview:(BOOL)allowReview allowRetry:(BOOL)allowRetry
{
    if (allowRetry || allowReview)
    {
        [self presentOptionsView];
        [_optionsView.reviewVideoButton setHidden:!allowReview];
        [_optionsView.deleteAndRetryVideoButton setHidden:!allowRetry];
    }
}

- (void)presentOptionsView
{
    if (_optionsView)
    {
        [_optionsView removeFromSuperview];
        _optionsView = nil;
    }

    _optionsView = [[ORKFrontFacingCameraStepOptionsView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _optionsView.translatesAutoresizingMaskIntoConstraints = NO;

    [_optionsView.reviewVideoButton addTarget:self
                                       action:@selector(optionsViewButtonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
    [_optionsView.deleteAndRetryVideoButton addTarget:self
                                               action:@selector(optionsViewButtonPressed:)
                                     forControlEvents:UIControlEventTouchUpInside];
    [_optionsView.submitVideoButton addTarget:self
                                       action:@selector(optionsViewButtonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_optionsView];
    [self setupOptionsViewConstraints];
}

- (void)setupOptionsViewConstraints {
        [[_optionsView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
        [[_optionsView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
        [[_optionsView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
        [[_optionsView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
}

- (void)optionsViewButtonPressed:(UIButton *)button {
    if (button) {
        if (button.tag == 0) {
            //review video
            [self invokeViewEventHandlerWithEvent:ORKFrontFacingCameraStepContentViewEventReviewRecording];
        } else if (button.tag == 1) {
            //delete and redo recording
            [self invokeViewEventHandlerWithEvent:ORKFrontFacingCameraStepContentViewEventRetryRecording];
            [_optionsView removeFromSuperview];
            _optionsView = nil;
        } else if (button.tag == 2) {
            //submit video
            [self invokeViewEventHandlerWithEvent:ORKFrontFacingCameraStepContentViewEventSubmitRecording];
        }
    }
}

@end
