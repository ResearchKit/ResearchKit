/*
 Copyright (c) 2016, Sage Bionetworks
 
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

ORK_CLASS_AVAILABLE
@interface ORKPageStepViewController : ORKStepViewController

/**
 The `ORKPageStep` associated with this view controller.
 */
@property (nonatomic, readonly, nullable) ORKPageStep *pageStep;

/**
 Returns the step view controller to associate with this step. By default, this will
 return the step view controller instantiated by the given step.
 
 @returns `ORKStepViewController` subclass for this step.
 */
- (ORKStepViewController *)stepViewControllerForStep:(ORKStep *)step;

/**
 Returns an `ORKTaskResultSource` for the steps that are included as substeps for this
 page view controller.
 
 @returns `ORKTaskResultSource` for the step results
 */
- (id <ORKTaskResultSource>)resultSource;

/**
 Go to the given step.
 
 @param step        The step to go to
 @param direction   The direction in which navigate
 @param animated    Should the change of view controllers be animated.
 */
- (void)goToStep:(ORKStep *)step direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
