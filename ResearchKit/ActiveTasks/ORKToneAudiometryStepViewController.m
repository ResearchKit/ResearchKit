/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
 
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

#import "ORKToneAudiometryStepViewController.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKToneAudiometryContentView.h"
#import "ORKAudioGenerator.h"
#import "ORKActiveStepView.h"
#import "ORKToneAudiometryStep.h"

@interface ORKToneAudiometryStepViewController ()

@property (nonatomic, strong) ORKToneAudiometryContentView *toneAudiometryContentView;
@property (nonatomic, strong) ORKAudioGenerator *audioGenerator;
@property (nonatomic, assign) BOOL expired;

@property (nonatomic, copy) NSArray *testingFrequencies;
@property (nonatomic, assign) NSUInteger currentTestIndex;

@property (nonatomic, strong) NSMutableArray *samples;

- (IBAction)buttonPressed:(id)button forEvent:(UIEvent *)event;

- (ORKToneAudiometryStep *)toneAudiometryStep;

@end


@implementation ORKToneAudiometryStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];

    if (self) {
        self.suspendIfInactive = YES;
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

    [self.toneAudiometryContentView.tapButton addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchDown];

    self.currentTestIndex = 0;
    self.testingFrequencies = @[@250, @500, @1000, @2000, @4000, @8000];
    self.audioGenerator = [ORKAudioGenerator new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.audioGenerator stop];
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];

    // "Now" is the end time of the result, which is either actually now,
    // or the last time we were in the responder chain.
    NSDate *now = sResult.endDate;

    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];

    ORKToneAudiometryResult *toneResult = [[ORKToneAudiometryResult alloc] initWithIdentifier:self.step.identifier];
    toneResult.startDate = sResult.startDate;
    toneResult.endDate = now;
    toneResult.samples = [self.samples copy];
    toneResult.outputVolume = @([AVAudioSession sharedInstance].outputVolume);

    [results addObject:toneResult];
    sResult.results = [results copy];

    return sResult;
}

- (void)stepDidFinish {
    [super stepDidFinish];

    self.expired = YES;
    [self.toneAudiometryContentView finishStep:self];
    [self goForward];
}

- (void)start {
    [super start];

    [self startCurrentTest];
}

- (void)suspend {
    [super suspend];
    // ...
}

- (void)resume {
    [super resume];
    // ...
}

- (void)finish {
    [super finish];
    // ...
}

- (IBAction)buttonPressed:(id)button forEvent:(UIEvent *)event {
    if (self.samples == nil) {
        _samples = [NSMutableArray array];
    }

    ORKToneAudiometrySample *sample = [ORKToneAudiometrySample new];
    NSUInteger frequencyIndex = (self.currentTestIndex / 2);
    NSNumber *frequency = self.testingFrequencies[frequencyIndex];
    sample.frequency = [frequency doubleValue];
    sample.channel = ((self.currentTestIndex % 2) == 0) ? ORKAudioChannelLeft : ORKAudioChannelRight;
    sample.amplitude = self.audioGenerator.volumeAmplitude;

    [self.samples addObject:sample];

    [self.audioGenerator stop];

    [self startNextTestOrFinish];
}

- (void)testExpired {
    [self.audioGenerator stop];

    [self startNextTestOrFinish];
}

- (void)startNextTestOrFinish {
    self.currentTestIndex ++;
    if (self.currentTestIndex == (self.testingFrequencies.count * 2)) {
        [self finish];
    } else {
        [self startCurrentTest];
    }
}

- (ORKToneAudiometryStep *)toneAudiometryStep {
    return (ORKToneAudiometryStep *)self.step;
}

- (void)startCurrentTest {
    const NSTimeInterval SoundDuration = self.toneAudiometryStep.toneDuration;

    NSUInteger testIndex = self.currentTestIndex;
    NSUInteger frequencyIndex = (testIndex / 2);
    NSAssert(frequencyIndex < self.testingFrequencies.count, nil);

    NSNumber *frequency = self.testingFrequencies[frequencyIndex];
    ORKAudioChannel channel = ((testIndex % 2) == 0) ? ORKAudioChannelLeft : ORKAudioChannelRight;

    CGFloat progress = 0.001 + (CGFloat)testIndex / (self.testingFrequencies.count * 2);
    [self.toneAudiometryContentView setProgress:progress
                                        caption:(channel == ORKAudioChannelLeft) ? [NSString stringWithFormat:ORKLocalizedString(@"TONE_LABEL_%@_LEFT", nil), ORKLocalizedStringFromNumber(frequency)] : [NSString stringWithFormat:ORKLocalizedString(@"TONE_LABEL_%@_RIGHT", nil), ORKLocalizedStringFromNumber(frequency)]
                                       animated:YES];

    [self.audioGenerator playSoundAtFrequency:frequency.doubleValue
                                    onChannel:channel
                               fadeInDuration:SoundDuration];

    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SoundDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        typeof(self)strongSelf = weakSelf;

        if (strongSelf.currentTestIndex == testIndex) {
            [strongSelf testExpired];
        }
    });
}

@end
