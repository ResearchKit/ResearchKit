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
#import "ORKAccessibility.h"
#import "ORKHelpers.h"


static const CGFloat DiskHeight = 10;
static const CGFloat DiskSpacing = 8;
static const CGFloat BaseSpacing = 10;

@implementation ORKTowerOfHanoiTowerView {
    NSInteger _maximumNumberOfDisks;
    UIView *_base;
    NSMutableArray *_diskViews;
    NSMutableArray *_diskSizes;
    NSMutableArray *_variableConstraints;
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame maximumNumberOfDisks:(NSUInteger)maximumNumberOfDisks {
    self = [super initWithFrame:frame];
    if (self) {
        _maximumNumberOfDisks = maximumNumberOfDisks;
        _base = [[UIView alloc] initWithFrame:CGRectZero];
        _base.backgroundColor = [UIColor ork_midGrayTintColor];
        _base.translatesAutoresizingMaskIntoConstraints = NO;
        _base.layer.cornerRadius = 2.5;
        _base.layer.masksToBounds = YES;
        _diskViews = [NSMutableArray new];
        _diskSizes = [NSMutableArray new];
        [self addSubview:_base];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapTower)]];
    }
    return self;
}

#pragma mark - UIView

- (void)updateConstraints {
    [NSLayoutConstraint deactivateConstraints:_variableConstraints];
    [_variableConstraints removeAllObjects];
    
    if (!_variableConstraints) {
        _variableConstraints = [NSMutableArray new];
    }
    
    CGFloat height = (DiskHeight * _maximumNumberOfDisks) + (DiskSpacing * _maximumNumberOfDisks);
    [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:height + BaseSpacing]];
    
    [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_base
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_base
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:2.0]];
    
    [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_base
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_base
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:(height * 0.5) + BaseSpacing]];
    
    UIView *topDisk;
    for (NSInteger index = 0 ; index < _diskSizes.count ; index++) {
        UIView *disk = _diskViews[index];
        CGFloat divide = 1.0 / _maximumNumberOfDisks;
        CGFloat multiply = ((NSNumber *)_diskSizes[index]).floatValue * divide;
        
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:disk
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:0.0]];
        
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:disk
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_base
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:multiply
                                                                      constant:0.0]];
        
        [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:disk
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:DiskHeight]];
        
        if (index == 0) {
            [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:disk
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:height * 0.5]];
        } else {
            [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:disk
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:topDisk
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0
                                                                          constant:-DiskSpacing]];
        }
        topDisk = disk;
    }
    [NSLayoutConstraint activateConstraints:_variableConstraints];
    [super updateConstraints];
}

- (void)tintColorDidChange {
    [self reloadData];
}

#pragma mark - Public

- (void)reloadData {
    [self updateDisks];
    [self highlightIfNeeded];
    [self indicateTargetIfNeeded];
    [self setNeedsUpdateConstraints];
}

#pragma mark - Private

- (void)userDidTapTower {
    [self.delegate towerOfHanoiTowerViewWasSelected:self];
}

- (void)updateDisks {
    [_diskViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    ORKRemoveConstraintsForRemovedViews(_variableConstraints, _diskViews);

    [_diskViews removeAllObjects];
    [_diskSizes removeAllObjects];

    NSInteger numberOfDisks = [self.dataSource numberOfDisksInTowerOfHanoiView:self];
    for (NSInteger index = 0 ; index < numberOfDisks ; index++) {
        NSNumber *diskSize = [self.dataSource towerOfHanoiView:self diskAtIndex:index];
        [_diskSizes addObject:diskSize];
        UIView *diskView = [[UIView alloc] initWithFrame:CGRectZero];
        diskView.backgroundColor = [self tintColor];
        diskView.translatesAutoresizingMaskIntoConstraints = NO;
        diskView.layer.cornerRadius = DiskHeight * 0.5;
        diskView.clipsToBounds = YES;
        [self addSubview:diskView];
        [_diskViews addObject:diskView];
    }
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

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    NSString *targetDisk = (self.isTargeted ? ORKLocalizedString(@"AX_TOWER_OF_HANOI_TARGET_DISK", nil) : nil);
    return ORKAccessibilityStringForVariables(ORKLocalizedString(@"AX_TOWER_OF_HANOI_TOWER", nil), targetDisk);
}

- (NSString *)accessibilityHint {
    if (!self.isHighLighted && [self.delegate towerOfHanoiHighlightedTowerView] != nil) {
        return ORKLocalizedString(@"AX_TOWER_OF_HANOI_PLACE_DISK", nil);
    }
    
    BOOL hasDisks = ([self.dataSource numberOfDisksInTowerOfHanoiView:self] > 0);
    return (self.isHighLighted ? nil : (hasDisks ? ORKLocalizedString(@"AX_TOWER_OF_HANOI_SELECT_DISK", nil) : nil));
}

- (UIAccessibilityTraits)accessibilityTraits {
    UIAccessibilityTraits traits = [super accessibilityTraits];
    if (self.isHighLighted) {
        traits |= UIAccessibilityTraitSelected;
    }
    
    // Don't echo if when a disk is placed.
    if (!self.isHighLighted && UIAccessibilityFocusedElement(UIAccessibilityNotificationVoiceOverIdentifier) == self) {
        traits |= UIAccessibilityTraitStartsMediaSession;
    }
    
    return traits;
}

- (NSString *)accessibilityValue {

    NSString *disksString = @"";
    
    for (NSNumber *diskSize in _diskSizes) {
        disksString = ORKAccessibilityStringForVariables(disksString, diskSize.stringValue, @", ");
    }
    
    NSString *value = (_diskSizes.count > 0 ? [NSString stringWithFormat:ORKLocalizedString(@"AX_TOWER_OF_HANOI_TOWER_CONTAINS", nil), disksString] : ORKLocalizedString(@"AX_TOWER_OF_HANOI_TOWER_EMPTY", nil));
    
    return value;
}

@end
