/*
 Copyright (c) 2026, Daniel Emden. All rights reserved.

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

@import XCTest;
@import ResearchKit_Private;
@import ResearchKitUI_Private;
@import ResearchKitActiveTask;
@import ResearchKitActiveTask_Private;

@interface ORKNavigationContainerView (EarlyFinishTesting)
- (void)continueAction:(id)sender;
@end

@interface ORKAudioStepViewController (EarlyFinishTesting)
- (BOOL)canFinishEarly;
- (void)finishEarly:(id)sender;
- (void)doSample;
- (void)startRecording;
@end

// Exercise the real controller/timer/finish path while replacing only recorder I/O.
@interface ORKAudioEarlyFinishControllerSpy : ORKAudioStepViewController
@property (nonatomic) NSUInteger recorderStarts;
@property (nonatomic) NSUInteger recorderStops;
@property (nonatomic) NSUInteger forwardCount;
@property (nonatomic, copy) void (^onFinish)(void);
@end
@implementation ORKAudioEarlyFinishControllerSpy
- (void)prepareRecorders {}
- (void)startRecorders { self.recorderStarts++; }
- (void)stopRecorders { self.recorderStops++; }
- (void)goForward { self.forwardCount++; }
- (void)stepDidFinish {
    [super stepDidFinish];
    if (self.onFinish) {
        self.onFinish();
    }
}
@end

@interface ORKAudioEarlyFinishTests : XCTestCase
@end
@implementation ORKAudioEarlyFinishTests

- (ORKAudioStep *)stepWithMinimum:(NSTimeInterval)minimum {
    ORKAudioStep *step = [[ORKAudioStep alloc] initWithIdentifier:@"audio"];
    step.stepDuration = 180;
    step.allowsEarlyFinish = YES;
    step.minDuration = minimum;
    step.shouldContinueOnFinish = YES;
    return step;
}

- (ORKAudioEarlyFinishControllerSpy *)controllerWithMinimum:(NSTimeInterval)minimum {
    ORKAudioEarlyFinishControllerSpy *controller = [[ORKAudioEarlyFinishControllerSpy alloc] initWithStep:[self stepWithMinimum:minimum]];
    [controller loadViewIfNeeded];
    return controller;
}

// Seed the real timer instead of waiting a minute per boundary assertion.
- (ORKActiveStepTimer *)setElapsed:(NSTimeInterval)elapsed on:(ORKAudioEarlyFinishControllerSpy *)controller {
    ORKActiveStepTimer *previous = [controller valueForKey:@"timer"];
    XCTAssertNotNil(previous);
    [previous reset];
    ORKActiveStepTimer *timer = [[ORKActiveStepTimer alloc] initWithDuration:180 interval:0.02 runtime:elapsed handler:previous.handler];
    [controller setValue:timer forKey:@"timer"];
    [controller doSample];
    return timer;
}

- (void)testExistingFactoryKeepsEarlyFinishDisabled {
    ORKNavigableOrderedTask *task = [ORKOrderedTask audioTaskWithIdentifier:@"speech" intendedUseDescription:nil speechInstruction:nil shortSpeechInstruction:nil duration:180 recordingSettings:nil checkAudioLevel:YES options:0];
    ORKAudioStep *step = (id)[task stepWithIdentifier:ORKAudioStepIdentifier];
    XCTAssertFalse(step.allowsEarlyFinish);
    XCTAssertEqual(step.minDuration, 0);
}

- (void)testEarlyFinishFactoriesKeepSettingsIdentifiersAndNavigation {
    NSDictionary *settings = @{AVFormatIDKey: @(kAudioFormatMPEG4AAC), AVSampleRateKey: @48000, AVNumberOfChannelsKey: @1};
    NSURL *directory = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    for (NSNumber *explicitDirectory in @[@NO, @YES]) {
        ORKNavigableOrderedTask *task = explicitDirectory.boolValue
            ? [ORKOrderedTask audioTaskWithIdentifier:@"speech" intendedUseDescription:nil speechInstruction:@"Speak" shortSpeechInstruction:@"Speak" duration:180 minDuration:60 recordingSettings:settings checkAudioLevel:YES options:0 outputDirectory:directory]
            : [ORKOrderedTask audioTaskWithIdentifier:@"speech" intendedUseDescription:nil speechInstruction:@"Speak" shortSpeechInstruction:@"Speak" duration:180 minDuration:60 recordingSettings:settings checkAudioLevel:YES options:0];
        ORKAudioStep *step = (id)[task stepWithIdentifier:ORKAudioStepIdentifier];
        XCTAssertTrue(step.allowsEarlyFinish);
        XCTAssertTrue(step.shouldContinueOnFinish);
        XCTAssertEqual(step.minDuration, 60);
        XCTAssertEqual(step.stepDuration, 180);
        ORKAudioRecorderConfiguration *config = (id)step.recorderConfigurations.firstObject;
        XCTAssertEqualObjects(config.identifier, ORKAudioRecorderIdentifier);
        XCTAssertEqualObjects(config.recorderSettings, settings);
        if (explicitDirectory.boolValue) { XCTAssertEqualObjects(config.outputDirectory, directory); }
        XCTAssertNotNil([task stepWithIdentifier:ORKCountdownStepIdentifier]);
        XCTAssertNotNil([task navigationRuleForTriggerStepIdentifier:ORKCountdownStepIdentifier]);
    }
}

- (void)testCopyAndSecureArchivePreserveMinimum {
    ORKAudioStep *step = [self stepWithMinimum:60];
    ORKAudioStep *copy = [step copy];
    XCTAssertEqualObjects(copy, step);
    XCTAssertTrue(copy.allowsEarlyFinish);
    XCTAssertEqual(copy.minDuration, 60);
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:step requiringSecureCoding:YES error:nil];
    NSError *error = nil;
    ORKAudioStep *decoded = [NSKeyedUnarchiver unarchivedObjectOfClass:ORKAudioStep.class fromData:data error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(decoded, step);
    XCTAssertTrue(decoded.allowsEarlyFinish);
    XCTAssertEqual(decoded.minDuration, 60);
    copy.minDuration = 45;
    XCTAssertNotEqualObjects(copy, step);
}

- (void)testInvalidMinimumIsRejected {
    for (NSNumber *value in @[@(-1), @(NAN), @(INFINITY), @(181)]) {
        ORKAudioStep *step = [self stepWithMinimum:value.doubleValue];
        XCTAssertThrowsSpecificNamed([step validateParameters], NSException, NSInvalidArgumentException);
    }
    ORKAudioStep *manual = [self stepWithMinimum:60];
    manual.useRecordButton = YES;
    XCTAssertThrowsSpecificNamed([manual validateParameters], NSException, NSInvalidArgumentException);
    XCTAssertNoThrow([[self stepWithMinimum:0] validateParameters]);
    XCTAssertNoThrow([[self stepWithMinimum:180] validateParameters]);
}

- (void)testButtonCannotFinishBeforeRecordingOrBeforeMinimum {
    ORKAudioEarlyFinishControllerSpy *vc = [self controllerWithMinimum:60];
    XCTAssertFalse([vc canFinishEarly]);
    XCTAssertFalse(vc.activeStepView.navigationFooterView.continueEnabled);
    [vc finishEarly:nil];
    XCTAssertFalse(vc.finished);
    [vc start];
    [self setElapsed:59.99 on:vc];
    XCTAssertFalse([vc canFinishEarly]);
    [vc finishEarly:nil];
    XCTAssertEqual(vc.recorderStops, 0u);
    [self setElapsed:60 on:vc];
    XCTAssertTrue([vc canFinishEarly]);
    XCTAssertTrue(vc.activeStepView.navigationFooterView.continueEnabled);
    UIBarButtonItem *item = vc.activeStepView.navigationFooterView.continueButtonItem;
    XCTAssertEqualObjects(item.accessibilityIdentifier, @"ORKAudioEarlyFinish");
    [vc.activeStepView.navigationFooterView continueAction:nil];
    XCTAssertTrue(vc.finished);
    XCTAssertEqual(vc.recorderStops, 1u);
    XCTAssertEqual(vc.forwardCount, 1u);
    [vc finishEarly:nil];
    [vc finish];
    [vc resume];
    XCTAssertEqual(vc.recorderStops, 1u);
    XCTAssertEqual(vc.recorderStarts, 1u);
    XCTAssertEqual(vc.forwardCount, 1u);
}

- (void)testZeroMinimumOnlyEnablesAfterStart {
    ORKAudioEarlyFinishControllerSpy *vc = [self controllerWithMinimum:0];
    XCTAssertFalse([vc canFinishEarly]);
    [vc start];
    XCTAssertTrue([vc canFinishEarly]);
    [vc finishEarly:nil];
    XCTAssertTrue(vc.finished);
}

- (void)testSuspensionDoesNotCountAndResumeKeepsElapsedTime {
    ORKAudioEarlyFinishControllerSpy *vc = [self controllerWithMinimum:60];
    [vc start];
    ORKActiveStepTimer *timer = [self setElapsed:45 on:vc];
    [vc suspend];
    XCTAssertFalse([vc canFinishEarly]);
    XCTAssertEqualWithAccuracy(timer.runtime, 45, 0.001);
    [vc finishEarly:nil];
    XCTAssertFalse(vc.finished);
    [vc resume];
    XCTAssertEqual([vc valueForKey:@"timer"], timer);
    XCTAssertEqualWithAccuracy(timer.runtime, 45, 0.1);
    XCTAssertFalse([vc canFinishEarly]);
    [self setElapsed:60 on:vc];
    XCTAssertTrue([vc canFinishEarly]);
    [vc finishEarly:nil];
}

- (void)testRestartResetsMinimumAndOldTimerCannotFinishNewRecording {
    ORKAudioEarlyFinishControllerSpy *vc = [self controllerWithMinimum:60];
    [vc start];
    ORKActiveStepTimer *oldTimer = [self setElapsed:90 on:vc];
    [vc suspend];
    [vc start];
    XCTAssertFalse([vc canFinishEarly]);
    oldTimer.handler(oldTimer, YES);
    XCTAssertFalse(vc.finished);
    [vc finish];
}

- (void)testAutomaticTimeoutStillFinishesExactlyOnce {
    ORKAudioEarlyFinishControllerSpy *vc = [self controllerWithMinimum:60];
    XCTestExpectation *done = [self expectationWithDescription:@"automatic recording completion"];
    vc.onFinish = ^{ [done fulfill]; };
    [vc start];
    ORKActiveStepTimer *timer = [self setElapsed:179.99 on:vc];
    [timer resume];
    [self waitForExpectations:@[done] timeout:2];
    XCTAssertTrue(vc.finished);
    XCTAssertEqual(vc.recorderStops, 1u);
    XCTAssertEqual(vc.forwardCount, 1u);
    timer.handler(timer, YES);
    XCTAssertEqual(vc.forwardCount, 1u);
}

- (void)testErrorPreventsEarlyFinishAndPausesTimer {
    ORKAudioEarlyFinishControllerSpy *vc = [self controllerWithMinimum:60];
    [vc start];
    ORKActiveStepTimer *timer = [self setElapsed:60 on:vc];
    ORKAudioRecorderConfiguration *config = [[ORKAudioRecorderConfiguration alloc] initWithIdentifier:@"test" recorderSettings:@{}];
    [vc recorder:[config recorderForStep:vc.step] didFailWithError:[NSError errorWithDomain:@"test" code:1 userInfo:nil]];
    XCTAssertFalse(vc.activeStepView.navigationFooterView.continueEnabled);
    XCTAssertEqualWithAccuracy(timer.runtime, 60, 0.001);
    XCTAssertFalse([vc canFinishEarly]);
    [vc finishEarly:nil];
    XCTAssertFalse(vc.finished);
    [timer reset];
}
- (void)testOldSuperclassTimerCannotFinishRestartedRecording {
    ORKAudioEarlyFinishControllerSpy *controller = [self controllerWithMinimum:60];
    [controller start];
    ORKActiveStepTimer *oldTimer = [controller valueForKey:@"activeStepTimer"];
    [controller suspend];
    [controller start];
    oldTimer.handler(oldTimer, YES);
    XCTAssertFalse(controller.finished);
    XCTAssertFalse([controller canFinishEarly]);
    [controller finish];
}

- (void)testExistingTimedRecordingDoesNotOfferEarlyFinish {
    ORKAudioStep *step = [[ORKAudioStep alloc] initWithIdentifier:@"audio"];
    step.stepDuration = 180;
    step.shouldContinueOnFinish = YES;
    ORKAudioEarlyFinishControllerSpy *controller = [[ORKAudioEarlyFinishControllerSpy alloc] initWithStep:step];
    [controller loadViewIfNeeded];
    [controller start];
    ORKActiveStepTimer *timer = [self setElapsed:180 on:controller];
    XCTAssertFalse([controller canFinishEarly]);
    XCTAssertTrue(controller.activeStepView.navigationFooterView.neverHasContinueButton);
    [controller finishEarly:nil];
    XCTAssertFalse(controller.finished);
    timer.handler(timer, YES);
    XCTAssertTrue(controller.finished);
    XCTAssertEqual(controller.forwardCount, 1u);
}

- (void)testExistingRecordButtonModesStillStartAndStop {
    for (NSNumber *duration in @[@0, @20]) {
        ORKAudioStep *step = [[ORKAudioStep alloc] initWithIdentifier:@"audio"];
        step.useRecordButton = YES;
        step.stepDuration = duration.doubleValue;
        step.shouldContinueOnFinish = YES;
        XCTAssertNoThrow([step validateParameters]);
        ORKAudioEarlyFinishControllerSpy *controller = [[ORKAudioEarlyFinishControllerSpy alloc] initWithStep:step];
        [controller loadViewIfNeeded];
        [controller start];
        XCTAssertEqual(controller.recorderStarts, 0u);
        [controller startRecording];
        XCTAssertEqual(controller.recorderStarts, 1u);
        XCTAssertFalse([controller canFinishEarly]);
        [controller finish];
        XCTAssertEqual(controller.recorderStops, 1u);
        XCTAssertEqual(controller.forwardCount, 1u);
    }
}

- (void)testEarlyFinishRestoresContinueButtonWhenNotAutomaticallyAdvancing {
    ORKAudioStep *step = [self stepWithMinimum:0];
    step.shouldContinueOnFinish = NO;
    ORKAudioEarlyFinishControllerSpy *controller = [[ORKAudioEarlyFinishControllerSpy alloc] initWithStep:step];
    [controller loadViewIfNeeded];
    UIBarButtonItem *continueItem = controller.continueButtonItem;
    [controller start];
    [controller.activeStepView.navigationFooterView continueAction:nil];
    XCTAssertTrue(controller.finished);
    XCTAssertEqual(controller.recorderStops, 1u);
    XCTAssertEqual(controller.forwardCount, 0u);
    XCTAssertEqual(controller.activeStepView.navigationFooterView.continueButtonItem, continueItem);
    XCTAssertFalse(controller.activeStepView.navigationFooterView.neverHasContinueButton);
    XCTAssertTrue(controller.activeStepView.navigationFooterView.continueEnabled);
    [controller.activeStepView.navigationFooterView continueAction:nil];
    XCTAssertEqual(controller.forwardCount, 1u);
    XCTAssertEqual(controller.recorderStops, 1u);
}

- (void)testFactoryRejectsInvalidMinimum {
    for (NSNumber *minimum in @[@(-1), @(NAN), @(INFINITY), @21]) {
        XCTAssertThrowsSpecificNamed([ORKOrderedTask audioTaskWithIdentifier:@"audio"
                                                   intendedUseDescription:nil
                                                        speechInstruction:nil
                                                   shortSpeechInstruction:nil
                                                                 duration:20
                                                              minDuration:minimum.doubleValue
                                                        recordingSettings:nil
                                                          checkAudioLevel:NO
                                                                  options:0],
                                    NSException, NSInvalidArgumentException);
    }
}

@end
