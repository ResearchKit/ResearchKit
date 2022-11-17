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


#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKActiveStep.h>

NS_ASSUME_NONNULL_BEGIN

ORK_CLASS_AVAILABLE
@interface ORKStroopStep : ORKActiveStep

@property (nonatomic, assign) NSInteger numberOfAttempts;

/**
A Boolean value indicating whether this task randomizes the visual and color of each stroop question.
This means that the color of the text displayed and the text may not match, which makes for a harder stroop test. 

By default, this property is set to `YES`
*/
@property (nonatomic, assign) BOOL randomizeVisualAndColorAlignment;

/**
A Boolean value indicating whether this task should use text or boxes.
If set to `YES` then color words will be displayed for the user to guess.
If set to `NO` we will display a square box with the current color for the user to guess

By default, this property is set to `YES`
*/
@property (nonatomic, assign) BOOL useTextForStimuli;

/**
A Boolean value indicating whether this task will use a 2x2 grid of buttons

By default, this property is set to `NO`
*/
@property (nonatomic, assign) BOOL useGridLayoutForButtons;

@end

NS_ASSUME_NONNULL_END
