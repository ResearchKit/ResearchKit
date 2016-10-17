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
 The TimeOfDay struct is a comparable structure for storing time of day values.
 
 @param hour    an integer which must be less than 24.
 @param minute  an integer which must be less than 60.
 */
public struct TimeOfDay: Comparable {
    let hour: Int
    let minute: Int
}

// We also make NSDate comparable and equatable to allow us to use it in NSPredicate
extension NSDate: Comparable { }

// MARK: Equatable

public func ==(lhs: TimeOfDay, rhs: TimeOfDay) -> Bool {
    return ((lhs.hour == rhs.hour) && (lhs.minute == rhs.minute))
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

// MARK: Comparable

public func <(lhs: TimeOfDay, rhs: TimeOfDay) -> Bool {
    let lhsTotalTime = (lhs.hour * 60) + lhs.minute
    let rhsTotalTime = (rhs.hour * 60) + rhs.minute
    return (lhsTotalTime < rhsTotalTime)
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
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
    
    convenience init <T where T: Comparable>(resultSelector: ORKResultSelector, minimum: T? = nil, maximum: T? = nil) {
        
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
    
    convenience init <T where T: Equatable>(resultSelector: ORKResultSelector, expected: T) {
        
        let subPredicateFormatArray: [String] = ["answer == %@"]
        let subPredicateFormatArgumentArray: [String] = ["\(expected)"]
        
        let predicateParameters = processORKResultSubpredicates(resultSelector, subPredicateFormatArray: subPredicateFormatArray, subPredicateFormatArgumentArray: subPredicateFormatArgumentArray, areSubPredicateFormatsSubquery: false)
        
        self.init(format: predicateParameters.format, argumentArray: predicateParameters.formatArgumentArray)
    }
    
    /**
     This is the internal function of choiceResultSelector - the public functions are expressed below and are more syntax-friendly.
     
     @param choiceResultSelector    The result selector object which specifies the question result
     you are interested in.
     @param expected                An array of string results for either matching or exact results.
     @param usePatterns             True if we are pattern-matching, false if it's an exact match
     */
    
    private convenience init (choiceResultSelector: ORKResultSelector, expected: [String], usePatterns: Bool) {
        
        var subPredicateFormatArray: [String] = []
        let repeatingSubPredicateFormat = (usePatterns == true) ?
            "answer, $w, $w matches %@" :
        "answer, $w, $w == %@"
        
        for _ in expected {
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
}
