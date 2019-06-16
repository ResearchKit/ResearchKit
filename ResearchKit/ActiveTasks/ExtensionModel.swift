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

public enum DeviceType: String {
    
    case iPhone5        = "iPhone5"
    case iPhone5C       = "iPhone5C"
    case iPhone5S       = "iPhone5S"
    case iPhone6Plus    = "iPhone6Plus"
    case iPhone6        = "iPhone6"
    case iPhone6S       = "iPhone6S"
    case iPhone6SPlus   = "iPhone6SPlus"
    case iPhone7        = "iPhone7"
    case iPhone7Plus    = "iPhone7Plus"
    case iPhoneSE       = "iPhoneSE"
    
    case IPodTouch5     = "iPod5,1"
    case IPodTouch6     = "iPod7,1"
}

func parseDeviceType(_ identifier: String) -> DeviceType {
    
    switch identifier {
    case "iPhone5,1", "iPhone5,2": return .iPhone5
    case "iPhone5,3", "iPhone5,4": return .iPhone5C
    case "iPhone6,1", "iPhone6,2": return .iPhone5S
    case "iPhone7,1": return .iPhone6Plus
    case "iPhone7,2": return .iPhone6
    case "iPhone8,2": return .iPhone6SPlus
    case "iPhone8,1": return .iPhone6S
    case "iPhone9,1", "iPhone9,3": return .iPhone7
    case "iPhone9,2", "iPhone9,4": return .iPhone7Plus
    case "iPhone8,4": return .iPhoneSE
        
    case "iPod5,1":   return .IPodTouch5
    case "iPod7,1":   return .IPodTouch6
        
    default:
        if UIDevice.iPhonePlus {
            return .iPhone7Plus
        } else {
            return .iPhone7
        }
    }
}

var pixelPerInchIphonePlus: CGFloat = 401

var pixelPerInchIphone: CGFloat = 326

var inchPerMm: CGFloat = 25.4

var renderedPixels: CGFloat = 1.15

func parsePixelPerInch(deviceType: DeviceType) -> CGFloat {
    
    switch deviceType {
    case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE, .iPhone6, .iPhone6S, .iPhone7, .IPodTouch5, .IPodTouch6: return pixelPerInchIphone
    case .iPhone6Plus, .iPhone6SPlus, .iPhone7Plus: return pixelPerInchIphonePlus
    }
}

public extension UIDevice {
    
    class var deviceType: DeviceType {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        let mirror = Mirror(reflecting: machine)
        var identifier = ""
        
        for child in mirror.children {
            if let value = child.value as? Int8, value != 0 {
                identifier.append(String(UnicodeScalar(UInt8(value))))
            }
        }
        
        return parseDeviceType(identifier)
    }
    
    class var pixelsPerMm: CGFloat {
        return parsePixelPerInch(deviceType: UIDevice.deviceType) / inchPerMm
    }
    
    class var iPhonePlus: Bool {
        if UIDevice.current.userInterfaceIdiom != .phone {
            return false
        }
        
        if UIScreen.main.scale > 2.9 {
            return true
        }
        
        return false
    }
}

