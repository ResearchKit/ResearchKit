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

import ResearchKit

///** Adapts any swift type to be contained within an ORKStep. When a
/// registered SwiftUI View will be presented to screen via `ORKHostingActiveStepViewController`,
/// the **rawStep** will be the value ultimately passed into that SwiftUI View.
///

nonisolated
public final class ORKAdapterStep<S>: ORKStep, ORKRawStepRepresentable {
    public nonisolated var rawStep: S

    public init(rawStep: S) {
        self.rawStep = rawStep
        let identifier = if let rawStep = rawStep as? ORKStepIdentifiable {
            rawStep.identifier
        } else {
            "\(type(of: self)).\(type(of: rawStep))"
        }
        super.init(identifier: identifier)
    }

    public init(identifiable: S) where S: ORKStepIdentifiable {
        self.rawStep = identifiable
        super.init(identifier: identifiable.identifier)
    }

    public required init(coder aDecoder: NSCoder) {
        self.rawStep = aDecoder.decodeObject(forKey: "rawStep") as! S
        super.init(coder: aDecoder)
    }

    public override func validateParameters() {
        if let rawStep = rawStep as? ORKStepValidatable {
            do {
                try rawStep.validateParameters()
            } catch {
                let name = NSExceptionName(String(reflecting: error))
                let userInfo: [String: Any] = ["error": error]
                NSException(name: name, reason: error.localizedDescription, userInfo: userInfo)
                    .raise()
            }
        }
    }
}

public protocol ORKStepIdentifiable {
    var identifier: String { get }
}

extension ORKStepIdentifiable where Self: Identifiable {
    public var id: String {
        identifier
    }
}
