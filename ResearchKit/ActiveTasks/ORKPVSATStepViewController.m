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

static const NSUInteger ORKPVSATNumberOfAdditions = 60;

@interface ORKPVSATStepViewController ()

@property (nonatomic, strong) NSMutableArray *samples;

@end

@implementation ORKPVSATStepViewController {
    ORKPVSATContentView *_pvsatContentView;
    NSArray *_digits;
    NSUInteger _currentDigitIndex;
    NSInteger _currentAnswer;
    NSTimeInterval _answerStart;
    NSTimeInterval _answerEnd;
}

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
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:ORKPVSATNumberOfAdditions+1];
    NSUInteger digit = 0;
    for (NSUInteger i = 0; i < ORKPVSATNumberOfAdditions+1; i++) {
        digit = (arc4random() % (8)) + 1;
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
    _pvsatContentView = [[ORKPVSATContentView alloc] init];
    _pvsatContentView.keyboardView.delegate = self;
    [_pvsatContentView setEnabled:NO];
    self.activeStepView.activeCustomView = _pvsatContentView;
}

- (ORKStepResult *)result {
    
    ORKStepResult *sResult = [super result];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKPVSATResult *PVSATResult = [[ORKPVSATResult alloc] initWithIdentifier:(NSString *__nonnull)self.step.identifier];
    PVSATResult.version = [self pvsatStep].version;
    PVSATResult.initialDigit = [(NSNumber *)[_digits objectAtIndex:0] integerValue];
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
    PVSATResult.samples = _samples;

    [results addObject:PVSATResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

- (void)start {
    [super start];
    
    _digits = [self arrayWithPVSATDigits];
    _currentDigitIndex = 0;
    [_pvsatContentView setAddition:_currentDigitIndex withDigit:[_digits objectAtIndex:_currentDigitIndex]];
    _currentAnswer = -1;
    _samples = [NSMutableArray array];
}

- (void)countDownTimerFired:(ORKActiveStepTimer *)timer finished:(BOOL)finished {
    NSInteger runtimeValue = (NSInteger)round(timer.runtime);
    
    NSUInteger pvsatVersion = [self pvsatStep].version == ORKPVSATVersionTwoSecond ? 2 : 3;
    NSUInteger remainder = runtimeValue % pvsatVersion;
    
    if (remainder == 1) {
        [_pvsatContentView setAddition:_currentDigitIndex withDigit:@(-1)];
    } else if (remainder == 0) {
        if (_currentDigitIndex == 0) {
            [_pvsatContentView setEnabled:YES];
            [self.activeStepView updateTitle:ORKLocalizedString(@"PVSAT_INSTRUCTION", nil) text:nil];
        } else {
            [self saveSample];
        }
        
        _currentDigitIndex++;
        _answerStart = CACurrentMediaTime();
        _answerEnd = 0;
        
        if (_currentDigitIndex <= ORKPVSATNumberOfAdditions) {
            [_pvsatContentView setAddition:_currentDigitIndex withDigit:[_digits objectAtIndex:_currentDigitIndex]];
        }
        
        _currentAnswer = -1;
    }
    
    [super countDownTimerFired:timer finished:finished];
}

- (void)saveSample {
    ORKPVSATSample *sample = [[ORKPVSATSample alloc] init];
    NSInteger previousDigit = [(NSNumber *)[_digits objectAtIndex:_currentDigitIndex-1] integerValue];
    NSInteger currentDigit = [(NSNumber *)[_digits objectAtIndex:_currentDigitIndex] integerValue];
    sample.correct = previousDigit + currentDigit == _currentAnswer ? YES : NO;
    sample.digit = currentDigit;
    sample.answer = _currentAnswer;
    sample.time = _answerEnd == 0 ? ([self pvsatStep].version == ORKPVSATVersionTwoSecond ? 2.0 : 3.0) : _answerEnd - _answerStart;
    
    [self.samples addObject:sample];
}

#pragma mark - keyboard view delegate

- (void)keyboardView:(ORKPVSATKeyboardView *)keyboardView didSelectAnswer:(NSInteger)answer {
    _currentAnswer = answer;
    _answerEnd = CACurrentMediaTime();
}

@end
