//
//  ORKAutocompleteStep.m
//  Medable Axon
//
//  Copyright (c) 2016 Medable Inc. All rights reserved.
//
//

#import "ORKAutocompleteStep.h"
#import "ORKAnswerFormat.h"
#import "ORKAutocompleteStepViewController.h"

@implementation ORKAutocompleteStep

+ (Class)stepViewControllerClass
{
    return [ORKAutocompleteStepViewController class];
}

- (ORKAnswerFormat *)answerFormat
{
    ORKTextAnswerFormat *answerFormat = [ORKTextAnswerFormat new];
    
    answerFormat.multipleLines = NO;
    answerFormat.secureTextEntry = NO;
    answerFormat.autocorrectionType = UITextAutocorrectionTypeNo;
    answerFormat.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    return answerFormat;
}


@end
