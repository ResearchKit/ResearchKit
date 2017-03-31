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


#import <ResearchKit/ORKAnswerFormat.h>


NS_ASSUME_NONNULL_BEGIN

ORK_EXTERN id ORKNullAnswerValue() ORK_AVAILABLE_DECL;


@interface ORKAnswerFormat ()

- (BOOL)isAnswerValidWithString:(nullable NSString *)text;

@end


/**
 The `ORKConfirmTextAnswerFormat` class represents the answer format for questions that collect a text
 response from the user and validates it with another text answer format.
 
 An `ORKConfirmTextAnswerFormat` object produces an `ORKBooleanQuestionResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKConfirmTextAnswerFormat : ORKTextAnswerFormat

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithMaximumLength:(NSInteger)maximumLength NS_UNAVAILABLE;

- (instancetype)initWithValidationRegularExpression:(NSRegularExpression *)validationRegularExpression
                                     invalidMessage:(NSString *)invalidMessage NS_UNAVAILABLE;

/**
 Returns an initialized text answer format using the original item identifier.
 
 @param originalItemIdentifier  The form item identifier against which this answer item is validated.
 @param errorMessage            The error message displayed if validation fails.
 
 @return An initialized confirm text answer format.
 */
- (instancetype)initWithOriginalItemIdentifier:(NSString *)originalItemIdentifier
                                  errorMessage:(NSString *)errorMessage;

/**
 The identifier for the form item that the current item will be validated against.
 */
@property (nonatomic, copy, readonly) NSString *originalItemIdentifier;


/**
 The error message displayed if validation fails.
 */
@property (nonatomic, copy, readonly) NSString *errorMessage;

@end

NS_ASSUME_NONNULL_END
