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
import Testing

@Suite(.tags(.serialization))
struct ORKDateAnswerFormatSerializationTests {

    @Test
    func testORKDateAnswerFormatBasicInit() throws {
        let minDate = Date(timeIntervalSinceReferenceDate: 0)
        let maxDate = minDate.addingTimeInterval(60 * 60 * 24)
        let defaultDate = minDate

        let minDateString = ORKResultDateTimeFormatter().string(from: minDate)
        let maxDateString = ORKResultDateTimeFormatter().string(from: maxDate)
        let defaultDateString = ORKResultDateTimeFormatter().string(from: defaultDate)

        let instance = ORKDateAnswerFormat(
            style: .date,
            defaultDate: defaultDate,
            minimumDate: minDate,
            maximumDate: maxDate,
            calendar: Calendar.default
        )

        instance.customDontKnowButtonText = "Don't know"

        let expectation = """
        {
          "_class" : "ORKDateAnswerFormat",
          "calendar" : "gregorian",
          "customDontKnowButtonText" : "Don't know",
          "defaultDate" : "\(defaultDateString)",
          "dontKnowButtonStyle" : 1,
          "isMaxDateCurrentTime" : false,
          "maximumDate" : "\(maxDateString)",
          "minimumDate" : "\(minDateString)",
          "minuteInterval" : 1,
          "showDontKnowButton" : false,
          "style" : "date"
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }

    @Test
    func testORKDateAnswerFormatWithDateOverride() throws {
        let currentDate = Date(timeIntervalSinceReferenceDate: 0)

        let instance = ORKDateAnswerFormat(
            style: .date,
            defaultDate: nil,
            minimumDate: nil,
            maximumDate: nil,
            calendar: Calendar.default
        )

        // For testing, use a round date due to precision errors in ISO8601
        instance._setCurrentDateOverride(currentDate)

        // As a side effect, this updates minimumDate
        instance.daysBeforeCurrentDateToSetMinimumDate = 10

        let minimumDate = try #require(instance.minimumDate)
        let minimumDateString = ORKResultDateTimeFormatter().string(from: minimumDate)

        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKDateAnswerFormat",
          "calendar" : "gregorian",
          "customDontKnowButtonText" : "",
          "daysBeforeCurrentDateToSetMinimumDate" : 10,
          "dontKnowButtonStyle" : 1,
          "isMaxDateCurrentTime" : false,
          "minimumDate" : "\(minimumDateString)",
          "minuteInterval" : 1,
          "showDontKnowButton" : false,
          "style" : "date"
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation) { instance in
            // When using daysBeforeCurrentDateToSetMinimumDate, because currentDate is not
            // serialized, objects are deserialized using "now", so the minimumDate needs to be ignored
            let instanceCopy = ORKDateAnswerFormat(
                style: instance.style,
                defaultDate: nil,
                minimumDate: nil,
                maximumDate: nil,
                calendar: instance.calendar
            )
            instanceCopy._setCurrentDateOverride(currentDate)
            instanceCopy.daysBeforeCurrentDateToSetMinimumDate = instance.daysBeforeCurrentDateToSetMinimumDate

            return instanceCopy
        }
    }

    @Test
    func testORKDateAnswerFormatWithUniqueStyle() throws {
        let minDate = Date(timeIntervalSinceReferenceDate: 0)
        let maxDate = Date(timeIntervalSinceReferenceDate: 24 * 24 * 60)
        let defaultDate = minDate

        let minDateString = ORKResultDateTimeFormatter().string(from: minDate)
        let maxDateString = ORKResultDateTimeFormatter().string(from: maxDate)
        let defaultDateString = ORKResultDateTimeFormatter().string(from: defaultDate)

        let instance = ORKDateAnswerFormat(
            style: .dateAndTime,
            defaultDate: defaultDate,
            minimumDate: minDate,
            maximumDate: maxDate,
            calendar: Calendar(identifier: .ethiopicAmeteAlem)
        )

        let expectation = """
        {
          "_class" : "ORKDateAnswerFormat",
          "calendar" : "ethiopic-amete-alem",
          "defaultDate" : "\(defaultDateString)",
          "dontKnowButtonStyle" : 1,
          "isMaxDateCurrentTime" : false,
          "maximumDate" : "\(maxDateString)",
          "minimumDate" : "\(minDateString)",
          "minuteInterval" : 1,
          "showDontKnowButton" : false,
          "style" : "dateTime"
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }

    @Test
    func testORKDateAnswerFormatWithMinMaxAndUniqueCalendar() throws {
        let minDate = Date(timeIntervalSinceReferenceDate: 0)
        let maxDate = Date(timeIntervalSinceReferenceDate: 24 * 24 * 60)
        let defaultDate = minDate

        let minDateString = ORKResultDateTimeFormatter().string(from: minDate)
        let maxDateString = ORKResultDateTimeFormatter().string(from: maxDate)
        let defaultDateString = ORKResultDateTimeFormatter().string(from: defaultDate)
                
        let instance = ORKAnswerFormat.dateAnswerFormat(
            withDefaultDate: defaultDate,
            minimumDate: minDate,
            maximumDate: maxDate,
            calendar: Calendar(identifier: .buddhist)
        )

        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKDateAnswerFormat",
          "calendar" : "buddhist",
          "customDontKnowButtonText" : "",
          "defaultDate" : "\(defaultDateString)",
          "dontKnowButtonStyle" : 1,
          "isMaxDateCurrentTime" : false,
          "maximumDate" : "\(maxDateString)",
          "minimumDate" : "\(minDateString)",
          "minuteInterval" : 1,
          "showDontKnowButton" : false,
          "style" : "date"
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}
