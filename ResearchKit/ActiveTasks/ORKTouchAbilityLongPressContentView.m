/*
 Copyright (c) 2018, Muh-Tarng Lin. All rights reserved.
 
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

#import "ORKTouchAbilityLongPressContentView.h"
#import "ORKTouchAbilityLongPressTrial.h"

#import "ORKHelpers_Internal.h"

@interface ORKTouchAbilityLongPressContentView ()

@property (nonatomic, assign) BOOL success;

@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, assign) NSUInteger numberOfRows;
@property (nonatomic, assign) NSUInteger targetColumn;
@property (nonatomic, assign) NSUInteger targetRow;
@property (nonatomic, assign) CGSize targetSize;

@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (nonatomic, copy) NSArray *targetConstraints;

@end

@implementation ORKTouchAbilityLongPressContentView


#pragma mark - Properties

- (UIView *)targetView {
    if (!_targetView) {
        _targetView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _targetView;
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
    }
    return _longPressGestureRecognizer;
}


#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.targetView.backgroundColor = self.tintColor;
        self.targetView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:self.targetView];
        
        self.longPressGestureRecognizer.enabled = NO;
        [self.contentView addGestureRecognizer:self.longPressGestureRecognizer];
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.targetView.backgroundColor = self.tintColor;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    if (self.numberOfColumns == 0 || self.numberOfRows == 0 || self.targetView.superview == nil) {
        return;
    }
    
    CGFloat width = self.contentView.frame.size.width / self.numberOfColumns;
    CGFloat height = self.contentView.frame.size.height / self.numberOfRows;
    
    CGFloat columnMidX = width * (self.targetColumn + 1.0/2.0);
    CGFloat rowMidY = height * (self.targetRow + 1.0/2.0);
    
    if (self.targetConstraints != nil) {
        [NSLayoutConstraint deactivateConstraints:self.targetConstraints];
        self.targetConstraints = nil;
    }
    
    NSMutableArray *constraintsArray = [NSMutableArray array];
    
    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.targetView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:self.targetSize.width]];
    
    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.targetView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:self.targetSize.height]];
    
    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.targetView
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.contentView
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:columnMidX]];
    
    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.targetView
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.contentView
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:rowMidY]];
    
    self.targetConstraints = constraintsArray;
    [NSLayoutConstraint activateConstraints:self.targetConstraints];
}


#pragma mark - ORKTouchAbilityCustomView

+ (Class)trialClass {
    return [ORKTouchAbilityLongPressTrial class];
}

- (ORKTouchAbilityTrial *)trial {
    
    ORKTouchAbilityLongPressTrial *trial = (ORKTouchAbilityLongPressTrial *)[super trial];
    trial.targetFrameInWindow = [self.targetView convertRect:self.targetView.bounds toView:nil];
    trial.success = self.success;
    
    return trial;
}

- (void)startTrial {
    [super startTrial];
    self.longPressGestureRecognizer.enabled = YES;
}

- (void)endTrial {
    [super endTrial];
    self.longPressGestureRecognizer.enabled = NO;
}

- (void)reloadData {
    [self resetTracks];
    
    self.success = NO;
    
    self.numberOfColumns = [self.dataSource numberOfColumnsInLongPressContentView:self] ?: 1;
    self.numberOfRows    = [self.dataSource numberOfRowsInLongPressContentView:self]    ?: 1;
    self.targetColumn    = [self.dataSource targetColumnInLongPressContentView:self]    ?: 0;
    self.targetRow       = [self.dataSource targetRowInLongPressContentView:self]       ?: 0;
    
    NSAssert(self.targetColumn >= 0 && self.targetColumn < self.numberOfColumns, @"Target column out of bounds.");
    NSAssert(self.targetRow >= 0 && self.targetRow < self.numberOfRows, @"target row out of bounds.");
    
    if ([self.dataSource respondsToSelector:@selector(targetSizeInLongPressContentView:)]) {
        self.targetSize = [self.dataSource targetSizeInLongPressContentView:self];
    } else {
        self.targetSize = CGSizeMake(76, 76);
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}


#pragma mark - Gesture Recognizer Handler

- (void)handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (CGRectContainsPoint(self.targetView.bounds, [sender locationInView:self.targetView])) {
            self.success = YES;
        } else {
            self.success = NO;
        }
    }
}

@end
