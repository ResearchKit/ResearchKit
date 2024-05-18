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


#import "ORKTouchRecorder.h"

#import "ORKDataLogger.h"

#import "ORKRecorder_Internal.h"

#import "UITouch+ORKJSONDictionary.h"


@protocol ORKTouchRecordingDelegate <NSObject>

- (void)view:(UIView *)view didDetectTouch:(UITouch *)touch;

@end


@interface ORKTouchGestureRecognizer : UIGestureRecognizer

@property (nonatomic, weak) id<ORKTouchRecordingDelegate> eventDelegate;

@end


@implementation ORKTouchGestureRecognizer

- (void)reportTouches:(NSSet *)touches {
    
    for (UITouch *touch in touches) {
        [self.eventDelegate view:self.view didDetectTouch:touch];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self reportTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self reportTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self reportTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self reportTouches:touches];
}

@end


@interface ORKTouchRecordingView : UIView

@property (nonatomic, weak) id<ORKTouchRecordingDelegate> delegate;

@end


@interface ORKTouchRecorder () <ORKTouchRecordingDelegate> {
    ORKDataLogger *_logger;
}

@property (nonatomic, strong) ORKTouchGestureRecognizer *gestureRecognizer;

@property (nonatomic, strong) NSMutableArray *touchArray;

@property (nonatomic) NSTimeInterval uptime;

@property (nonatomic, strong) NSError *recordingError;

@end


@implementation ORKTouchRecorder

- (void)dealloc {
    [_logger finishCurrentLog];
}

- (void)viewController:(UIViewController *)viewController willStartStepWithView:(UIView *)view {
    if (self.isRecording == NO) {
        _touchView = view;
    }
}

- (void)start {
    if (!_logger) {
        NSError *error = nil;
        _logger = [self makeJSONDataLoggerWithError:&error];
        if (!_logger) {
            [self finishRecordingWithError:error];
            return;
        }
    }
    
    if (self.touchView) {
        [self.touchView addGestureRecognizer:self.gestureRecognizer];
        
        [super start];
        
        self.touchArray = [NSMutableArray array];
        _uptime = [NSProcessInfo processInfo].systemUptime;
    } else {
        @throw [NSException exceptionWithName:NSGenericException
                                       reason:@"No touch capture view provided"
                                     userInfo:@{@"recorder": self}];
    }
}

- (ORKTouchGestureRecognizer *)gestureRecognizer {
    if (_gestureRecognizer == nil) {
        _gestureRecognizer = [ORKTouchGestureRecognizer new];
        _gestureRecognizer.eventDelegate = self;
    }
    return _gestureRecognizer;
}

- (void)stop {
    [self doStopRecording];
    [_logger finishCurrentLog];
    
    NSError *error = nil;
    __block NSURL *fileUrl = nil;
    [_logger enumerateLogs:^(NSURL *logFileUrl, BOOL *stop) {
        fileUrl = logFileUrl;
    } error:&error];
    
    [self reportFileResultWithFile:fileUrl error:error];
    
    [super stop];
}

- (void)doStopRecording {
    if (_touchView) {
        [self.touchView removeGestureRecognizer:self.gestureRecognizer];
        _touchView = nil;
    }
}

- (void)finishRecordingWithError:(NSError *)error {
    [self doStopRecording];
    [super finishRecordingWithError:error];
}

- (NSString *)recorderType {
    return @"touch";
}

- (NSString *)mimeType {
    return @"application/json";
}

- (void)reset {
    [super reset];
    
    _logger = nil;
}

#pragma mark - ORKTouchRecordingDelegate

- (void)view:(UIView *)view didDetectTouch:(UITouch *)touch {
    
    if ([self.touchArray containsObject:touch] == NO) {
        [self.touchArray addObject:touch];
    }
    
    NSError *error = nil;
    if (![_logger append:[touch ork_JSONDictionaryInView:view allTouches:self.touchArray] error:&error]) {
        assert(error != nil);
        [self finishRecordingWithError:error];
    }
}

@end


@implementation ORKTouchRecorderConfiguration

- (instancetype)initWithIdentifier:(NSString *)identifier {
    return [super initWithIdentifier:identifier];
}

- (ORKRecorder *)recorderForStep:(ORKStep *)step outputDirectory:(NSURL *)outputDirectory {
    ORKTouchRecorder *recorder = [[ORKTouchRecorder alloc] initWithIdentifier:self.identifier
                                                                         step:step
                                                              outputDirectory:outputDirectory];
    return recorder;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [super initWithCoder:aDecoder];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

