//
//  MDRTextInputFeedback.h
//  ResearchKit
//
//  Created by J.Rodden on 5/23/18.
//  Copyright © 2018 Medable Inc. All rights reserved.
//

@protocol MDRTextInputFeedback

- (void)updateTextField:(UITextField* __nonnull)textField
               forValue:(NSString* __nullable)newTextFieldValue;

@end
