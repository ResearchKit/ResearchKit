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

import Foundation
import os
import Testing

extension Tag {
    @Tag static var serialization: Self
}

extension SerializationTestHelper {
    static func assertEquality<T: Equatable & NSObject & NSCoding>(
        _ object: T,
        _ jsonString: String,
        additionalProviders: [ORKSerializationEntryProvider] = [],
        skipStringComparison: Bool = false,
        modifyingDeserializedObjectBeforeComparison modifyObject: ((T) -> T)? = nil
    ) throws {
        if modifyObject != nil {
            let classType = "\(type(of: object))"
            os_log(
                .info,
                log: .init(subsystem: "Serialization Tests", category: "Equatable Check"),
                "%@ is not bidirectionally serializable. This can be improved in the future.", classType
            )
        }

        let modifyObject = modifyObject ?? { $0 }
        let normalizedJSONString = try SerializationTestHelper.normalizeJSON(jsonString)

        try assertJSONStringEquality(
            object,
            against: normalizedJSONString,
            additionalProviders: additionalProviders,
            skipStringComparison: skipStringComparison,
            modifyObject: modifyObject
        )

        try assertDictionaryEquality(
            object,
            against: normalizedJSONString,
            additionalProviders: additionalProviders,
            skipStringComparison: skipStringComparison,
            modifyObject: modifyObject
        )

        try assertArchiveEquality(object)

        try assertCopyEquality(object, additionalProviders: additionalProviders, modifyObject: modifyObject)
    }

    // MARK: - Private

    private static func assertJSONStringEquality<T: Equatable & NSObject & NSCoding>(
        _ object: T,
        against normalizedJSONString: String,
        additionalProviders: [ORKSerializationEntryProvider],
        skipStringComparison: Bool,
        modifyObject: (T) -> T
    ) throws {
        let serializedStringResult = try SerializationTestHelper.serializeToPrettyPrintedString(object, additionalProviders: additionalProviders)

        if !skipStringComparison {
            #expect(
                normalizedJSONString == serializedStringResult,
                "The serialization verification (String -> String) validation has failed."
            )
        }

        let deserializedStringResult: T = try SerializationTestHelper.deserializedFromPrettyPrintedString(
            serializedStringResult,
            additionalProviders: additionalProviders
        )

        #expect(
            object == modifyObject(deserializedStringResult),
            "The serialization verification (Object -> Object) validation has failed."
        )
    }

    private static func assertDictionaryEquality<T: Equatable & NSObject & NSCoding>(
        _ object: T,
        against normalizedJSONString: String,
        additionalProviders: [ORKSerializationEntryProvider],
        skipStringComparison: Bool,
        modifyObject: (T) -> T
    ) throws {
        let dictionaryResult = try SerializationTestHelper.serializeToDictionary(object, additionalProviders: additionalProviders)
        let deserializedDictionaryResult: T = try SerializationTestHelper.deserializeFromDictionary(
            dictionaryResult,
            additionalProviders: additionalProviders
        )
        let serializedDictionaryResult = try SerializationTestHelper.serializeDictionaryToPrettyPrintedString(
            dictionaryResult
        )

        #expect(
            object == modifyObject(deserializedDictionaryResult),
            "The serialization verification (Object -> Object) validation has failed."
        )
        if !skipStringComparison {
            #expect(
                serializedDictionaryResult == normalizedJSONString,
                "The serialization verification (String -> String) validation has failed."
            )
        }
    }

    private static func assertArchiveEquality<T: Equatable & NSObject & NSCoding>(_ object: T) throws {
        let archiveResult = try SerializationTestHelper.archiveAndUnarchive(object)
        #expect(
            object == archiveResult,
            "The serialization verification (Object -> Object) validation has failed."
        )
    }

    private static func assertCopyEquality<T: Equatable & NSObject & NSCoding>(
        _ object: T,
        additionalProviders: [ORKSerializationEntryProvider],
        modifyObject: (T) -> T
    ) throws {
        if let copyableObject = object as? NSCopying {
            let copyResult = try #require(copyableObject.copy() as? T)
            #expect(
                object == modifyObject(copyResult),
                "The serialization verification (Object -> Object) validation has failed."
            )
        } else {
            let classType = "\(type(of: object))"
            os_log(
                .info,
                log: .init(subsystem: "Serialization Tests", category: "Copyable Check"),
                "Skipping copy equality check because class %@ doesn't conform to NSCopying.",
                classType
            )
        }
    }
}
