//
//  ORKAutocompleteStep.h
//  Medable Axon
//
//  Copyright (c) 2016 Medable Inc. All rights reserved.
//
//

@import Foundation;
#import <ResearchKit/ORKQuestionStep.h>

NS_ASSUME_NONNULL_BEGIN

ORK_CLASS_AVAILABLE
@interface ORKAutocompleteStep : ORKQuestionStep

/*
 * Completion Text List
 * c_completion_text_list
 *
 * List of autocomplete entries.
 */
@property (nonatomic, nullable) NSArray *completionTextList;

/**
 * Restrict Value
 * c_completion_text_list_restrict
 *
 * When true, restrict possible values to only those matching an entry in the completion text list.
 */
@property (nonatomic) BOOL restrictValue;

/**
 * Match Anywhere
 * c_match_anywhere
 *
 * When true, match the search term anywhere in the autocomplete value (instead of looking for a prefix only).
 */
@property (nonatomic) BOOL matchAnywhere;

@end

NS_ASSUME_NONNULL_END
