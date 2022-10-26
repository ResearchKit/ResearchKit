/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import <Foundation/Foundation.h>
#import <ResearchKit/ORKAudioFitnessStepViewController.h>

@import XCTest;

@interface ORKMockAudioPlayer : NSObject <ORKAudioPlayer>
@property BOOL didPrepare;
@property BOOL didPlay;
@property BOOL didPause;
@property BOOL didStop;
@end

@implementation ORKMockAudioPlayer

- (BOOL)prepareToPlay {
    self.didPrepare = YES;
    return YES;
}

- (BOOL)play {
    self.didPlay = YES;
    return YES;
}

- (void)pause {
    self.didPause = YES;
}

- (void)stop {
    self.didStop = YES;
}

@end

@interface ORKMockAudioFitnessStepViewController : ORKAudioFitnessStepViewController
@property (nonatomic) ORKMockAudioPlayer *mockPlayer;
@end

@implementation ORKMockAudioFitnessStepViewController

- (id<ORKAudioPlayer>)audioPlayer {
    return self.mockPlayer;
}

- (ORKMockAudioPlayer*)mockPlayer {
    if (!_mockPlayer) {
        _mockPlayer = [[ORKMockAudioPlayer alloc] init];
    }
    return _mockPlayer;
}

@end

@interface ORKAudioFitnessStepViewControllerTests : XCTestCase {
    ORKMockAudioFitnessStepViewController *audioFitnessStepViewController;
}
@end

@implementation ORKAudioFitnessStepViewControllerTests

- (void)setUp {
    audioFitnessStepViewController = [[ORKMockAudioFitnessStepViewController alloc] init];
}

- (void)tearDown {
    audioFitnessStepViewController = nil;
}

- (void)testLoadingViewPreparesAudioToPlay {
    [audioFitnessStepViewController viewDidLoad];
    XCTAssertTrue(audioFitnessStepViewController.mockPlayer.didPrepare);
}

- (void)testStartingTheTaskPlaysAudio {
    [audioFitnessStepViewController start];
    XCTAssertTrue(audioFitnessStepViewController.mockPlayer.didPlay);
}

- (void)testSuspendingTheTaskPausesAudio {
    [audioFitnessStepViewController suspend];
    XCTAssertTrue(audioFitnessStepViewController.mockPlayer.didPause);
}

- (void)testResumingTheTaskResumeAudio {
    [audioFitnessStepViewController resume];
    XCTAssertTrue(audioFitnessStepViewController.mockPlayer.didPlay);
}

- (void)testFinishingTheTaskStopsAudio {
    [audioFitnessStepViewController finish];
    XCTAssertTrue(audioFitnessStepViewController.mockPlayer.didStop);
}

@end
