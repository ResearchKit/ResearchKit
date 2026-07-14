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


@objc public class WarningStateFooterView: UITableViewHeaderFooterView {

    // MARK: padding and corner radius
    
    private let warningStateWarningLabelTopBottomPadding: CGFloat = 10
    
    private let warningStateContainerViewBottomPadding = 15.0
    
    private let backgroundViewCornerRadius: CGFloat = 12.0
    
    // MARK: constraints
    
    private var cellConstraints: [NSLayoutConstraint] = []
    
    private var contentViewContraints: [NSLayoutConstraint] {
        let constraint = contentView.bottomAnchor.constraint(
            equalTo: backgroundContainerView.bottomAnchor,
            constant: warningStateContainerViewBottomPadding
        )
        
        constraint.priority = .defaultHigh
        
        return [
          constraint
        ]
    }
    
    private var backgroundViewConstraints: [NSLayoutConstraint] {
        [
            backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
    }
    
    private lazy var warningLabelTopConstraint: NSLayoutConstraint = {
        warningLabel.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 0)
    }()
    
    private lazy var warningLabelBottomConstraint: NSLayoutConstraint = {
        let labelBottomConstraint =  warningLabel.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: 0)
        labelBottomConstraint.priority = .defaultHigh
        return labelBottomConstraint
    }()
    
    private var warningLabelConstraints: [NSLayoutConstraint] {
        [
            warningLabel.leadingAnchor.constraint(equalTo: backgroundContainerView.layoutMarginsGuide.leadingAnchor),
            warningLabel.trailingAnchor.constraint(equalTo: backgroundContainerView.layoutMarginsGuide.trailingAnchor),
            warningLabelTopConstraint,
            warningLabelBottomConstraint
        ]
    }
    
    // MARK: fill colors
    
    private let darkCardFillColor: UIColor = .init(
        red: 0.173,
        green: 0.173,
        blue: 0.180,
        alpha: 1.0
    )
    
    private var cardFillColor: UIColor {
        traitCollection.userInterfaceStyle == .dark ? darkCardFillColor : .secondarySystemGroupedBackground
    }
    
    // MARK: backgroundContainerView & warningLabel
    
    private lazy var backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = cardFillColor
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = backgroundViewCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.directionalLayoutMargins = ORKLargeContentLayoutMargins
        
        return view
    }()
    
    private var warningMessage: String?
    
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = .preferredFont(forTextStyle: .footnote)
        label.isAccessibilityElement = true
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.directionalLayoutMargins = ORKLargeContentLayoutMargins
        
        contentView.addSubview(backgroundContainerView)
        backgroundContainerView.addSubview(warningLabel)
        
        setUpConstraints()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    public func configure(with warningText: String) {
        warningMessage = warningText
    }
    
    @objc
    public var shouldShowWarningMessage: Bool = false {
        didSet {
            warningLabel.attributedText = shouldShowWarningMessage ? getWarningMessageAttributedString() : nil
            warningLabelTopConstraint.constant = shouldShowWarningMessage ? warningStateWarningLabelTopBottomPadding : 0
            warningLabelBottomConstraint.constant = shouldShowWarningMessage ? -warningStateContainerViewBottomPadding : 0
            warningLabel.isAccessibilityElement = shouldShowWarningMessage
        }
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.deactivate(cellConstraints)
        
        cellConstraints = contentViewContraints
        cellConstraints += backgroundViewConstraints
        cellConstraints += warningLabelConstraints
        
        NSLayoutConstraint.activate(cellConstraints)
    }
    
    private func getWarningMessageAttributedString() -> NSAttributedString? {
        guard let message = warningMessage else { return nil }
        
        let font = UIFont.preferredFont(forTextStyle: .footnote)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: font.pointSize, weight: .regular, scale: .medium)
        if let exclamationMarkImage = UIImage(systemName: "exclamationmark.triangle", withConfiguration: imageConfig) {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = exclamationMarkImage.withRenderingMode(.alwaysTemplate)
            
            let imageString = NSMutableAttributedString(attachment: imageAttachment)
            imageString.append(NSMutableAttributedString(string: message))
            
            return imageString
        }
        
        return NSMutableAttributedString(string: message)
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        warningMessage = nil
        warningLabel.attributedText = nil
        warningLabelTopConstraint.constant = 0
        warningLabelBottomConstraint.constant = 0
    }
}
