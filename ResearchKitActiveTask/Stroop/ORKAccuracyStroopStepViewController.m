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

#import "ORKAccuracyStroopStepViewController.h"
#import "ORKAccuracyStroopStep.h"
#import "ORKAccuracyStroopResult.h"

#import "ORKCollectionResult.h"
#import "ORKHelpers_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "UIColor+String.h"

@interface ORKAccuracyStroopStepViewController () <UIGestureRecognizerDelegate>

@property (nonatomic) NSMutableArray <UIView *> *circles;
@property (nonatomic, strong) UILabel *colorLabel;
@property (nonatomic) UIView *circlesView;
@property (nonatomic) NSArray<NSLayoutConstraint *> *constraints;
@property (nonatomic) double distanceToClosestCenter;
@property (nonatomic) UIColor *selectedColor;

@end

@implementation ORKAccuracyStroopStepViewController

- (ORKAccuracyStroopStep *)accuracyStroopStep {
    return (ORKAccuracyStroopStep *)self.step;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    if (self.step && [self isViewLoaded]) {
        [self setupColorLabel];
        [self setupCirclesView];
        [self setupConstraints];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupCircles];
            [self setupViewTap];
        });
    }
}

- (void)setupViewTap {
    for (UIGestureRecognizer *recognizer in self.circlesView.gestureRecognizers) {
        [self.circlesView removeGestureRecognizer:recognizer];
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGestureRecognizer.delegate = self;
    [self.circlesView addGestureRecognizer:tapGestureRecognizer];
}

- (void)setupCirclesView {
    [self.circlesView removeFromSuperview];
    self.circlesView = nil;
    
    self.circlesView = UIView.new;
    [self.view addSubview:self.circlesView];
}

- (void)setupColorLabel {
    [self.colorLabel removeFromSuperview];
    self.colorLabel = nil;
    
    self.colorLabel = UILabel.new;
    self.colorLabel.text = self.accuracyStroopStep.actualDisplayColor.textRepresentation;
    self.colorLabel.textColor = self.accuracyStroopStep.baseDisplayColor;
    self.colorLabel.font = [UIFont systemFontOfSize:35.0 weight:UIFontWeightMedium];
    [self.view addSubview:self.colorLabel];
}

- (void)setupConstraints {
    if (self.constraints) {
        [NSLayoutConstraint deactivateConstraints:self.constraints];
    }
    self.colorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.circlesView.translatesAutoresizingMaskIntoConstraints = NO;
    self.constraints = nil;
    self.constraints = @[
        [NSLayoutConstraint constraintWithItem:self.colorLabel
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:10.0],
        [NSLayoutConstraint constraintWithItem:self.colorLabel
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:self.circlesView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.colorLabel
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:self.circlesView
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:self.circlesView
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:self.circlesView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:0.0]
    ];
    [NSLayoutConstraint activateConstraints:self.constraints];
}

- (void)setupCircles {
    for (UIView *circle in self.circles) {
        [circle removeFromSuperview];
    }

    [self.circles removeAllObjects];
    self.circles = NSMutableArray.array;
    
    // Constants to use for ball and grid
    int ballSize = 50;
    int padding = 10;
    int cellSize = ballSize + padding * 2;

    // Calculating number of rows/columns in grid to layout color circles
    uint32_t numRows = (self.circlesView.bounds.size.height) / cellSize;
    uint32_t numColumns = (self.circlesView.bounds.size.width) / cellSize;
    
    // Extra padding to ensure that the grid spans the whole screen width
    int extraHorizontalSpaceForCell = ((int)self.circlesView.bounds.size.width % cellSize) / numColumns;
    
    // Matrix to keep track of cells that already have a circle --> avoid overlap in O(n)
    bool cellTakenMatrix[numRows][numColumns];
    for (uint32_t r = 0; r < numRows; r++) {
        for (uint32_t c = 0; c < numColumns; c++) {
            cellTakenMatrix[r][c] = false;
        }
    }
    
    for (int colorIndex = 0; colorIndex < ORKAccuracyStroopStep.colors.count; colorIndex++) {
        // Obtain random location for color circle within bounds
        int randomR = (int)arc4random_uniform(numRows);
        int randomC = (int)arc4random_uniform(numColumns);

        ORK_Log_Debug("Trying placement for color: %d at (r, c): (%d, %d)", colorIndex, randomR, randomC);
        
        // If cell is already taken, look at 8 spots around for a free spot
        if (cellTakenMatrix[randomR][randomC]) {
            ORK_Log_Debug("Position (r, c): (%d, %d) already taken", randomR, randomC);
            
            // Loops through the 3x3 grid with randomR,randomC as the center
            bool shouldBreak = false;
            for (int r = randomR - 1; !shouldBreak && r <= randomR + 1; r++) {
                for (int c = randomC - 1; !shouldBreak && c <= randomC + 1; c++) {
                    // If r/c are out of circleView's bounds, then don't consider
                    if ((r < 0 || r >= numRows) || (c < 0 || c >= numColumns)) { continue; }
                    
                    // If cell is not taken, then can assign to there and break out of for-loops
                    if (!cellTakenMatrix[r][c]) {
                        randomR = r;
                        randomC = c;
                        shouldBreak = true;
                    }
                }
            }
        }
        
        ORK_Log_Info("Final position for color: %d at (r, c): (%d, %d)", colorIndex, randomR, randomC);

        cellTakenMatrix[randomR][randomC] = true;
        
        CGFloat circleX = (randomC * (cellSize + extraHorizontalSpaceForCell)) + padding + extraHorizontalSpaceForCell / 2;
        CGFloat circleY = (randomR * cellSize) + padding;
        CGRect frame = CGRectMake(circleX, circleY, ballSize, ballSize);
        UIView *newCircle = [[UIView alloc] initWithFrame:frame];
        newCircle.backgroundColor = ORKAccuracyStroopStep.colors[colorIndex];
        newCircle.clipsToBounds = YES;
        newCircle.layer.cornerRadius = ballSize / 2;
        newCircle.tag = colorIndex;
        [self.circles addObject:newCircle];
        [self.circlesView addSubview:newCircle];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint touchPoint = [recognizer locationInView:self.circlesView];
    double minDistance = INFINITY;
        
    for (UIView *circle in self.circles) {
        double dx = (touchPoint.x - circle.center.x);
        double dy = (touchPoint.y - circle.center.y);
        double distance = sqrt(dx * dx + dy * dy);
        if (distance < minDistance) {
            minDistance = distance;
        }
        
        if (CGRectContainsPoint(circle.frame, touchPoint)) {
            self.selectedColor = ORKAccuracyStroopStep.colors[circle.tag];
            self.distanceToClosestCenter = distance;
            [super goForward];
            return;
        }
    }
    
    self.distanceToClosestCenter = minDistance;
    [super goForward];
}

- (BOOL)hasPreviousStep {
    return NO;
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    
    ORKAccuracyStroopResult *result = [[ORKAccuracyStroopResult alloc] initWithIdentifier:self.accuracyStroopStep.identifier];
    result.color = self.accuracyStroopStep.baseDisplayColor.textRepresentation;
    result.colorSelected = self.selectedColor.textRepresentation;
    result.distanceToClosestCenter = self.distanceToClosestCenter;
    result.startDate = stepResult.startDate;
    result.endDate = stepResult.endDate;
    result.timeTakenToSelect = [result.endDate timeIntervalSinceDate:result.startDate];

    NSMutableArray *results = [[NSMutableArray alloc] init];
    if (stepResult.results) {
        results = [stepResult.results mutableCopy];
    }
    
    [results addObject:result];
    
    stepResult.results = [results copy];
    return stepResult;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
}

@end
