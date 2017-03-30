/*
 Copyright (c) 2015-2017, Apple Inc. All rights reserved.
 Copyright (c) 2015, Bruce Duncan.
 Copyright (c) 2015-2017, Ricardo Sanchez-Saez.
 Copyright (c) 2016-2017, Sage Bionetworks
 
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


@import UIKit;


/*  NOTE: The task creation utility methods are alphabetically sorted within their
 *        their own category file. Make sure you insert your code in the appropriate place
 *        so all the methods in each categoty files remain alphabetically sorted.
 */

@protocol ORKTask;
@class ORKConsentDocument;
@class ORKTaskResult;


// Helper properties to communicate task intent to MainViewController
@interface NSObject (TaskFactory)

@property (nonatomic, assign) BOOL hidesProgressInNavigationBar;
@property (nonatomic, assign) BOOL isEmbeddedReviewTask;
@property (nonatomic, assign) BOOL hidesLearnMoreButtonOnInstructionStep;
@property (nonatomic, assign) BOOL triggersStepWillDisappearAction;

@end


@interface TaskFactory : NSObject

+ (instancetype)sharedInstance;

- (id<ORKTask>)makeTaskWithIdentifier:(NSString *)identifier;

- (ORKConsentDocument *)buildConsentDocument;

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size border:(BOOL)border;

@property (nonatomic, copy) ORKConsentDocument *currentConsentDocument;

@property (nonatomic, strong) ORKTaskResult *embeddedReviewTaskResult;

@end
