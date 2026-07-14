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

import Foundation

struct JSONNode: Identifiable {
    let id = UUID()
    let key: String
    let value: JSONValue
}

indirect enum JSONValue {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    case object([JSONNode])
    case array([JSONNode])

    /// Converts any Foundation-compatible JSON value into a `JSONValue`.
    static func from(_ value: Any) -> JSONValue {
        switch value {
        case let s as String:
            return .string(s)
        case let n as NSNumber:
            return CFGetTypeID(n) == CFBooleanGetTypeID() ? .bool(n.boolValue) : .number(n.doubleValue)
        case let dict as [AnyHashable: Any]:
            let nodes = dict.compactMap { key, val -> JSONNode? in
                guard let key = key as? String else { return nil }
                return JSONNode(key: key, value: .from(val))
            }.sorted { $0.key < $1.key }
            return .object(nodes)
        case let array as [Any]:
            let nodes = array.enumerated().map { index, element in
                JSONNode(key: "[\(index)]", value: .from(element))
            }
            return .array(nodes)
        case is NSNull:
            return .null
        default:
            return .string(String(describing: value))
        }
    }
}
