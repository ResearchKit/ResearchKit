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

@objc
public enum VisionStepLeftOrRightEye: Int {
    case left
    case right
}

@objc
public enum VisionStepType: Int {
    case visualAcuity
    case contrastSensitivity
}

@objc
public class ORKLandoltCStep: ORKActiveStep {
    
    public var testType: VisionStepType?
    public var eyeToTest: VisionStepLeftOrRightEye?
    
    enum Key: String {
        case testType
        case eyeToTest
    }
    
    public override class func stepViewControllerClass() -> AnyClass {
        return ORKLandoltCStepViewController.self
    }
    
    public class func supportsSecureCoding() -> Bool {
        return true
    }
    
    @objc
    public init(identifier: String, testType: VisionStepType, eyeToTest: VisionStepLeftOrRightEye) {
        super.init(identifier: identifier)
        self.testType = testType
        self.eyeToTest = eyeToTest
    }
    
    public override var allowsBackNavigation: Bool {
        return false
    }

    public override func copy(with zone: NSZone? = nil) -> Any {
        let visionStep: ORKLandoltCStep = super.copy(with: zone) as! ORKLandoltCStep
        return visionStep
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let typeValue = aDecoder.decodeObject(forKey: "stepType") as? Int {
            testType = VisionStepType(rawValue: typeValue)
        }
        
        if let eyeValue = aDecoder.decodeObject(forKey: "eyeToTest") as? Int {
            eyeToTest = VisionStepLeftOrRightEye(rawValue: eyeValue)
        }
    }
    
    public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(testType, forKey: Key.testType.rawValue)
        aCoder.encode(eyeToTest, forKey: Key.eyeToTest.rawValue)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? ORKLandoltCStep {
            return testType == object.testType && eyeToTest == object.eyeToTest
        }
        return false
    }
    
}

