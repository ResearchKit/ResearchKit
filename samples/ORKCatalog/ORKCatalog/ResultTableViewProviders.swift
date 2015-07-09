/*
Copyright (c) 2015, Apple Inc. All rights reserved.

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

import UIKit
import ResearchKit

/**
    Create a `protocol<UITableViewDataSource, UITableViewDelegate>` that knows
    how to present the metadata for an `ORKResult` instance. Extra metadata is
    displayed for specific `ORKResult` types. For example, a table view provider
    for an `ORKFileResult` instance will display the `fileURL` in addition to the
    standard `ORKResult` properties.

    To learn about how to read metadata from the different kinds of `ORKResult`
    instances, see the `ResultTableViewProvider` subclasses below. Specifically,
    look at their `resultRowsForSection(_:)` implementations which are meant to
    enhance the metadata that is displayed for the result table view provider.

    Note: since these table view providers are meant to display data for developers
    and are not user visible (see description in `ResultViewController`), none
    of the properties / content are localized.
*/
func resultTableViewProviderForResult(result: ORKResult?) -> protocol<UITableViewDataSource, UITableViewDelegate>? {
    if let result = result {
        // The type that will be used to create an instance of a table view provider.
        let providerType: ResultTableViewProvider.Type
        
        /*
            Map the type of the result to its associated `ResultTableViewProvider`.
            To reduce the possible effects of someone modifying this code--i.e.
            cases getting reordered and accidentally getting matches for subtypes
            of the intended result type, we guard against any subtype matches
            (e.g. the `ORKCollectionResult` guard against `result` being an 
            `ORKTaskResult` instance).
        */
        switch result {
            case is ORKScaleQuestionResult:
                providerType = ScaleQuestionResultTableViewProvider.self

            case is ORKNumericQuestionResult:
                providerType = NumericQuestionResultTableViewProvider.self

            case is ORKTimeOfDayQuestionResult:
                providerType = TimeOfDayQuestionResultTableViewProvider.self

            case is ORKDateQuestionResult:
                providerType = DateQuestionResultTableViewProvider.self

            case is ORKTimeIntervalQuestionResult:
                providerType = TimeIntervalQuestionResultTableViewProvider.self

            case is ORKTextQuestionResult:
                providerType = TextQuestionResultTableViewProvider.self

            case is ORKChoiceQuestionResult:
                providerType = ChoiceQuestionResultTableViewProvider.self

            case is ORKBooleanQuestionResult:
                providerType = BooleanQuestionResultTableViewProvider.self

            case is ORKTappingIntervalResult:
                providerType = TappingIntervalResultTableViewProvider.self

            case is ORKSpatialSpanMemoryResult:
                providerType = SpatialSpanMemoryResultTableViewProvider.self
            
            case is ORKReactionTimeResult:
                providerType = ReactionTimeViewProvider.self
            
            case is ORKFileResult:
                providerType = FileResultTableViewProvider.self

            case is ORKConsentSignatureResult:
                providerType = ConsentSignatureResultTableViewProvider.self

            case is ORKTaskResult:
                providerType = TaskResultTableViewProvider.self

            case is ORKToneAudiometryResult:
                providerType = ToneAudiometryResultTableViewProvider.self

            /*
                Refer to the comment near the switch statement for why the
                additional guard is here.
            */
            case is ORKCollectionResult where !(result is ORKTaskResult):
                providerType = CollectionResultTableViewProvider.self

            default:
                fatalError("No ResultTableViewProvider defined for \(NSStringFromClass(result.dynamicType)).")
        }
        
        // Return a new instance of the specific `ResultTableViewProvider`.
        return providerType(result: result)
    }
    
    /*
        Use a table view provider that shows that there hasn't been a recently
        provided result.
    */
    return NoRecentResultTableViewProvider()
}

/**
    An enum representing the data that can be presented in a `UITableViewCell` by
    a `ResultsTableViewProvider` type.
*/
enum ResultRow {
    // MARK: Cases

    case Text(String, detail: String, selectable: Bool)
    case TextImage(String, image: UIImage?)
    case Image(UIImage?)
    
    // MARK: Types
    
    /**
        Possible `UITableViewCell` identifiers that have been defined in the main
        storyboard.
    */
    enum TableViewCellIdentifier: String {
        case Default =          "Default"
        case NoResultSet =      "NoResultSet"
        case NoChildResults =   "NoChildResults"
        case TextImage =        "TextImage"
        case Image =            "Image"
    }
    
    // MARK: Initialization
    
    /// Helper initializer for `ResultRow.Text`.
    init(text: String, detail: Any?, selectable: Bool = false) {
        /*
            Show the string value if `detail` is not `nil`, otherwise show that
            it's "nil". Use Optional's map method to map the value to a string
            if the detail is not `nil`.
        */
        let detailText = detail.map { toString($0) } ?? "nil"
        
        self = .Text(text, detail: detailText, selectable: selectable)
    }
}

/**
    A special `protocol<UITableViewDataSource, UITableViewDelegate>` that displays
    a row saying that there's no result.
*/
class NoRecentResultTableViewProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(ResultRow.TableViewCellIdentifier.NoResultSet.rawValue, forIndexPath: indexPath) as! UITableViewCell
    }
}

// MARK: ResultTableViewProvider and Subclasses

/**
    Base class for displaying metadata for an `ORKResult` instance. The metadata
    that's displayed are common properties for all `ORKResult` instances (e.g.
    `startDate` and `endDate`).
*/
class ResultTableViewProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    // MARK: Properties
    
    let result: ORKResult
    
    // MARK: Initializers
    
    required init(result: ORKResult) {
        self.result = result
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let resultRows = resultRowsForSection(section)

        // Show an empty row if there isn't any metadata in the rows for this section.
        if resultRows.isEmpty {
            return 1
        }
        
        return resultRows.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let resultRows = resultRowsForSection(indexPath.section)
        
        // Show an empty row if there isn't any metadata in the rows for this section.
        if resultRows.isEmpty {
            return tableView.dequeueReusableCellWithIdentifier(ResultRow.TableViewCellIdentifier.NoChildResults.rawValue, forIndexPath: indexPath) as! UITableViewCell
        }

        // Fetch the `ResultRow` that corresponds to `indexPath`.
        let resultRow = resultRows[indexPath.row]
        
        switch resultRow {
            case let .Text(text, detail: detailText, selectable):
                let cell = tableView.dequeueReusableCellWithIdentifier(ResultRow.TableViewCellIdentifier.Default.rawValue, forIndexPath: indexPath) as! UITableViewCell

                cell.textLabel!.text = text
                cell.detailTextLabel!.text = detailText
                
                /*
                    In this sample, the accessory type should be a disclosure
                    indicator if the table view cell is selectable.
                */
                cell.selectionStyle = selectable ? .Default : .None
                cell.accessoryType  = selectable ? .DisclosureIndicator : .None
            
                return cell

            case let .TextImage(text, image):
                let cell = tableView.dequeueReusableCellWithIdentifier(ResultRow.TableViewCellIdentifier.TextImage.rawValue, forIndexPath: indexPath) as! TextImageTableViewCell

                cell.leftTextLabel.text = text
                cell.rightImageView.image = image

                return cell

            case let .Image(image):
                let cell = tableView.dequeueReusableCellWithIdentifier(ResultRow.TableViewCellIdentifier.Image.rawValue, forIndexPath: indexPath) as! ImageTableViewCell

                cell.fullImageView.image = image

                return cell

            default:
                fatalError("Unexpected result table row type.")
        }

        fatalError("No cell could be created in the current context.")
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Result" : nil
    }
    
    // MARK: Overridable Methods
    
    func resultRowsForSection(section: Int) -> [ResultRow] {
        if section == 0 {
            return [
                // The class name of the result object.
                ResultRow(text: "type", detail: NSStringFromClass(result.dynamicType)),

                /*
                    The identifier of the result, which corresponds to the task,
                    step or item that generated it.
                */
                ResultRow(text: "identifier", detail: result.identifier),
                
                // The start date for the result.
                ResultRow(text: "start", detail: result.startDate),
                
                // The end date for the result.
                ResultRow(text: "end", detail: result.endDate)
            ]
        }
        
        // Default to an empty array.
        return []
    }
}

/// Table view provider specific to an `ORKScaleQuestionResult` instance.
class ScaleQuestionResultTableViewProvider: ResultTableViewProvider {
    // MARK: ResultTableViewProvider
    
    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let scaleQuestionResult = result as! ORKScaleQuestionResult
        
        return super.resultRowsForSection(section) + [
            // The numeric value returned from the discrete or continuous slider.
            ResultRow(text: "scaleAnswer", detail: scaleQuestionResult.scaleAnswer)
        ]
    }
}

/// Table view provider specific to an `ORKNumericQuestionResult` instance.
class NumericQuestionResultTableViewProvider: ResultTableViewProvider {
    // MARK: ResultTableViewProvider
    
    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let questionResult = result as! ORKNumericQuestionResult
        
        return super.resultRowsForSection(section) + [
            // The numeric value the user entered.
            ResultRow(text: "numericAnswer", detail: questionResult.numericAnswer),

            // The unit string that was displayed with the numeric value.
            ResultRow(text: "unit", detail: questionResult.unit)
        ]
    }
}

/// Table view provider specific to an `ORKTimeOfDayQuestionResult` instance.
class TimeOfDayQuestionResultTableViewProvider: ResultTableViewProvider {
    // MARK: ResultTableViewProvider
    
    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let questionResult = result as! ORKTimeOfDayQuestionResult
        
        // Format the date components received in the result.
        let dateComponentsFormatter = NSDateComponentsFormatter()
        let dateComponentsAnswerText = dateComponentsFormatter.stringFromDateComponents(questionResult.dateComponentsAnswer!)

        return super.resultRowsForSection(section) + [
            // String summarizing the date components the user entered.
            ResultRow(text: "dateComponentsAnswer", detail: dateComponentsAnswerText)
        ]
    }
}

/// Table view provider specific to an `ORKDateQuestionResult` instance.
class DateQuestionResultTableViewProvider: ResultTableViewProvider {
    // MARK: ResultTableViewProvider
    
    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let questionResult = result as! ORKDateQuestionResult
        
        return super.resultRowsForSection(section) + [
            // The date the user entered.
            ResultRow(text: "dateAnswer", detail: questionResult.dateAnswer),

            // The calendar that was used when the date picker was presented.
            ResultRow(text: "calendar", detail: questionResult.calendar),
            
            // The timezone when the user answered.
            ResultRow(text: "timeZone", detail: questionResult.timeZone)
        ]
    }
}

/// Table view provider specific to an `ORKTimeIntervalQuestionResult` instance.
class TimeIntervalQuestionResultTableViewProvider: ResultTableViewProvider {
    // MARK: ResultTableViewProvider

    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let questionResult = result as! ORKTimeIntervalQuestionResult
        
        return super.resultRowsForSection(section) + [
            // The time interval the user answered.
            ResultRow(text: "intervalAnswer", detail: questionResult.intervalAnswer)
        ]
    }
}

/// Table view provider specific to an `ORKTextQuestionResult` instance.
class TextQuestionResultTableViewProvider: ResultTableViewProvider {
    // MARK: ResultTableViewProvider

    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let questionResult = result as! ORKTextQuestionResult
        
        return super.resultRowsForSection(section) + [
            // The text the user typed into the text view.
            ResultRow(text: "textAnswer", detail: questionResult.textAnswer)
        ]
    }
}

/// Table view provider specific to an `ORKChoiceQuestionResult` instance.
class ChoiceQuestionResultTableViewProvider: ResultTableViewProvider {
    // MARK: ResultTableViewProvider
    
    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let choiceResult = result as! ORKChoiceQuestionResult
        
        return super.resultRowsForSection(section) + [
            ResultRow(text: "choices", detail: choiceResult.choiceAnswers)
        ]
    }
}

/// Table view provider specific to an `ORKBooleanQuestionResult` instance.
class BooleanQuestionResultTableViewProvider: ResultTableViewProvider   {
    // MARK: ResultTableViewProvider
    
    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let boolResult = result as! ORKBooleanQuestionResult
        
        var boolResultDetailText: String?
        if let booleanAnswer = boolResult.booleanAnswer {
            boolResultDetailText = booleanAnswer.boolValue ? "true" : "false"
        }
        
        return super.resultRowsForSection(section) + [
            ResultRow(text: "bool", detail: boolResultDetailText)
        ]
    }
}

/// Table view provider specific to an `ORKTappingIntervalResult` instance.
class TappingIntervalResultTableViewProvider: ResultTableViewProvider {
    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return super.tableView(tableView, titleForHeaderInSection: 0)
        }
        
        return "Samples"
    }
    
    // MARK: ResultTableViewProvider
    
    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let questionResult = result as! ORKTappingIntervalResult
        
        let rows = super.resultRowsForSection(section)
        
        if section == 0 {
            return rows + [
                // The size of the view where the two target buttons are displayed.
                ResultRow(text: "stepViewSize", detail: questionResult.stepViewSize),

                // The rect corresponding to the left button.
                ResultRow(text: "buttonRect1", detail: questionResult.buttonRect1),
                
                // The rect corresponding to the right button.
                ResultRow(text: "buttonRect2", detail: questionResult.buttonRect2)
            ]
        }
        
        // Add a `ResultRow` for each sample.
        return rows + questionResult.samples!.map { sample in
            let tappingSample = sample as! ORKTappingSample
            
            // These tap locations are relative to the rectangle defined by `stepViewSize`.
            let buttonText = tappingSample.buttonIdentifier == .None ? "None" : "button \(tappingSample.buttonIdentifier.rawValue)"
            
            let text = String(format: "%.3f", tappingSample.timestamp)
            let detail = "\(buttonText) \(tappingSample.location)"
            
            return ResultRow(text: text, detail: detail)
        }
    }
}

/// Table view provider specific to an `ORKToneAudiometryResult` instance.
class ToneAudiometryResultTableViewProvider: ResultTableViewProvider {
    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return super.tableView(tableView, titleForHeaderInSection: 0)
        }

        return "Samples"
    }

    // MARK: ResultTableViewProvider

    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let toneAudiometryResult = result as! ORKToneAudiometryResult
        let rows = super.resultRowsForSection(section)

        if section == 0 {
            return rows + [
                // The size of the view where the two target buttons are displayed.
                ResultRow(text: "outputVolume", detail: toneAudiometryResult.outputVolume),
            ]
        }

        // Add a `ResultRow` for each sample.
        return rows + toneAudiometryResult.samples!.map { sample in
            let toneSample = sample as! ORKToneAudiometrySample

            let text : String
            let detail : String

            if let frequency = toneSample.frequency,
                amplitude = toneSample.amplitude {
                    let channelName = toneSample.channel == ORKAudioChannel.Left ? "Left" : "Right"

                    text = "\(frequency) \(channelName)"
                    detail = "\(amplitude)"
            }
            else {
                text = ""
                detail = ""
            }

            return ResultRow(text: text, detail: detail)
        }
    }
}

/// Table view provider specific to an `ORKSpatialSpanMemoryResult` instance.
class SpatialSpanMemoryResultTableViewProvider: ResultTableViewProvider {
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return super.tableView(tableView, titleForHeaderInSection: 0)
        }
        
        return "Game Records"
    }
    
    // MARK: ResultTableViewProvider
    
    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let questionResult = result as! ORKSpatialSpanMemoryResult
        
        let rows = super.resultRowsForSection(section)
        
        if section == 0 {
            return rows + [
                // The score the user received for the game as a whole.
                ResultRow(text: "score", detail: questionResult.score),

                // The number of games played.
                ResultRow(text: "numberOfGames", detail: questionResult.numberOfGames),
                
                // The number of failures.
                ResultRow(text: "numberOfFailures", detail: questionResult.numberOfFailures)
            ]
        }
        
        return rows + questionResult.gameRecords!.map { gameRecord in
            // Note `gameRecord` is of type `ORKSpatialSpanMemoryGameRecord`.
            return ResultRow(text: "game", detail: gameRecord.score)
        }
    }
}

/// Table view provider specific to an `ORKReactionTimeResult` instance.
class ReactionTimeViewProvider: ResultTableViewProvider {
    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return super.tableView(tableView, titleForHeaderInSection: 0)
        }
        
        return "File Results"
    }
    
    // MARK: ResultTableViewProvider

    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let reactionTimeResult = result as! ORKReactionTimeResult
        
        let rows = super.resultRowsForSection(section)
        
        if section == 0 {
            return rows + [ ResultRow(text: "timestamp", detail: reactionTimeResult.timestamp) ]
        }
        
        return rows + [ ResultRow(text: "File Result", detail: reactionTimeResult.fileResult.fileURL!.absoluteString) ]
    }
}

/// Table view provider specific to an `ORKFileResult` instance.
class FileResultTableViewProvider: ResultTableViewProvider {
    // MARK: ResultTableViewProvider
    
    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let questionResult = result as! ORKFileResult
        
        let rows = super.resultRowsForSection(section) + [
            // The MIME content type for the file produced.
            ResultRow(text: "contentType", detail: questionResult.contentType),

            // The URL of the generated file on disk.
            ResultRow(text: "fileURL", detail: questionResult.fileURL)
        ]

        if let fileURL = questionResult.fileURL, let contentType = questionResult.contentType where contentType.hasPrefix("image/") {
            if let data = NSData(contentsOfURL: fileURL), let image = UIImage(data: data) {
                return rows + [
                    // The image of the generated file on disk.
                    .Image(image)
                ]
            }
        }
        
        return rows
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let resultRows = resultRowsForSection(indexPath.section)
        
        if !resultRows.isEmpty {
            switch resultRows[indexPath.row] {
                case .Image(.Some(let image)):
                    // Keep the aspect ratio the same.
                    let imageAspectRatio = image.size.width / image.size.height

                    return tableView.frame.size.width / imageAspectRatio

                default:
                    break
            }
        }
        
        return UITableViewAutomaticDimension
    }
}

/// Table view provider specific to an `ORKConsentSignatureResult` instance.
class ConsentSignatureResultTableViewProvider: ResultTableViewProvider {
    // MARK: ResultTableViewProvider
    
    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let signatureResult = result as! ORKConsentSignatureResult
        let signature = signatureResult.signature!
        
        return super.resultRowsForSection(section) + [
            /*
                The identifier for the signature, identifying which one it is in
                the document.
            */
            ResultRow(text: "identifier", detail: signature.identifier),
            
            /*
                The title of the signatory, displayed under the line. For
                example, "Participant".
            */
            ResultRow(text: "title", detail: signature.title),
            
            // The given name of the signatory.
            ResultRow(text: "givenName", detail: signature.givenName),
            
            // The family name of the signatory.
            ResultRow(text: "familyName", detail: signature.familyName),
            
            // The date the signature was obtained.
            ResultRow(text: "date", detail: signature.signatureDate),
            
            // The captured image.
            .TextImage("signature", image: signature.signatureImage)
        ]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let lastRow = self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1
        
        if indexPath.row == lastRow {
            return 200
        }
       
        return UITableViewAutomaticDimension
    }
}

/// Table view provider specific to an `ORKTaskResult` instance.
class TaskResultTableViewProvider: CollectionResultTableViewProvider {
    // MARK: ResultTableViewProvider
    
    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let taskResult = result as! ORKTaskResult
        
        let rows = super.resultRowsForSection(section)
        
        if section == 0 {
            return rows + [
                ResultRow(text: "taskRunUUID", detail: taskResult.taskRunUUID.UUIDString),
                ResultRow(text: "outputDirectory", detail: taskResult.outputDirectory)
            ]
        }
        
        return rows
    }
}

/// Table view provider specific to an `ORKCollectionResult` instance.
class CollectionResultTableViewProvider: ResultTableViewProvider {
    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return super.tableView(tableView, titleForHeaderInSection: 0)
        }
        
        return "Child Results"
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    // MARK: ResultTableViewProvider
    
    override func resultRowsForSection(section: Int) -> [ResultRow] {
        let collectionResult = result as! ORKCollectionResult
        
        let rows = super.resultRowsForSection(section)
        
        // Show the child results in section 1.
        if section == 1 {
            return rows + collectionResult.results!.map { childResult in
                let childResultClassName = NSStringFromClass(childResult.dynamicType)

                return ResultRow(text: childResultClassName, detail: childResult.identifier, selectable: true)
            }
        }
        
        return rows
    }
}
