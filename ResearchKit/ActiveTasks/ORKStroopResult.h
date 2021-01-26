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

#import <ResearchKit/ORKResult.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKStroopResult` class represents the result of each stimulus within an ORKStroopStep as well as results that change over the entire task.
 
 A stroop result is typically generated by the framework as the task proceeds. When the task completes, it may be appropriate to serialize the sample for transmission to a server or to immediately perform analysis on it.
 */
ORK_CLASS_AVAILABLE
@interface ORKStroopResult: ORKResult

/**
 The `startTime` property is equal to the start time of the each step.
 */
@property (nonatomic, assign) NSTimeInterval startTime;

/**
 The `endTime` property is equal to the timestamp when user answers a particular step by selecting a color.
 */
@property (nonatomic, assign) NSTimeInterval endTime;

/**
 The `reactionTime` property is the time taken (in seconds) for a response to a stimulus, equal to the difference between startTime and endTime.
 */
@property (nonatomic, assign) double reactionTime;

/**
 The `color` property is the color of the question string.
 */
@property (nonatomic, copy) NSString *color;

/**
 The `text` property is the text of the question string.
 */
@property (nonatomic, copy) NSString *text;

/**
 The `colorSelected` corresponds to the button tapped by the user as an answer.
 */
@property (nonatomic, copy, nullable) NSString *colorSelected;

/**
 The 'match' property is a Boolean value indicating whether the value of colorSelected matches that of color.
 The value of this property is `YES` when there is a match, and `NO` otherwise.
 */
@property (nonatomic, assign) BOOL match;

/**
 The 'timedOut' property is a Boolean value indicating whether the the attempt timed out, based on the value set in the non-zero 'timeout' parameter (in seconds), before a selection was made. The value of this property is `YES` when the timeout value was reached, and `NO` otherwise. When YES, reactionTime values will not contribute to task summaries (means and standard deviations).
 */
@property (nonatomic, assign) BOOL timedOut;

/**
The `percentCorrect` property is the percentage of correct 'match' answers for all images in the task so far . This updates with every image presented in the set.
*/
@property (nonatomic, assign) double percentCorrect;

/**
 The `meanReactionTime` property is the mean (average) of reactionTime (in seconds). This updates with every word presented in the task.
 */
@property (nonatomic, assign) double meanReactionTime;

/**
 The `stdReactionTime` property is the standard deviation (a measure of distribution) of reactionTime (in seconds). This updates with every word presented in the set.
 */
@property (nonatomic, assign) double stdReactionTime;


@end

NS_ASSUME_NONNULL_END

