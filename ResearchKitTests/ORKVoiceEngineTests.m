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

#import <XCTest/XCTest.h>
#import "ORKVoiceEngine_Internal.h"

@interface ORKMockSpeechSynthesizer : AVSpeechSynthesizer {
    BOOL _speaking;
}

@property (nonatomic, readonly) BOOL didStopSpeaking;
@property (nonatomic, readonly) BOOL didSpeakText;
@property (nonatomic, readonly) NSString *speech;
@property (nonatomic, readonly) AVSpeechBoundary stopBoundary;

@end

@implementation ORKMockSpeechSynthesizer

- (void)injectSpeaking:(BOOL)speaking {
    _speaking = speaking;
}

- (BOOL)isSpeaking {
    return _speaking;
}

- (BOOL)stopSpeakingAtBoundary:(AVSpeechBoundary)boundary {
    _didStopSpeaking = YES;
    _stopBoundary = boundary;
    return YES;
}

- (void)speakUtterance:(AVSpeechUtterance *)utterance {
    _didSpeakText = YES;
    _speech = utterance.speechString;
}

@end

@interface ORKVoiceEngineTests : XCTestCase

@end

@implementation ORKVoiceEngineTests {
    ORKVoiceEngine *_voiceEngine;
    ORKMockSpeechSynthesizer *_mockSpeechSynthesizer;
}

- (void)setUp {
    [super setUp];
    _voiceEngine = [[ORKVoiceEngine alloc] init];
    _mockSpeechSynthesizer = [[ORKMockSpeechSynthesizer alloc] init];
    _voiceEngine.speechSynthesizer = _mockSpeechSynthesizer;
    _mockSpeechSynthesizer.delegate = _voiceEngine;
}

- (void)testSharedInstance {
    XCTAssertEqualObjects([ORKVoiceEngine sharedVoiceEngine], [ORKVoiceEngine sharedVoiceEngine]);
}

- (void)testSpeakText {
    [_voiceEngine speakText:@"foo"];
    
    XCTAssertTrue(_mockSpeechSynthesizer.didSpeakText);
    XCTAssertEqualObjects(@"foo", _mockSpeechSynthesizer.speech);
}

- (void)testSpeakTextWhenVoiceEngineIsAlreadySpeaking {
    [_mockSpeechSynthesizer injectSpeaking:YES];
        
    [_voiceEngine speakText:@"foo"];
        
    XCTAssertTrue(_mockSpeechSynthesizer.didStopSpeaking);
    XCTAssertTrue(_mockSpeechSynthesizer.didSpeakText);
    XCTAssertEqualObjects(@"foo", _mockSpeechSynthesizer.speech);
}

- (void)testSpeakInt {
    [_voiceEngine speakInt:42];
    
    XCTAssertTrue(_mockSpeechSynthesizer.didSpeakText);
    XCTAssertEqualObjects(@"42", _mockSpeechSynthesizer.speech);
}

- (void)testStopTalking {
    [_voiceEngine stopTalking];
    
    XCTAssertTrue(_mockSpeechSynthesizer.didStopSpeaking);
    XCTAssertEqual(_mockSpeechSynthesizer.stopBoundary, AVSpeechBoundaryWord);
}

- (void)testIsSpeaking {
    {
        [_mockSpeechSynthesizer injectSpeaking:NO];
        XCTAssertFalse(_voiceEngine.isSpeaking);
    }
    
    {
        [_mockSpeechSynthesizer injectSpeaking:YES];
        XCTAssertTrue(_voiceEngine.isSpeaking);
    }
}

@end
