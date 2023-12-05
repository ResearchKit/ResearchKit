/*
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

public class ORKSwiftStroopResult: ORKResult {
    
    public var startTime: TimeInterval?
    public var endTime: TimeInterval?
    public var color: String?
    public var text: String?
    public var colorSelected: String?
    
    enum Keys: String {
        case startTime
        case endTime
        case color
        case text
        case colorSelected
    }
    
    public override init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(startTime, forKey: Keys.startTime.rawValue)
        aCoder.encode(endTime, forKey: Keys.endTime.rawValue)
        aCoder.encode(color, forKey: Keys.color.rawValue)
        aCoder.encode(text, forKey: Keys.text.rawValue)
        aCoder.encode(colorSelected, forKey: Keys.colorSelected.rawValue)
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        startTime = aDecoder.decodeObject(forKey: Keys.startTime.rawValue) as? Double
        endTime = aDecoder.decodeObject(forKey: Keys.endTime.rawValue) as? Double
        color = aDecoder.decodeObject(forKey: Keys.color.rawValue) as? String
        text = aDecoder.decodeObject(forKey: Keys.text.rawValue) as? String
        colorSelected = aDecoder.decodeObject(forKey: Keys.colorSelected.rawValue) as? String
    }
    
    public class func supportsSecureCoding() -> Bool {
        return true
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        let isParentSame = super.isEqual(object)
        
        if let castObject = object as? ORKSwiftStroopResult {
            return (isParentSame &&
                   (startTime == castObject.startTime) &&
                   (endTime == castObject.endTime) &&
                   (color == castObject.color) &&
                   (text == castObject.text) &&
                   (colorSelected == castObject.colorSelected))
        }
        return true
    }
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        if let result = super.copy(with: zone) as? ORKSwiftStroopResult {
            result.startTime = startTime
            result.endTime = endTime
            result.color = color
            result.text = text
            result.colorSelected = colorSelected
            return result
        } else {
            return super.copy(with: zone)
        }
    }
    
    public override func description(withNumberOfPaddingSpaces numberOfPaddingSpaces: UInt) -> String {
        return "\(descriptionPrefix(withNumberOfPaddingSpaces: numberOfPaddingSpaces)); color: \(color ?? "") text: \(text ?? "") colorSelected: \(colorSelected ?? "") \(descriptionSuffix())"
    }
}
