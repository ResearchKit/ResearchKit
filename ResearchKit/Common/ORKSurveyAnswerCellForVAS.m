//
//  ORKSurveyAnswerCellForVAS.m
//  ResearchKit
//
//  Created by Bill Byrom and Willie Muehlhausen, ICON Clinical Research.
//  Copyright (c) 2016 ICON Clinical Research.  All rights reserved.
//

#import "ORKSurveyAnswerCellForVAS.h"
#import "ORKScaleSlider.h"
#import "ORKSkin.h"
#import "ORKQuestionStep_Internal.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKVASSliderView.h"


@interface ORKSurveyAnswerCellForVAS () <ORKVASSliderViewDelegate>

@property (nonatomic, strong) ORKVASSliderView *sliderView;
@property (nonatomic, strong) id<ORKVASAnswerFormatProvider> formatProvider;

@end


@implementation ORKSurveyAnswerCellForVAS

- (id<ORKVASAnswerFormatProvider>)formatProvider {
    if (_formatProvider == nil) {
        _formatProvider = (id<ORKVASAnswerFormatProvider>)[self.step impliedAnswerFormat];
    }
    return _formatProvider;
}

- (void)prepareView {
    [super prepareView];
    
    id<ORKVASAnswerFormatProvider> formatProvider = self.formatProvider;
    
    if (_sliderView == nil) {
        _sliderView = [[ORKVASSliderView alloc] initWithFormatProvider:formatProvider delegate:self];
        [self addSubview:_sliderView];
        
        self.sliderView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = @{ @"sliderView": _sliderView };
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sliderView]|"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sliderView]|"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil
                                                                       views:views]];
    }
    
    [self answerDidChange];
}

- (void)answerDidChange {
    id<ORKVASAnswerFormatProvider> formatProvider = self.formatProvider;
    id answer = self.answer;
    if (answer && answer != ORKNullAnswerValue()) {
        [_sliderView setCurrentAnswerValue:answer];
    } else {
        if (answer == nil && [formatProvider defaultAnswer]) {
            [self.sliderView setCurrentAnswerValue:[formatProvider defaultAnswer]];
            [self ork_setAnswer:self.sliderView.currentAnswerValue];
        } else {
            [self.sliderView setCurrentAnswerValue:nil];
        }
    }
}

- (NSArray *)suggestedCellHeightConstraintsForView:(UIView *)view {
    return @[];
}

- (void)VASSliderViewCurrentValueDidChange:(ORKVASSliderView *)sliderView {
    [self ork_setAnswer:sliderView.currentAnswerValue];
}

@end
