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


#import <AVFoundation/AVFoundation.h>

#import "ORKVisualConsentTransitionAnimator.h"
#import "ORKVisualConsentStepViewController.h"
#import "ORKHelpers.h"

#import "ORKEAGLMoviePlayerView.h"
#import "ORKVisualConsentStepViewController_Internal.h"


// Internal object to hold the direction we're animating, the phase of the animation, and the animation completion handler.
@interface ORKVisualConsentAnimationContext : NSObject

@property (nonatomic, assign) UIPageViewControllerNavigationDirection direction;
@property (nonatomic, assign) BOOL hasCalledLoadHandler;
@property (nonatomic, copy) ORKVisualConsentAnimationCompletionHandler handler;
@property (nonatomic, copy) ORKVisualConsentAnimationCompletionHandler loadHandler;

@property (nonatomic, strong) NSValue *startTime;

// Establish a retain cycle by setting this to ourselves, to lengthen lifetime
@property (nonatomic, strong) id selfReference;

@end


@implementation ORKVisualConsentAnimationContext

@end


@interface ORKVisualConsentTransitionAnimator () <AVPlayerItemOutputPullDelegate>

@end


@implementation ORKVisualConsentTransitionAnimator {
    __weak ORKVisualConsentStepViewController *_stepViewController;
    NSURL *_movieURL;
    AVPlayer *_moviePlayer;
    AVPlayerItem *_playerItem;
    
    BOOL _observingPlayerStatusKey;
    BOOL _observingPlayerItemDurationKey;
    
    CADisplayLink *_displayLink;
    AVPlayerItemVideoOutput *_videoOutput;
    dispatch_queue_t _videoOutputQueue;
    NSInteger _frameCounter;
    ORKVisualConsentAnimationContext *_pendingContext;
}

- (instancetype)initWithVisualConsentStepViewController:(ORKVisualConsentStepViewController *)stepViewController
                                               movieURL:(NSURL *)movieURL {
    self = [super init];
    if (self) {
        NSParameterAssert(stepViewController != nil);
        NSParameterAssert(movieURL != nil);
        
        _stepViewController = stepViewController;
        _movieURL = [movieURL copy];
        
        _moviePlayer = [[AVPlayer alloc] init];
        _moviePlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        
        // Setup CADisplayLink which will callback displayPixelBuffer: at every vsync.
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [_displayLink setPaused:YES];
        
        // Setup AVPlayerItemVideoOutput with the required pixelbuffer attributes.
        NSDictionary *pixelBufferAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
        _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixelBufferAttributes];
        _videoOutputQueue = dispatch_queue_create("_ork_animationVideoQueue", DISPATCH_QUEUE_SERIAL);
        [_videoOutput setDelegate:self queue:_videoOutputQueue];
    }
    return self;
}

- (NSURL *)movieURL {
    return _movieURL;
}

- (void)animateTransitionWithDirection:(UIPageViewControllerNavigationDirection)direction
                           loadHandler:(ORKVisualConsentAnimationCompletionHandler)loadHandler
                     completionHandler:(ORKVisualConsentAnimationCompletionHandler)handler {
    ORKVisualConsentAnimationContext *context = [ORKVisualConsentAnimationContext new];
    context.handler = handler;
    context.direction = direction;
    context.loadHandler = loadHandler;
    
    _playerItem = [AVPlayerItem playerItemWithURL:_movieURL];
    
    [_playerItem addOutput:_videoOutput];
    [_moviePlayer replaceCurrentItemWithPlayerItem:_playerItem];
    [_videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0.015];
    
    context.startTime = [NSValue valueWithCMTime:CMTimeMake(0, NSEC_PER_SEC)];
    
    [self attemptAnimationWithContext:context];
}

- (void)attemptAnimationWithContext:(ORKVisualConsentAnimationContext *)context {
    BOOL playerIsReady = [_moviePlayer status] == AVPlayerStatusReadyToPlay;
    BOOL playerItemIsReady = CMTimeGetSeconds([_playerItem duration]) > 0;
    
    // Observe the properties for which we still need to wait
    if (!playerIsReady && !_observingPlayerStatusKey) {
        [_moviePlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:(void *)context];
        _observingPlayerStatusKey = YES;
        context.selfReference = context;
    }
    if (!playerItemIsReady && !_observingPlayerItemDurationKey) {
        [_playerItem addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:(void *)context];
        _observingPlayerItemDurationKey = YES;
        context.selfReference = context;
    }
    
    // Stop observing properties that have now changed to a ready state
    if (playerIsReady && _observingPlayerStatusKey) {
        [_moviePlayer removeObserver:self forKeyPath:@"status"];
        _observingPlayerStatusKey = NO;
    }
    if (playerItemIsReady && _observingPlayerItemDurationKey) {
        [_playerItem removeObserver:self forKeyPath:@"duration"];
        _observingPlayerItemDurationKey = NO;
    }
    
    if (playerIsReady && playerItemIsReady) {
        context.selfReference = nil;
        [self performAnimationWithContext:context];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    ORKVisualConsentAnimationContext *animationContext = (__bridge ORKVisualConsentAnimationContext *)context;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (([keyPath isEqualToString:@"status"] && object == _moviePlayer) ||
            ([keyPath isEqualToString:@"duration"] && object == _playerItem)) {
            if (_moviePlayer.error) {
                ORK_Log_Warning(@"%@", _moviePlayer.error);
            }
            
            [self attemptAnimationWithContext:animationContext];
        }
    });
}

- (void)playbackDidFinish:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:notification.object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:notification.object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:notification.object];
    
    [_moviePlayer pause];
    
    [self finishAnimationWithContext:_pendingContext];
}

- (void)performAnimationWithContext:(ORKVisualConsentAnimationContext *)context {
    
    _pendingContext = context;
    
    [[_stepViewController animationPlayerView] setupGL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_moviePlayer currentItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:[_moviePlayer currentItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:AVPlayerItemPlaybackStalledNotification object:[_moviePlayer currentItem]];
    
    __weak AVPlayer *weakPlayer = _moviePlayer;
    [_moviePlayer seekToTime:context.startTime.CMTimeValue
             toleranceBefore:CMTimeMake(NSEC_PER_SEC * (1.0 / 60.0), NSEC_PER_SEC) toleranceAfter:CMTimeMake(NSEC_PER_SEC * (1.0 / 60.0), NSEC_PER_SEC)  completionHandler:^(BOOL finished) {
                 AVPlayer *localPlayer = weakPlayer;
                 [localPlayer play];
             }];
}

- (void)finishAnimationWithContext:(ORKVisualConsentAnimationContext *)context {
    if (context == _pendingContext) {
        _pendingContext = nil;
    }
    
    if (context.handler) {
        context.handler(self, context.direction);
    }
    
    // Clear the handler so it is not called twice
    context.handler = nil;
    // Make sure the context is released
    context.selfReference = nil;
}

#pragma mark - CADisplayLink Callback

- (void)initialFrameDidDisplay {
    // Once our initial frame has definitely been drawn, we make ourselves visible
    // and signal the caller that the animation has started.
    ORKEAGLMoviePlayerView *playerView = [_stepViewController animationPlayerView];
    playerView.hidden = NO;
    
    if (_pendingContext && !_pendingContext.hasCalledLoadHandler) {
        if (_pendingContext.loadHandler) {
            _pendingContext.loadHandler(self, _pendingContext.direction);
        }
        _pendingContext.hasCalledLoadHandler = YES;
    }
}

- (void)displayLinkCallback:(CADisplayLink *)sender {
    /*
     The callback gets called once every Vsync.
     Using the display link's timestamp and duration we can compute the next time the screen will be refreshed, and copy the pixel buffer for that time
     This pixel buffer can then be processed and later rendered on screen.
     */
    CMTime outputItemTime = kCMTimeInvalid;
    
    // Calculate the nextVsync time which is when the screen will be refreshed next.
    CFTimeInterval nextVSync = ([sender timestamp] + [sender duration]);
    
    outputItemTime = [_videoOutput itemTimeForHostTime:nextVSync];
    
    if ([_videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
        CVPixelBufferRef pixelBuffer = NULL;
        pixelBuffer = [_videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
        
        ORKEAGLMoviePlayerView *playerView = [_stepViewController animationPlayerView];
        CGSize playerItemPresentationSize = _playerItem.presentationSize;
        if (!CGSizeEqualToSize(playerView.presentationSize, playerItemPresentationSize)) {
            playerView.presentationSize = playerItemPresentationSize;
        }
        BOOL canDisplay = [playerView consumePixelBuffer:pixelBuffer];
        if (pixelBuffer != NULL) {
            CFRelease(pixelBuffer);
            pixelBuffer = NULL;
        }
        if (canDisplay) {
            [playerView render];
        }
        
        if (_frameCounter == 1) {
            [self initialFrameDidDisplay];
        }
        _frameCounter ++;
    }
}

#pragma mark - AVPlayerItemOutputPullDelegate

- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender {
    // Restart display link.
    [_displayLink setPaused:NO];
    _frameCounter = 0;
}

- (void)finish {
    [_moviePlayer pause];
    [_displayLink invalidate]; // This makes animator single-use
    
    if (_observingPlayerStatusKey) {
        [_moviePlayer removeObserver:self forKeyPath:@"status"];
        _observingPlayerStatusKey = NO;
    }
    if (_observingPlayerItemDurationKey) {
        [_playerItem removeObserver:self forKeyPath:@"duration"];
        _observingPlayerItemDurationKey = NO;
    }
    
    _videoOutputQueue = nil;
    _moviePlayer = nil;
    _displayLink = nil;
    _pendingContext = nil;
    _videoOutput = nil;
    _videoOutputQueue = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
