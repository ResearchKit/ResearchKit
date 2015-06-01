/*
 Copyright (c) 2015, Bruce Duncan. All rights reserved.
 
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


#import "ORKImageCaptureCameraPreviewView.h"
#import "ORKTintedImageView.h"
#import "ORKHelpers.h"
#import <tgmath.h>
#import "ORKDefines_Private.h"


@interface ORKImageCaptureCameraPreviewView ()

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) ORKTintedImageView *templateImageView;
@property (nonatomic, strong) NSLayoutConstraint *templateImageViewTopInset;
@property (nonatomic, strong) NSLayoutConstraint *templateImageViewLeftInset;
@property (nonatomic, strong) NSLayoutConstraint *templateImageViewBottomInset;
@property (nonatomic, strong) NSLayoutConstraint *templateImageViewRightInset;
@property (nonatomic, strong) ORKTintedImageView *capturedImageView;

@end


@implementation ORKImageCaptureCameraPreviewView

- (instancetype)init {
    self = [super init];
    if (self) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _previewLayer.needsDisplayOnBoundsChange = YES;
        [self.layer addSublayer:_previewLayer];
    
        _templateImageView = [[ORKTintedImageView alloc] init];
        _templateImageView.contentMode = UIViewContentModeScaleAspectFit;
        _templateImageView.shouldApplyTint = YES;
        _templateImageView.alpha = 0;
        [self addSubview:_templateImageView];
        
        _capturedImageView = [[ORKTintedImageView alloc] init];
        _capturedImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_capturedImageView];
        
        NSDictionary *dictionary = NSDictionaryOfVariableBindings(self, _templateImageView, _capturedImageView);
        ORKEnableAutoLayoutForViews([dictionary allValues]);
        // Make the insets for the template image view changable later
        _templateImageViewTopInset = [NSLayoutConstraint constraintWithItem:_templateImageView attribute: NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self addConstraint:_templateImageViewTopInset];
        _templateImageViewLeftInset = [NSLayoutConstraint constraintWithItem:_templateImageView attribute: NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        [self addConstraint:_templateImageViewLeftInset];
        _templateImageViewBottomInset = [NSLayoutConstraint constraintWithItem:_templateImageView attribute: NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self addConstraint:_templateImageViewBottomInset];
        _templateImageViewRightInset = [NSLayoutConstraint constraintWithItem:_templateImageView attribute: NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        [self addConstraint:_templateImageViewRightInset];
        // Make the captured image view use the available space (taking into account the layout margins)
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_capturedImageView]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_capturedImageView]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
    }
    return self;
}

- (AVCaptureSession *)session {
    return _previewLayer.session;
}

- (void)setSession:(AVCaptureSession * __nullable)session {
    _previewLayer.session = session;
}

- (UIImage *)templateImage {
    return _templateImageView.image;
}

- (void)setTemplateImage:(UIImage * __nullable)templateImage {
    _templateImageView.image = templateImage;
}

- (void)setTemplateImageHidden:(BOOL)hidden {
    _templateImageView.alpha = hidden ? 0 : 1;
}

- (BOOL)isTemplateImageHidden {
    return _templateImageView.alpha==0;
}

- (UIImage *)capturedImage {
    return _capturedImageView.image;
}

- (void)setCapturedImage:(UIImage * __nullable)capturedImage {
    _capturedImageView.image = capturedImage;
    _previewLayer.hidden = capturedImage!=nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Ensure that the preview layer takes up all the space
    self.previewLayer.frame = self.frame;
    
    // Update the insets for the template and catpured image views
    [self updateInsets];
}

- (void)updateInsets {
    // Update the layoutMargins to match those being used by the preview layer content, if needed
    UIEdgeInsets previewLayerContentFrameInsets = [self getPreviewLayerContentFrameInsets];
    if (!UIEdgeInsetsEqualToEdgeInsets(previewLayerContentFrameInsets, self.layoutMargins)) {
        self.layoutMargins = previewLayerContentFrameInsets;
    }
    
    // Update the insets on the template image view, if needed
    CGRect previewLayerContentFrame = UIEdgeInsetsInsetRect(_previewLayer.frame, previewLayerContentFrameInsets);
    UIEdgeInsets insets = UIEdgeInsetsMake(round(self.templateImageInsets.top * previewLayerContentFrame.size.height),
                                           round(self.templateImageInsets.left * previewLayerContentFrame.size.width),
                                           round(self.templateImageInsets.bottom * previewLayerContentFrame.size.height),
                                           round(self.templateImageInsets.right * previewLayerContentFrame.size.width));
    
    if (_templateImageViewTopInset.constant!=insets.top) {
        _templateImageViewTopInset.constant = insets.top;
    }
    if (_templateImageViewLeftInset.constant!=insets.left) {
        _templateImageViewLeftInset.constant = insets.left;
    }
    if (_templateImageViewBottomInset.constant!=-insets.bottom) {
        _templateImageViewBottomInset.constant = -insets.bottom;
    }
    if (_templateImageViewRightInset.constant!=-insets.right) {
        _templateImageViewRightInset.constant = -insets.right;
    }
}

- (UIEdgeInsets)getPreviewLayerContentFrameInsets {
    // Determine the insets on the preview layer frame that correspond to the actual video content
    // when using a videoGravity of AVLayerVideoGravityResizeAspect;
    NSArray *inputs = _previewLayer.session.inputs;
    if (!inputs || [inputs count] == 0)
        return UIEdgeInsetsZero;
    AVCaptureDeviceInput* input = (AVCaptureDeviceInput*)inputs[0];
    CMVideoDimensions cmd = CMVideoFormatDescriptionGetDimensions(input.device.activeFormat.formatDescription);
    AVCaptureVideoOrientation avcvo = _previewLayer.connection.videoOrientation;
    BOOL landscape = avcvo == AVCaptureVideoOrientationLandscapeLeft || avcvo == AVCaptureVideoOrientationLandscapeRight;
    
    CGRect contentFrame = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(landscape ? cmd.width : cmd.height, landscape ? cmd.height : cmd.width), _previewLayer.frame);
    CGRect overallFrame = _previewLayer.frame;
    return UIEdgeInsetsMake(contentFrame.origin.y - overallFrame.origin.y,
                            contentFrame.origin.x - overallFrame.origin.x,
                            (overallFrame.origin.y + overallFrame.size.height) - (contentFrame.origin.y + contentFrame.size.height),
                            (overallFrame.origin.x + overallFrame.size.width) - (contentFrame.origin.x + contentFrame.size.width));
}

- (AVCaptureVideoOrientation)videoOrientation {
    return _previewLayer.connection.videoOrientation;
}

- (void)setVideoOrientation:(AVCaptureVideoOrientation)videoOrientation {
    _previewLayer.connection.videoOrientation = videoOrientation;
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString * __nullable)accessibilityLabel {
    return ORKLocalizedString(@"AX_IMAGE_CAPTURE_LABEL", nil);
}

- (UIAccessibilityTraits)accessibilityTraits {
    return [super accessibilityTraits] | UIAccessibilityTraitImage;
}

@end
