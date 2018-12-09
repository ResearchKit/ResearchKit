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


#import "ORKdBHLToneAudiometryStep.h"
#import "ORKdBHLToneAudiometryOnboardingStepViewController.h"

@implementation ORKdBHLToneAudiometryOnboardingStepViewController {
    int indexOffset;
}

- (void)goForward {
    if ([self hasNextStep]) {
        indexOffset = 3;
        ORKdBHLToneAudiometryStep *toneAudiometryStep = [self getFutureStep];
        ORKAudioChannel userSelectedChannel = ORKAudioChannelLeft;
        NSString *userSelectedChannelString = ((ORKChoiceQuestionResult *)self.result.results[0]).choiceAnswers[0];
        NSString *userSelectedHeadphoneTypeString = ((ORKChoiceQuestionResult *)self.result.results[1]).choiceAnswers[0];
        if ([userSelectedChannelString isEqualToString:@"RIGHT"]) {
            userSelectedChannel = ORKAudioChannelRight;
        } else {
            userSelectedChannelString = @"LEFT";
        }
        if (toneAudiometryStep) {
            toneAudiometryStep.headphoneType = userSelectedHeadphoneTypeString;
            toneAudiometryStep.earPreference = userSelectedChannel;
            toneAudiometryStep.text = [NSString stringWithFormat:@"Playback occurring in the %@ channel of your headphones. Tap the button below every time you hear a tone.", userSelectedChannelString];
        }
        indexOffset = 5;
        // flip selections
        if ([userSelectedChannelString isEqualToString:@"RIGHT"]) {
            userSelectedChannelString = @"LEFT";
            userSelectedChannel = ORKAudioChannelLeft;
        } else {
            userSelectedChannel = ORKAudioChannelRight;
            userSelectedChannelString = @"RIGHT";
        }
        toneAudiometryStep = [self getFutureStep];
        if (toneAudiometryStep) {
            toneAudiometryStep.headphoneType = userSelectedHeadphoneTypeString;
            toneAudiometryStep.earPreference = userSelectedChannel;
            toneAudiometryStep.text = [NSString stringWithFormat:@"Playback occurring in the %@ channel of your headphones. Tap the button below every time you hear a tone.", userSelectedChannelString];
        }
    }
    [super goForward];
}

- (nullable ORKdBHLToneAudiometryStep *)getFutureStep {
    ORKOrderedTask *task = (ORKOrderedTask *)[self.taskViewController task];
    NSUInteger nextStepIndex = [task indexOfStep:[self step]] + indexOffset;
    ORKStep *nextStep = [task steps][nextStepIndex];
    
    if ([nextStep isKindOfClass:[ORKdBHLToneAudiometryStep class]]) {
        return (ORKdBHLToneAudiometryStep *)nextStep;
    } else {
        return nil;
    }
}

@end

