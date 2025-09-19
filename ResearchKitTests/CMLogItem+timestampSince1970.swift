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

import CoreMotion
import Testing

@testable import ResearchKitActiveTask

@Suite
struct CMLogItemTimestampTests {
    let sut = MockCMLogItem()
    
    static let calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return calendar
    }()
    
    @Test("Calculating correct timestamp since 1970 given reference uptime", arguments: [
        BootTime.past,
        BootTime.recent,
        BootTime.now,
    ])
    func calculateTimeStampSince1970(using lastBootTime: BootTime) {
        // Given the reference uptime
        let referenceUptime = lastBootTime.referenceUptime
        
        // When calculating the timestamp value since 1970 in reference to the reference up time
        let timestampSince1970 = sut.timestampSince1970(using: referenceUptime)

        // Then the log item's dates calculated using timestamp or timestampSince1970 are identical as expected.
        let dateAtTimestampFromTimeInterval = lastBootTime.date.addingTimeInterval(sut.timestamp)
        let dateAtTimestampFromTimeIntervalSince1970 = Date(timeIntervalSince1970: timestampSince1970)

        #expect(Self.calendar.isDate(
            dateAtTimestampFromTimeIntervalSince1970,
            equalTo: dateAtTimestampFromTimeInterval,
            toGranularity: .second),
                """
                Given a last boot date of \(lastBootTime.date), \
                translating to a reference uptime of \(referenceUptime), \
                expected the date derived from the calculated timestamp since 1970 (\(timestampSince1970)) \
                to yield the last boot date + \(sut.timestamp) seconds = \(dateAtTimestampFromTimeInterval), \
                but got \(dateAtTimestampFromTimeIntervalSince1970) instead.
                """
        )
    }
}

class MockCMLogItem: CMLogItem {
    override var timestamp: TimeInterval {
        900.00 // The log item event happened 900s, i.e 15 min, after the reference uptime.
    }
}

extension CMLogItemTimestampTests {
    enum BootTime {
        case past
        case recent
        case now
        
        var date: Date {
            Date(timeIntervalSinceNow: -referenceUptime)
        }
        
        var referenceUptime: TimeInterval {
            switch self {
            case .past: 1556172614.3611889 // 1976/04/01 10:10:10
            case .recent: 5 // 5s ago
            case .now: 0 // 0s ago
            }
        }
    }
}
