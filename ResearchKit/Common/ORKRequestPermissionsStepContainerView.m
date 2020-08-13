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

#import "ORKRequestPermissionsStepContainerView.h"
#import "ORKRequestPermissionView.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKStepContainerView_Private.h"
#import "ORKRequestPermissionView.h"


@implementation ORKRequestPermissionsStepContainerView {
    UIView *_contentView;
}

- (instancetype)initWithCardViews:(NSMutableArray<ORKRequestPermissionView *> *)cardViews {
    self = [super init];

    if (self) {
        _cardViews = cardViews;
        [self setupContentView];
        [self setupCardViewConstraints];
    }

    return self;
}

- (void)setupContentView {
    _contentView = [UIView new];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.customContentView = _contentView;

    for (ORKRequestPermissionView *cardView in _cardViews) {

        cardView.translatesAutoresizingMaskIntoConstraints = NO;
        [_contentView addSubview:cardView];
    }
}

- (void)setupCardViewConstraints {
    UIView *lastView;

    for (ORKRequestPermissionView *cardView in _cardViews) {
        [[cardView.topAnchor constraintEqualToAnchor:lastView ? lastView.topAnchor : _contentView.topAnchor constant:10.0] setActive:YES];
        [[cardView.centerXAnchor constraintEqualToAnchor:_contentView.centerXAnchor] setActive:YES];
        [[cardView.leadingAnchor constraintEqualToAnchor:_contentView.leadingAnchor] setActive:YES];
        [[cardView.trailingAnchor constraintEqualToAnchor:_contentView.trailingAnchor] setActive:YES];
        
        lastView = cardView;
    }

    if (lastView) {
        [[_contentView.bottomAnchor constraintEqualToAnchor:lastView.bottomAnchor constant:10.0] setActive:YES];
    }
}

@end

