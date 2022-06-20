/*
 Copyright (c) 2016, Darren Levy. All rights reserved.
 Copyright (c) 2021, Dr David W. Evans. All rights reserved.
 
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


#import "ORKTouchAnywhereStep.h"
#import "ORKTouchAnywhereStepViewController.h"
#import "ORKHelpers_Internal.h"


@implementation ORKTouchAnywhereStep

+ (Class)stepViewControllerClass {
    return [ORKTouchAnywhereStepViewController class];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithIdentifier:(NSString *)identifier instructionText:(NSString *)instructionText numberOfTaps:(NSInteger)numberOfTaps numberOfTouches:(NSInteger)numberOfTouches {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.shouldStartTimerAutomatically = YES;
        self.numberOfTaps = numberOfTaps;
        self.numberOfTouches = numberOfTouches;
        self.text = [NSString stringWithFormat:@"%@\n\n%@", instructionText, [self getInstructionText]];
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];
    
    // limit required number of touches (fingers) to between 1 and 4
    if (self.numberOfTouches < 1 || self.numberOfTouches > 4) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:ORKLocalizedString(@"TOUCH_ANYWHERE_NUMBER_OF_TOUCHES_ERROR", nil)
                                     userInfo:nil];
    }
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTouchAnywhereStep *step = [super copyWithZone:zone];
    step.numberOfTaps = self.numberOfTaps;
    step.numberOfTouches = self.numberOfTouches;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self ) {
        ORK_DECODE_INTEGER(aDecoder, numberOfTaps);
        ORK_DECODE_INTEGER(aDecoder, numberOfTouches);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, numberOfTaps);
    ORK_ENCODE_INTEGER(aCoder, numberOfTouches);
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.numberOfTaps == castObject.numberOfTaps) &&
            (self.numberOfTouches == castObject.numberOfTouches));
}

- (NSString *)getInstructionText {
    NSString *instructionText;
    if(self.numberOfTaps <= 1) { // default
        if (self.numberOfTouches > 1) { // number of fingers
            instructionText = [NSString localizedStringWithFormat:ORKLocalizedString(@"TOUCH_ANYWHERE_BEGIN", nil), [NSString localizedStringWithFormat:ORKLocalizedString(@"TOUCH_ANYWHERE_MULTIPLE_FINGERS", nil), @(self.numberOfTouches)]];
        } else { // number of fingers is 1 or 0
            instructionText = [NSString localizedStringWithFormat:ORKLocalizedString(@"TOUCH_ANYWHERE_BEGIN", nil), @""];
        }
    } else if (self.numberOfTaps == 2) {
        if (self.numberOfTouches > 1) {
            instructionText = [NSString localizedStringWithFormat:ORKLocalizedString(@"TOUCH_ANYWHERE_DOUBLE_TAP_BEGIN", nil), [NSString localizedStringWithFormat:ORKLocalizedString(@"TOUCH_ANYWHERE_MULTIPLE_FINGERS", nil), @(self.numberOfTouches)]];
        } else { // number of fingers is 1
            instructionText = [NSString localizedStringWithFormat:ORKLocalizedString(@"TOUCH_ANYWHERE_DOUBLE_TAP_BEGIN", nil), @""];
        }
    } else { // number of taps required is more than two
        if (self.numberOfTouches > 1) {
            instructionText = [NSString localizedStringWithFormat:ORKLocalizedString(@"TOUCH_ANYWHERE_BEGIN", nil), [NSString stringWithFormat:@"%@%@", [NSString localizedStringWithFormat:ORKLocalizedString(@"TOUCH_ANYWHERE_MULTIPLE_FINGERS", nil), @(self.numberOfTouches)], [NSString localizedStringWithFormat:ORKLocalizedString(@"TOUCH_ANYWHERE_NUMBER_OF_TOUCHES", nil), @(self.numberOfTaps)]]];
        } else { // number of fingers is 1
            instructionText = [NSString localizedStringWithFormat:ORKLocalizedString(@"TOUCH_ANYWHERE_BEGIN", nil), [NSString localizedStringWithFormat:ORKLocalizedString(@"TOUCH_ANYWHERE_NUMBER_OF_TOUCHES", nil), @(self.numberOfTaps)]];
        }
    }
    return instructionText;
}

@end
