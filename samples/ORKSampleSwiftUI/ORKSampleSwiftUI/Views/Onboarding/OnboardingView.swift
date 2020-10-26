/*
Copyright (c) 2020, Helio Tejedor. All rights reserved.

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

import Combine
import UIKit
import ResearchKit
import SwiftUI

struct OnboardingView: UIViewControllerRepresentable {
    @EnvironmentObject var sampleService: SampleService
    var onCompleted: (Bool) -> Void
    
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let consentDocument = ConsentDocument()
        let consentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
        
        let healthDataStep = HealthDataStep(identifier: "Health")
        
        let signature = consentDocument.signatures!.first!
        
        let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)
        
        reviewConsentStep.text = "Review the consent form."
        reviewConsentStep.reasonForConsent = "Consent to join the Developer Health Research Study."
        
        let passcodeStep = ORKPasscodeStep(identifier: "Passcode")
        passcodeStep.text = "Now you will create a passcode to identify yourself to the app and protect access to information you've entered."
        
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = "Welcome aboard."
        completionStep.text = "Thank you for joining this study."
         
        let orderedTask = ORKOrderedTask(identifier: "Join", steps: [consentStep, reviewConsentStep, healthDataStep, passcodeStep, completionStep])
        let taskViewController = ORKTaskViewController(task: orderedTask, taskRun: nil)
        return taskViewController
    }
    
    func updateUIViewController(_ uiViewController: ORKTaskViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        context.coordinator.sampleService = sampleService
        context.coordinator.onCompleted = onCompleted
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, ORKTaskViewControllerDelegate, AskAuthorizationDelegate {
        var sampleService: SampleService?
        var onCompleted: ((Bool) -> Void)?
        var authorizedCancellable: AnyCancellable?
        
        public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
            onCompleted?(reason == .completed)
        }
        
        func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
            if step is HealthDataStep {
                let healthStepViewController = HealthDataStepViewController(step: step, delegate: self)
                return healthStepViewController
            }
            return nil
        }
        
        func requestAuthorization(completion: @escaping (Bool) -> Void) {
            guard let sampleService = sampleService else {
                authorizedCancellable = nil
                completion(false)
                return
            }
            authorizedCancellable = sampleService.$authorized
                .dropFirst()
                .sink { value in
                    completion(value)
                    self.authorizedCancellable = nil
                }
            sampleService.requestAuthorization()
        }
    }

}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView() { _ in }
    }
}
