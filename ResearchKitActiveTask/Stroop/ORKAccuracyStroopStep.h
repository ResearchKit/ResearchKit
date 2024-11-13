/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
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

#import <ResearchKit/ORKActiveStep.h>

NS_ASSUME_NONNULL_BEGIN

ORK_CLASS_AVAILABLE
@interface ORKAccuracyStroopStep : ORKActiveStep

/**
 The color of the label.

 The base display color is the color that the user must tap on to be correct. The text of
 the label may match the base display color depending on the `isColorMatching` property.
*/
@property (nonatomic) UIColor *baseDisplayColor;

/**
 Whether the text and base display color are matching.

 If this value is true, the text of the label will spell out the same color as the base display
 color, making the task easier for the user. If this value is false, the label color and label text
 will represent different colors, which adds complexity to the puzzle task.
*/
@property (nonatomic) BOOL isColorMatching;

/**
 The text of the label. (read-only)

 The value of this property is generated based on the `baseDisplayColor` and `isColorMatching`
 properties. If `isColorMatching` is false, the actual display color will be randomly generated
 to be a color that is not the base display color.
*/
@property (nonatomic, readonly) UIColor *actualDisplayColor;

+ (NSArray <UIColor *> *)colors;

@end

NS_ASSUME_NONNULL_END
