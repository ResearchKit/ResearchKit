/*
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


internal class ORKSwiftStroopContentView: ORKActiveStepCustomView {
    
    public var colorLabelText: String?
    public var colorLabelColor: UIColor?
    
    public let redButton: ORKBorderedButton = {
        let button = ORKBorderedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(ORKSwiftLocalizedString("STROOP_COLOR_RED_INITIAL", ""), for: .normal)
        return button
    }()
    
    public let greenButton: ORKBorderedButton = {
        let button = ORKBorderedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(ORKSwiftLocalizedString("STROOP_COLOR_GREEN_INITIAL", ""), for: .normal)
        return button
    }()
    
    public let blueButton: ORKBorderedButton = {
        let button = ORKBorderedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(ORKSwiftLocalizedString("STROOP_COLOR_BLUE_INITIAL", ""), for: .normal)
        return button
    }()
    
    public let yellowButton: ORKBorderedButton = {
        let button = ORKBorderedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(ORKSwiftLocalizedString("STROOP_COLOR_YELLOW_INITIAL", ""), for: .normal)
        return button
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        let colorLabelFontSize: CGFloat = 60.0
        label.numberOfLines = 1
        label.text = " "
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: colorLabelFontSize)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let buttonStackView: UIStackView
    
    private let minimumButtonHeight: CGFloat = 60.0
    private let buttonStackViewSpacing: CGFloat = 20.0
    
    private override init(frame: CGRect) {
        buttonStackView = UIStackView(arrangedSubviews: [redButton, greenButton, blueButton, yellowButton])
        super.init(frame: frame)
        setup()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        buttonStackView = UIStackView(arrangedSubviews: [redButton, greenButton, blueButton, yellowButton])
        super.init(coder: aDecoder)
        setup()
    }
    
    internal func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.spacing = buttonStackViewSpacing
        buttonStackView.axis = .horizontal
        self.addSubview(colorLabel)
        self.addSubview(buttonStackView)
        setUpConstraints()
    }
    
    internal func setColorLabelText(colorLabelText text: String) {
        colorLabelText = text
        colorLabel.text = text
        setNeedsDisplay()
    }
    
    internal func setColorLabelColor(colorLabelColor color: UIColor) {
        colorLabelColor = color
        colorLabel.textColor = color
        setNeedsDisplay()
    }
    
    internal func getColorLabelText() -> String {
        return colorLabel.text!
    }
    
    internal func getColorLabelColor() -> UIColor {
        return colorLabel.textColor
    }
    
    internal func setUpConstraints() {
        
        var constraints = [NSLayoutConstraint]()
        var views = [String: Any]()
        views["colorLabel"] = colorLabel
        views["buttonStackView"] = buttonStackView
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==30)-[colorLabel]-(>=10)-[buttonStackView]-(==30)-|",
                                                          options: .alignAllCenterX,
                                                          metrics: nil,
                                                          views: views)
        
        constraints += [
            NSLayoutConstraint(item: buttonStackView as Any,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1.0,
                               constant: minimumButtonHeight),
            NSLayoutConstraint(item: buttonStackView as Any,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .centerX,
                               multiplier: 1.0,
                               constant: 0.0)
        ]
    
        for button in [redButton, greenButton, blueButton, yellowButton] {
            constraints += [
                NSLayoutConstraint(item: button,
                                   attribute: .width,
                                   relatedBy: .equal,
                                   toItem: button,
                                   attribute: .height,
                                   multiplier: 1.0,
                                   constant: 0.0)
            ]
        }
        
        self.addConstraints(constraints)
        NSLayoutConstraint.activate(constraints)
    }
}
