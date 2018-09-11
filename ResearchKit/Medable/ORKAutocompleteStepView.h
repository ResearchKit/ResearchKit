//
//  ORKAutocompleteStepView.h
//  Medable Axon
//
//  Copyright (c) 2016 Medable Inc. All rights reserved.
//
//

#import "ORKQuestionStepView.h"
#import "ORKSurveyAnswerCell.h"

NS_ASSUME_NONNULL_BEGIN

@class ORKAutocompleteStep;

@interface ORKAutocompleteStepView : ORKQuestionStepView

@property (nonatomic, strong, nullable) ORKAutocompleteStep *autocompleteStep;

@property (nonatomic, weak) id<ORKSurveyAnswerCellDelegate> answerDelegate;

@end

NS_ASSUME_NONNULL_END
