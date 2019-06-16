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


import Foundation

public class ORKSwiftStroopStep: ORKActiveStep {

    public var numberOfAttempts = 0
    private let minimumAttempts = 10
    
    enum Key: String {
        case numberOfAttempts
    }

    public override class func stepViewControllerClass() -> AnyClass {
        return ORKSwiftStroopStepViewController.self
    }
    
    public class func supportsSecureCoding() -> Bool {
        return true
    }
    
    public override init(identifier: String) {
        super.init(identifier: identifier)
        
        shouldVibrateOnStart = true
        shouldShowDefaultTimer = false
        shouldContinueOnFinish = true
        stepDuration = TimeInterval(NSIntegerMax)
    }
    
    public override func validateParameters() {
        super.validateParameters()
        assert(numberOfAttempts >= minimumAttempts, "number of attempts should be greater or equal to \(minimumAttempts)")
    }

    public override func startsFinished() -> Bool {
        return false
    }
    
    public override var allowsBackNavigation: Bool {
        return false
    }
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let stroopStep = super.copy(with: zone)
        return stroopStep
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        numberOfAttempts = aDecoder.decodeInteger(forKey: Key.numberOfAttempts.rawValue)
    }
    
    public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(numberOfAttempts, forKey: Key.numberOfAttempts.rawValue)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? ORKSwiftStroopStep {
            return numberOfAttempts == object.numberOfAttempts
        }
        return false
    }
}
