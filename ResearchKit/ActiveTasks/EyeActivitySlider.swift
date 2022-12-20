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

internal class EyeActivitySlider: UIView {
    
    private var testType: VisionStepType?
    
    private var incorrectAnswers = 0
    private let contentGap: CGFloat = 20.0
    private let toleranceAngle = 22.5
    private let letterAngles = [0, 45, 90, 135, 180, 225, 270, 315]
    private var letterSize: CGFloat {
        var letterSize: CGFloat!
        
        if self.testType == .visualAcuity {
            letterSize = letterMmSizes[currentStep] * UIDevice.pixelsPerMm / UIScreen.main.nativeScale
        } else {
            letterSize = 20 * UIDevice.pixelsPerMm / UIScreen.main.nativeScale
        }
     
        return letterSize
    }
    
    private var currentStep = 0
    private var letterMmSizes: [CGFloat] = [5.82, 4.65, 3.72, 2.91, 2.33, 1.86, 1.45, 1.16, 0.93, 0.73, 0.58, 0.47, 0.37]
    private var contrastLevels: [CGFloat] = [0.9, 0.92, 0.937, 0.95, 0.96, 0.968, 0.975, 0.98, 0.984, 0.9875, 0.99]
    private var stepScores: [Int] = [50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110]
    private var letterAngle = 0.0
    
    private lazy var letterImageView: UIImageView = {
        let letterImage = UIImage(named: "iCNLandoltC",
                                  in: Bundle(for: type(of: self)),
                                  compatibleWith: nil)
        let imageView = UIImageView(image: letterImage!)
        return imageView
    }()
    
    private lazy var circleImageView: UIImageView = {
        let circleImage = UIImage(named: "orangeGrayCircle",
                                  in: Bundle(for: type(of: self)),
                                  compatibleWith: nil)
        return UIImageView(image: circleImage!)
    }()
    
    private var slider: CircleSlider?
    
    internal init(testType: VisionStepType) {
        super.init(frame: CGRect())
        
        self.testType = testType
        commonInit()
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(letterImageView)
        
        circleImageView.contentMode = .scaleAspectFit
        addSubview(circleImageView)
        
        let thumbImage = UIImage(named: "iCNDialPointerWithShadow",
                                 in: Bundle(for: type(of: self)),
                                 compatibleWith: nil)
        
        slider = CircleSlider(frame: bounds, options: [
            CircleSliderOption.barColor(UIColor.clear),
            CircleSliderOption.trackingColor(UIColor.clear),
            CircleSliderOption.startAngle(0),
            CircleSliderOption.maxValue(360),
            CircleSliderOption.minValue(0),
            CircleSliderOption.thumbImage(thumbImage!)
            ])
        
        addSubview(slider!)
        updateSliderAndLetter()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        letterAngle = Double(letterAngles[Int(arc4random_uniform(7))])
        letterImageView.transform = CGAffineTransform.identity
        letterImageView.frame = CGRect(origin: CGPoint(), size: CGSize(width: letterSize, height: letterSize))
        letterImageView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        letterImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Math.degreesToRadians(letterAngle)))
        letterImageView.alpha = getAlpha()
        slider?.frame = bounds
        
        var frame = contentFrame()
        circleImageView.frame = frame
        
        let labelMargin: CGFloat = 30.0
        frame.origin.x += labelMargin
        frame.origin.y += labelMargin
        frame.size.width -= labelMargin * 2
        frame.size.height -= labelMargin * 2
    }
    
    private func updateSliderAndLetter() {
        guard incorrectAnswers < 2 else { return }
        
        letterImageView.isHidden = false
        slider?.sliderValue = 0
        slider?.isUserInteractionEnabled = true
        slider?.isHidden = false
        setNeedsLayout()
    }
    
    private func contentFrame() -> CGRect {
        let sideLength = min(bounds.size.width, bounds.size.height) - contentGap
        let contentFrame = CGRect(x: (bounds.size.width - sideLength) / 2, y: (bounds.size.height - sideLength) / 2, width: sideLength, height: sideLength)
        return contentFrame
    }
    
    private func getAlpha() -> CGFloat {
        return testType == .visualAcuity ? 1.0 : (1 - contrastLevels[currentStep])
    }
    
    private func getResult() -> Bool {
        let sliderValue = Double((slider?.sliderValue)!)
        let leftMargin = letterAngle - toleranceAngle
        let rightMargin = letterAngle + toleranceAngle
        let result = sliderValue > leftMargin && sliderValue < rightMargin
        
        if result == false {
            incorrectAnswers += 1
        } else {
            currentStep += 1
        }
        
        return result
    }
    
    internal func hideLetter() {
        letterImageView.isHidden = true
    }
    
    internal func fetchResultDataAndUpdateSlider() -> (outcome: Bool, letterAngle: Double, sliderAngle: Double, score: Int, incorrectAnswers: Int, maxScore: Int) {
        let outcome = getResult()
        let score = stepScores[currentStep]
        let currentSliderValue = Double((slider?.sliderValue)!)
        let currentLetterAngle = letterAngle
        let maxScore = testType == .visualAcuity ? stepScores.last! : stepScores[contrastLevels.count - 1]
        updateSliderAndLetter()
        
        return (outcome, currentLetterAngle, currentSliderValue, score, incorrectAnswers, maxScore)
    }
}

