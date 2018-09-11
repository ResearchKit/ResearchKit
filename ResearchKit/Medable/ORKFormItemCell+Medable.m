//
//  ORKFormItemCell+Medable.m
//  Axon
//
//  Created by J.Rodden on 5/18/18.
//  Copyright © 2018 Medable Inc. All rights reserved.
//

#import "ResearchKit.h"
#import "ORKFormItemCell.h"
#import "ORKTextFieldView.h"
#import "MDRTextInputFeedback.h"

// see ORKFormItemCell.m
@interface ORKFormItemCell ()
- (void)ork_setAnswer:(id)answer;
@end

// see ORKFormItemCell.m
@interface ORKFormItemTextFieldBasedCell()
- (ORKUnitTextField *)textField;
@end

#pragma mark -

@implementation ORKFormItemTextFieldBasedCell (Medable)

- (void)ork_setAnswer:(id)answer
{
    [super ork_setAnswer:answer];
    
    NSObject<MDRTextInputFeedback>* textInputFeedback =
    (NSObject<MDRTextInputFeedback>*)self.formItem.answerFormat;
    
    if ([textInputFeedback conformsToProtocol:@protocol(MDRTextInputFeedback)])
    {
        answer = [answer isKindOfClass:NSString.class] ? answer : nil;
        [textInputFeedback updateTextField:self.textField forValue:answer];
    }
}

@end
