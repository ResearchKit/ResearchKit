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


#import "CustomRecorder.h"
#import <ResearchKit/ResearchKit_Private.h>


@interface CustomRecorder () {
    UIView *_containerFiller;
}

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *records;

@end


@implementation CustomRecorder

- (void)viewController:(UIViewController *)viewController willStartStepWithView:(UIView *)view {
    [super viewController:viewController willStartStepWithView:view];
    self.containerView = view;
    
    // Here we try to keep the recorder self-contained by adding our own view to the container.
    // However, it might be better (as in, the results will be more clearly defined)
    // to add a custom view to the active step controller, and then
    // find that view here and attach to it.
    //
    // As it is, in this example we are adding constraints to "view" without
    // really owning its constraint space.
    [_containerFiller removeFromSuperview];
    _containerFiller = [UIView new];
    [_containerFiller setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containerView addSubview:_containerFiller];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[c]|" options:0 metrics:nil views:@{@"c":_containerFiller}]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[c]|" options:0 metrics:nil views:@{@"c":_containerFiller}]];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_containerFiller attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:160];
    heightConstraint.priority = UILayoutPriorityFittingSizeLevel;
    [_containerFiller addConstraint:heightConstraint];
    
    _containerFiller.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.25];
}

- (void)start {
    [super start];
    
    NSAssert(self.containerView != nil, @"No container view attached.");
    
    if (_button) {
        [_button removeFromSuperview];
    }
    
    _button = [UIButton buttonWithType:UIButtonTypeSystem];
    [_button setTitle:@"Tap here" forState:UIControlStateNormal];
    [_button setTranslatesAutoresizingMaskIntoConstraints:NO];
    _button.frame = CGRectInset(_containerView.bounds, 10, 10);
    _button.backgroundColor = [UIColor orangeColor];
    _button.hidden = YES;
    [_button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchDown];
    [_containerFiller addSubview:_button];
    [_containerFiller addConstraint:[NSLayoutConstraint constraintWithItem:_button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_containerFiller attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [_containerFiller addConstraint:[NSLayoutConstraint constraintWithItem:_button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_containerFiller attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    _records = [NSMutableArray array];
    
    [self.timer invalidate];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    });
}

- (IBAction)timerFired:(id)sender {
    _button.hidden = !_button.hidden;
    
    NSDictionary *dictionary = @{@"event": _button.hidden? @"buttonHide": @"buttonShow",
                                 @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
    
    [_records addObject:dictionary];
    
}

- (IBAction)buttonTapped:(id)sender {
    NSDictionary *dictionary = @{@"event": @"userTouchDown",
                                 @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
    
    [_records addObject:dictionary];
    
}

- (void)stop {
    [self doStopRecording];
    
    NSError *error = nil;
    ORKDataResult *result = nil;
    if (self.records) {
        NSLog(@"%@", self.records);
        result = [[ORKDataResult alloc] init];
        result.contentType = [self mimeType];
        result.data = [NSJSONSerialization dataWithJSONObject:self.records options:(NSJSONWritingOptions)0 error:&error];
        result.filename = self.fileName;
        self.records = nil;
    } else {
        error = [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:NSFileNoSuchFileError
                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Records object is nil.", nil)}];
    }
    
    id<ORKRecorderDelegate> localDelegate = self.delegate;
    if (! error)
    {
        if (localDelegate && [localDelegate respondsToSelector:@selector(recorder:didCompleteWithResult:)]) {
            [localDelegate recorder:self didCompleteWithResult:result];
        }
    } else {
        [self finishRecordingWithError:error];
    }
    
    [super stop];
}

- (void)doStopRecording {
    [self.timer invalidate];
    [_button removeFromSuperview];
    _button = nil;
    [_containerFiller removeFromSuperview];
    _containerFiller = nil;
}

- (void)finishRecordingWithError:(NSError *)error {
    [self doStopRecording];
    [super finishRecordingWithError:error];
}

- (NSString *)dataType {
    return @"tapTheButton";
}

- (NSString *)mimeType {
    return @"application/json";
}

- (NSString *)fileName {
    return @"tapTheButton.json";
}

@end


@implementation CustomRecorderConfiguration

- (instancetype)initWithIdentifier:(NSString *)identifier {
    return [super initWithIdentifier:identifier];
}

- (ORKRecorder *)recorderForStep:(ORKStep *)step outputDirectory:(NSURL *)outputDirectory {
    return [[CustomRecorder alloc] initWithIdentifier:self.identifier step:step outputDirectory:outputDirectory];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
}

@end
