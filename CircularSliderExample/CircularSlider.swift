import UIKit

enum SliderHandleType {
    case transparentWhiteColor
}
struct Constants{
    static var minimumValue: Double = 0.0
    static var maximumValue:Double = 100.0
    static var currentValue:Double = 0.0
    static var handleRadius:CGFloat = 0.0
    static var sliderLineWidth:CGFloat = 1.0
    static var lastAngle:Double = 0.0
    static let circleRadius:CGFloat = 0.0

}

@IBDesignable
class CircularSlider: UIControl {
    
    @IBInspectable open var minimumValue: Double = Constants.minimumValue
    @IBInspectable open var maximumValue: Double = Constants.maximumValue
    @IBInspectable open var currentValue: Double = Constants.currentValue{
        didSet {
            if currentValue > maximumValue {
                currentValue = maximumValue - 0.0001
            } else if currentValue < minimumValue {
                currentValue = minimumValue
            }
            
            self.setNeedsLayout()
            self.setNeedsDisplay()
            self.sendActions(for: .valueChanged)
        }
    }
    
    @IBInspectable open var handleRadius: CGFloat = Constants.handleRadius {
        didSet {
            if handleRadius * 2 < sliderLineWidth {
                handleRadius = sliderLineWidth / 2.0
            }
        }
    }
    
    
    fileprivate var lastAngle: Double = Constants.lastAngle
    fileprivate var centerPoint: CGPoint {
        get {
            let xPosition = self.frame.size.width / 2.0
            let yPosition = self.frame.size.height / 2.0
            return CGPoint(x: xPosition, y: yPosition)
        }
    }
    
    fileprivate var sliderLineWidth: CGFloat = Constants.sliderLineWidth
    fileprivate var sliderLineRadiusDisplayment: CGFloat = 0.0
    fileprivate var unfilledColor: UIColor = UIColor.black
    fileprivate var filledColor: UIColor = UIColor.white
    
    fileprivate var angle: Double {
        get {
            let angle = 360.0 - (360.0 * currentValue / maximumValue)
            return angle == 360.0 ? 0.0 : angle
        }
    }
    
    fileprivate var circleDiameter: CGFloat {
        get {
            switch self.handleType {
            case .transparentWhiteColor:
                return self.sliderLineWidth
            }
        }
    }
    
    fileprivate var circleRadius: CGFloat = Constants.circleRadius
    
    @IBInspectable open var radius: CGFloat {
        set {
            circleRadius = newValue > self.frame.size.height / 2.0 - self.sliderLineWidth / 2.0 - (self.circleDiameter - self.sliderLineWidth) - self.sliderLineRadiusDisplayment ? self.frame.size.height / 2.0 - self.sliderLineWidth / 2.0 - (self.circleDiameter - self.sliderLineWidth) - self.sliderLineRadiusDisplayment : newValue
        }
        get {
            return circleRadius
        }
    }
    
    open var handleType: SliderHandleType = .transparentWhiteColor
    
    @IBInspectable open var handleColor: UIColor = UIColor.white
    
    @IBInspectable open var lineWidth: CGFloat {
        set {
            sliderLineWidth = newValue
            setNeedsDisplay()
        }
        get {
            return sliderLineWidth
        }
    }
    
    @IBInspectable open var sliderBackgroundColor: UIColor {
        set {
            unfilledColor = newValue
            setNeedsDisplay()
        }
        get {
            return unfilledColor
        }
    }
    
    @IBInspectable open var sliderColor: UIColor {
        set {
            filledColor = newValue
            setNeedsDisplay()
        }
        get {
            return filledColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - drawing methods
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let ctx: CGContext =  UIGraphicsGetCurrentContext() else {
            return
        }
        
        //draw the unfiled circle
        
        let center = CGPoint(x: self.frame.size.width/2,y: self.frame.size.height/2)
        
        ctx.addRect(CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.size.width, height: self.bounds.size.height))
        UIColor.clear.set()
        ctx.setLineCap(.butt)
        ctx.drawPath(using: .fillStroke)
        
        
        ctx.addArc(center: center, radius: self.radius, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2.0), clockwise: false)
        self.unfilledColor.setStroke()
        ctx.setLineWidth(sliderLineWidth)
        ctx.setLineCap(.butt)
        ctx.drawPath(using: .stroke)
        
        ctx.addArc(center: center, radius: self.radius, startAngle: CGFloat(3 * Double.pi / 2.0), endAngle: CGFloat(3 * Double.pi / 2.0 - self.angle.degreesToRadians), clockwise: false)
        self.filledColor.setStroke()
        ctx.setLineWidth(sliderLineWidth)
        ctx.setLineCap(.butt)
        ctx.drawPath(using: .stroke)

        self.drawHandle(ctx)
    }

    fileprivate func drawHandle(_ ctx: CGContext) {
        ctx.saveGState()
        let handleCenter: CGPoint = self.pointFromCurrentAngle()
        self.handleColor.set()
        ctx.fillEllipse(in: CGRect(x: handleCenter.x - (handleRadius * 2.0 - sliderLineWidth) / 2.0, y: handleCenter.y - (handleRadius * 2.0 - sliderLineWidth) / 2.0, width: handleRadius * 2.0, height: handleRadius * 2.0))
        ctx.restoreGState()
    }
    
    fileprivate func pointFromCurrentAngle() -> CGPoint {
        let centerPoint = CGPoint(x: self.frame.size.width / 2.0 - sliderLineWidth / 2.0, y: self.frame.size.height / 2.0 - sliderLineWidth / 2.0)
        
        return CGPoint(x: centerPoint.x + radius * CGFloat(cos((-angle-90).degreesToRadians)), y: centerPoint.y + radius * CGFloat(sin((-angle-90).degreesToRadians)))
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        //return self.bounds.contains(point);
        var minimumAngle = (currentValue / maximumValue) * 360 - 20.0
        if minimumAngle < 0 {
            minimumAngle = 360 + minimumAngle
        }
        
        var maximumAngle = (currentValue / maximumValue) * 360 + 20.0
        if maximumAngle > 359.9999 {
            maximumAngle = maximumAngle - 359.9999
        }
        let touchedAngle = floor(angleFromNorth(centerPoint, point, false))
        return  touchedAngle > minimumAngle || touchedAngle < maximumAngle
    }
    
    // MARK: - UIControl methods
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        lastAngle = floor(angleFromNorth(centerPoint, touch.location(in: self), false))
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        let lastPoint = touch.location(in: self)
        self.moveHandle(lastPoint)
        self.sendActions(for: .valueChanged)
        
        return true
    }
    
    
    fileprivate func moveHandle(_ point:CGPoint) {
        let currentAngle = floor(angleFromNorth(centerPoint, point, false))
        var angleInterval = abs(currentAngle - lastAngle)
        var rotationDirection = currentAngle - lastAngle >= 0 ? 1.0 : -1.0
        if 360.0 - 2 * angleInterval < 0 {
            angleInterval = 360 - angleInterval
            rotationDirection *= -1.0
        }
        
        currentValue += self.valueFrom(angleInterval) * rotationDirection
        
        lastAngle = currentAngle
        self.setNeedsDisplay()
    }
    
    fileprivate func valueFrom(_ angle: Double) -> Double {
        return angle * (maximumValue - minimumValue) / 360
    }
    
    fileprivate func angleFromNorth(_ fromPoint:CGPoint,_ toPoint:CGPoint,_ flipped: Bool) -> Double {
        var v: CGPoint = CGPoint(x: toPoint.x - fromPoint.x, y: toPoint.y - fromPoint.y)
        let vmag: Double = sqrt(Double(v.x * v.x + v.y * v.y))
        var result: Double = 0.0
        v.x = v.x / CGFloat(vmag)
        v.y = v.y / CGFloat(vmag)
        let radians: Double = atan2(Double(v.y), Double(v.x))
        result = radians.radiansToDegrees
        return result >= -90.0 ? result + 90 : result + 450.0
    }
    
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
