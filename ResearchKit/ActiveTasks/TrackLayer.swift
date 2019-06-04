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

internal class TrackLayer: CAShapeLayer {
    
    struct Setting {
        var startAngle = Double()
        var barWidth = CGFloat()
        var barColor = UIColor()
        var trackingColor = UIColor()
    }
    
    internal var setting = Setting()
    internal var degree: Double = 0
    internal var hollowRadius: CGFloat {
        return (bounds.width * 0.5) - setting.barWidth
    }
    internal var currentCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    internal var hollowRect: CGRect {
        return CGRect(
            x: currentCenter.x - hollowRadius,
            y: currentCenter.y - hollowRadius,
            width: hollowRadius * 2.0,
            height: hollowRadius * 2.0)
    }
    internal init(bounds: CGRect, setting: Setting) {
        super.init()
        self.bounds = bounds
        self.setting = setting
        cornerRadius = bounds.size.width * 0.5
        masksToBounds = true
        position = currentCenter
        backgroundColor = setting.barColor.cgColor
        mask()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal func draw(in ctx: CGContext) {
        drawTrack(ctx: ctx)
    }
    
    private func mask() {
        let maskLayer = CAShapeLayer()
        maskLayer.bounds = bounds
        let ovalRect = hollowRect
        let path = UIBezierPath(ovalIn: ovalRect)
        path.append(UIBezierPath(rect: maskLayer.bounds))
        maskLayer.path = path.cgPath
        maskLayer.position = currentCenter
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        mask = maskLayer
    }
    
    private func drawTrack(ctx: CGContext) {
        let adjustDegree = Math.adjustDegree(setting.startAngle, degree: degree)
        let centerX = currentCenter.x
        let centerY = currentCenter.y
        let radius = min(centerX, centerY)
        ctx.setFillColor(setting.trackingColor.cgColor)
        ctx.beginPath()
        ctx.move(to: CGPoint(x: centerX, y: centerY))
        ctx.addArc(center: CGPoint(x: centerX, y: centerY),
                   radius: radius,
                   startAngle: CGFloat(Math.degreesToRadians(setting.startAngle)),
                   endAngle: CGFloat(Math.degreesToRadians(adjustDegree)),
                   clockwise: false)
        
        ctx.closePath()
        ctx.fillPath()
    }
}

