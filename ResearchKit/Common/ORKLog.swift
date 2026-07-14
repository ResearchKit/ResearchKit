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


import os
import ResearchKit_Private

private let _logger = ORKLogger()

/// Logs a debug-level message through the ResearchKit logging system.
///
/// Debug messages are not captured in crash reports and are intended for
/// development use only.
///
/// - Parameters:
///     - message: The message to log.
///     - file: The source file name.
///     - function: The function name.
///     - line: The line number.
public func ORKLogDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    _logger.debug(message, file: file, function: function, line: line)
}

/// Logs an info-level message through the ResearchKit logging system.
///
/// Use info-level messages for general operational information that may be
/// useful for diagnosing issues in production.
///
/// - Parameters:
///     - message: The message to log.
///     - file: The source file name.
///     - function: The function name.
///     - line: The line number.
public func ORKLogInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    _logger.info(message, file: file, function: function, line: line)
}

/// Logs an error-level message through the ResearchKit logging system.
///
/// Use error-level messages to record recoverable errors that affected behavior.
/// Error messages are preserved in crash reports.
///
/// - Parameters:
///     - message: The message to log.
///     - file: The source file name.
///     - function: The function name.
///     - line: The line number.
public func ORKLogError(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    _logger.error(message, file: file, function: function, line: line)
}

/// Logs a fault-level message through the ResearchKit logging system.
///
/// Fault-level messages represent unrecoverable conditions. These messages
/// are always captured and preserved in crash reports regardless of the
/// `ORKLoggingEnabled` setting.
///
/// - Parameters:
///     - message: The message to log.
///     - file: The source file name.
///     - function: The function name.
///     - line: The line number.
public func ORKLogFault(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    _logger.fault(message, file: file, function: function, line: line)
}

struct ORKLogger {
    private let logger: Logger

    init(category: String = "ResearchKit") {
        logger = Logger(subsystem: "com.apple.ResearchKit", category: category)
    }

    private var isLoggingEnabled: Bool {
        ORKLoggingEnabled.boolValue
    }

    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }

    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }

    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }

    func fault(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .fault, file: file, function: function, line: line)
    }

    private func log(_ message: String, level: OSLogType, file: String, function: String, line: Int) {
        guard isLoggingEnabled else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(level.rawValue)] [\(fileName):\(line)] \(function) - \(message)"

        logger.log(level: level, "\(logMessage)")
    }
}
