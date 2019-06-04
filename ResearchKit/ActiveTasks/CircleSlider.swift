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

public enum CircleSliderOption {
    case startAngle(Double)
    case barColor(UIColor)
    case trackingColor(UIColor)
    case thumbColor(UIColor)
    case thumbImage(UIImage)
    case barWidth(CGFloat)
    case thumbWidth(CGFloat)
    case maxValue(Float)
    case minValue(Float)
    case sliderEnabled(Bool)
    case viewInset(CGFloat)
    case minMaxSwitchTreshold(Float)
}

open class CircleSlider: UISlider {
    
    private let minThumbTouchAreaWidth: CGFloat = 44
    private var latestDegree: Double = 0
    private var startValue: Float = 0
    open var sliderValue: Float {
        get {
            return startValue
        }
        set {
            var value = newValue
            let significantChange = (maxValue - minValue) * (1.0 - minMaxSwitchTreshold)
            let isSignificantChangeOccured = abs(newValue - startValue) > significantChange
            
            if isSignificantChangeOccured {
                if startValue < newValue {
                    value = minValue
                } else {
                    value = maxValue
                }
            } else {
                value = newValue
            }
            
            startValue = value
            sendActions(for: .valueChanged)
            var degree = Math.degreeFromValue(startAngle, value: sliderValue, maxValue: maxValue, minValue: minValue)
            
            if startValue == maxValue {
                degree -= degree / (360 * 100)
            }
            
            layout(degree)
        }
    }
    private var trackLayer: TrackLayer! {
        didSet {
            layer.addSublayer(trackLayer)
        }
    }
    private var thumbView: UIView! {
        didSet {
            if sliderEnabled {
                thumbView.backgroundColor = thumbColor
                thumbView.center = thumbCenter(startAngle)
                thumbView.layer.cornerRadius = thumbView!.bounds.size.width * 0.5
                addSubview(thumbView)
                if let thumbImage = thumbImage {
                    let thumbImageView = UIImageView(frame: thumbView.bounds)
                    thumbImageView.image = thumbImage
                    thumbView.addSubview(thumbImageView)
                    thumbView.backgroundColor = UIColor.clear
                }
            } else {
                thumbView.isHidden = true
            }
        }
    }
    
    private var startAngle: Double = -90
    private var barColor = UIColor.lightGray
    private var trackingColor = UIColor.blue
    private var thumbColor = UIColor.black
    private var barWidth: CGFloat = 20
    private var maxValue: Float = 101
    private var minValue: Float = 0
    private var sliderEnabled = true
    private var viewInset: CGFloat = 20
    private var minMaxSwitchTreshold: Float = 0.0
    private var thumbImage: UIImage?
    private var _thumbWidth: CGFloat?
    private var thumbWidth: CGFloat {
        get {
            if let retValue = _thumbWidth {
                return retValue
            }

            return (thumbImage?.size.height)!
        }
        set {
            _thumbWidth = newValue
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
    }
    
    public init(frame: CGRect, options: [CircleSliderOption]?) {
        super.init(frame: frame)
        if let options = options {
            build(options)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandle(sender:)))
            tapGesture.numberOfTouchesRequired = 1
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(tapHandle(sender:)))
            addGestureRecognizer(tapGesture)
            addGestureRecognizer(panGesture)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSublayers(of layer: CALayer) {
        if trackLayer == nil {
            trackLayer = TrackLayer(bounds: bounds.insetBy(dx: viewInset, dy: viewInset), setting: createLayerSetting())
        }
        if thumbView == nil {
            if let image = thumbImage {
                thumbView = UIView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            } else {
                thumbView = UIView(frame: CGRect(x: 0, y: 0, width: thumbWidth, height: thumbWidth))
            }
        }
    }
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !sliderEnabled {
            return nil
        }
    
        return self
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bounds = self.bounds
        bounds = bounds.insetBy(dx: 100.0, dy: 100.0)
        return bounds.contains(point)
    }
    
    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let degree = Math.pointPairToBearingDegrees(center, endPoint: touch.location(in: self))
        latestDegree = degree
        layout(degree)
        let value = Float(Math.adjustValue(startAngle, degree: degree, maxValue: maxValue, minValue: minValue))
        thumbView.transform = CGAffineTransform(rotationAngle: CGFloat(Math.degreesToRadians(degree)))
        sliderValue = value
        return true
    }
    
    @objc
    func tapHandle(sender: UIGestureRecognizer) {
        if isUserInteractionEnabled {
            let degree = Math.pointPairToBearingDegrees(center, endPoint: sender.location(in: self))
            latestDegree = degree
            layout(degree)
            let value = Float(Math.adjustValue(startAngle, degree: degree, maxValue: maxValue, minValue: minValue))
            thumbView.transform = CGAffineTransform(rotationAngle: CGFloat(Math.degreesToRadians(degree)))
            sliderValue = value
        }
    }
    
    open func changeOptions(_ options: [CircleSliderOption]) {
        build(options)
        redraw()
    }
    
    private func redraw() {
        
        if trackLayer != nil {
            trackLayer.removeFromSuperlayer()
        }
        trackLayer = TrackLayer(bounds: bounds.insetBy(dx: viewInset, dy: viewInset), setting: createLayerSetting())
        if thumbView != nil {
            thumbView.removeFromSuperview()
        }
        
        if let image = thumbImage {
            thumbView = UIView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        } else {
            thumbView = UIView(frame: CGRect(x: 0, y: 0, width: thumbWidth, height: thumbWidth))
        }
        
        self.layout(self.latestDegree)
    }
    
    func build(_ options: [CircleSliderOption]) {
        for option in options {
            switch option {
            case let .startAngle(value):
                startAngle = value
                latestDegree = startAngle
            case let .barColor(value):
                barColor = value
            case let .trackingColor(value):
                trackingColor = value
            case let .thumbColor(value):
                thumbColor = value
            case let .barWidth(value):
                barWidth = value
            case let .thumbWidth(value):
                thumbWidth = value
            case let .maxValue(value):
                maxValue = value
                maxValue += 1
            case let .minValue(value):
                minValue = value
                startValue = minValue
            case let .sliderEnabled(value):
                sliderEnabled = value
            case let .viewInset(value):
                viewInset = value
            case let .minMaxSwitchTreshold(value):
                minMaxSwitchTreshold = value
            case let .thumbImage(value):
                thumbImage = value
            }
        }
    }
    
    private func layout(_ degree: Double) {
        if let trackLayer = trackLayer, let thumbView = self.thumbView {
            trackLayer.degree = degree
            thumbView.center = thumbCenter(degree)
            thumbView.transform = CGAffineTransform(rotationAngle: CGFloat(Math.degreesToRadians(degree)))
            trackLayer.setNeedsDisplay()
        }
    }
    
    private func createLayerSetting() -> TrackLayer.Setting {
        var setting = TrackLayer.Setting()
        setting.startAngle = startAngle
        setting.barColor = barColor
        setting.trackingColor = trackingColor
        setting.barWidth = barWidth
        return setting
    }
    
    private func thumbCenter(_ degree: Double) -> CGPoint {
        let radius = (bounds.insetBy(dx: viewInset, dy: viewInset).width * 0.5) - (barWidth * 0.5) + 5
        return Math.pointFromAngle(frame, angle: degree, radius: Double(radius))
    }
}

