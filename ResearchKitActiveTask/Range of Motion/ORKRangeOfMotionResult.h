/*
 Copyright (c) 2016, Darren Levy. All rights reserved.
 
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


#import <ResearchKit/ORKResult.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKRangeOfMotionResult` class records the results of a range of motion active task.
 
 An `ORKRangeOfMotionResult` object records the angle values in degrees.
 */
ORK_CLASS_AVAILABLE
@interface ORKRangeOfMotionResult : ORKResult

/**
 The angle (degrees) from the device reference position at the start position.
 */
@property (nonatomic, assign) double start;

/**
 The angle (degrees) from the device reference position when the task finishes recording.
 */
@property (nonatomic, assign) double finish;

/**
 The angle (degrees) from the device reference position at the minimum angle (e.g. when the knee is most bent, such as at the end of the task).
 */
@property (nonatomic, assign) double minimum;

/**
 The angle (degrees) from the device reference position at the maximum angle (e.g. when the knee is extended).
 */
@property (nonatomic, assign) double maximum;

/**
 The angle (degrees) passed through from the start position to the maximum angle (e.g. from when the knee is flexed to when it is extended).
 */
@property (nonatomic, assign) double range;

@end

NS_ASSUME_NONNULL_END
