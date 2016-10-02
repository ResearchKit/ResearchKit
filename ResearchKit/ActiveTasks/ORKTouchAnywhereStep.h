//
//  ORKTouchAnywhereStep.h
//  ResearchKit
//
//  Created by Darren Levy on 8/8/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

@import Foundation;
#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKActiveStep.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKTouchAnywhereStep` class represents a step that displays a title with custom instructions
 and the text "Touch anywhere to continue." The user can touch almost anywhere on the
 screen and the step will end and the task will continue. The back button is still
 tappable.
 */
ORK_CLASS_AVAILABLE
@interface ORKTouchAnywhereStep : ORKActiveStep

- (instancetype)initWithIdentifier:(NSString *)identifier instructionText:(NSString *)instructionText;

@end

NS_ASSUME_NONNULL_END
