/*
 Copyright (c) 2017, Ricardo Sanchez-Saez.
 
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


#import "ORKDeprecated.h"

#import "ORKRegistrationStep_Internal.h"


@implementation ORKAnswerFormat (Deprecated)

+ (ORKTextAnswerFormat *)textAnswerFormatWithValidationRegex:(NSString *)validationRegularExpressionPattern
                                              invalidMessage:(NSString *)invalidMessage {
        return [[ORKTextAnswerFormat alloc] initWithValidationRegex:validationRegularExpressionPattern
                                                     invalidMessage:invalidMessage];
}

@end


@implementation ORKTextAnswerFormat (Deprecated)

- (instancetype)initWithValidationRegex:(NSString *)validationRegularExpressionPattern
                         invalidMessage:(NSString *)invalidMessage {
    NSRegularExpression *validationRegularExpression = [NSRegularExpression regularExpressionWithPattern:validationRegularExpressionPattern
                                                                                         options:(NSRegularExpressionOptions)0
                                                                                           error:nil];
    return [self initWithValidationRegularExpression:validationRegularExpression
                                      invalidMessage:invalidMessage];

}

- (NSString *)validationRegex {
    return self.validationRegularExpression.pattern;
}

@end


@implementation ORKRegistrationStep (Deprecated)

- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(nullable NSString *)title
                              text:(nullable NSString *)text
           passcodeValidationRegex:(nullable NSString *)passcodeValidationRegularExpressionPattern
            passcodeInvalidMessage:(nullable NSString *)passcodeInvalidMessage
                           options:(ORKRegistrationStepOption)options {
    NSRegularExpression *validationRegularExpression = [NSRegularExpression regularExpressionWithPattern:passcodeValidationRegularExpressionPattern
                                                                                                 options:(NSRegularExpressionOptions)0
                                                                                                   error:nil];
    return [self initWithIdentifier:identifier
                              title:title
                               text:text
passcodeValidationRegularExpression:validationRegularExpression
             passcodeInvalidMessage:passcodeInvalidMessage
                            options:options];
}

- (NSString *)passcodeValidationRegex {
    return [self passwordAnswerFormat].validationRegularExpression.pattern;
}

@end
