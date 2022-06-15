/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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

#import "ORKStepView_Private.h"
#import "ORKStepContentView_Private.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKSkin.h"

@interface ORKStepView ()<ORKStepContentLearnMoreItemDelegate>

@end

@implementation ORKStepView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isNavigationContainerScrollable = YES;
        _stepTopContentImageContentMode = UIViewContentModeScaleAspectFit;
        [self setupStepContentView];
        [self setupNavigationContainerView];
    }
    return self;
}

- (void)setupStepContentView {
    if (!self.stepContentView) {
        self.stepContentView = [ORKStepContentView new];
    }
    self.stepContentView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepContentViewImageChanged:) name:ORKStepTopContentImageChangedKey object:nil];
}

- (void)stepContentViewImageChanged:(NSNotification *)notification {
    
}

- (void)setupNavigationContainerView {
    if (!self.navigationFooterView) {
        self.navigationFooterView = [ORKNavigationContainerView new];
    }
    
    if (_isNavigationContainerScrollable == NO) {
        [self.navigationFooterView removeStyling];
    }
}

- (void)setStepTopContentImage:(UIImage *)stepTopContentImage {
    _stepTopContentImage = stepTopContentImage;
}

- (void)setStepTopContentImageContentMode:(UIViewContentMode)stepTopContentImageContentMode {
    _stepContentView.topContentImageView.contentMode = stepTopContentImageContentMode;
}

- (void)setAuxiliaryImage:(UIImage *)auxiliaryImage {
    _auxiliaryImage = auxiliaryImage;
}

- (void)pinNavigationContainerToBottom {
    _isNavigationContainerScrollable = NO;
    [self placeNavigationContainerView];
}

- (void)placeNavigationContainerView {
    
}

- (void)setTitleIconImage:(UIImage *)titleIconImage {
    _titleIconImage = titleIconImage;
    [_stepContentView setTitleIconImage:_titleIconImage];
}

- (void)setStepTitle:(NSString *)stepTitle {
    _stepTitle = stepTitle;
    [_stepContentView setStepTitle:_stepTitle];
}

- (void)setStepText:(NSString *)stepText {
    _stepText = stepText;
    [_stepContentView setStepText:_stepText];
}

- (void)setStepDetailText:(NSString *)stepDetailText {
    _stepDetailText = stepDetailText;
    [_stepContentView setStepDetailText:_stepDetailText];
}

- (void)setStepHeaderTextAlignment:(NSTextAlignment)stepHeaderTextAlignment {
    _stepHeaderTextAlignment = stepHeaderTextAlignment;
    [_stepContentView setStepHeaderTextAlignment:_stepHeaderTextAlignment];
}

- (void)setBodyTextAlignment:(NSTextAlignment)bodyTextAlignment {
    _bodyTextAlignment = bodyTextAlignment;
    [_stepContentView setBodyTextAlignment:_bodyTextAlignment];
}

- (void)setBodyItems:(NSArray<ORKBodyItem *> *)bodyItems {
    _bodyItems = bodyItems;
    [_stepContentView setBodyItems:_bodyItems];
}

- (void)setBuildInBodyItems:(BOOL)buildInBodyItems {
    _buildInBodyItems = buildInBodyItems;
    [_stepContentView setBuildsInBodyItems:_buildInBodyItems];
}


- (void)setUseExtendedPadding:(BOOL)useExtendedPadding {
    _useExtendedPadding = useExtendedPadding;
    [_stepContentView setUseExtendedPadding:_useExtendedPadding];
}

- (UIImage *)topContentAndAuxiliaryImage {
    if (!_auxiliaryImage) {
        return _stepTopContentImage;
    }
    CGSize size = _auxiliaryImage.size;
    UIGraphicsBeginImageContext(size);
    
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    
    [_auxiliaryImage drawInRect:rect];
    [_stepTopContentImage drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ORKStepContentLearnMoreItemDelegate

- (void)stepContentLearnMoreButtonPressed:(ORKLearnMoreInstructionStep *)learnMoreStep {
    [_delegate stepViewLearnMoreButtonPressed:learnMoreStep];
}

@end
