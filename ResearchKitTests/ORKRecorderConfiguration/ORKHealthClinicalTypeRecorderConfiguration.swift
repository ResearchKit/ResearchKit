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


import ResearchKitActiveTask
import ResearchKitActiveTask_Private


import Testing

@testable import ResearchKitActiveTask

extension ORKRecorderConfigurationTests {
    @Suite("ORKHealthClinicalTypeRecorderConfiguration")
    struct ORKHealthClinicalTypeRecorderConfigurationTests {
        let anyHealthClinicalType: HKClinicalType = .clinicalType(forIdentifier: .allergyRecord)!
        let anyHealthFHIRResourceType: HKFHIRResourceType = .allergyIntolerance

        @available(*, deprecated) // To avoid a warning about the function being tested being deprecated.
        @Test(
            """
            When passing nil to the deprecated recorderForStep:outputDirectory function's outputDirectory \
            parameter, the configuration's output directory is the one set in the configuration.
            """
        )
        func recorderForStepOutputDirectory_DeprecationMechanism_outputDirectoryPassedIsNil() throws {
            let expectedOutputDirectory = anyOutputDirectory

            let recorderConfiguration = ORKHealthClinicalTypeRecorderConfiguration(
                identifier: anyIdentifier,
                healthClinicalType: anyHealthClinicalType,
                healthFHIRResourceType: anyHealthFHIRResourceType,
                outputDirectory: expectedOutputDirectory,
                rollingFileSizeThreshold: anyRollingFileSizeThreshold
            )

            let recorder = recorderConfiguration.recorder(for: anyStep, outputDirectory: nil)

            #expect(recorder?.outputDirectory == expectedOutputDirectory)
        }

        @available(*, deprecated) // To avoid a warning about the function being tested being deprecated.
        @Test(
            """
            When passing a value to the deprecated recorderForStep:outputDirectory function's outputDirectory \
            parameter, the configuration's output directory is that value.
            """
        )
        func recorderForStepOutputDirectory_DeprecationMechanism_outputDirectoryPassedIsNonNil() throws {
            let initialOutputDirectory = anyOutputDirectory
            let expectedFinalOutputDirectory = anyOtherOutputDirectory

            let recorderConfiguration = ORKHealthClinicalTypeRecorderConfiguration(
                identifier: anyIdentifier,
                healthClinicalType: anyHealthClinicalType,
                healthFHIRResourceType: anyHealthFHIRResourceType,
                outputDirectory: initialOutputDirectory,
                rollingFileSizeThreshold: anyRollingFileSizeThreshold
            )

            let recorder = recorderConfiguration.recorder(
                for: anyStep,
                outputDirectory: expectedFinalOutputDirectory
            )

            #expect(recorder?.outputDirectory == expectedFinalOutputDirectory)
        }
    }
}
