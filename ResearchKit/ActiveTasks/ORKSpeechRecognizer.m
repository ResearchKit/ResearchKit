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


#import "ORKSpeechRecognizer.h"

#import <Speech/SFSpeechRecognitionRequest.h>
#import <Speech/SFSpeechRecognizer.h>
#import <Speech/SFSpeechRecognitionTask.h>
#import <Speech/SFTranscription.h>
#import <Speech/SFSpeechRecognitionResult.h>
#import <Speech/SFTranscriptionSegment.h>

#import <ResearchKit/ORKRecorder.h>
#import "ORKHelpers_Internal.h"
#import "ORKSpeechRecognitionError.h"


@interface ORKSpeechRecognizer() <SFSpeechRecognitionTaskDelegate, SFSpeechRecognizerDelegate>
@property(nonatomic, weak) id<ORKSpeechRecognitionDelegate> responseDelegate;
@end

@implementation ORKSpeechRecognizer {
    SFSpeechAudioBufferRecognitionRequest *request;
    SFSpeechRecognizer *recognizer;
    dispatch_queue_t _requestQueue;
    dispatch_queue_t _responseQueue;
}

+ (void)requestAuthorization {
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                ORK_Log_Debug(@"Speech recognition request was authorized");
                break;
            default:
                // User did not authorize speech recognition
                break;
        }
    }];
}

- (void)startRecognitionWithLocale:(NSLocale *)locale reportPartialResults:(BOOL)reportPartialResults responseDelegate:(id<ORKSpeechRecognitionDelegate>)delegate errorHandler:(void (^)(NSError *error))handler
{

    _requestQueue = dispatch_queue_create("SpeechRequestQueue", DISPATCH_QUEUE_SERIAL);
    _responseQueue = dispatch_queue_create("SpeechResponseQueue", DISPATCH_QUEUE_SERIAL);
    
    recognizer = [[SFSpeechRecognizer alloc] initWithLocale:locale];
    if (!recognizer) {
        handler([NSError errorWithDomain:ORKErrorDomain
                                    code:ORKSpeechRecognitionErrorLanguageNotAvailable
                                userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"Speech recognizer could not be initialized", nil)}]);
        return;
    }
    [recognizer setDelegate:self];

    SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
    if (status != SFSpeechRecognizerAuthorizationStatusAuthorized) {
        handler([NSError errorWithDomain:ORKErrorDomain
                                    code:ORKSpeechRecognitionErrorLanguageNotAvailable
                                userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"Speech recognizer not authorized", nil)}]);
        return;
    }
    [recognizer isAvailable];
    
    _responseDelegate = delegate;

    request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    if (!request) {
        handler([NSError errorWithDomain:ORKErrorDomain
                                    code:ORKSpeechRecognitionErrorLanguageNotAvailable
                                userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"Speech recognizer could not be initialized", nil)}]);
        return;
    }
    
    request.shouldReportPartialResults = reportPartialResults;
    request.taskHint = SFSpeechRecognitionTaskHintDictation;
    [recognizer recognitionTaskWithRequest:request delegate:self];
    
}

- (void)addAudio:(AVAudioPCMBuffer *)audioBuffer {
    dispatch_async(_requestQueue, ^{
        [request appendAudioPCMBuffer:audioBuffer];
    });
}

- (void)endAudio {
    dispatch_async(_requestQueue, ^{
        [request endAudio];
    });
}

// MARK: SFSpeechRecognizerDelegate

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    dispatch_async(_responseQueue, ^{
        ORK_Log_Debug(@"Availability did change = %d", available);
        [_responseDelegate availabilityDidChange:available];
    });
}

// MARK: SFSpeechRecognizerTaskDelegate

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult {
    dispatch_async(_responseQueue, ^{
        ORK_Log_Debug(@"did produce final result %@", [[recognitionResult bestTranscription] formattedString]);
        [_responseDelegate didHypothesizeTranscription:[recognitionResult bestTranscription]];
    });
}
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription {
    dispatch_async(_responseQueue, ^{
        // Produces transcription if shouldReportPartialResults is true
        ORK_Log_Debug(@"did produce partial results %@", [transcription formattedString]);
        [_responseDelegate didHypothesizeTranscription:transcription];
    });
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishSuccessfully:(BOOL)successfully {
    dispatch_async(_responseQueue, ^{
        if (!successfully) {
            [_responseDelegate didFinishRecognitionWithError:task.error];
        } else {
            [_responseDelegate didFinishRecognitionWithError:nil];
        }
    });
}

- (void)speechRecognitionTaskWasCancelled:(SFSpeechRecognitionTask *)task {
    dispatch_async(_responseQueue, ^{
        ORK_Log_Debug(@"Request cancelled");
        [_responseDelegate didFinishRecognitionWithError:nil];
    });
}

@end
