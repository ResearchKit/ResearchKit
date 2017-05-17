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


#import "ORKFFTUtils.h"


@implementation ORKFFTUtils

- (UInt32)Mask8:(UInt32)x {
    return (x) & 0xFF;
}

- (UInt32)getBlue:(UInt32)x {
    return [self Mask8:x];
}

- (UInt32)getGreen:(UInt32)x {
    return [self Mask8:(x >> 8)];
}

- (UInt32)getRed:(UInt32)x {
    return [self Mask8:(x >> 16)];
}

- (float *)absOfComplex:(COMPLEX_SPLIT)complex withSize:(int)size {
    
    float *absArray = malloc(size * sizeof(float));
    
    for (int i = 0; i < size; i++){
        absArray[i] = sqrt(pow(complex.realp[i], 2) + pow(complex.imagp[i], 2));
    }
    
    return absArray;
}

- (NSArray *)getProperSamples:(NSMutableArray *)ppgSignal{
    
    NSArray *ppgData = [[NSMutableArray alloc]init];
    int ppgSamplesNum = (int)[ppgSignal count];
    
    if (ppgSamplesNum >= FftMinSamplesN && ppgSamplesNum < FftInnerStepSamplesN){
        ppgData = [ppgSignal subarrayWithRange:NSMakeRange(ppgSamplesNum - FftMinSamplesN, FftMinSamplesN)];
    } else if(ppgSamplesNum >= FftInnerStepSamplesN && ppgSamplesNum < FftMaxSamplesN){
        ppgData = [ppgSignal subarrayWithRange:NSMakeRange(ppgSamplesNum - FftInnerStepSamplesN, FftInnerStepSamplesN)];
    } else {
        ppgData = [ppgSignal subarrayWithRange:NSMakeRange(ppgSamplesNum - FftMaxSamplesN, FftMaxSamplesN)];
    }
    
    return ppgData;
}

- (float) getHrFromPpg:(NSMutableArray *)ppgSignal {
    
    // Holds the samples which we want to work on.
    NSArray *ppgData = [[NSMutableArray alloc]init];
    
    // From the total number of samples we get the biggest amount of them that is a power of 2 so we dont have to padd
    // with zeroes and loose accuracy. We are getting the last 2^k samples.
    ppgData = [self getProperSamples:ppgSignal];
    
    // From the available samples how many are we really using
    int samplesNum = (int) [ppgData count];
    int fftRadix = log2(samplesNum);
    int halfSamples = (int) (samplesNum / 2);
    
    // Setup the FFT
    FFTSetup setup = vDSP_create_fftsetup(fftRadix, FFT_RADIX2);
    
    // Getting a simple float array of PPG data
    float *ppgSamples = malloc(samplesNum * sizeof(float));
    
    for (int i=0;i<samplesNum;i++){
        ppgSamples[i] = [ppgData[i] floatValue];
    }
    
    // Hamming window function
    float *window = (float *) malloc(sizeof(float) * samplesNum);
    vDSP_hamm_window(window, samplesNum, 0);
    
    // Window the samples
    vDSP_vmul(ppgSamples, 1, window, 1, ppgSamples, 1, samplesNum);
    
    // Define complex buffer
    COMPLEX_SPLIT complex;
    complex.realp = (float *) malloc(halfSamples * sizeof(float));
    complex.imagp = (float *) malloc(halfSamples * sizeof(float));
    
    // Pack samples
    vDSP_ctoz((COMPLEX *) ppgSamples, 2, &complex, 1, halfSamples);
    
    // Perform a forward FFT using fftSetup and A, results returned in A
    vDSP_fft_zrip(setup, &complex, 1, fftRadix, FFT_FORWARD);
    
    // Get the absolute value of the FFT
    float *absFFT = [self absOfComplex:complex withSize:halfSamples];
    
    // Calculate the frequencies for FFT
    double freq[halfSamples];
    float start = 0.0;
    float stop = 1.0;
    
    for (int i = 1;i <= halfSamples; i++){
        freq[i-1] = (SamplingRate / 2) * (start + (i - 1) * (stop - start) / (halfSamples - 1));
    }
    
    // Find max value for FFT in range of HR and take its frequency
    int maxIndex = 0;
    float maxAmp = 0.0;
    
    // Consider only the frequencies between min and max config variables
    for(int i = 1; i < halfSamples - 1; i++){
        if(freq[i] >= FftMinHzForHR && freq[i] <= FftMaxHzForHR){//Consider only valid frequencies for Heartbeats 60-120 BPM
            if(absFFT[i] > maxAmp){// Validate is greater than the last one
                maxAmp = absFFT[i];
                maxIndex = i;
            }
        }
    }
    
    // Since we have the frequency in Hz (cycles per second), we want it in BPM (beats per minute)
    float estimatedBpm = freq[maxIndex] * 60;
    
    // Free the custom ppg array
    free(ppgSamples);
    
    return estimatedBpm;
}

@end
