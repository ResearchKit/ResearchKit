/*
 Copyright (c) 2025, Apple Inc. All rights reserved.
 
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

// Temporary Shim
extension NSTimeZone {
    @objc
    public convenience init?(iso8601String: String) {
        guard let timeZone = TimeZone(iso8601String: iso8601String) else { return nil }
        self.init(forSecondsFromGMT: timeZone.secondsFromGMT())
    }
}

extension TimeZone {
    /// Extracts the timeZone from an ISO8601 formatted date string
    /// ISO8602 format: "yyyy-MM-dd'T'HH:mm:ssZ"
    /// Date example: 1987-03-06T07:30:00-0400
    init?(iso8601String: String) {
        guard let secondsFromGMT = if #available(iOS 16.0, *) {
            Self.parseSecondsFromGMT(in: iso8601String)
        } else {
            Self.legacy_parseSecondsFromGMT(in: iso8601String)
        } else { return nil }
                
        self.init(secondsFromGMT: secondsFromGMT)
    }
    
    @available(iOS 16.0, *)
    private static func parseSecondsFromGMT(in iso8601String: String) -> Int? {
        let search = /(?<year>[0-9]{4})-(?<month>[0-9]{2})-(?<day>[0-9]{2})T(?<hours>[0-9]{2}):(?<minutes>[0-9]{2}):(?<seconds>[0-9]{2})(?<sign>[\-\+]{1})(?<GMTHours>[0-9]{2})(?<GMTMinutes>[0-9]{2})/

        guard
            let result = try? search.wholeMatch(in: iso8601String),
            let GMTHours = Int(result.sign + result.GMTHours),
            let GMTMinutes = Int(result.sign + result.GMTMinutes)
        else { return nil }
            
        
        return GMTHours * 3600 + GMTMinutes * 60
    }
    
    private static func legacy_parseSecondsFromGMT(in iso8601String: String) -> Int? {
        let timeZoneString = String(iso8601String.suffix(5))
        let sign = String(timeZoneString.prefix(1))

        guard sign == "+" || sign == "-" else {
            return nil
        }

        let fullTimeString = timeZoneString.filter("0123456789".contains)

        guard
            fullTimeString.count == 4,
            let GMTHours = Int(sign+fullTimeString.prefix(2)),
            let GMTMinutes = Int(sign+fullTimeString.suffix(2))
        else {
            return nil
        }
        
        return GMTHours * 3600 + GMTMinutes * 60
    }
}
