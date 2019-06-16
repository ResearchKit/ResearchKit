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

internal class Math {
    
    internal class func degreesToRadians(_ angle: Double) -> Double {
        return angle / 180 * .pi
    }
    
    internal class func pointFromAngle(_ frame: CGRect, angle: Double, radius: Double) -> CGPoint {
        let radian = degreesToRadians(angle)
        let xPoint = Double(frame.midX) + cos(radian) * radius
        let yPoint = Double(frame.midY) + sin(radian) * radius
        return CGPoint(x: xPoint, y: yPoint)
    }
    
    internal class func pointPairToBearingDegrees(_ startPoint: CGPoint, endPoint: CGPoint) -> Double {
        let originPoint = CGPoint(x: endPoint.x - startPoint.x, y: endPoint.y - startPoint.y)
        let bearingRadians = atan2(Double(originPoint.y), Double(originPoint.x))
        var bearingDegrees = bearingRadians * (180.0 / .pi)
        bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees))
        return bearingDegrees
    }
    
    internal class func adjustValue(_ startAngle: Double, degree: Double, maxValue: Float, minValue: Float) -> Double {
        let ratio = Double((maxValue - minValue) / 360)
        let ratioStart = ratio * startAngle
        let ratioDegree = ratio * degree
        let adjustValue: Double
        if startAngle < 0 {
            adjustValue = (360 + startAngle) > degree ? (ratioDegree - ratioStart) : (ratioDegree - ratioStart) - (360 * ratio)
        } else {
            adjustValue = (360 - (360 - startAngle)) < degree ? (ratioDegree - ratioStart) : (ratioDegree - ratioStart) + (360 * ratio)
        }
        return adjustValue + (Double(minValue))
    }
    
    internal class func adjustDegree(_ startAngle: Double, degree: Double) -> Double {
        return (360 + startAngle) > degree ? degree : -(360 - degree)
    }
    
    internal class func degreeFromValue(_ startAngle: Double, value: Float, maxValue: Float, minValue: Float) -> Double {
        let ratio = Double((maxValue - minValue) / 360)
        let angle = Double(value) / ratio
        return angle + startAngle - (Double(minValue) / ratio)
    }
}

