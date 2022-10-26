/*
 Copyright (c) 2019, Novartis.
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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

import ResearchKit.Private

public class ORKLandoltCResult: ORKResult {
    
    public var outcome: Bool?
    public var letterAngle: Double?
    public var sliderAngle: Double?
    public var score: Int?
    
    enum Keys: String {
        case outcome
        case letterAngle
        case sliderAngle
        case score
    }
    
    public init(identifier: String, outcome: Bool, letterAngle: Double, sliderAngle: Double, score: Int) {
        super.init(identifier: identifier)
        
        self.outcome = outcome
        self.letterAngle = letterAngle
        self.sliderAngle = sliderAngle
        self.score = score
    }
    
    override public func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        
        aCoder.encode(outcome, forKey: Keys.outcome.rawValue)
        aCoder.encode(letterAngle, forKey: Keys.letterAngle.rawValue)
        aCoder.encode(sliderAngle, forKey: Keys.sliderAngle.rawValue)
        aCoder.encode(score, forKey: Keys.score.rawValue)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        outcome = aDecoder.decodeObject(forKey: Keys.outcome.rawValue) as? Bool ?? false
        letterAngle = aDecoder.decodeObject(forKey: Keys.letterAngle.rawValue) as? Double ?? 0.0
        sliderAngle = aDecoder.decodeObject(forKey: Keys.sliderAngle.rawValue) as? Double ?? 0.0
        score = aDecoder.decodeObject(forKey: Keys.score.rawValue) as? Int ?? 0
    }
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let result = super.copy(with: zone) as! ORKLandoltCResult
        
        result.outcome = outcome
        result.letterAngle = letterAngle
        result.sliderAngle = sliderAngle
        result.score = score
        
        return result
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        let isParentSame = super.isEqual(object)
        
        if let castObject = object as? ORKLandoltCResult {
            
            return (isParentSame &&
                ORKEqualObjects(outcome as Any, castObject.outcome as Any) &&
                ORKEqualObjects(letterAngle as Any, castObject.letterAngle as Any) &&
                ORKEqualObjects(sliderAngle as Any, castObject.sliderAngle as Any) &&
                ORKEqualObjects(score as Any, castObject.score as Any))
        }
        
        return true
    }
    
    override public func description(withNumberOfPaddingSpaces numberOfPaddingSpaces: UInt) -> String {
        let descriptionString = """
        \(descriptionPrefix(withNumberOfPaddingSpaces: numberOfPaddingSpaces));
        Outcome: \(String(describing: outcome)); LetterAngle: \(String(describing: letterAngle));
        SliderAngle: \(String(describing: sliderAngle)); Score: \(String(describing: score))
        """
        return descriptionString
    }
}

