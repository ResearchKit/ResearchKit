/*
 Copyright (c) 2015, James Cox. All rights reserved.
 
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


#import "ORKTowerOfHanoiTowerView.h"
#import "ORKActiveStepView.h"
#import "ORKSkin.h"

static const CGFloat kDiskHeight = 10;
static const CGFloat kDiskSpacing = 8;
static const CGFloat baseSpacing = 10;

@implementation ORKTowerOfHanoiTowerView {
    NSInteger _maximumNumberOfDisks;
    UIView *_base;
    NSMutableArray *_diskViews;
    NSMutableArray *_diskSizes;
    NSArray *_currentConstraints;
}

#pragma Mark -- Init

- (instancetype)initWithFrame:(CGRect)frame maximumNumberOfDisks:(NSUInteger)maximumNumberOfDisks {
    self = [super initWithFrame:frame];
    if (self) {
        _maximumNumberOfDisks = maximumNumberOfDisks;
        _base = [[UIView alloc] initWithFrame:CGRectZero];
        _base.backgroundColor = [UIColor ork_midGrayTintColor];
        [_base setTranslatesAutoresizingMaskIntoConstraints:NO];
        _base.layer.cornerRadius = 2.5;
        _base.layer.masksToBounds = YES;
        [self addSubview:_base];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapTower)]];
    }
    return self;
}

#pragma Mark -- UIView

- (void)updateConstraints {
    if (_currentConstraints != nil) {
        [NSLayoutConstraint deactivateConstraints:_currentConstraints];
    }
    NSMutableArray *newConstraints = [NSMutableArray new];
    CGFloat height = (kDiskHeight * _maximumNumberOfDisks) + (kDiskSpacing * _maximumNumberOfDisks);
    
    [newConstraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:height + baseSpacing]];
    
    [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_base
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1
                                                            constant:0]];
    
    [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_base
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:2]];
    
    [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_base
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier:1
                                                            constant:0]];
    
    [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_base
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1
                                                            constant:(height * 0.5) + baseSpacing]];
    
    UIView *topDisk;
    for (NSInteger index = 0 ; index < _diskSizes.count ; index++) {
        UIView *disk = _diskViews[index];
        CGFloat divide = 1.0 / _maximumNumberOfDisks;
        CGFloat multiply = [(NSNumber *)_diskSizes[index] floatValue] * divide;
        
        [newConstraints addObject:[NSLayoutConstraint constraintWithItem:disk
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0]];
        
        
        
        [newConstraints addObject:[NSLayoutConstraint constraintWithItem:disk
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_base
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:multiply
                                                                constant:0]];
        
        [newConstraints addObject:[NSLayoutConstraint constraintWithItem:disk
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1
                                                                constant:kDiskHeight]];
        
        if (index == 0) {
            [newConstraints addObject:[NSLayoutConstraint constraintWithItem:disk
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:height * 0.5]];
        } else {
            [newConstraints addObject:[NSLayoutConstraint constraintWithItem:disk
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:topDisk
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:-kDiskSpacing]];
        }
        topDisk = disk;
    }
    _currentConstraints = newConstraints;
    [NSLayoutConstraint activateConstraints:newConstraints];
    [super updateConstraints];
}

#pragma Mark -- Public

- (void)reloadData {
    [_diskViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addDisks];
    [self highlightIfNeeded];
    [self indicateTargetIfNeeded];
    [self setNeedsUpdateConstraints];
}

#pragma Mark -- Private

- (void)userDidTapTower {
    [self.delegate towerOfHanoiTowerViewWasSelected:self];
}

- (void)addDisks {
    NSInteger numberOfDisks = [self.dataSource numberOfDisksInTowerOfHanoiView:self];
    NSMutableArray *diskViews = [NSMutableArray new];
    NSMutableArray *diskSizes = [NSMutableArray new];
    for (NSInteger index = 0 ; index < numberOfDisks ; index++) {
        [diskSizes addObject:[self.dataSource towerOfHanoiView:self diskAtIndex:index]];
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        v.backgroundColor = [self tintColor];
        v.translatesAutoresizingMaskIntoConstraints = NO;
        v.layer.cornerRadius = kDiskHeight * 0.5;
        v.clipsToBounds = YES;
        [self addSubview:v];
        [diskViews addObject:v];
    }
    _diskSizes = diskSizes;
    _diskViews = diskViews;
}

- (void)highlightIfNeeded {
    if (self.isHighLighted) {
        ((UIView *)_diskViews.lastObject).alpha = 0.2;
    }
}

- (void)indicateTargetIfNeeded {
    if (self.isTargeted) {
        _base.backgroundColor = [self tintColor];
    }
}

@end
