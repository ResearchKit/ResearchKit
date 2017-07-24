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


#import "ORKToneAudiometryPracticeStepViewController.h"

#import "ORKAudioGenerator.h"
#import "ORKActiveStepView.h"
#import "ORKRoundTappingButton.h"
#import "ORKToneAudiometryContentView.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKToneAudiometryPracticeStep.h"


@interface ORKToneAudiometryPracticeStepViewController ()

@property (nonatomic, strong) ORKToneAudiometryContentView *toneAudiometryContentView;
@property (nonatomic, strong) ORKAudioGenerator *audioGenerator;
@property (nonatomic, assign) BOOL expired;

- (IBAction)buttonPressed:(id)button forEvent:(UIEvent *)event;

@end


@implementation ORKToneAudiometryPracticeStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
        _audioGenerator = [ORKAudioGenerator new];
    }
    
    return self;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    // Don't show next button
    self.internalContinueButtonItem = nil;
    self.internalDoneButtonItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.expired = NO;
    
    self.toneAudiometryContentView = [[ORKToneAudiometryContentView alloc] init];
    self.activeStepView.activeCustomView = self.toneAudiometryContentView;
    
    [self.toneAudiometryContentView.leftButton addTarget:self
                                                  action:@selector(buttonPressed:forEvent:)
                                        forControlEvents:UIControlEventTouchDown];
    [self.toneAudiometryContentView.rightButton addTarget:self
                                                   action:@selector(buttonPressed:forEvent:)
                                         forControlEvents:UIControlEventTouchDown];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
}

- (void)stepDidFinish {
    [super stepDidFinish];
    
    self.expired = YES;
    [self.toneAudiometryContentView finishStep:self];
    [self goForward];
}

- (void)playReferenceTone {
    [self.audioGenerator playSoundAtFrequency:1000.0];
}

- (void)start {
    [super start];
    [self playReferenceTone];
}

- (void)suspend {
    [super suspend];
    [self.audioGenerator stop];
}

- (void)resume {
    [super resume];
    [self playReferenceTone];
}

- (void)finish {
    [super finish];
    [self.audioGenerator stop];
}

- (IBAction)buttonPressed:(id)button forEvent:(UIEvent *)event {
    [self finish];
}

@end
