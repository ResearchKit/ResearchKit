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

import ResearchKit
import ResearchKitActiveTask

/// Framework-agnostic serialization primitives
enum SerializationTestHelper {
    static func normalizeJSON(_ jsonString: String) throws -> String {
        guard let data = jsonString.data(using: .utf8) else { throw Error.unexpectedNil }
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        let normalizedData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        guard let result = String(data: normalizedData, encoding: .utf8) else { throw Error.unexpectedNil }
        return result
    }

    static func serializeToPrettyPrintedString(_ object: Any, additionalProviders: [ORKSerializationEntryProvider] = []) throws -> String {
        let serializer = makeSerializer(additionalProviders: additionalProviders)
        let data = try serializer.jsonData(for: object)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        let prettyData = try serializer.jsonData(for: json, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        guard let result = String(data: prettyData, encoding: .utf8) else { throw Error.unexpectedNil }
        return result
    }

    static func serializeDictionaryToPrettyPrintedString(_ dictionary: [AnyHashable: Any]) throws -> String {
        let prettyData = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        guard let result = String(data: prettyData, encoding: .utf8) else { throw Error.unexpectedNil }
        return result
    }

    static func serializeToDictionary(_ object: Any, additionalProviders: [ORKSerializationEntryProvider] = []) throws -> [AnyHashable: Any] {
        try makeSerializer(additionalProviders: additionalProviders).jsonObject(for: object)
    }

    static func deserializeFromDictionary<T: Equatable>(_ dictionary: [AnyHashable: Any], additionalProviders: [ORKSerializationEntryProvider] = []) throws -> T {
        let object = try makeSerializer(additionalProviders: additionalProviders).object(fromJSONObject: dictionary)
        guard let typed = object as? T else { throw Error.typeMismatch }
        return typed
    }

    static func deserializedFromPrettyPrintedString<T>(_ string: String, additionalProviders: [ORKSerializationEntryProvider] = []) throws -> T {
        guard let data = string.data(using: .utf8) else { throw Error.unexpectedNil }
        let object = try makeSerializer(additionalProviders: additionalProviders).object(fromJSONData: data)
        guard let typed = object as? T else { throw Error.typeMismatch }
        return typed
    }

    static func archiveAndUnarchive<T: Equatable & NSObject & NSCoding>(_ object: T) throws -> T {
        let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true)
        guard let unarchived = try NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: data) else {
            throw Error.unexpectedNil
        }
        return unarchived
    }

    // MARK: - Private

    private static func makeSerializer(additionalProviders: [ORKSerializationEntryProvider] = []) -> ORKESerializer {
        ORKESerializer(entryProviders: [
            ORKCoreSerializationEntryProvider(),
            ORKActiveTaskSerializationEntryProvider()
        ] + additionalProviders)
    }
}

extension SerializationTestHelper {
    enum Error: Swift.Error {
        case unexpectedNil
        case typeMismatch
    }
}
