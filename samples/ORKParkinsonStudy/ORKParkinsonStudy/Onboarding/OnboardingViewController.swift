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

protocol OnboardingManagerDelegate: class {
    func didCompleteOnboarding()
}

class OnboardingViewController: ORKTaskViewController, ORKTaskViewControllerDelegate {
    
    weak var onboardingManagerDelegate: OnboardingManagerDelegate?
    
    override init(task: ORKTask?, taskRun taskRunUUID: UUID?) {
        super.init(task: task, taskRun: taskRunUUID)
        self.task = getTasks()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func getTasks() -> ORKNavigableOrderedTask {
        
        // Welcome View Controller
        let welcomeStep = ORKInstructionStep(identifier: "welcomeStepIdentifier")
        welcomeStep.title = NSLocalizedString("ONBOARDING_WELCOME_INTRO_TITLE", comment: "")
        welcomeStep.detailText = NSLocalizedString("ONBOARDING_WELCOME_INTRO_DETAIL", comment: "")
        welcomeStep.iconImage = UIImage(named: "graph")!.withRenderingMode(.alwaysTemplate)
        
        // What to Expect
        let whatToExpectStep = ORKTableStep(identifier: "whatToExpectStep")
        whatToExpectStep.title = NSLocalizedString("ONBOARDING_WELCOME_EXPECTATIONS_TITLE", comment: "")
        whatToExpectStep.text = NSLocalizedString("ONBOARDING_WELCOME_EXPECTATIONS_BODY", comment: "")
        whatToExpectStep.items = [
            NSLocalizedString("ONBOARDING_WELCOME_EXPECTATIONS_FOREGROUND", comment: "") as NSString,
            NSLocalizedString("ONBOARDING_WELCOME_EXPECTATIONS_STUDY_DURATION", comment: "") as NSString,
            NSLocalizedString("ONBOARDING_WELCOME_EXPECTATIONS_STUDY_OWNER", comment: "") as NSString
        ]
        whatToExpectStep.bulletIconNames = ["phone", "calendar", "share"]
        whatToExpectStep.bulletType = .circle
        
        // Requirements
        let requirementsStep = ORKTableStep(identifier: "requirementsStep")
        requirementsStep.title = NSLocalizedString("ONBOARDING_WELCOME_REQUIREMENTS_TITLE", comment: "")
        requirementsStep.text = NSLocalizedString("ONBOARDING_WELCOME_REQUIREMENTS_BODY", comment: "")
        requirementsStep.items = [
            NSLocalizedString("ONBOARDING_WELCOME_REQUIREMENTS_AGE_LIMIT", comment: "") as NSString,
            NSLocalizedString("ONBOARDING_WELCOME_REQUIREMENTS_SIMILAR_STUDY", comment: "") as NSString,
            NSLocalizedString("ONBOARDING_WELCOME_REQUIREMENTS_CARRY_IPHONE", comment: "") as NSString
        ]
        requirementsStep.isBulleted = true
        
        // Consent document including data gathering
        let consentDoc = ConsentDocument()
        let consentStep = ORKVisualConsentStep(identifier: "consentStep", document: consentDoc)
        
        // Review step
        let signature = consentDoc.signatures!.first!
        let reviewStep = ORKConsentReviewStep(identifier: "reviewStep", signature: signature, in: consentDoc)
        reviewStep.text = NSLocalizedString("ONBOARDING_WELCOME_REVIEW_BODY", comment: "")
        reviewStep.reasonForConsent = NSLocalizedString(
            "ONBOARDING_WELCOME_REVIEW_CONSENT_AFFIRM", comment: ""
        )
        
        // Completion
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = NSLocalizedString("ONBOARDING_WELCOME_REVIEW_COMPLETION_TITLE", comment: "")
        completionStep.text = NSLocalizedString("ONBOARDING_WELCOME_REVIEW_COMPLETION_BODY", comment: "")
        
        // Create task and present it
        let task = ORKNavigableOrderedTask(
            identifier: "JoinTask", steps: [
                welcomeStep,
                whatToExpectStep,
                requirementsStep,
                consentStep,
                reviewStep,
                completionStep
            ]
        )
        
        return task
    }
    
    func signatureResult(taskViewController: ORKTaskViewController) -> ORKConsentSignatureResult? {
        
        let taskResults: [ORKResult]? = taskViewController.result.results
        let reviewStepResult = taskResults?.first(where: { (result) -> Bool in
            result.identifier == "reviewStep"
        })
        let reviewStepResults = (reviewStepResult as? ORKStepResult)?.results
        let signatureResult = reviewStepResults?.first as? ORKConsentSignatureResult
        
        return signatureResult
        
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didChange result: ORKTaskResult) {
        
        // If there is a signature result, and no consent, exit onboarding.
        if
            let signatureResult = signatureResult(taskViewController: taskViewController),
            signatureResult.consented == false {
            
            self.presentingViewController?.dismiss(animated: false, completion: nil)
            
        }
        
    }
    
    public func taskViewController(
        _ taskViewController: ORKTaskViewController,
        didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        switch reason {
        case .discarded, .failed, .saved:
            
            self.presentingViewController?.dismiss(animated: false, completion: nil)
            
        case .completed:
            
            OnboardingStateManager.shared.setOnboardingCompletedState(state: true)
            
            // Access the first and last name from the review step
            
            if
                let signatureResult = signatureResult(taskViewController: taskViewController),
                let signature = signatureResult.signature {
                
                let defaults = UserDefaults.standard
                defaults.set(signature.givenName, forKey: "firstName")
                defaults.set(signature.familyName, forKey: "lastName")
                
            }
            
            self.presentingViewController?.dismiss(animated: true, completion: nil)

        }
    }
}

