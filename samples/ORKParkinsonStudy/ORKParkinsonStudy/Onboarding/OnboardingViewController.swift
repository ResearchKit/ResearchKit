/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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

protocol OnboardingManagerDelegate {
    func didCompleteOnboarding()
}

class OnboardingViewController: ORKTaskViewController, ORKTaskViewControllerDelegate {
    
    var onboardingManagerDelegate: OnboardingManagerDelegate?
    
    override init(task: ORKTask?, taskRun taskRunUUID: UUID?) {
        super.init(task: task, taskRun: taskRunUUID)
        self.task = getTasks()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.delegate = self
    }
    
    func getTasks() -> ORKNavigableOrderedTask {
        
        // Welcome View Controller
        let welcomeStep = ORKInstructionStep(identifier: "welcomeStepIdentifier")
        welcomeStep.title = "Welcome"
        welcomeStep.detailText = "Welcome to the ResearchKit Example Study. This sample app is an example of how to utilize the ResearchKit modules and views to create a great study.\n\nTo provide the best user experience for your study participants consider only using the necessary steps in the onboarding and consent process. This helps reduce the number of steps required to get into your main application."
        welcomeStep.iconImage = UIImage(named: "graph")!.withRenderingMode(.alwaysTemplate)
        
        // What to Expect
        let whatToExpectStep = ORKTableStep(identifier: "whatToExpectStep")
        whatToExpectStep.title = "Study Expectations"
        whatToExpectStep.text = "You should expect the following items when participating in the ResearchKit study."
        whatToExpectStep.items = ["The study will continue to run on your device even if the study app is not in the foreground." as NSCopying & NSSecureCoding & NSObjectProtocol,
                                  "The study will last for 2-4 weeks." as NSCopying & NSSecureCoding & NSObjectProtocol,
                                  "ResearchKit study data will be sent to the study owner." as NSCopying & NSSecureCoding & NSObjectProtocol]
        whatToExpectStep.bulletIconNames = ["phone", "calendar", "share"]
        whatToExpectStep.isBulleted = true
        
        // Requirements
        let requirementsStep = ORKTableStep(identifier: "requirementsStep")
        requirementsStep.title = "Study Requirements"
        requirementsStep.text = "In order to participate in this study you must meet the following critera:"
        requirementsStep.items = ["Be over the age of 18" as NSCopying & NSSecureCoding & NSObjectProtocol,
                                  "Have not participated in a prior or similar version of this study" as NSCopying & NSSecureCoding & NSObjectProtocol,
                                  "Carry your iPhone or Apple device around with you regularly" as NSCopying & NSSecureCoding & NSObjectProtocol]
        requirementsStep.isBulleted = true
        
        // Consent document including data gathering
        let consentDoc = ConsentDocument()
        let consentStep = ORKVisualConsentStep(identifier: "consentStep", document: consentDoc)
        
        // Review step
        let signiature = consentDoc.signatures!.first!
        let reviewStep = ORKConsentReviewStep(identifier: "reviewStep", signature: signiature, in: consentDoc)
        reviewStep.text = "Review the consent agreement and begin the agreement process by entering your first and last name below."
        reviewStep.reasonForConsent = "Consent to join the ResearchKit Study"
        
        // Completion
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = "Success"
        completionStep.text = "Thank you for enrolling in the ResearchKit study.For the best results please stay enrolled in the study for its entire duration."
        
        // Create task and present it
        let task = ORKNavigableOrderedTask(identifier: "JoinTask", steps: [welcomeStep, whatToExpectStep, requirementsStep, consentStep, reviewStep, completionStep])
        
        return task
    }
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .discarded, .failed, .saved:
            self.dismiss(animated: false, completion: nil)
            break;
        case .completed:
            OnboardingStateManager.shared.setOnboardingCompletedState(state: true)
            
            if (taskViewController.result.results != nil) {
                let results: [ORKResult] = taskViewController.result.results!
                
                for result in results {
                    if (result.identifier == "reviewStep") {
                        let stepResult: ORKStepResult = result as! ORKStepResult;
                        if (stepResult.results != nil && stepResult.results!.count > 0) {
                            let signarureResult: ORKConsentSignatureResult = stepResult.results![0] as! ORKConsentSignatureResult
                            if (signarureResult.signature != nil) {
                                let defaults = UserDefaults.standard;
                                defaults.set(signarureResult.signature!.givenName, forKey: "firstName")
                                defaults.set(signarureResult.signature!.familyName, forKey: "lastName");
                            }
                        }
                    }
                }
            }
            
            dismiss(animated: true, completion: {
                if ((self.onboardingManagerDelegate != nil) && (self.onboardingManagerDelegate?.didCompleteOnboarding != nil)) {
                }
            })
            break;
        }
    }
}

