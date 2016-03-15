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


#import "ORKPSATStepViewController.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKPSATContentView.h"
#import "ORKPSATStep.h"
#import "ORKVerticalContainerView.h"
#import "ORKActiveStepView.h"
#import "ORKPSATKeyboardView.h"
#import "ORKHelpers.h"


@interface ORKPSATStepViewController () <ORKPSATKeyboardViewDelegate>

@property (nonatomic, strong) NSMutableArray *samples;
@property (nonatomic, strong) ORKPSATContentView *psatContentView;
@property (nonatomic, strong) NSArray<NSNumber *> *digits;
@property (nonatomic, assign) NSUInteger currentDigitIndex;
@property (nonatomic, assign) NSInteger currentAnswer;
@property (nonatomic, strong) ORKActiveStepTimer *clearDigitsTimer;
@property (nonatomic, assign) NSTimeInterval answerStart;
@property (nonatomic, assign) NSTimeInterval answerEnd;

@end

@implementation ORKPSATStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
    }
    
    return self;
}

- (ORKPSATStep *)psatStep {
    return (ORKPSATStep *)self.step;
}

- (NSArray *)arrayWithPSATDigits {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self psatStep].seriesLength + 1];
    NSUInteger digit = 0;
    for (NSUInteger i = 0; i < [self psatStep].seriesLength + 1; i++) {
        do
        {
            digit = (arc4random() % (9)) + 1;
        } while (digit == ((NSNumber *)[array lastObject]).integerValue);
        [array addObject:@(digit)];
    }
    return array;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    // Don't show buttons
    self.internalContinueButtonItem = nil;
    self.internalDoneButtonItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activeStepView.stepViewFillsAvailableSpace = YES;
    self.psatContentView = [[ORKPSATContentView alloc] initWithPresentationMode:[self psatStep].presentationMode];
    self.psatContentView.keyboardView.delegate = self;
    [self.psatContentView setEnabled:NO];
    self.activeStepView.activeCustomView = self.psatContentView;
    
    self.timerUpdateInterval = [self psatStep].interStimulusInterval;
}

- (ORKStepResult *)result {
    
    ORKStepResult *sResult = [super result];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKPSATResult *PSATResult = [[ORKPSATResult alloc] initWithIdentifier:self.step.identifier];
    PSATResult.presentationMode = [self psatStep].presentationMode;
    PSATResult.interStimulusInterval = [self psatStep].interStimulusInterval;
    if ([self psatStep].presentationMode & ORKPSATPresentationModeVisual) {
        PSATResult.stimulusDuration = [self psatStep].stimulusDuration;
    } else {
        PSATResult.stimulusDuration = 0.0;
    }
    PSATResult.length = [self psatStep].seriesLength;
    PSATResult.initialDigit = self.digits[0].integerValue;
    NSInteger totalCorrect = 0;
    BOOL previousAnswerCorrect = NO;
    NSInteger totalDyad = 0;
    CGFloat totalTime = 0.0;
    for (ORKPSATSample *sample in self.samples) {
        totalTime += sample.time;
        if (sample.isCorrect) {
            totalCorrect++;
            if (previousAnswerCorrect) {
                totalDyad++;
            }
        }
        previousAnswerCorrect = sample.isCorrect;
    }
    PSATResult.totalCorrect = totalCorrect;
    PSATResult.totalTime = totalTime;
    PSATResult.totalDyad = totalDyad;
    PSATResult.samples = self.samples;

    [results addObject:PSATResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

- (void)start {
    self.digits = [self arrayWithPSATDigits];
    self.currentDigitIndex = 0;
    [self.psatContentView setAddition:self.currentDigitIndex forTotal:[self psatStep].seriesLength withDigit:self.digits[self.currentDigitIndex]];
    [self.psatContentView setProgress:0.001 animated:NO];
    self.currentAnswer = -1;
    self.samples = [NSMutableArray array];
    
    if ([self psatStep].presentationMode & ORKPSATPresentationModeVisual &&
        ([self psatStep].interStimulusInterval - [self psatStep].stimulusDuration) > 0.05 ) {
        
        // Don't show `-` if the difference between stimulusDuration and interStimulusInterval is less than timer's resolution.
        ORKWeakTypeOf(self) weakSelf = self;
        self.clearDigitsTimer = [[ORKActiveStepTimer alloc] initWithDuration:[self psatStep].stepDuration
                                                                    interval:[self psatStep].interStimulusInterval
                                                                     runtime:-[self psatStep].stimulusDuration
                                                                     handler:^(ORKActiveStepTimer *timer, BOOL finished) {
                                                                         ORKStrongTypeOf(self) strongSelf = weakSelf;
                                                                         [strongSelf clearDigitsTimerFired];
                                                                     }];
        [self.clearDigitsTimer resume];
    }
    
    [super start];
}

- (void)suspend {
    [self.clearDigitsTimer pause];
    [super suspend];
}

- (void)resume {
    [self.clearDigitsTimer resume];
    [super resume];
}

- (void)finish {
    [self.clearDigitsTimer reset];
    self.clearDigitsTimer = nil;
    [super finish];
}

- (void)countDownTimerFired:(ORKActiveStepTimer *)timer finished:(BOOL)finished {
    if (self.currentDigitIndex == 0) {
        [self.psatContentView setEnabled:YES];
        [self.activeStepView updateTitle:ORKLocalizedString(@"PSAT_INSTRUCTION", nil) text:nil];
    } else {
        [self saveSample];
    }
    
    self.currentDigitIndex++;
    self.answerStart = CACurrentMediaTime();
    self.answerEnd = 0;
    
    if (self.currentDigitIndex <= [self psatStep].seriesLength) {
        [self.psatContentView setAddition:self.currentDigitIndex forTotal:[self psatStep].seriesLength withDigit:self.digits[self.currentDigitIndex]];
    }
    
    self.currentAnswer = -1;
    
    CGFloat progress = finished ? 1 : (timer.runtime / timer.duration);
    [self.psatContentView setProgress:progress animated:YES];
    
    [super countDownTimerFired:timer finished:finished];
}

- (void)clearDigitsTimerFired {
    [self.psatContentView setAddition:self.currentDigitIndex forTotal:[self psatStep].seriesLength withDigit:@(-1)];
}

- (void)saveSample {
    ORKPSATSample *sample = [[ORKPSATSample alloc] init];
    NSInteger previousDigit = self.digits[self.currentDigitIndex - 1].integerValue;
    NSInteger currentDigit = self.digits[self.currentDigitIndex].integerValue;;
    sample.correct = previousDigit + currentDigit == self.currentAnswer ? YES : NO;
    sample.digit = currentDigit;
    sample.answer = self.currentAnswer;
    sample.time = self.answerEnd == 0 ? [self psatStep].interStimulusInterval : self.answerEnd - self.answerStart;
    
    [self.samples addObject:sample];
}

#pragma mark - keyboard view delegate

- (void)keyboardView:(ORKPSATKeyboardView *)keyboardView didSelectAnswer:(NSInteger)answer {
    self.currentAnswer = answer;
    self.answerEnd = CACurrentMediaTime();
}

@end
