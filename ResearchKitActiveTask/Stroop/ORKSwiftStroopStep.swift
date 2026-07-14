/*
 Copyright (c) 2026, Apple Inc. All rights reserved.
 
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


@objc(ORKSwiftStroopStep)
public final class ORKSwiftStroopStep: ORKStroopStep, ORKStepIdentifiable {

    public override class var supportsSecureCoding: Bool { true }

    public private(set) var convertibleStep: StroopStep

    init(convertibleStep: StroopStep) {
        self.convertibleStep = convertibleStep
        super.init(identifier: convertibleStep.identifier)
    }

    public override init(identifier: String) {
        self.convertibleStep = .init(withoutValidation: identifier)
        super.init(identifier: identifier)
    }

    public required init(coder aDecoder: NSCoder) {
        guard let identifier = aDecoder.decodeObject(forKey: "identifier") as? String else {
            fatalError("ORKSwiftStroopStep: failed to decode identifier from archive")
        }
        self.convertibleStep = StroopStep(withoutValidation: identifier)
        super.init(coder: aDecoder)
        convertibleStep.trialCount = super.numberOfAttempts

        if let colorNames = aDecoder.decodeObject(of: [NSArray.self, NSString.self], forKey: CodingKeys.colorChoices) as? [String] {
            convertibleStep.colorChoices = colorNames.compactMap(StroopColor.init(rawValue:))
        }
        if let maskName = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.interTrialMaskType) as? String {
            convertibleStep.interTrialMaskType = StroopInterTrialMask(rawValue: maskName) ?? .none
        }
        if aDecoder.containsValue(forKey: CodingKeys.congruentFrequency) {
            convertibleStep.congruentFrequency = aDecoder.decodeDouble(forKey: CodingKeys.congruentFrequency)
        }
        if aDecoder.containsValue(forKey: CodingKeys.incongruentFrequency) {
            convertibleStep.incongruentFrequency = aDecoder.decodeDouble(forKey: CodingKeys.incongruentFrequency)
        }
        if aDecoder.containsValue(forKey: CodingKeys.neutralFrequency) {
            convertibleStep.neutralFrequency = aDecoder.decodeDouble(forKey: CodingKeys.neutralFrequency)
        }
        if aDecoder.containsValue(forKey: CodingKeys.minimumInterTrialDelay) {
            convertibleStep.minimumInterTrialDelay = aDecoder.decodeDouble(forKey: CodingKeys.minimumInterTrialDelay)
        }
        if aDecoder.containsValue(forKey: CodingKeys.maximumInterTrialDelay) {
            convertibleStep.maximumInterTrialDelay = aDecoder.decodeDouble(forKey: CodingKeys.maximumInterTrialDelay)
        }
        if aDecoder.containsValue(forKey: CodingKeys.recordResults) {
            convertibleStep.recordResults = aDecoder.decodeBool(forKey: CodingKeys.recordResults)
        }
    }

    public override var identifier: String {
        convertibleStep.identifier
    }

    public override var numberOfAttempts: Int {
        get { convertibleStep.trialCount }
        set { convertibleStep.trialCount = newValue }
    }

    public var colorChoices: [StroopColor] {
        get { convertibleStep.colorChoices }
        set { convertibleStep.colorChoices = newValue }
    }

    public var interTrialMaskType: StroopInterTrialMask {
        get { convertibleStep.interTrialMaskType }
        set { convertibleStep.interTrialMaskType = newValue }
    }

    @objc public var congruentFrequency: Double {
        get { convertibleStep.congruentFrequency }
        set { convertibleStep.congruentFrequency = newValue }
    }

    @objc public var incongruentFrequency: Double {
        get { convertibleStep.incongruentFrequency }
        set { convertibleStep.incongruentFrequency = newValue }
    }

    @objc public var neutralFrequency: Double {
        get { convertibleStep.neutralFrequency }
        set { convertibleStep.neutralFrequency = newValue }
    }

    @objc public var minimumInterTrialDelay: TimeInterval {
        get { convertibleStep.minimumInterTrialDelay }
        set { convertibleStep.minimumInterTrialDelay = newValue }
    }

    @objc public var maximumInterTrialDelay: TimeInterval {
        get { convertibleStep.maximumInterTrialDelay }
        set { convertibleStep.maximumInterTrialDelay = newValue }
    }

    @objc public var recordResults: Bool {
        get { convertibleStep.recordResults }
        set { convertibleStep.recordResults = newValue }
    }

    // MARK: - ObjC Serialization Bridging

    @objc var serializedColorChoices: [String] {
        get { colorChoices.map(\.rawValue) }
        set { colorChoices = newValue.compactMap(StroopColor.init(rawValue:)) }
    }

    @objc var serializedInterTrialMaskType: String {
        get { interTrialMaskType.rawValue }
        set { interTrialMaskType = StroopInterTrialMask(rawValue: newValue) ?? .none }
    }

    // MARK: - NSCoding

    private enum CodingKeys {
        static let colorChoices = "colorChoices"
        static let interTrialMaskType = "interTrialMaskType"
        static let congruentFrequency = "congruentFrequency"
        static let incongruentFrequency = "incongruentFrequency"
        static let neutralFrequency = "neutralFrequency"
        static let minimumInterTrialDelay = "minimumInterTrialDelay"
        static let maximumInterTrialDelay = "maximumInterTrialDelay"
        static let recordResults = "recordResults"
    }

    public override func encode(with coder: NSCoder) {
        // ORK_ENCODE_INTEGER accesses the _numberOfAttempts ivar directly,
        // bypassing the Swift computed property override. Sync before super encodes.
        super.numberOfAttempts = convertibleStep.trialCount
        super.encode(with: coder)
        coder.encode(serializedColorChoices, forKey: CodingKeys.colorChoices)
        coder.encode(serializedInterTrialMaskType, forKey: CodingKeys.interTrialMaskType)
        coder.encode(congruentFrequency, forKey: CodingKeys.congruentFrequency)
        coder.encode(incongruentFrequency, forKey: CodingKeys.incongruentFrequency)
        coder.encode(neutralFrequency, forKey: CodingKeys.neutralFrequency)
        coder.encode(minimumInterTrialDelay, forKey: CodingKeys.minimumInterTrialDelay)
        coder.encode(maximumInterTrialDelay, forKey: CodingKeys.maximumInterTrialDelay)
        coder.encode(recordResults, forKey: CodingKeys.recordResults)
    }

    // MARK: - NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! ORKSwiftStroopStep
        copy.convertibleStep = convertibleStep
        return copy
    }

    // MARK: - Equality

    public override func isEqual(_ object: Any?) -> Bool {
        guard super.isEqual(object), let other = object as? ORKSwiftStroopStep else {
            return false
        }
        return convertibleStep == other.convertibleStep
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(super.hash)
        hasher.combine(convertibleStep)
        return hasher.finalize()
    }

    public override func validateParameters() {
        do {
            try convertibleStep.validateParameters()
        } catch {
            NSException(
                name: .init(String(reflecting: error)),
                reason: error.localizedDescription,
                userInfo: nil
            ).raise()
        }
    }
}
