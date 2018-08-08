/*
 Copyright (c) 2016, Motus Design Group Inc. All rights reserved.
 
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


#import "ORKTrailmakingContentView.h"

#import "ORKHeadlineLabel.h"
#import "ORKLabel.h"

#import "ORKAccessibility.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

#import "ORKRoundTappingButton.h"


@interface ORKTrailmakingTestView : UIView {
    int linesToDraw;
}

@end


@implementation ORKTrailmakingTestView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setLinesToDraw:(int)numLines {
    linesToDraw = numLines;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    
    int curLine = 0;
    
    UIView* lastChild = nil;
    for (UIView* child in self.subviews) {
        if (curLine == linesToDraw)
            break;
        
        if (lastChild == nil) {
            lastChild = child;
        } else {
            CGRect r1 = child.frame;
            CGRect r2 = lastChild.frame;
            
            CGContextSetStrokeColorWithColor(ctx, child.tintColor.CGColor);
            CGContextSetLineWidth(ctx, 5.0f);
            
            CGContextMoveToPoint(ctx, r1.origin.x + r1.size.width / 2, r1.origin.y + r1.size.height / 2);
            CGContextAddLineToPoint(ctx, r2.origin.x + r2.size.width / 2, r2.origin.y + r2.size.height / 2);
            CGContextStrokePath(ctx);
            
            lastChild = child;
            curLine++;
        }
    }
}

@end


@interface ORKTrailmakingButton : ORKRoundTappingButton

@end


@implementation ORKTrailmakingButton

+ (UIFont *)defaultFont {
    // Don't scale too much, because all buttons need to fit on screen and be readable within the circle
    return [[UIFontMetrics metricsForTextStyle:UIFontTextStyleTitle3] scaledFontForFont:[UIFont systemFontOfSize:20.0] maximumPointSize:30.0];
}

@end


@interface ORKTrailmakingContentView ()

@property (nonatomic, strong) ORKTrailmakingTestView* testView;

@end


@implementation ORKTrailmakingContentView

- (instancetype)initWithType:(NSString*)trailType {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.isAccessibilityElement = YES;
        self.accessibilityLabel = ORKLocalizedString(@"AX_TAP_BUTTON_DIRECT_TOUCH_AREA", nil);
        self.accessibilityTraits = UIAccessibilityTraitAllowsDirectInteraction;

        self.testView = [[ORKTrailmakingTestView alloc] init];
        _testView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_testView];
        
        NSMutableArray* buttons = [NSMutableArray array];
        for (int i = 0; i < 13; i++)
        {
            ORKTrailmakingButton* b = [[ORKTrailmakingButton alloc] init];
            
            NSString* title;
            if ([trailType isEqual:@"A"]) {
                title = [self stringWithNumberFormatter:i + 1];
            } else {
                NSArray *letters = [[NSArray alloc] initWithObjects:ORKLocalizedString(@"TRAILMAKING_LETTER_A", nil),
                                    ORKLocalizedString(@"TRAILMAKING_LETTER_B", nil),
                                    ORKLocalizedString(@"TRAILMAKING_LETTER_C", nil),
                                    ORKLocalizedString(@"TRAILMAKING_LETTER_D", nil),
                                    ORKLocalizedString(@"TRAILMAKING_LETTER_E", nil),
                                    ORKLocalizedString(@"TRAILMAKING_LETTER_F", nil), nil];
                
                if (i % 2 == 0)
                    title = [self stringWithNumberFormatter:i / 2 + 1];
                else
                    title = letters[i/2];
            }
            
            [b setTitle:title forState:UIControlStateNormal];
            [buttons addObject:b];
            
            [_testView addSubview:b];
        }
        _tapButtons = [buttons copy];
        
        [self setUpConstraints];
    }
    return self;
}

- (NSString *)stringWithNumberFormatter: (double)value {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterNoStyle;
    formatter.locale = [NSLocale currentLocale];
    
    return [NSString stringWithFormat:@"%@", [formatter stringFromNumber:[NSNumber numberWithDouble:value]]];
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_testView);
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_testView(>=100)]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-32-[_testView(>=100)]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setLinesToDraw:(int)numLines {
    _testView.linesToDraw = numLines;
}

- (CGRect)testArea {
    return _testView.bounds;
}

- (void)setError:(int)buttonIdex {
    ORKRoundTappingButton* button = [_tapButtons objectAtIndex:buttonIdex];
    [button setTintColor:[UIColor redColor]];
}

- (void)clearErrors {
    for (ORKRoundTappingButton* button in _tapButtons) {
        [button setTintColor:self.tintColor];
    }
}

@end
