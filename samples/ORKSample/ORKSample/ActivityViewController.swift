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

enum Activity: Int {
    case survey, microphone, tapping
    
    static var allValues: [Activity] {
        var index = 0
        return Array (
            AnyIterator {
                let returnedElement = self.init(rawValue: index)
                index = index + 1
                return returnedElement
            }
        )
    }
    
    var title: String {
        switch self {
            case .survey:
                return "Survey"
            case .microphone:
                return "Microphone"
            case .tapping:
                return "Tapping"
        }
    }
    
    var subtitle: String {
        switch self {
            case .survey:
                return "Answer 6 short questions"
            case .microphone:
                return "Voice evaluation"
            case .tapping:
                return "Test tapping speed"
        }
    }
}

class ActivityViewController: UITableViewController {
    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else { return 0 }
        
        return Activity.allValues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath)
        
        if let activity = Activity(rawValue: (indexPath as NSIndexPath).row) {
            cell.textLabel?.text = activity.title
            cell.detailTextLabel?.text = activity.subtitle
        }

        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let activity = Activity(rawValue: (indexPath as NSIndexPath).row) else { return }
        
        let taskViewController: ORKTaskViewController
        switch activity {
            case .survey:
                taskViewController = ORKTaskViewController(task: StudyTasks.surveyTask, taskRun: NSUUID() as UUID)
            
            case .microphone:
                taskViewController = ORKTaskViewController(task: StudyTasks.microphoneTask, taskRun: NSUUID() as UUID)
                
                do {
                    let defaultFileManager = FileManager.default
                    
                    // Identify the documents directory.
                    let documentsDirectory = try defaultFileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    
                    // Create a directory based on the `taskRunUUID` to store output from the task.
                    let outputDirectory = documentsDirectory.appendingPathComponent(taskViewController.taskRunUUID.uuidString)
                    try defaultFileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
                    
                    taskViewController.outputDirectory = outputDirectory
                }
                catch let error as NSError {
                    fatalError("The output directory for the task with UUID: \(taskViewController.taskRunUUID.uuidString) could not be created. Error: \(error.localizedDescription)")
                }
                
            case .tapping:
                taskViewController = ORKTaskViewController(task: StudyTasks.tappingTask, taskRun: NSUUID() as UUID)
        }

        taskViewController.delegate = self
        navigationController?.present(taskViewController, animated: true, completion: nil)
    }
}

extension ActivityViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        // Handle results using taskViewController.result

        if reason == ORKTaskViewControllerFinishReason.completed {
            if taskViewController.task!.identifier == "SurveyTask" {
                let patient = ORKHL7CDAPerson()
                patient.givenName = "John"
                patient.familyName = "Appleseed"
                do {
                    let dateOfBirth = try HKHealthStore().dateOfBirthComponents()
                    patient.birthdate = dateOfBirth.date!
                }
                catch {
                    // As this is just an example we will fudge the results by setting the DOB as today's date
                    // In a full application we would probably need to prompt for this to be filled in earlier
                    // in the application
                    patient.birthdate = Date ()
                }
                patient.birthdate = Date()
                patient.gender = ORKHL7CDAAdministrativeGenderType.male
            
                let deviceAuthorAddress = ORKHL7CDAAddress()
                deviceAuthorAddress.street = "South John Street"
                deviceAuthorAddress.city = "Liverpool"
                deviceAuthorAddress.state = "Merseyside"
                deviceAuthorAddress.country = "UK"
                deviceAuthorAddress.postalCode = "L1 8BU"

                let deviceAuthorWorkTelecom = ORKHL7CDATelecom()
                deviceAuthorWorkTelecom.telecomUseType = ORKHL7CDATelecomUseType.workPlace
                deviceAuthorWorkTelecom.value = "+44 (0) 151 472 7200"
            
                let deviceAuthor = ORKHL7CDADeviceAuthor()
                deviceAuthor.address = deviceAuthorAddress
                deviceAuthor.telecoms = [deviceAuthorWorkTelecom]
                deviceAuthor.softwareName = "ORKSample"
            
                let custodian = ORKHL7CDACustodian ()
                custodian.address = deviceAuthorAddress
                custodian.telecom = deviceAuthorWorkTelecom
                custodian.name = "ResearchKit Developer"
            
                let assignedPerson = ORKHL7CDAPerson()
                assignedPerson.prefix = "Dr"
                assignedPerson.givenName = "A"
                assignedPerson.familyName = "Cula"
            
                let hl7CDAOutput = ORKHL7CDA.make(taskViewController.result, withTemplate:ORKHL7CDADocumentType.CCD, forPatient:patient, effectiveFrom:Date(), effectiveTo:Date(), deviceAuthor:deviceAuthor, custodian:custodian, assignedPerson:assignedPerson)
            
                let documentData: Data = hl7CDAOutput.data(using: .utf8)!
            
                do {
                    let cdaSample = try HKCDADocumentSample.init(data: documentData, start:Date(), end: Date(), metadata: nil)
            
                    HKHealthStore().save(cdaSample, withCompletion: { (success, error) in
                        if !success {
                            fatalError("The CDA Document couldn't be saved")
                        }
                    })
                    
                } catch {
                    // Handle validation error creating sample here...
                    fatalError("The CDA Document failed validation - this shouldn't happen")
                }
            }
        }
        taskViewController.dismiss(animated: true, completion: nil)

    }
}

