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


import UIKit
import ResearchKit

let padding: CGFloat = 10.0

class BarGraphChartTableViewCell: UITableViewCell {

    var graphView: ORKBarGraphChartView
    let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        graphView = ORKBarGraphChartView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(graphView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 25.0, weight: .thin)
        titleLabel.textAlignment = .center
        self.contentView.addSubview(titleLabel)
        setupConstraints()
    }
    
    func setupConstraints() {
        graphView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                NSLayoutConstraint.init(item: titleLabel,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: self.safeAreaLayoutGuide,
                                        attribute: .top,
                                        multiplier: 1.0,
                                        constant: padding),
                NSLayoutConstraint.init(item: titleLabel,
                                        attribute: .left,
                                        relatedBy: .equal,
                                        toItem: self.safeAreaLayoutGuide,
                                        attribute: .left,
                                        multiplier: 1.0,
                                        constant: padding),
                NSLayoutConstraint.init(item: graphView,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: titleLabel,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: padding),
                NSLayoutConstraint.init(item: graphView,
                                        attribute: .left,
                                        relatedBy: .equal,
                                        toItem: self.safeAreaLayoutGuide,
                                        attribute: .left,
                                        multiplier: 1.0,
                                        constant: padding),
                NSLayoutConstraint.init(item: graphView,
                                        attribute: .right,
                                        relatedBy: .equal,
                                        toItem: self.safeAreaLayoutGuide,
                                        attribute: .right,
                                        multiplier: 1.0,
                                        constant: -padding),
                NSLayoutConstraint.init(item: self,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: graphView.safeAreaLayoutGuide,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: padding)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
