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

@objc
public extension ORKRecorder {
    /**
     A short string that uniquely identifies the recorder (usually assigned by the recorder configuration).
     
     The identifier is reproduced in the results of a recorder created from this configuration. In fact, the only way to link a result
     (an `ORKFileResult` object) to the recorder that generated it is to look at the value of
     `identifier`. To accurately identify recorder results, you need to ensure that recorder identifiers
     are unique within each step.
     
     In some cases, it can be useful to link the recorder identifier to a unique identifier in a
     database; in other cases, it can make sense to make the identifier human
     readable.
     */
    var identifier: String? {
        configuration.identifier
    }
    
    /**
     The file URL of the output directory configured during initialization.
     
     Typically, you set the `outputDirectory` property for the `ORKTaskViewController` object
     before presenting the task.
     */
    var outputDirectory: URL? {
        configuration.outputDirectory
    }
    
    /**
     The file-size threshold in bytes used to determine when data is rolled over to multiple files as data is being written.
     If the value is 0, data is written to only one file and not rolled over to multiple files.
     */
    var rollingFileSizeThreshold: Int {
        configuration.rollingFileSizeThreshold
    }
}
