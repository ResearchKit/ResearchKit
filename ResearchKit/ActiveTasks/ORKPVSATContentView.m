/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
 
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


#import "ORKPVSATContentView.h"
#import "ORKSkin.h"
#import "ORKPVSATKeyboardView.h"
#import "ORKSubheadlineLabel.h"
#import "ORKTapCountLabel.h"
#import "ORKBorderedButton.h"


@interface ORKPVSATContentView ()

@property (nonatomic, strong) ORKSubheadlineLabel *answerCaptionLabel;
@property (nonatomic, strong) ORKTapCountLabel *digitLabel;
@property (nonatomic, assign) ORKScreenType screenType;
@property (nonatomic, strong) NSArray *constraints;

@end


@implementation ORKPVSATContentView

- (instancetype)init {
    self = [super init];
    if (self) {
        _screenType = ORKGetScreenTypeForWindow(self.window);
        _answerCaptionLabel = [ORKSubheadlineLabel new];
        _answerCaptionLabel.textAlignment = NSTextAlignmentCenter;
        _answerCaptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _digitLabel = [ORKTapCountLabel new];
        _digitLabel.textColor = [self tintColor];
        _digitLabel.textAlignment = NSTextAlignmentCenter;
        _digitLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _keyboardView = [ORKPVSATKeyboardView new];
        _keyboardView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_answerCaptionLabel];
        [self addSubview:_digitLabel];
        [self addSubview:_keyboardView];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;

        [self setNeedsUpdateConstraints];
    }
    
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.digitLabel.textColor = [self tintColor];
}

- (void)setEnabled:(BOOL)enabled {
    [self.keyboardView setEnabled:enabled];
}

- (void)setAddition:(NSUInteger)additionIndex forTotal:(NSUInteger)totalAddition withDigit:(NSNumber *)digit {
    if (digit.integerValue == -1) {
        self.digitLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
        self.digitLabel.text = @"-";
    } else {
        [self.keyboardView.selectedAnswerButton setSelected:NO];
        self.digitLabel.textColor = [self tintColor];
        self.digitLabel.text = digit.stringValue;
        if (additionIndex == 0) {
            self.answerCaptionLabel.text = ORKLocalizedString(@"PVSAT_INITIAL_ADDITION", nil);
        } else {
            self.answerCaptionLabel.text = [NSString stringWithFormat:ORKLocalizedString(@"PVSAT_ADDITION_%@", nil), @(additionIndex), @(totalAddition)];
        }
    }
}

- (void)updateConstraints {
    if ([self.constraints count]) {
        [NSLayoutConstraint deactivateConstraints:self.constraints];
        self.constraints = nil;
    }
    
    const CGFloat ORKPVSATKeyboardWidth = ORKGetMetricForScreenType(ORKScreenMetricPVSATKeyboardViewWidth, self.screenType);
    const CGFloat ORKPVSATKeyboardHeight = ORKGetMetricForScreenType(ORKScreenMetricPVSATKeyboardViewHeight, self.screenType);
    
    NSMutableArray *constraintsArray = [NSMutableArray array];

    NSDictionary *views = NSDictionaryOfVariableBindings(_answerCaptionLabel, _digitLabel, _keyboardView);
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-[_keyboardView(==%f)]-|", ORKPVSATKeyboardWidth]
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil views:views]];
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[_keyboardView(==%f)]", ORKPVSATKeyboardHeight]
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil views:views]];
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_answerCaptionLabel][_digitLabel]-(>=10)-[_keyboardView]-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil views:views]];
    
    self.constraints = constraintsArray;
    [self addConstraints:self.constraints];
    
    [NSLayoutConstraint activateConstraints:self.constraints];
    [super updateConstraints];
}

@end
