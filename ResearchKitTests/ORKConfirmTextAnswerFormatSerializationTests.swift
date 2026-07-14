/*
 Copyright (c) 2024, Apple Inc. All rights reserved.
 
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
import Testing

@Suite(.tags(.serialization))
struct ORKConfirmTextAnswerFormatSerializationTests {
    @Test
    func testORKConfirmTextAnswerFormat() throws {
        let instance = ORKConfirmTextAnswerFormat(
            originalItemIdentifier: "id",
            errorMessage: "error"
        )
        instance.textContentType = UITextContentType.name
        instance.placeholder = "placeholder"
        instance.customDontKnowButtonText = "Don't know"
        instance.invalidMessage = "invalid"
        instance.passwordRules = UITextInputPasswordRules(
            descriptor: "required: upper; required: lower; required: digit; max-consecutive: 2; minlength: 8;"
        )
        instance.defaultTextAnswer = "default"
        instance.validationRegularExpression = try? NSRegularExpression(pattern: "[A-Z]", options: .caseInsensitive)
        instance.isSecureTextEntry = true
        instance.spellCheckingType = .yes
        instance.autocorrectionType = .no
        
        let expectation = """
        {
          "_class" : "ORKConfirmTextAnswerFormat",
          "autocapitalizationType" : 2,
          "autocorrectionType" : 1,
          "customDontKnowButtonText" : "Don't know",
          "defaultTextAnswer" : "default",
          "dontKnowButtonStyle" : 1,
          "errorMessage" : "error",
          "hideCharacterCountLabel" : false,
          "hideClearButton" : false,
          "invalidMessage" : "invalid",
          "keyboardType" : 0,
          "maximumLength" : 0,
          "multipleLines" : false,
          "originalItemIdentifier" : "id",
          "passwordRules" : {
            "rules" : "required: upper; required: lower; required: digit; max-consecutive: 2; minlength: 8;"
          },
          "placeholder" : "placeholder",
          "secureTextEntry" : true,
          "showDontKnowButton" : false,
          "spellCheckingType" : 2,
          "textContentType" : "name",
          "validationRegularExpression" : {
            "options" : [
              "NSRegularExpressionCaseInsensitive"
            ],
            "pattern" : "[A-Z]"
          }
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}
