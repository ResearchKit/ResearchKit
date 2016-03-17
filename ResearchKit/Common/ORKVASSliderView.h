//
//  ORKVASSliderView.h
//  ResearchKit
//
//  Created by Janusz Bień on 16.03.2016.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/ResearchKit.h>
#import "ORKAnswerFormat_Internal.h"
#import "ORKScaleSlider.h"


NS_ASSUME_NONNULL_BEGIN

@class ORKScaleRangeLabel;
@class ORKScaleValueLabel;
@class ORKScaleRangeDescriptionLabel;
@class ORKScaleRangeImageView;
@class ORKVASSliderView;

@protocol ORKVASSliderViewDelegate <NSObject>

- (void)VASSliderViewCurrentValueDidChange:(ORKVASSliderView *)sliderView;

@end


@interface ORKVASSliderView : UIView

- (instancetype)initWithFormatProvider:(id<ORKVASAnswerFormatProvider>)formatProvider delegate:(id<ORKVASSliderViewDelegate>)delegate;

@property (nonatomic, weak, readonly) id<ORKVASSliderViewDelegate> delegate;

@property (nonatomic, strong, readonly) id<ORKVASAnswerFormatProvider> formatProvider;

@property (nonatomic, strong, readonly) ORKScaleRangeDescriptionLabel *leftRangeDescriptionLabel;

@property (nonatomic, strong, readonly) ORKScaleRangeDescriptionLabel *rightRangeDescriptionLabel;

@property (nonatomic, strong, readonly) UIImageView *rightArrowView;

@property (nonatomic, strong, readonly) UIImageView *leftArrowView;

// Accepts NSNumber for continous scale or discrete scale.
// Accepts NSArray<id<NSCopying, NSCoding, NSObject>> for text scale.
@property (nonatomic, strong, nullable) id currentAnswerValue;

@end

NS_ASSUME_NONNULL_END
