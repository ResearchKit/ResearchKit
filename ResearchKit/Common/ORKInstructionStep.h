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


#import <ResearchKit/ResearchKit.h>


NS_ASSUME_NONNULL_BEGIN

/**
 An `ORKInstructionStep` object gives the participant instructions for a task.
 
 You can use instruction steps to present various types of content during a task, such as
 introductory content, instructions in the middle
 of a task, or a final message at the completion of a task.
 
To indicate the completion of a task, consider using an `ORKCompletionStep` object instead.
 */
ORK_CLASS_AVAILABLE
@interface ORKInstructionStep : ORKStep

/**
 Additional detailed explanation for the instruction.
 
 The detail text is displayed below the content of the `text` property.
 */
@property (nonatomic, copy, nullable) NSString *detailText;

/**
 An image that provides visual context for the instruction.
 
 The image is displayed with aspect fit. Depending on the device, the screen area
 available for this image can vary. For exact
 metrics, see `ORKScreenMetricIllustrationHeight`.
 */
@property (nonatomic, copy, nullable) UIImage *image;

@end

NS_ASSUME_NONNULL_END
