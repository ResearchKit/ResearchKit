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

// MARK: - Public

public extension CMLogItem {
    /// The timestamp as a time interval in seconds since 1970, calculated from `timestamp` with the system
    /// uptime as reference.
    ///
    /// - Important: This API has the potential of being misused to access device signals to try to identify
    /// the device or user, also known as fingerprinting. Regardless of whether a user gives your app
    /// permission to track,fingerprinting is not allowed. When you use this API in your app or third-party
    /// SDK (an SDK not provided by Apple), declare your usage and the reason for using the API in your app
    /// or third-party SDK’s PrivacyInfo.xcprivacy file. For more information, including the list of valid
    /// reasons for using the API, see [Describing use of required reason API](https://developer.apple.com/documentation/BundleResources/describing-use-of-required-reason-api).
    ///
    /// - SeeAlso: `timeInterval`
    /// - SeeAlso: `ProcessInfo.processInfo.systemUptime`
    @objc
    var timestampSince1970: TimeInterval {
        timestampSince1970()
    }
}

// MARK: - Internal

extension CMLogItem {
    /// Calculates `timestamp` as a time interval in seconds since 1970, using `referenceUptime` if
    /// provided, or the system uptime otherwise.
    ///
    /// - Parameter referenceUptime: The amount of time the system has been awake since the last time it was
    /// restarted. If not provided, uses the system uptime. **This value should always be positive.**
    ///
    /// - Returns the timestamp as a time interval since 1970.
    ///
    /// - Important: the `referenceUptime` parameter is a duration. It should always be positive. If deriving
    /// it from a `Date` using `timeIntervalFromNow`, the returned time interval will be negative for a date
    /// in the past. In that case, make sure to pass the absolute value.
    ///
    /// - SeeAlso: `timeInterval`
    /// - SeeAlso: `ProcessInfo.processInfo.systemUptime`
    func timestampSince1970(
        using referenceUptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    ) -> TimeInterval {
        let bootDateFromReferenceUptime = Date(timeIntervalSinceNow: -referenceUptime)
        let timeStampDate = bootDateFromReferenceUptime.addingTimeInterval(timestamp)
        return timeStampDate.timeIntervalSince1970
    }
}
