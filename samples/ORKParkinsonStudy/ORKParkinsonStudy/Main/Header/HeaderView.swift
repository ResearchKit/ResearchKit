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
import UIKit

class HeaderView: UIView {
    
    var title: String!
    var descriptionText: NSAttributedString!
    var iconName: String!
    var invertColors: Bool!
    
    let PADDING: CGFloat = 30.0;
    let CIRCLE_DIM: CGFloat = 60.0;
    var nameContainer: UIView!
    var iconContainer: UIView!
    var bottomLineView: UIView!
    
    init(title: String, descriptionText: NSAttributedString, iconName: String, invertColors: Bool) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        self.title = title
        self.descriptionText = descriptionText
        self.iconName = iconName
        self.invertColors = invertColors
        
        self.setupNameView()
        self.setupIcon()
        self.setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupNameView() {
        self.nameContainer = UIView()
        self.nameContainer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.nameContainer)
        
        let activeLabel = UILabel()
        activeLabel.attributedText = self.descriptionText
        activeLabel.translatesAutoresizingMaskIntoConstraints = false
        //activeLabel.textColor = (self.invertColors == true) ? UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0) : UIColor.lightGray
//        activeLabel.font =
        activeLabel.textColor = UIColor.white
        self.nameContainer.addSubview(activeLabel)
        
        let nameLabel = UILabel()
        nameLabel.text = self.title
        nameLabel.textColor = (self.invertColors == true) ? UIColor.white : UIColor.black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let largeFont = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
        let boldFont = largeFont.withSymbolicTraits(.traitBold)
        nameLabel.font = UIFont(descriptor: boldFont!, size: 0)
        self.nameContainer.addSubview(nameLabel)
        
        activeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3.0).isActive = true
        activeLabel.leadingAnchor.constraint(equalTo: self.nameContainer.safeAreaLayoutGuide.leadingAnchor, constant: PADDING).isActive = true
        activeLabel.bottomAnchor.constraint(equalTo: self.nameContainer.bottomAnchor, constant: -(PADDING + (CIRCLE_DIM / 2) - 15)).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: self.nameContainer.topAnchor, constant: PADDING).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: self.nameContainer.safeAreaLayoutGuide.leadingAnchor, constant: PADDING).isActive = true
        
        bottomLineView = UIView()
        bottomLineView.backgroundColor = Colors.tableViewBackgroundColor.color
        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bottomLineView)
        
        nameContainer.backgroundColor = invertColors ? UIColor.clear : UIColor.white
    }
    
    func setupIcon() {
        self.iconContainer = UIView()

        self.iconContainer.layer.cornerRadius = CIRCLE_DIM / 2;
        self.iconContainer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(iconContainer)
        
        let iconView = UIImageView()
        iconView.image = UIImage(named: self.iconName)?.withRenderingMode(.alwaysTemplate)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        self.iconContainer.addSubview(iconView)
        
        let ICON_PADDING: CGFloat = 5.0;
        iconView.topAnchor.constraint(equalTo: self.iconContainer.topAnchor, constant: ICON_PADDING).isActive = true
        iconView.leadingAnchor.constraint(equalTo: self.iconContainer.leadingAnchor, constant: ICON_PADDING).isActive = true
        iconView.trailingAnchor.constraint(equalTo: self.iconContainer.trailingAnchor, constant: -ICON_PADDING).isActive = true
        iconView.bottomAnchor.constraint(equalTo: self.iconContainer.bottomAnchor, constant: -ICON_PADDING).isActive = true
        iconContainer.backgroundColor = invertColors ? UIColor.white : UIColor.clear
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.nameContainer.backgroundColor = invertColors ? UIColor.clear: UIColor.white
        self.iconContainer.backgroundColor = invertColors ? UIColor.white : UIColor.clear
    }
    
    func setupConstraints() {
        
        self.nameContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 20.0).isActive = true
        self.nameContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.nameContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.iconContainer.heightAnchor.constraint(equalToConstant: CIRCLE_DIM).isActive = true
        self.iconContainer.widthAnchor.constraint(equalToConstant: CIRCLE_DIM).isActive = true
        self.iconContainer.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: PADDING).isActive = true
        self.iconContainer.topAnchor.constraint(equalTo: self.nameContainer.bottomAnchor, constant: -(CIRCLE_DIM / 2)).isActive = true
        self.iconContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0).isActive = true
        
        bottomLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        bottomLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bottomLineView.topAnchor.constraint(equalTo: self.nameContainer.bottomAnchor).isActive = true
        bottomLineView.bottomAnchor.constraint(equalTo: self.iconContainer.bottomAnchor).isActive = true
    }
}
