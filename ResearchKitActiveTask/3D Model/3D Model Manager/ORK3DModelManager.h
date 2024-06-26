/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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
#import <ResearchKit/ORKResult.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ORK3DModelManagerProtocol <NSObject>

@required


/**
This method is called within the ORK3DModelStepViewController's viewDidLoad method.
 
You are passed the contentView of the step so that you can add whatever visuals you choose.
*/
- (void)addContentToView:(UIView *)view;

/**
This method provides the ORK3DModelManager sublass the opportunity for cleanup before step is deallocated.
*/
- (void)stepWillEnd;

/**
This method is called by the ORK3DModelStepViewController's after the user taps the continue button or after the 3DModelManager subclass calls the endStep method.
 
This method signifies that the step is about to end so any necessary clean up before deallocation should be done here.
 
You can also optionally pass back an array of ORKResults.
*/
- (nullable NSArray<ORKResult *> *)provideResultsWithIdentifier:(NSString *)identifier;

@end

ORK_CLASS_AVAILABLE
@interface ORK3DModelManager : NSObject <ORK3DModelManagerProtocol, NSSecureCoding, NSCopying>

- (instancetype)init;

@property (nonatomic, assign) BOOL allowsSelection;
@property (nonatomic, nullable) UIColor *highlightColor;
@property (nonatomic, nullable) NSArray<NSString *> *identifiersOfObjectsToHighlight;

- (void)setContinueEnabled:(BOOL)enabled;
- (void)endStep;

@end

NS_ASSUME_NONNULL_END
