/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
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

@import ResearchKit.Private;

@interface ORKAudiometryTests : XCTestCase

@property (nonatomic, strong) NSArray *audiogramPool;
@property (nonatomic, strong) NSDictionary *keys;

@end

@implementation ORKAudiometryTests

- (void)setUp {
    NSString *testDataPath = [[NSBundle bundleForClass:self.class] pathForResource:@"ORKAudiometryTestData" ofType:@"plist"];
    self.audiogramPool = [NSArray arrayWithContentsOfFile:testDataPath];
    XCTAssertNotEqual(self.audiogramPool.count, 0, @"audiogramPool contains no data");
}

- (void)tearDown {
    self.audiogramPool = nil;
    self.keys = nil;
}

- (void)testORKAudiometry {
    self.keys = @{@1000: @"AUXU1K1", @2000: @"AUXU2K", @3000: @"AUXU3K", @4000: @"AUXU4K", @6000: @"AUXU6K", @8000: @"AUXU8K", @500: @"AUXU500"};
    ORKdBHLToneAudiometryStep *step = [self stepForCurrentKeys];
    [self runTestForAudiometryClass:^id<ORKAudiometryProtocol>{
        return [[ORKAudiometry alloc] initWithStep:step];
    }];
    
    self.keys = @{@1000: @"AUXU1K2", @2000: @"AUXU2K", @3000: @"AUXU3K", @4000: @"AUXU4K", @6000: @"AUXU6K", @8000: @"AUXU8K", @500: @"AUXU500"};
    ORKdBHLToneAudiometryStep *alternativeStep = [self stepForCurrentKeys];
    [self runTestForAudiometryClass:^id<ORKAudiometryProtocol>{
        return [[ORKAudiometry alloc] initWithStep:alternativeStep];
    }];
}

- (ORKdBHLToneAudiometryStep *)stepForCurrentKeys {
    ORKdBHLToneAudiometryStep *step = [[ORKdBHLToneAudiometryStep alloc] initWithIdentifier:@"ORKAudiometryTests"];
    step.frequencyList = [self.keys allKeys];
    return step;
}

- (void)runTestForAudiometryClass:(id<ORKAudiometryProtocol> (^_Nonnull)(void))audiometryConstructor {
    [self.audiogramPool enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull audiogramDict, NSUInteger idx, BOOL * _Nonnull stop) {
        [self runTestForAudiogram:audiogramDict onAudiometryEngine:audiometryConstructor()];
    }];
}

- (void)runTestForAudiogram:(NSDictionary *)audiogramDict onAudiometryEngine:(id<ORKAudiometryProtocol>)audiometry {
    while (audiometry.testEnded == false) {
        ORKAudiometryStimulus *stimulus = [audiometry nextStimulus];
        NSNumber *frequencyKey = self.keys[[NSNumber numberWithDouble:stimulus.frequency]];
        NSNumber *referenceLevel = audiogramDict[frequencyKey];

        if ([audiometry respondsToSelector:@selector(registerStimulusPlayback)]) {
            [audiometry registerStimulusPlayback];
        }
        [audiometry registerResponse:stimulus.level >= referenceLevel.doubleValue];
    }
    
    NSArray<ORKdBHLToneAudiometryFrequencySample *> *result = [audiometry resultSamples];
    XCTAssertNotEqual(result.count, 0, @"result contains no data");
        
    [result enumerateObjectsUsingBlock:^(ORKdBHLToneAudiometryFrequencySample * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *frequencyKey = self.keys[[NSNumber numberWithDouble:obj.frequency]];
        NSNumber *expectedThreshold = audiogramDict[frequencyKey];
        
        XCTAssertEqual(obj.calculatedThreshold, expectedThreshold.doubleValue, "calculatedThreshold does not match expected level for frequency: %.0lf on %@", obj.frequency, audiogramDict);
    }];
}

@end
