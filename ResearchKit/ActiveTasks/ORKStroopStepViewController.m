/*
 Copyright (c) 2017, Apple Inc. All rights reserved.
 
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


#import "ORKStroopStepViewController.h"
#import "ORKActiveStepView.h"
#import "ORKStroopContentView.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKStroopResult.h"
#import "ORKResult_Private.h"
#import "ORKCollectionResult_Private.h"
#import "ORKStroopStep.h"
#import "ORKHelpers_Internal.h"
#import "ORKBorderedButton.h"


@interface ORKStroopStepViewController ()

@property (nonatomic, strong) ORKStroopContentView *stroopContentView;
@property (nonatomic, strong) NSMutableDictionary *colors;
@property (nonatomic, strong) NSMutableDictionary *differentColorLabels;
@property (nonatomic) NSUInteger questionNumber;

@end


@implementation ORKStroopStepViewController {
    UIColor *_red;
    UIColor *_green;
    UIColor *_blue;
    UIColor *_yellow;
    NSString *_redString;
    NSString *_greenString;
    NSString *_blueString;
    NSString *_yellowString;
    NSTimer *_nextQuestionTimer;
    
    NSMutableArray *_results;
    NSTimeInterval _startTime;
    NSTimeInterval _endTime;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        self.suspendIfInactive = YES;
    }
    
    return self;
}

- (ORKStroopStep *)stroopStep {
    return (ORKStroopStep *)self.step;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _results = [NSMutableArray new];
    _redString = ORKLocalizedString(@"STROOP_COLOR_RED", nil);
    _greenString = ORKLocalizedString(@"STROOP_COLOR_GREEN", nil);
    _blueString = ORKLocalizedString(@"STROOP_COLOR_BLUE", nil);
    _yellowString = ORKLocalizedString(@"STROOP_COLOR_YELLOW", nil);
    _red = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    _green = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    _blue = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    _yellow = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
    
    self.colors = [[NSMutableDictionary alloc] initWithObjectsAndKeys: _red, _redString, _blue, _blueString, _yellow, _yellowString, _green, _greenString, nil];
    
    self.differentColorLabels = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSArray arrayWithObjects:_blue,
                                                                                     _green,
                                                                                     _yellow, nil], _redString,
                                 [NSArray arrayWithObjects:_red,
                                  _green,
                                  _yellow, nil], _blueString,
                                 [NSArray arrayWithObjects:_red,
                                  _blue,
                                  _green, nil], _yellowString,
                                 [NSArray arrayWithObjects:_red,
                                  _blue,
                                  _yellow, nil], _greenString, nil];

    self.questionNumber = 0;
    _stroopContentView = [ORKStroopContentView new];
    self.activeStepView.activeCustomView = _stroopContentView;
    self.activeStepView.stepViewFillsAvailableSpace = YES;
    
    [self.stroopContentView.RButton addTarget:self
                                       action:@selector(buttonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
    [self.stroopContentView.GButton addTarget:self
                                       action:@selector(buttonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
    [self.stroopContentView.BButton addTarget:self
                                       action:@selector(buttonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
    [self.stroopContentView.YButton addTarget:self
                                       action:@selector(buttonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonPressed:(id)sender {
    if (![self.stroopContentView.colorLabelText isEqualToString:@" "]) {
        [self setButtonsDisabled];
        if (sender == self.stroopContentView.RButton) {
            [self createResult:[self.colors allKeysForObject:self.stroopContentView.colorLabelColor][0] withText:self.stroopContentView.colorLabelText withColorSelected:_redString];
        }
        else if (sender == self.stroopContentView.GButton) {
            [self createResult:[self.colors allKeysForObject:self.stroopContentView.colorLabelColor][0] withText:self.stroopContentView.colorLabelText withColorSelected:_greenString];
        }
        else if (sender == self.stroopContentView.BButton) {
            [self createResult:[self.colors allKeysForObject:self.stroopContentView.colorLabelColor][0] withText:self.stroopContentView.colorLabelText withColorSelected:_blueString];
        }
        else if (sender == self.stroopContentView.YButton) {
            [self createResult:[self.colors allKeysForObject:self.stroopContentView.colorLabelColor][0] withText:self.stroopContentView.colorLabelText withColorSelected:_yellowString];
        }
        self.stroopContentView.colorLabelText = @" ";
        _nextQuestionTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                             target:self
                                                           selector:@selector(startNextQuestionOrFinish)
                                                           userInfo:nil
                                                            repeats:NO];
    }
}

- (void)startNextQuestionTimer {
    _nextQuestionTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                         target:self
                                                       selector:@selector(startNextQuestionOrFinish)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
}

- (void)stepDidFinish {
    [super stepDidFinish];
    [self.stroopContentView finishStep:self];
    [self goForward];
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    if (_results) {
         stepResult.results = [_results copy];
    }
    return stepResult;
}

- (void)start {
    [super start];
    [self startQuestion];
}


#pragma mark - ORKResult

- (void)createResult:(NSString *)color withText:(NSString *)text withColorSelected:(NSString *)colorSelected {
    ORKStroopResult *stroopResult = [[ORKStroopResult alloc] initWithIdentifier:self.step.identifier];
    stroopResult.startTime = _startTime;
    stroopResult.endTime =  [NSProcessInfo processInfo].systemUptime;
    stroopResult.color = color;
    stroopResult.text = text;
    stroopResult.colorSelected = colorSelected;
    [_results addObject:stroopResult];
}

- (void)startNextQuestionOrFinish {
    self.questionNumber = self.questionNumber + 1;
    if (self.questionNumber == ([self stroopStep].numberOfAttempts)) {
        [self finish];
    } else {
        [self startQuestion];
    }
}

- (void)startQuestion {
    int pattern = arc4random() % 2;
    if (pattern == 0) {
        int index = arc4random() % [self.colors.allKeys count];
        NSString *text = [self.colors.allKeys objectAtIndex:index];
        self.stroopContentView.colorLabelText = text;
        UIColor *color = [self.colors valueForKey:text];
        self.stroopContentView.colorLabelColor = color;
    }
    else {
        int index = arc4random() % [self.differentColorLabels.allKeys count];
        NSString *text = [self.differentColorLabels.allKeys objectAtIndex:index];
        self.stroopContentView.colorLabelText = text;
        NSArray *colorArray = [self.differentColorLabels valueForKey:text];
        int randomColor = arc4random() % colorArray.count;
        UIColor *color = [colorArray objectAtIndex:randomColor];
        self.stroopContentView.colorLabelColor = color;
    }
    [self setButtonsEnabled];
    _startTime = [NSProcessInfo processInfo].systemUptime;
}

- (void)setButtonsDisabled {
    [self.stroopContentView.RButton setEnabled: NO];
    [self.stroopContentView.GButton setEnabled: NO];
    [self.stroopContentView.BButton setEnabled: NO];
    [self.stroopContentView.YButton setEnabled: NO];
}

- (void)setButtonsEnabled {
    [self.stroopContentView.RButton setEnabled: YES];
    [self.stroopContentView.GButton setEnabled: YES];
    [self.stroopContentView.BButton setEnabled: YES];
    [self.stroopContentView.YButton setEnabled: YES];
}

@end
