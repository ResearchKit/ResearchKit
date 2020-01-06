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


@import UIKit;
#import "ORKStepView_Private.h"

NS_ASSUME_NONNULL_BEGIN

@class ORKTableContainerView;
@class ORKStepContentView;

@protocol ORKTableContainerViewDelegate <NSObject>

@required
- (UITableViewCell *)currentFirstResponderCellForTableContainerView:(ORKTableContainerView *)tableContainerView;

@end

@class ORKNavigationContainerView;

@interface ORKTableContainerView : ORKStepView

@property (nonatomic, weak, nullable) id<ORKTableContainerViewDelegate> tableContainerDelegate;

@property (nonatomic, strong, readonly) UITableView *tableView;

/*
 If tap off events should be accepted from outside this view's bounds, provide
 the parent view where the tap off gesture recognizer should be attached.
 */
@property (nonatomic, weak, nullable) UIView *tapOffView;

- (void)scrollCellVisible:(UITableViewCell *)cell animated:(BOOL)animated;
    
- (instancetype)initWithStyle:(UITableViewStyle)style pinNavigationContainer:(BOOL)pinNavigationContainer;

- (void)sizeHeaderToFit;

- (void)resizeFooterToFit;

@end

NS_ASSUME_NONNULL_END
