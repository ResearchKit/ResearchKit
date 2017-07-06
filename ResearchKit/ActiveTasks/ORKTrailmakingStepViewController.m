/*
 Copyright (c) 2016, Motus Design Group Inc. All rights reserved.
 
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


#import "ORKTrailmakingStepViewController.h"

#import "ORKActiveStepTimer.h"
#import "ORKActiveStepView.h"
#import "ORKTrailmakingContentView.h"
#import "ORKCustomStepView_Internal.h"
#import "ORKRoundTappingButton.h"

#import "ORKActiveStepViewController_Internal.h"

#import "ORKTrailmakingStep.h"
#import "ORKStep_Private.h"
#import "ORKResult.h"

#import "ORKHelpers_Internal.h"
#import "ORKStepViewController_Internal.h"


#define BOUND(lo, hi, v) (((v) < (lo)) ? (lo) : (((v) > (hi)) ? (hi) : (v)))


@implementation ORKTrailmakingStepViewController {
    ORKTrailmakingContentView *_trailmakingContentView;
    NSArray *_testPoints;
    ORKTrailMakingTypeIdentifier _trailType;
    int _nextIndex;
    int _errors;
    NSMutableArray *_taps;
    NSTimer *_updateTimer;
    UILabel *_timerLabel;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        _testPoints = [self fetchRandomTest];
        _taps = [NSMutableArray array];
        
        if ([step isKindOfClass:[ORKTrailmakingStep class]]) {
            _trailType = [((ORKTrailmakingStep*)step) trailType];
        } else {
            _trailType = ORKTrailMakingTypeIdentifierA;
        }
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
    // Do any additional setup after loading the view.
    _trailmakingContentView = [[ORKTrailmakingContentView alloc] initWithType:_trailType];
    
    self.activeStepView.activeCustomView = _trailmakingContentView;
    
    for (ORKRoundTappingButton* b in _trailmakingContentView.tapButtons) {
        [b addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchDown];
    }
    
    _timerLabel = [[UILabel alloc] init];
    _timerLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:_timerLabel];
}

- (void)timerUpdated:(NSTimer*)timer {
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate: self.presentedDate];
    NSString *text = [NSString localizedStringWithFormat:ORKLocalizedString(@"TRAILMAKING_TIMER", nil), elapsed];
    
    if (_errors == 1) {
        text = [NSString localizedStringWithFormat:ORKLocalizedString(@"TRAILMAKING_ERROR", nil), text, _errors];
    } else if (_errors > 1) {
        text = [NSString localizedStringWithFormat:ORKLocalizedString(@"TRAILMAKING_ERROR_PLURAL", nil), text, _errors];
    }
    
    _timerLabel.text = text;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int screenSize = MAX(screenRect.size.width, screenRect.size.height);
    
    int cx;
    
    if (screenSize >= 736) {
        cx = 50;  // iPhone 6+/7+
    } else if (screenSize >= 667) {
        cx = 45; // iPhone 6/7
    } else {
        cx = 40;  // iPhone 5/SE
    }
    
    CGRect labelRect = _trailmakingContentView.testArea;
    labelRect.size.height = 20;
    [_timerLabel setFrame:labelRect];
    
    CGRect r = _trailmakingContentView.testArea;
        
    int idx = 0;
    
    for (ORKRoundTappingButton* b in _trailmakingContentView.tapButtons) {
        CGPoint pp = [[_testPoints objectAtIndex:idx] CGPointValue];
        
        if (r.size.width > r.size.height)
        {
            float temp = pp.x;
            pp.x = pp.y;
            pp.y = temp;
        }
        
        const int x = BOUND(5, r.size.width - cx - 5, pp.x * r.size.width);
        const int y = BOUND(5, r.size.height - cx - 5, pp.y * r.size.height);
        
        b.frame = CGRectMake(x, y, cx, cx);
        b.diameter = cx;
        
        idx++;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerUpdated:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_updateTimer != nil) {
        [_updateTimer invalidate];
        _updateTimer = nil;
    }
}

- (IBAction)buttonPressed:(id)button forEvent:(UIEvent *)event {
    NSUInteger buttonIndex = [_trailmakingContentView.tapButtons indexOfObject:button];
    if (buttonIndex != NSNotFound) {
        
        ORKTrailmakingTap* tap = [[ORKTrailmakingTap alloc] init];
        tap.timestamp = [[NSDate date] timeIntervalSinceDate: self.presentedDate];
        tap.index = buttonIndex;
        
        if (buttonIndex == _nextIndex) {
            _nextIndex++;
            
            _trailmakingContentView.linesToDraw = _nextIndex - 1;
            if (_nextIndex == _trailmakingContentView.tapButtons.count) {
                [self performSelector:@selector(finish) withObject:nil afterDelay:1.5];
                [_updateTimer invalidate];
                _updateTimer = nil;
            }
            tap.incorrect = NO;
            
            [_trailmakingContentView clearErrors];
        } else {
            _errors++;
            tap.incorrect = YES;
            
            [_trailmakingContentView clearErrors];
            [_trailmakingContentView setError:(int)buttonIndex];
        }
        [_taps addObject:tap];
    }
}

- (NSArray<NSString*>*)testData {
    static NSArray<NSString*> *testData;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        testData = @[
                     @"0.819257,0.121951,0.603041,0.214286,0.182432,0.121951,0.231419,0.490418,0.177365,0.836237,0.478041,0.812718,0.398649,0.442509,0.565878,0.670732,0.652027,0.804878,0.827703,0.343206,0.604730,0.306620,0.633446,0.533101,0.283784,0.267422",
                     @"0.779661,0.907746,0.722034,0.190601,0.906780,0.395997,0.869492,0.063534,0.161017,0.060923,0.223729,0.328111,0.105085,0.879896,0.286441,0.799826,0.461017,0.830287,0.505085,0.580505,0.654237,0.800696,0.640678,0.461271,0.337288,0.533507",
                     @"0.824027,0.881533,0.604061,0.790941,0.186125,0.876307,0.231810,0.509582,0.177665,0.163763,0.485618,0.183798,0.401015,0.554007,0.571912,0.332753,0.659898,0.195993,0.830795,0.657665,0.604061,0.695993,0.634518,0.466899,0.291032,0.735192",
                     @"0.777403,0.092334,0.728499,0.808362,0.905565,0.602787,0.854975,0.935540,0.166948,0.934669,0.225970,0.670732,0.109612,0.123693,0.288364,0.203833,0.463744,0.169861,0.505902,0.420732,0.654300,0.202962,0.644182,0.540941,0.338954,0.469512",
                     @"0.487310,0.475610,0.318105,0.262195,0.763113,0.186411,0.560068,0.758711,0.521151,0.614111,0.270728,0.450348,0.390863,0.865854,0.089679,0.935540,0.142132,0.686411,0.138748,0.141986,0.514382,0.164634,0.906937,0.082753,0.896785,0.710801",
                     @"0.634518,0.369338,0.678511,0.827526,0.448393,0.370209,0.509306,0.751742,0.257191,0.797909,0.087986,0.912021,0.145516,0.223868,0.076142,0.055749,0.873096,0.100174,0.912014,0.514808,0.737733,0.230836,0.839256,0.935540,0.411168,0.941638",
                     @"0.483871,0.530078,0.315789,0.744551,0.758913,0.816042,0.555178,0.242371,0.516129,0.391456,0.263158,0.552746,0.385399,0.136879,0.083192,0.071491,0.135823,0.315606,0.139219,0.861377,0.514431,0.838710,0.903226,0.919791,0.893039,0.293810",
                     @"0.633446,0.633827,0.673986,0.176112,0.445946,0.632084,0.503378,0.251962,0.260135,0.205754,0.087838,0.088056,0.146959,0.780296,0.081081,0.949433,0.869932,0.903226,0.908784,0.485615,0.736486,0.770706,0.837838,0.066260,0.410473,0.061029",
                     @"0.505068,0.481707,0.263514,0.751742,0.728041,0.816202,0.618243,0.162892,0.538851,0.323171,0.255068,0.577526,0.361486,0.136760,0.116554,0.087108,0.136824,0.418118,0.119932,0.890244,0.479730,0.837108,0.869932,0.922474,0.859797,0.438153",
                     @"0.587838,0.630662,0.699324,0.148955,0.479730,0.519164,0.481419,0.155052,0.263514,0.183798,0.076014,0.123693,0.231419,0.722997,0.131757,0.913763,0.878378,0.898955,0.912162,0.533972,0.711149,0.798781,0.854730,0.056620,0.334459,0.056620",
                     @"0.501689,0.523560,0.256757,0.253054,0.724662,0.185864,0.616554,0.841187,0.535473,0.678883,0.256757,0.424084,0.358108,0.866492,0.111486,0.915358,0.133446,0.583770,0.118243,0.109948,0.478041,0.164049,0.868243,0.079407,0.854730,0.564572",
                     @"0.587140,0.370435,0.695431,0.851304,0.478849,0.481739,0.483926,0.845217,0.265651,0.817391,0.074450,0.873043,0.233503,0.274783,0.133672,0.087826,0.878173,0.103478,0.920474,0.467826,0.717428,0.202609,0.852792,0.942609,0.314721,0.946087"
                     ];
    });
  return testData;
}

- (NSArray*)fetchRandomTest {
    const int testNum = arc4random_uniform((uint32_t)[[self testData] count]);
    const bool invertX = arc4random_uniform(2) == 1;
    const bool invertY = arc4random_uniform(2) == 1;
    const bool reverse = arc4random_uniform(2) == 1;
    
    NSMutableArray* points = [NSMutableArray array];
    NSString* testPointsStr = [self.testData objectAtIndex:testNum];
    NSArray* chunks = [testPointsStr componentsSeparatedByString:@","];
    
    for (int i = 0; i < chunks.count; i += 2) {
        CGPoint pp;
        pp.x = [[chunks objectAtIndex:i + 0] floatValue];
        pp.y = [[chunks objectAtIndex:i + 1] floatValue];
        
        if (invertX) pp.x = 1.0f - pp.x;
        if (invertY) pp.y = 1.0f - pp.y;
        
        [points addObject:[NSValue valueWithCGPoint:pp]];
    }
    
    return reverse ? [[points reverseObjectEnumerator] allObjects] : [points copy];
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    
    // "Now" is the end time of the result, which is either actually now,
    // or the last time we were in the responder chain.
    NSDate *now = stepResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:stepResult.results];
    
    ORKTrailmakingResult *trailmakingResult = [[ORKTrailmakingResult alloc] initWithIdentifier:self.step.identifier];
    trailmakingResult.startDate = stepResult.startDate;
    trailmakingResult.endDate = now;
    trailmakingResult.taps = [_taps copy];
    trailmakingResult.numberOfErrors = _errors;
    
    [results addObject:trailmakingResult];
    stepResult.results = [results copy];
    
    return stepResult;
}

@end
