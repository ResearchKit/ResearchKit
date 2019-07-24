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

enum Colors {
    
    private func tremorGraphColor() -> UIColor {
        return UIColor(red: 158.0 / 255.0, green: 130.0 / 255.0, blue: 231.0 / 255.0, alpha: 1.0)
    }
    
    private func dyskinesiaGraphColor() -> UIColor {
        return UIColor(red: 91.0 / 255.0, green: 162.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
    }
    
    case appTintColor, tableViewCellBackgroundColor, graphReferenceLinceColor, tableViewBackgroundColor, tableCellTextColor, tableCellLineColor, tremorGraphColor, dyskinesiaSymptomGraphColor
    
    var color: UIColor {
        switch self {
        
        case .appTintColor:
            
            let backgroundGradientLayer = CAGradientLayer()
            backgroundGradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 1000.0)
            
            let cgColors = [dyskinesiaGraphColor().cgColor, tremorGraphColor().cgColor]

            backgroundGradientLayer.colors = cgColors
            backgroundGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            backgroundGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            UIGraphicsBeginImageContext(backgroundGradientLayer.bounds.size)
            backgroundGradientLayer.render(in: UIGraphicsGetCurrentContext()!)
            let backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return UIColor(patternImage: backgroundColorImage!)
            
        case .tableViewCellBackgroundColor:
            return UIColor.white
        
        case .graphReferenceLinceColor:
            return UIColor(red: 226.0 / 255.0, green: 226.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
        
        case .tableViewBackgroundColor:
            return UIColor(red: 245.0 / 255.0, green: 246.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
        
        case .tableCellTextColor:
            return UIColor(red: 142.0 / 255.0, green: 141.0 / 255.0, blue: 147.0 / 255.0, alpha: 1.0)
            
        case .tableCellLineColor:
            return UIColor(red: 214.0 / 255.0, green: 214.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)

        case .tremorGraphColor:
            return tremorGraphColor()
            
        case .dyskinesiaSymptomGraphColor:
            return dyskinesiaGraphColor()
        }
    }
}

