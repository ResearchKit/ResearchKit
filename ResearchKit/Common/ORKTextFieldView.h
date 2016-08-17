/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


@import UIKit;
#import "ORKAnswerTextField.h"


NS_ASSUME_NONNULL_BEGIN

@interface ORKCaretOptionalTextField : ORKAnswerTextField

@property (nonatomic) BOOL allowsSelection; // Defaults to NO

@property (nonatomic) BOOL hitClearButton;

@end


@interface ORKPasscodeTextField : ORKCaretOptionalTextField

- (void)updateTextWithNumberOfFilledBullets:(NSInteger)filledBullets;

@property (nonatomic) NSInteger numberOfDigits;

@end


@interface ORKUnitTextField : ORKCaretOptionalTextField

@property (nonatomic, copy, nullable) NSString *unit;

@property (nonatomic) BOOL manageUnitAndPlaceholder;

@end


/**
 Manages a text field with unit label and a clear button: [text unit    (x)]
 */
@interface ORKTextFieldView : UIView

@property (nonatomic, strong, readonly) ORKUnitTextField *textField;

@property (nonatomic, readonly) CGFloat estimatedWidth;

@end

NS_ASSUME_NONNULL_END
