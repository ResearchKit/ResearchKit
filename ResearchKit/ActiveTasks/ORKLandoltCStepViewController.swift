/*
 Copyright (c) 2019, Novartis.
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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

import ResearchKit.Private

public class ORKLandoltCStepViewController: ORKActiveStepViewController {
    
    private var activityTimer = Timer()
    private var results = NSMutableArray()
    private var visionStepView: ORKLandoltCStepView
    private var eyeToTest: VisionStepLeftOrRightEye?
    private var testType: VisionStepType?

    public override init(step: ORKStep?) {
        if let visionStep = step as? ORKLandoltCStep {
            eyeToTest = visionStep.eyeToTest
            testType = visionStep.testType
        }
        visionStepView = ORKLandoltCStepView(testType: testType)
        super.init(step: step)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var result: ORKStepResult? {
        let stepResult = super.result
        stepResult?.results = results.copy() as? [ORKResult]
        
        return stepResult!
    }
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        activeStepView?.customContentView = visionStepView
        activeStepView?.removeCustomContentPadding()
        activeStepView?.customContentFillsAvailableSpace = true
        
        //        TODO: Localize
        visionStepView.currentEyeLabel.text = eyeToTest == .left ? "Left Eye" : "Right Eye"
        visionStepView.continueButton.addTarget(self, action: #selector(continueButtonWasPressed), for: .touchUpInside)
        startTimer()
    }
    
    override public func stepDidFinish() {
        super.stepDidFinish()
        goForward()
    }
    
    private func startTimer() {
        activityTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(hideCircle), userInfo: nil, repeats: false)
    }
    
    @objc
    private func hideCircle() {
        activityTimer.invalidate()
        visionStepView.visionContentView?.eyeActivitySlider?.hideLetter()
        visionStepView.topInstructionLabel.isHidden = false
    }
    
    @objc
    private func continueButtonWasPressed() {
        activityTimer.invalidate()
        visionStepView.topInstructionLabel.isHidden = true
        visionStepView.continueButton.isEnabled = false
        
        if let resultData = visionStepView.visionContentView?.eyeActivitySlider?.fetchResultDataAndUpdateSlider() {
            let stepResult: ORKLandoltCResult = ORKLandoltCResult(identifier: step!.identifier,
                                                                          outcome: resultData.outcome,
                                                                          letterAngle: resultData.letterAngle,
                                                                          sliderAngle: resultData.sliderAngle,
                                                                          score: resultData.score)
            results.add(stepResult)
            
            if resultData.incorrectAnswers == 2 || resultData.score == resultData.maxScore {
                stepDidFinish()
            } else {
                visionStepView.continueButton.isEnabled = true
                startTimer()
            }
        }
    }
}

public class ORKLandoltCStepView: UIView {
    
    var visionContentView: ORKLandoltCStepContentView?
    
    let continueButtonCornerRadius: CGFloat = 12.0
    let eyeLabelTopPadding: CGFloat = 20.0
    let instructionLabelTopPadding: CGFloat = 15.0
    let visionContentTopPadding: CGFloat = 10.0
    
    let continueButton = ORKRoundTappingButton()
    let currentEyeLabel = UILabel()
    let topInstructionLabel = UILabel()
    
    init(testType: VisionStepType!) {
        super.init(frame: .zero)
        setupCurrentEyeLabel()
        setupTopInstructionLabel()
        setupVisionContentView(testType: testType)
        setupContinueButton()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupVisionContentView(testType: VisionStepType!) {
        if visionContentView == nil {
            visionContentView = ORKLandoltCStepContentView(testType: testType)
        }
        addSubview(visionContentView!)
    }
    
    func setupCurrentEyeLabel() {
        currentEyeLabel.isHidden = true
        currentEyeLabel.textAlignment = .center
        currentEyeLabel.textColor = UIColor.black
        currentEyeLabel.numberOfLines = 0
        //        TODO: set FontDescriptor
        currentEyeLabel.font = UIFont(name: "", size: 20.0)
        addSubview(currentEyeLabel)
    }
    
    func setupTopInstructionLabel() {
        topInstructionLabel.textAlignment = .center
        topInstructionLabel.numberOfLines = 0
        topInstructionLabel.textColor = UIColor.black
        //        TODO: Localize
        topInstructionLabel.text = "Move the dial to where you think the opening in the letter was."
        //        TODO: set FontDescriptor
        topInstructionLabel.font = UIFont(name: "", size: 20.0)
        topInstructionLabel.isHidden = true
        addSubview(topInstructionLabel)
    }
    
    func setupContinueButton() {
        //        TODO: Localize
        continueButton.diameter = 60.0
        continueButton.setTitle("Next", for: UIControl.State.normal)
        continueButton.backgroundColor = tintColor
        continueButton.layer.cornerRadius = continueButtonCornerRadius
        addSubview(continueButton)
    }
    
    private func setupConstraints() {
        currentEyeLabel.translatesAutoresizingMaskIntoConstraints = false
        topInstructionLabel.translatesAutoresizingMaskIntoConstraints = false
        visionContentView?.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            NSLayoutConstraint(item: currentEyeLabel,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .top,
                               multiplier: 1.0,
                               constant: eyeLabelTopPadding),
            NSLayoutConstraint(item: currentEyeLabel,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .centerX,
                               multiplier: 1.0,
                               constant: 0.0),
            NSLayoutConstraint(item: topInstructionLabel,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: currentEyeLabel,
                               attribute: .bottom,
                               multiplier: 1.0,
                               constant: instructionLabelTopPadding),
            NSLayoutConstraint(item: topInstructionLabel,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .centerX,
                               multiplier: 1.0,
                               constant: 0.0),
            NSLayoutConstraint(item: topInstructionLabel,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .width,
                               multiplier: 0.8,
                               constant: 0.0),
            NSLayoutConstraint(item: visionContentView!,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: topInstructionLabel,
                               attribute: .bottom,
                               multiplier: 1.0,
                               constant: visionContentTopPadding),
            NSLayoutConstraint(item: visionContentView!,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .centerX,
                               multiplier: 1.0,
                               constant: 0.0),
            NSLayoutConstraint(item: visionContentView!,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .width,
                               multiplier: 0.8,
                               constant: 0.0),
            NSLayoutConstraint(item: visionContentView!,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .height,
                               multiplier: 0.8,
                               constant: 0.0),
            NSLayoutConstraint(item: continueButton,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .centerX,
                               multiplier: 1.0,
                               constant: 0.0),
            NSLayoutConstraint(item: continueButton,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .bottom,
                               multiplier: 1.0,
                               constant: -20.0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
