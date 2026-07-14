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
import ResearchKit

/// Swift equivalent of the ObjC `ORKLocalizedString` macro.
///
/// Looks up `key` in the `ResearchKit` strings table using the ResearchKit framework bundle.
/// The `value` parameter is returned as a fallback when the key has no translation.
///
/// Resolves the active localization fresh on each call via
/// `Bundle.preferredLocalizations(from:forPreferences:)` rather than reading
/// the framework bundle's cached `preferredLocalizations`. The cached value is
/// established when the framework is first loaded and does not update when
/// `AppleLanguages` is overridden later (notably in tests where xctestplan's
/// `language` option or `-testLanguage` apply launch-arg overrides after
/// framework load). Reading the cached value would silently fall back to the
/// development-region (`en`) strings even when the test process has been
/// configured for another locale.
///
/// The resolved `lproj` `Bundle` is cached per match key so subsequent calls
/// avoid the file-system instantiation. The match key changes when the active
/// locale changes, so caching does not interfere with the fresh-resolution
/// behavior above.
func ORKLocalizedString(
    _ key: String,
    value: String = "",
    preferredLanguages: [String] = Locale.preferredLanguages
) -> String {
    let frameworkBundle = Bundle(for: ORKStep.self)
    if let bestMatch = Bundle.preferredLocalizations(
            from: frameworkBundle.localizations,
            forPreferences: preferredLanguages
       ).first,
       let lprojBundle = LprojBundleCache.shared.bundle(for: bestMatch, in: frameworkBundle) {
        return lprojBundle.localizedString(forKey: key, value: value, table: "ResearchKit")
    }
    return NSLocalizedString(
        key,
        tableName: "ResearchKit",
        bundle: frameworkBundle,
        value: value,
        comment: ""
    )
}

private final class LprojBundleCache: @unchecked Sendable {
    static let shared = LprojBundleCache()
    private let lock = NSLock()
    private var cache: [String: Bundle] = [:]

    func bundle(for bestMatch: String, in frameworkBundle: Bundle) -> Bundle? {
        lock.lock()
        defer { lock.unlock() }
        if let cached = cache[bestMatch] {
            return cached
        }
        guard let lprojPath = frameworkBundle.path(forResource: bestMatch, ofType: "lproj"),
              let lprojBundle = Bundle(path: lprojPath) else {
            return nil
        }
        cache[bestMatch] = lprojBundle
        return lprojBundle
    }
}
