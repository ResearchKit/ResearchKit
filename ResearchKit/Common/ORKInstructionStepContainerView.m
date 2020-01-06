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


#import "ORKInstructionStepContainerView.h"
#import "ORKBodyItem.h"

@implementation ORKInstructionStepContainerView


- (instancetype)initWithInstructionStep:(ORKInstructionStep *)instructionStep {
    self = [super init];
    if (self) {
        self.instructionStep = instructionStep;
    }
    [self setVariables];
    return self;
}

- (void)setVariables {
    self.stepTitle = _instructionStep.title;
    self.stepText = _instructionStep.text;
    self.stepDetailText = _instructionStep.detailText;
    self.stepHeaderTextAlignment = _instructionStep.headerTextAlignment;
    self.bodyTextAlignment = _instructionStep.bodyItemTextAlignment;
    self.bodyItems = _instructionStep.bodyItems;
    self.buildInBodyItems = _instructionStep.buildInBodyItems;
    self.useExtendedPadding = _instructionStep.useExtendedPadding;

    self.auxiliaryImage = _instructionStep.auxiliaryImage;
    self.titleIconImage = _instructionStep.iconImage;
    
    [super updatePaddingConstraints];
    if (_instructionStep.centerImageVertically) {
        UIImageView *centeredImageView = [UIImageView new];
        centeredImageView.image = _instructionStep.image;
        centeredImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self setCustomContentView:centeredImageView withTopPadding:80.0];
        [self customContentFillsAvailableSpace];
    }
    else {
        self.stepTopContentImage = _instructionStep.image;
        self.stepTopContentImageContentMode = _instructionStep.imageContentMode;
    }
}

@end
