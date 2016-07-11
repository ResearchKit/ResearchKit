/*
 Copyright (c) 2016, Andrew Hill.
 
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

import Foundation

/**
 The CanSupportMinMaxORKResultPredicate is a marker for ResearchKit's extensions to NSPredicate that
 this particular class can be compared with minimum and maximum values. At present the classes
 suitable are NSDates and derivatives of doubles.
 
 ResearchKit authors creating ORKResults with class-specific returns can make their return value
 conform to this protocol and can thereby gain the predicate functionality 'for free'.
*/
public protocol CanSupportMinMaxORKResultPredicate {
    
}

extension NSDate: CanSupportMinMaxORKResultPredicate {
    
}

extension Double: CanSupportMinMaxORKResultPredicate {
    
}


/**
 The CanSupportExpectedORKResultPredicate is a marker for ResearchKit's extensions to NSPredicate that
 this particular class can be compared with being given an expected value. At present the classes
 suitable are Bools and Strings.
 
 ResearchKit authors creating ORKResults with class-specific returns can make their return value
 conform to this protocol and can thereby gain the predicate functionality 'for free'.
 */
public protocol CanSupportExpectedORKResultPredicate {
    
}

extension Bool: CanSupportExpectedORKResultPredicate {
    
}

extension String: CanSupportExpectedORKResultPredicate {
    
}

extension Double: CanSupportExpectedORKResultPredicate {
    
}

extension NSDate: CanSupportExpectedORKResultPredicate {
    
}

/**
 This standalone function takes a set of subpredicates, and formats them into a single predicate and
 arguments array.
 
 @param resultSelector              The result selector object which specifies the question result
 you are interested in.
 @param subPredicateFormatArray     An array of format strings for the subpredicates (eg. minimum and maximum bounds).
 @param subPredicateFormatArgumentArray An array of arguments to match the format strings.
 @param areSubPredicateFormatsSubquery  Boolean value specifying whether to treat the SubPredicateFormats array as a subquery of our main predicate.
 */
func processORKResultSubpredicates(resultSelector: ORKResultSelector,
                                                 subPredicateFormatArray: [String],
                                                 subPredicateFormatArgumentArray: [String],
                                                 areSubPredicateFormatsSubquery: Bool)
    -> (format: String, formatArgumentArray: [String]) {
        
        var format: String
        var formatArgumentArray: [String] = []
        
        if let taskIdentifier = resultSelector.taskIdentifier {
            format = "SUBQUERY(SELF, $x, $x.identifier == %@"
            formatArgumentArray.append(taskIdentifier)
        }
        else {
            format = "SUBQUERY(SELF, $x, $x.identifier == $\(ORKResultPredicateTaskIdentifierVariableName)"
        }
        
        // Match question result identifier
        format += " AND SUBQUERY($x.results, $y, $y.identifier == %@ AND SUBQUERY($y.results, $z, $z.identifier == %@"
        
        // If the stepIdentifier is not defined (it is still marked as an optional String in Swift) then
        // set the stepIdentifier to be the same as the resultIdentifier
        if let stepIdentifier = resultSelector.stepIdentifier {
            formatArgumentArray.append(stepIdentifier)
        }
        else {
            formatArgumentArray.append(resultSelector.resultIdentifier)
        }
        formatArgumentArray.append(resultSelector.resultIdentifier)
        
        // Add question sub predicates. They can be normal predicates (for question results with only one answer)
        // or part of an additional subquery predicate (for question results with an array of answers, like ORKChoiceQuestionResult).
        
        for subPredicateFormat in subPredicateFormatArray {
            if (!areSubPredicateFormatsSubquery) {
                format += " AND $z." + subPredicateFormat
            }
            else {
                format += " AND SUBQUERY($z." + subPredicateFormat + ").@count > 0"
            }
        }
        formatArgumentArray += subPredicateFormatArgumentArray
        
        format += ").@count > 0).@count > 0).@count > 0"
        return (format, formatArgumentArray)
}


public extension NSPredicate {
    
    /**
     Creates a predicate matching a result which is comparable using minimums and maximums. Suitable
     result types include Dates, numerical values, and time intervals.
     
     @param resultSelector         The result selector object which specifies the question result
     you are interested in.
     @param minimum                The minimum value. Omit this parameter if you don't want to
     compare the answer against a minimum value.
     @param maximum                The maximum value. Omit this parameter if you don't want to
     compare the answer against a maximum value.
     
     */

    convenience init <T where T: CanSupportMinMaxORKResultPredicate>(resultSelector: ORKResultSelector, minimum: T? = nil, maximum: T? = nil) {
        
        var subPredicateFormatArray: [String] = []
        var subPredicateFormatArgumentArray: [String] = []
        
        if let minimum = minimum {
            subPredicateFormatArray.append("answer >= %@")
            subPredicateFormatArgumentArray.append("\(minimum)")
        }
        if let maximum = maximum {
            subPredicateFormatArray.append("answer <= %@")
            subPredicateFormatArgumentArray.append("\(maximum)")
        }
    
        let predicateParameters = processORKResultSubpredicates(resultSelector, subPredicateFormatArray: subPredicateFormatArray, subPredicateFormatArgumentArray: subPredicateFormatArgumentArray, areSubPredicateFormatsSubquery: false)
        
        self.init(format: predicateParameters.format, argumentArray: predicateParameters.formatArgumentArray)
    }
    
    /**
     Creates a predicate matching a result which has an expected value. Suitable
     result types include Booleans and Strings.
     
     @param resultSelector              The result selector object which specifies the question result
     you are interested in.
     @param expected                    The result that you are expecting.
     
     */
    
    convenience init <T where T: CanSupportExpectedORKResultPredicate>(resultSelector: ORKResultSelector, expected: T) {
        
        var subPredicateFormatArray: [String] = ["answer == %@"]
        var subPredicateFormatArgumentArray: [String] = ["\(expected)"]
        
        let predicateParameters = processORKResultSubpredicates(resultSelector, subPredicateFormatArray: subPredicateFormatArray, subPredicateFormatArgumentArray: subPredicateFormatArgumentArray, areSubPredicateFormatsSubquery: false)
        
        self.init(format: predicateParameters.format, argumentArray: predicateParameters.formatArgumentArray)
    }

    /**
     This is the internal function of choiceResultSelector - the public functions are expressed below
     
     */
    
    private convenience init (choiceResultSelector: ORKResultSelector, expected: [String], usePatterns: Bool) {
        
        var subPredicateFormatArray: [String] = []
        let repeatingSubPredicateFormat = (usePatterns == true) ?
            "answer, $w, $w matches %@" :
            "answer, $w, $w == %@"
        
        for expectedAnswer in expected {
            subPredicateFormatArray.append(repeatingSubPredicateFormat)
        }
        
        let predicateParameters = processORKResultSubpredicates(choiceResultSelector, subPredicateFormatArray: subPredicateFormatArray, subPredicateFormatArgumentArray: expected, areSubPredicateFormatsSubquery: true)
        
        self.init(format: predicateParameters.format, argumentArray: predicateParameters.formatArgumentArray)
    }
    
    /**
     Creates a predicate for a choice result to match against several results.
     
     @param choiceResultSelector    The result selector object which specifies the question result
     you are interested in.
     @param matches                 An array of string results to match exactly against.
     
     */
    
    convenience init (choiceResultSelector: ORKResultSelector, matches: [String])
    {
        self.init(choiceResultSelector: choiceResultSelector, expected: matches, usePatterns: false)
    }
    
    /**
     Creates a predicate for a choice result to match against a single result.
     
     @param choiceResultSelector    The result selector object which specifies the question result
     you are interested in.
     @param match                   A string result to match exactly against.
     
     */
    
    convenience init (choiceResultSelector: ORKResultSelector, match: String)
    {
        self.init(choiceResultSelector: choiceResultSelector, expected: [match], usePatterns: false)
    }
    
    /**
     Creates a predicate for a choice result to match against several patterns.
     
     @param choiceResultSelector    The result selector object which specifies the question result
     you are interested in.
     @param patterns                An array of string patterns to match against.
     
     */
    
    convenience init (choiceResultSelector: ORKResultSelector, patterns: [String])
    {
        self.init(choiceResultSelector: choiceResultSelector, expected: patterns, usePatterns: true)
    }
    
    /**
     Creates a predicate for a choice result to match against a single pattern.
     
     @param choiceResultSelector    The result selector object which specifies the question result
     you are interested in.
     @param pattern                A string pattern to match against
     
     */
    
    convenience init (choiceResultSelector: ORKResultSelector, pattern: String)
    {
        self.init(choiceResultSelector: choiceResultSelector, expected: [pattern], usePatterns: true)
    }

    
    // The functions below here are for interoperability with Objective C only; ideally they should be unavailable
    // for Swift projects.
    
    
    /**
     Creates a predicate matching a result of type `ORKBooleanQuestionResult` whose answer is the
     specified Boolean value. This function is deprecated in Swift, use resultSelector: expected: instead.
     
     @param resultSelector      The result selector object which specifies the question result you are
     interested in.
     @param expectedAnswer      The expected boolean value.
     
     @return A result predicate.
     */
    
    @objc convenience init (booleanQuestionResultWithResultSelector: ORKResultSelector, expectedAnswer: Bool) {
        self.init(resultSelector: booleanQuestionResultWithResultSelector, expected: expectedAnswer)
    }
    
    /**
     Creates a predicate matching a result of type `ORKChoiceQuestionResult` whose answer is equal to
     the specified object. This function is deprecated in Swift, use choiceResultSelector: match: instead.
     
     @param resultSelector          The result selector object which specifies the question result you
     are interested in.
     @param expectedAnswerValue     The expected answer object.
     
     @return A result predicate.
     */
    
    @objc convenience init (choiceQuestionResultWithResultSelector: ORKResultSelector, expectedAnswerValue: String) {
        self.init(choiceResultSelector: choiceQuestionResultWithResultSelector, expected: [expectedAnswerValue], usePatterns: false)
    }

    /**
     Creates a predicate matching a result of type `ORKDateQuestionResult` whose answer is a date within
     the specified dates. This function is deprecated in Swift, use resultSelector: minimum: maximum: instead.
     
     @param resultSelector              The result selector object which specifies the question result
     you are interested in.
     @param minimumExpectedAnswerDate   The minimum expected date. Pass `nil` if you don't want to
     compare the answer against a minimum date.
     @param maximumExpectedAnswerDate   The maximum expected date. Pass `nil` if you don't want to
     compare the answer against a maximum date.
     
     @return A result predicate.
     */
    
    @objc convenience init (dateQuestionResultWithResultSelector: ORKResultSelector,
                            minimumExpectedAnswerDate: NSDate, maximumExpectedAnswerDate: NSDate) {
        self.init(resultSelector: dateQuestionResultWithResultSelector, minimum: minimumExpectedAnswerDate, maximum: maximumExpectedAnswerDate)
    }

    /**
     Creates a predicate matching a result of type `ORKTimeIntervalQuestionResult` whose answer is the
     specified integer value. This function is deprecated in Swift, use resultSelector: minimum: maximum: instead.
     
     @param resultSelector              The result selector object which specifies the question result
     you are interested in.
     @param maximumExpectedAnswerValue  The maximum expected `NSTimeInterval` value.
     
     @return A result predicate.
     */
    @objc convenience init (timeIntervalQuestionResultWithResultSelector: ORKResultSelector,
                            maximumExpectedAnswerValue: NSTimeInterval) {
        self.init(resultSelector: timeIntervalQuestionResultWithResultSelector, maximum: maximumExpectedAnswerValue)
    }

    /**
     Creates a predicate matching a result of type `ORKTimeIntervalQuestionResult` whose answer is the
     specified integer value. This function is deprecated in Swift, use resultSelector: minimum: maximum: instead.
     
     @param resultSelector              The result selector object which specifies the question result
     you are interested in.
     @param minimumExpectedAnswerValue  The minimum expected `NSTimeInterval` value.
     
     @return A result predicate.
     */
    @objc convenience init (timeIntervalQuestionResultWithResultSelector: ORKResultSelector,
                            minimumExpectedAnswerValue: NSTimeInterval) {
        self.init(resultSelector: timeIntervalQuestionResultWithResultSelector, minimum: minimumExpectedAnswerValue)
    }
    
    /**
     Creates a predicate matching a result of type `ORKTimeIntervalQuestionResult` whose answer is
     within the specified `NSTimeInterval` values. This function is deprecated in Swift, use resultSelector: minimum: maximum: instead.
     
     @param resultSelector              The result selector object which specifies the question result
     you are interested in.
     @param minimumExpectedAnswerValue  The minimum expected `NSTimeInterval` value. Pass
     `ORKIgnoreTimeIntervlValue` if you don't want to compare the
     answer against a maximum `NSTimeInterval` value.
     @param maximumExpectedAnswerValue  The maximum expected `NSTimeInterval` value. Pass
     `ORKIgnoreTimeIntervlValue` if you don't want to compare the
     answer against a minimum `NSTimeInterval` value.
     
     @return A result predicate.
     */
    @objc convenience init (timeIntervalQuestionResultWithResultSelector: ORKResultSelector,
                            minimumExpectedAnswerValue: NSTimeInterval,
                            maximumExpectedAnswerValue: NSTimeInterval) {
        self.init(resultSelector: timeIntervalQuestionResultWithResultSelector, minimum: minimumExpectedAnswerValue,
                  maximum: maximumExpectedAnswerValue)
    }
    
    /**
     Creates a predicate matching a result of type `ORKNumericQuestionResult` whose answer is within the
     specified double values. This function is deprecated in Swift, use resultSelector: minimum: maximum: instead.
     
     @param resultSelector              The result selector object which specifies the question result
     you are interested in.
     @param minimumExpectedAnswerValue  The minimum expected double value. Pass `ORKIgnoreDoubleValue`
     if you don't want to compare the answer against a maximum
     double value.
     @param maximumExpectedAnswerValue  The maximum expected double value. Pass `ORKIgnoreDoubleValue`
     if you don't want to compare the answer against a minimum
     double value.
     
     @return A result predicate.
     */
    @objc convenience init (numericQuestionResultWithResultSelector: ORKResultSelector,
                            minimumExpectedAnswerValue: Double,
                            maximumExpectedAnswerValue: Double) {
        self.init(resultSelector: numericQuestionResultWithResultSelector, minimum: minimumExpectedAnswerValue,
                  maximum: maximumExpectedAnswerValue)
    }
    
    /**
     Creates a predicate matching a result of type `ORKNumericQuestionResult` whose answer is greater
     than or equal to the specified double value. This function is deprecated in Swift, use resultSelector: minimum: maximum: instead.
     
     @param resultSelector              The result selector object which specifies the question result
     you are interested in.
     @param minimumExpectedAnswerValue  The minimum expected double value.
     
     @return A result predicate.
     */
    @objc convenience init (numericQuestionResultWithResultSelector: ORKResultSelector,
                            minimumExpectedAnswerValue: Double) {
        self.init(resultSelector: numericQuestionResultWithResultSelector, minimum: minimumExpectedAnswerValue)
    }
    
    /**
     Creates a predicate matching a result of type `ORKNumericQuestionResult` whose answer is less than
     or equal to the specified double value. This function is deprecated in Swift, use resultSelector: minimum: maximum: instead.
     
     @param resultSelector              The result selector object which specifies the question result
     you are interested in.
     @param maximumExpectedAnswerValue  The maximum expected double value.
     
     @return A result predicate.
     */
    @objc convenience init (numericQuestionResultWithResultSelector: ORKResultSelector,
                            maximumExpectedAnswerValue: Double) {
        self.init(resultSelector: numericQuestionResultWithResultSelector, maximum: maximumExpectedAnswerValue)
    }

    /**
     Creates a predicate matching a result of type `ORKNumericQuestionResult` whose answer is the
     specified integer value. This function is deprecated in Swift, use resultSelector: expected: instead.
     
     @param resultSelector      The result selector object which specifies the question result you are
     interested in.
     @param expectedAnswer      The expected integer value.
     
     @return A result predicate.
     */
    @objc convenience init (numericQuestionResultWithResultSelector: ORKResultSelector,
                            expectedAnswer: Double) {
        self.init(resultSelector: numericQuestionResultWithResultSelector, expected: expectedAnswer)
    }

    /**
     Creates a predicate matching a result of type `ORKScaleQuestionResult` whose answer is the
     specified integer value. This function is deprecated in Swift, use resultSelector: expected: instead.
     
     @param resultSelector      The result selector object which specifies the question result you are
     interested in.
     @param expectedAnswer      The expected integer value.
     
     @return A result predicate.
     */
    @objc convenience init (scaleQuestionResultWithResultSelector: ORKResultSelector,
                            expectedAnswer: Double) {
        self.init(resultSelector: scaleQuestionResultWithResultSelector, expected: expectedAnswer)
    }
    
    /**
     Creates a predicate matching a result of type `ORKScaleQuestionResult` whose answer is within the
     specified double values. This function is deprecated in Swift, use resultSelector: minimum: maximum: instead.
     
     @param resultSelector              The result selector object which specifies the question result
     you are interested in.
     @param minimumExpectedAnswerValue  The minimum expected double value. Pass `ORKIgnoreDoubleValue`
     if you don't want to compare the answer against a maximum
     double value.
     @param maximumExpectedAnswerValue  The maximum expected double value. Pass `ORKIgnoreDoubleValue`
     if you don't want to compare the answer against a maximum
     double value.
     
     @return A result predicate.
     */
    @objc convenience init (scaleQuestionResultWithResultSelector: ORKResultSelector,
                            minimumExpectedAnswerValue: Double,
                            maximumExpectedAnswerValue: Double) {
        self.init(resultSelector: scaleQuestionResultWithResultSelector, minimum: minimumExpectedAnswerValue,
                  maximum: maximumExpectedAnswerValue)
    }
    
    /**
     Creates a predicate matching a result of type `ORKScaleQuestionResult` whose answer is greater than
     or equal to the specified double value. This function is deprecated in Swift, use resultSelector: minimum: maximum: instead.
     
     @param resultSelector              The result selector object which specifies the question result
     you are interested in.
     @param minimumExpectedAnswerValue  The minimum expected double value.
     
     @return A result predicate.
     */
    @objc convenience init (scaleQuestionResultWithResultSelector: ORKResultSelector,
                            minimumExpectedAnswerValue: Double) {
        self.init(resultSelector: scaleQuestionResultWithResultSelector, minimum: minimumExpectedAnswerValue)
    }
    
    /**
     Creates a predicate matching a result of type `ORKScaleQuestionResult` whose answer is less than or
     equal to the specified double value. This function is deprecated in Swift, use resultSelector: minimum: maximum: instead.
     
     @param resultSelector              The result selector object which specifies the question result
     you are interested in.
     @param maximumExpectedAnswerValue  The maximum expected double value.
     
     @return A result predicate.
     */
    @objc convenience init (scaleQuestionResultWithResultSelector: ORKResultSelector,
                            maximumExpectedAnswerValue: Double) {
        self.init(resultSelector: scaleQuestionResultWithResultSelector, maximum: maximumExpectedAnswerValue)
    }

}
