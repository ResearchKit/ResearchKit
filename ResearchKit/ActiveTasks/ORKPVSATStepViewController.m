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

#import "ORKPVSATStepViewController.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKPVSATContentView.h"
#import "ORKPVSATStep.h"
#import "ORKVerticalContainerView.h"
#import "ORKActiveStepView.h"

@interface ORKPVSATStepViewController ()

@property (nonatomic, strong) NSMutableArray *samples;
@property (nonatomic, strong) ORKPVSATContentView *pvsatContentView;
@property (nonatomic, strong) NSArray *digits;
@property (nonatomic, assign) NSUInteger currentDigitIndex;
@property (nonatomic, assign) NSInteger currentAnswer;
@property (nonatomic, strong) ORKActiveStepTimer *timeoutTimer;
@property (nonatomic, assign) NSTimeInterval answerStart;
@property (nonatomic, assign) NSTimeInterval answerEnd;

@end

@implementation ORKPVSATStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
    }
    
    return self;
}

- (ORKPVSATStep *)pvsatStep {
    return (ORKPVSATStep *)self.step;
}

- (NSArray *)arrayWithPVSATDigits {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self pvsatStep].serieLength + 1];
    NSUInteger digit = 0;
    for (NSUInteger i = 0; i < [self pvsatStep].serieLength + 1; i++) {
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
    self.pvsatContentView = [[ORKPVSATContentView alloc] init];
    self.pvsatContentView.keyboardView.delegate = self;
    [self.pvsatContentView setEnabled:NO];
    self.activeStepView.activeCustomView = self.pvsatContentView;
    
    self.timerUpdateInterval = [self pvsatStep].additionDuration;
}

- (void)setupTimeoutTimer {
    [self timeoutTimerFired];
    __weak typeof(self) weakSelf = self;
    self.timeoutTimer = [[ORKActiveStepTimer alloc] initWithDuration:[self pvsatStep].stepDuration
                                                            interval:[self pvsatStep].additionDuration
                                                             runtime:0
                                                             handler:^(ORKActiveStepTimer *timer, BOOL finished) {
                                                                 typeof(self) strongSelf = weakSelf;
                                                                 [strongSelf timeoutTimerFired];
                                                             }];
    [self.timeoutTimer resume];
}

- (ORKStepResult *)result {
    
    ORKStepResult *sResult = [super result];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKPVSATResult *PVSATResult = [[ORKPVSATResult alloc] initWithIdentifier:(NSString *__nonnull)self.step.identifier];
    PVSATResult.duration = [self pvsatStep].additionDuration;
    PVSATResult.length = [self pvsatStep].serieLength;
    PVSATResult.initialDigit = [(NSNumber *)[self.digits objectAtIndex:0] integerValue];
    NSInteger totalCorrect = 0;
    CGFloat totalTime = 0.0;
    for (ORKPVSATSample *sample in self.samples) {
        totalTime += sample.time;
        if (sample.isCorrect) {
            totalCorrect++;
        }
    }
    PVSATResult.totalCorrect = totalCorrect;
    PVSATResult.totalTime = totalTime;
    PVSATResult.samples = self.samples;

    [results addObject:PVSATResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

- (void)start {
    self.digits = [self arrayWithPVSATDigits];
    self.currentDigitIndex = 0;
    [self.pvsatContentView setAddition:self.currentDigitIndex withDigit:[self.digits objectAtIndex:self.currentDigitIndex]];
    self.currentAnswer = -1;
    self.samples = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        typeof(self) strongSelf = weakSelf;
        [strongSelf setupTimeoutTimer];
    });
    
    [super start];
}

- (void)suspend {
    [self.timeoutTimer pause];
    [super suspend];
}

- (void)resume {
    [self.timeoutTimer resume];
    [super resume];
}

- (void)finish {
    [self.timeoutTimer reset];
    [super finish];
}

- (void)countDownTimerFired:(ORKActiveStepTimer *)timer finished:(BOOL)finished {
    if (self.currentDigitIndex == 0) {
        [self.pvsatContentView setEnabled:YES];
        [self.activeStepView updateTitle:ORKLocalizedString(@"PVSAT_INSTRUCTION", nil) text:nil];
    } else {
        [self saveSample];
    }
    
    self.currentDigitIndex++;
    self.answerStart = CACurrentMediaTime();
    self.answerEnd = 0;
    
    if (self.currentDigitIndex <= [self pvsatStep].serieLength) {
        [self.pvsatContentView setAddition:self.currentDigitIndex withDigit:[self.digits objectAtIndex:self.currentDigitIndex]];
    }
    
    self.currentAnswer = -1;
    
    [super countDownTimerFired:timer finished:finished];
}

- (void)timeoutTimerFired {
    [self.pvsatContentView setAddition:self.currentDigitIndex withDigit:@(-1)];
}

- (void)saveSample {
    ORKPVSATSample *sample = [[ORKPVSATSample alloc] init];
    NSInteger previousDigit = [(NSNumber *)[self.digits objectAtIndex:self.currentDigitIndex-1] integerValue];
    NSInteger currentDigit = [(NSNumber *)[self.digits objectAtIndex:self.currentDigitIndex] integerValue];
    sample.correct = previousDigit + currentDigit == self.currentAnswer ? YES : NO;
    sample.digit = currentDigit;
    sample.answer = self.currentAnswer;
    sample.time = self.answerEnd == 0 ? [self pvsatStep].additionDuration : self.answerEnd - self.answerStart;
    
    [self.samples addObject:sample];
}

#pragma mark - keyboard view delegate

- (void)keyboardView:(ORKPVSATKeyboardView *)keyboardView didSelectAnswer:(NSInteger)answer {
    self.currentAnswer = answer;
    self.answerEnd = CACurrentMediaTime();
}

@end
