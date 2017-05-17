/*
 Copyright (c) 2017, Apple Inc. All rights reserved.
 
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
#include <Accelerate/Accelerate.h>

NS_ASSUME_NONNULL_BEGIN

static const int FftMinSamplesN = 64; //The minimum number of samples required for the first fft calculation. Around 2 seconds if Fs=30
static const int FftInnerStepSamplesN = 128; // Start using this number rather than fftMinSamplesN as soon as we have enough data
static const int FftMaxSamplesN = 256; // The maximum number of samples to be used for fft calculations. Around 8 seconds if Fs=30
static const int SamplingRate = 30; //How many samples per second are we getting. Fs
static const float FftMinHzForHR = 0.8; //Spectrum lower limit on FFT to be considered (according to a possible HR of 48  bpm)
static const float FftMaxHzForHR = 4.0; //Spectrum upper limit on FFT to be considered (according to a possible HR of 204 bpm)
static const float FftCalculationFrequency = 1; //Seconds between each HR estimation using fft for timer


@interface ORKFFTUtils : NSObject {
    
}

/**
 Get RGB bits from a 32 bit string
 */
- (UInt32)Mask8:(UInt32)x;

/**
 Gets the blue channel bits
 */
- (UInt32)getBlue:(UInt32)x;

/**
 Gets the green channel bits
 */
- (UInt32)getGreen:(UInt32)x;

/**
 Gets the red channel bits
 */
- (UInt32)getRed:(UInt32)x;

/**
 Returns absolute value of a complex number
 */
- (float *)absOfComplex:(COMPLEX_SPLIT)complex withSize:(int)size;

/**
 Gets the desired amount of samples needed to perform FFT
 */
- (NSMutableArray *)getProperSamples:(NSMutableArray *)ppgSignal;

/**
 Calculates FFT of the ppgSignal then estimates HR from it
 */
- (float)getHrFromPpg:(NSMutableArray *)ppgSignal;

@end


NS_ASSUME_NONNULL_END
