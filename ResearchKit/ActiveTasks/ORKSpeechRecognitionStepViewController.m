/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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


@import AVFoundation;
@import Accelerate;

#import "ORKSpeechRecognitionStepViewController.h"

#import "ORKQuestionStep.h"
#import "ORKAnswerFormat.h"
#import "ORKTask.h"
#import "ORKActiveStepView.h"
#import "ORKActiveStepViewController_Internal.h"

#import "ORKSpeechRecognitionContentView.h"
#import "ORKStreamingAudioRecorder.h"
#import "ORKSpeechRecognizer.h"
#import "ORKSpeechRecognitionStep.h"
#import "ORKSpeechRecognitionError.h"

#import "ORKHelpers_Internal.h"
#import "ORKBorderedButton.h"
#import "ORKSpeechRecognitionResult.h"
#import "ORKResult_Private.h"
#import "ORKCollectionResult_Private.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController.h"

#import "ORKOrderedTask.h"


@interface ORKSpeechRecognitionStepViewController () <ORKStreamingAudioResultDelegate, ORKSpeechRecognitionDelegate, UITextFieldDelegate>

@end


@implementation ORKSpeechRecognitionStepViewController {
    ORKSpeechRecognitionContentView *_speechRecognitionContentView;
    ORKStreamingAudioRecorder *_audioRecorder;
    ORKSpeechRecognizer *_speechRecognizer;
    
    dispatch_queue_t _speechRecognitionQueue;
    ORKSpeechRecognitonResult *_localResult;
    BOOL _errorState;
    float _peakPower;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ORKSpeechRecognitionStep *step = (ORKSpeechRecognitionStep *) self.step;
    _speechRecognitionContentView = [ORKSpeechRecognitionContentView new];
    _speechRecognitionContentView.shouldHideTranscript = step.shouldHideTranscript;
    self.activeStepView.activeCustomView = _speechRecognitionContentView;
    _speechRecognitionContentView.speechRecognitionImage = step.speechRecognitionImage;
    _speechRecognitionContentView.speechRecognitionText = step.speechRecognitionText;
    
    [_speechRecognitionContentView.recordButton addTarget:self
                                                   action:@selector(recordButtonPressed:)
                                         forControlEvents:UIControlEventTouchDown];
    
    _errorState = NO;
   
    [ORKSpeechRecognizer requestAuthorization];

    _localResult = [[ORKSpeechRecognitonResult alloc] initWithIdentifier:self.step.identifier];
    _speechRecognitionQueue = dispatch_queue_create("SpeechRecognitionQueue", DISPATCH_QUEUE_SERIAL);
}

- (void)initializeRecognizer {
    _speechRecognizer = [[ORKSpeechRecognizer alloc] init];
    
    if (_speechRecognizer) {
        [_speechRecognizer startRecognitionWithLocale:[NSLocale localeWithLocaleIdentifier:((ORKSpeechRecognitionStep *)self.step).speechRecognizerLocale] reportPartialResults:YES responseDelegate:self errorHandler:^(NSError *error) {
            if (error) {
                [self stopWithError:error];
            }
        }];
    }
}

- (void)recordButtonPressed:(id)sender {
    if (sender == _speechRecognitionContentView.recordButton) {
        if ([_speechRecognitionContentView.recordButton.titleLabel.text
             isEqualToString:ORKLocalizedString(@"SPEECH_RECOGNITION_STOP_RECORD_LABEL", nil)]) {
            [self stopWithError:nil];
        } else {
            
            [self initializeRecognizer];
            
            [self start];
            [_speechRecognitionContentView.recordButton setTitle:ORKLocalizedString(@"SPEECH_RECOGNITION_STOP_RECORD_LABEL", nil)
                                                        forState:UIControlStateNormal];
            _speechRecognitionContentView.recordButton.enabled = YES;
        }
    }
}

- (void)recordersDidChange {
    ORKStreamingAudioRecorder *audioRecorder = nil;
    for (ORKRecorder *recorder in self.recorders) {
        if ([recorder isKindOfClass:[ORKStreamingAudioRecorder class]]) {
            audioRecorder = (ORKStreamingAudioRecorder *)recorder;
            break;
        }
    }
    _audioRecorder = audioRecorder;
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    if (_speechRecognitionQueue) {
        dispatch_sync(_speechRecognitionQueue, ^{
            if (_localResult != nil) {
                NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
                [results addObject:_localResult];
                sResult.results = [results copy];
            }
        });
    }
    return sResult;
}

- (void)stopWithError:(NSError *)error {
    if (_speechRecognizer) {
        [_speechRecognizer endAudio];
    }
    
    if (error) {
        ORK_Log_Error(@"Speech recognition failed with error message: \"%@\"", error.localizedDescription);
        [_speechRecognitionContentView addRecognitionError:error.localizedDescription];
        _speechRecognitionContentView.recordButton.enabled = NO;
        _errorState = YES;
    }
    [self stopRecorders];
}

- (void)resume {
    // Background processing is not supported
}

- (void)goForward {
    if ([self hasNextStep]) {
        ORKQuestionStep *nextStep = [self nextStep];
        if (nextStep) {
            [((ORKTextAnswerFormat *)nextStep.answerFormat) setDefaultTextAnswer: [_localResult.transcription formattedString]];
        }
    }
    [super goForward];
}

- (nullable ORKQuestionStep *)nextStep {
    ORKOrderedTask *task = (ORKOrderedTask *)[self.taskViewController task];
    NSUInteger nextStepIndex = [task indexOfStep:[self step]] + 1;
    ORKStep *nextStep = [task steps][nextStepIndex];
    
    if ([nextStep isKindOfClass:[ORKQuestionStep class]]) {
        return (ORKQuestionStep *)nextStep;
    } else {
        return nil;
    }
}

- (void)stepDidFinish {
    _speechRecognitionContentView.finished = YES;
}

- (void)recorder:(ORKRecorder *)recorder didFailWithError:(NSError *)error {
    [super recorder:recorder didFailWithError:error];
    [self stopWithError:error];
}

// Methods running on a different thread

#pragma mark - ORKStreamingAudioResultDelegate
- (void)audioAvailable:(AVAudioPCMBuffer *)buffer {
    if (_errorState) {
        return;
    }
    [_speechRecognizer addAudio:buffer];
    
    // audio metering display
    float * const *channelData = [buffer floatChannelData];
    if (channelData[0]) {
        float avgValue = 0;
        unsigned long nFrames = [buffer frameLength];
        vDSP_maxmgv(channelData[0], 1 , &avgValue, nFrames);
        float lvlLowPassTrig = 0.3;
        _peakPower = lvlLowPassTrig * ((avgValue == 0)? -100 : 20* log10(avgValue)) + (1 - lvlLowPassTrig) * _peakPower;
        float clampedValue = MAX(_peakPower / 60.0, -1) + 1;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_speechRecognitionContentView addSample:@(clampedValue)];
        });
    }
}

#pragma mark - ORKSpeechRecognitionDelegate

- (void)didFinishRecognitionWithError:(NSError *)error {
    if (_errorState) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            ORK_Log_Error(@"Speech framework failed with error code: %ld, and error description: %@", (long)error.code, error.localizedDescription);
            NSError *recognitionError = [NSError errorWithDomain:ORKErrorDomain
                                                            code:ORKSpeechRecognitionErrorRecognitionFailed
                                                        userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"SPEECH_RECOGNITION_FAILED", nil)}];
            [self stopWithError:recognitionError];
        } else {
            [self stopWithError:nil];
            [self finish];
        }
    });
}

- (void)didHypothesizeTranscription:(SFTranscription *)transcription {
    if (_errorState) {
        return;
    }
    dispatch_sync(_speechRecognitionQueue, ^{
        _localResult.transcription = transcription;
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_speechRecognitionContentView updateRecognitionText:[transcription formattedString]];
    });
}

- (void)availabilityDidChange:(BOOL)available {
    if (!available) {
        dispatch_async(dispatch_get_main_queue(), ^{
        [self stopWithError:[NSError errorWithDomain:ORKErrorDomain
                                                code:ORKSpeechRecognitionErrorLanguageNotAvailable
                                            userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"Speech recognizer not available", nil)}]];
        });
    }
}

- (void)recordersWillStart {
    NSLog(@"Recorder is starting");
}

@end

