//
//  NotificationView.swift
//  StreamBitrate
//
//  Created by Do Thi Hong Ha on 1/8/16.
//  Copyright © 2016 Yotel. All rights reserved.
//

import UIKit

enum FRViewPosition: UInt, CustomDebugStringConvertible {
    case Top
    case Bottom
    case Middle
    case Left
    case Right
    var debugDescription: String {
        switch self {
        case Top:
            return "Top"
        case Bottom:
            return "Bottom"
        case Left:
            return "Left"
        case Right:
            return "Right"
        case Middle:
            return "Middle"
        }
    }
}

enum FROverlayStyle {
    case None
    case Blur(style: UIBlurEffectStyle, alpha: CGFloat) //iOS 8+ only
    case SolidColor(UIColor)
}

enum FRViewTransitionStyle: CustomDebugStringConvertible {
    case None
    case Default
    case Slide(from: FRViewPosition)
    case Fade(startAlpha: CGFloat, endAlpha : CGFloat )
    case Bounce(from: FRViewPosition)
    
    var debugDescription: String {
        switch self {
        case None:
            return "None"
        case Default:
            return "Default"
        case Slide(let position):
            return "Slide from \(position)"
        case Fade(let startAlpha, let endAlpha):
            return "Fade from \(startAlpha) to \(endAlpha)"
        case Bounce(let position):
            return "Bounce from \(position)"
        }
    }
    
    static func randomStyle() -> FRViewTransitionStyle {
        let num = arc4random_uniform(5)
        switch num {
        case 1:
            return .Default
        case 2:
            let position = FRViewPosition(rawValue: UInt(arc4random_uniform(5)))!
            return .Slide(from: position)
        case 3:
            let startAlpha = CGFloat(arc4random_uniform(5)) / 10
            let endAlpha = (CGFloat(arc4random_uniform(4) + 7)) / 10
            return .Fade(startAlpha: startAlpha, endAlpha: endAlpha)
        case 4:
            let position = FRViewPosition(rawValue: UInt(arc4random_uniform(5)))!
            return .Bounce(from: position)
        default:
            return .None
        }
    }
}

enum FRViewWidthConstraintMode: CustomDebugStringConvertible {
    case HorizontalMargin(left: CGFloat, right: CGFloat)
    case AutoAdjustToFitContent(minimumXMargin: CGFloat, minimumHeight: CGFloat)
    case ProportionalToSuperView(ratio:CGFloat, minWidth: CGFloat, maxWidth: CGFloat)
    case FixedWidth(width: CGFloat)
    
    static func randomMode() -> FRViewWidthConstraintMode {
        let mode = arc4random_uniform(4)
        if (mode == 0) {
            let left = CGFloat(arc4random_uniform(8) + 9)
            let right = CGFloat(arc4random_uniform(8) + 9)
            return .HorizontalMargin(left: left, right: right)
        }
        else if (mode == 1) {
            let minimumXMargin = CGFloat(arc4random_uniform(4) + 5)
            let minimumHeight = CGFloat(arc4random_uniform(10) + 21)
            return .AutoAdjustToFitContent(minimumXMargin: minimumXMargin, minimumHeight: minimumHeight)
        }
        else if (mode == 2) {
            let ratio = CGFloat(arc4random_uniform(4) + 6) / 10
            let minWidth = UIScreen.mainScreen().bounds.size.width * (CGFloat(arc4random_uniform(4)) / 10)
            let maxWidth = minWidth * (CGFloat(arc4random_uniform(4)) / 10 + 1)
            return .ProportionalToSuperView(ratio: ratio, minWidth: minWidth, maxWidth: maxWidth)
        }
        else {
            let width = UIScreen.mainScreen().bounds.size.width * (CGFloat(arc4random_uniform(4) + 6) / 10)
            return .FixedWidth(width: width)
        }
    }
    
    var debugDescription: String {
        switch self {
        case .HorizontalMargin(let left, let right):
            return "Horizontal margin left = \(left) right = \(right)"
        case .AutoAdjustToFitContent(let minimumXMargin, let minimumHeight):
            return "Auto adjust to fit content with minimum X margin = \(minimumXMargin) minimum height = \(minimumHeight)"
        case .ProportionalToSuperView(let ratio):
            return "Proportional to superview with width ratio = \(ratio)"
        case .FixedWidth(let width):
            return "Fixed width: \(width)"
        }
    }
}

enum FRViewArrangementOptions: CustomDebugStringConvertible {
    case StretchToFillEdge(sideDimension: CGFloat, minimumSize: CGFloat)
    case AnchorToCorner(corner: FRViewPosition, width: CGFloat, height: CGFloat)
    
    static func randomOptions() -> FRViewArrangementOptions {
        let opt = arc4random_uniform(2)
        if (opt == 0) {
            let sideDimension = CGFloat(arc4random_uniform(20) + 21)
            let minimunSize = CGFloat(arc4random_uniform(10)) + 11
            return .StretchToFillEdge(sideDimension: sideDimension, minimumSize: minimunSize)
        }
        else {
            let corner = FRViewPosition(rawValue: UInt(arc4random_uniform(5)))!
            let width = CGFloat(arc4random_uniform(40) + 21)
            let height = CGFloat(arc4random_uniform(20) + 21)
            return .AnchorToCorner(corner: corner, width: width, height: height)
        }
    }
    
    var debugDescription: String {
        switch self {
        case .AnchorToCorner(let corner, let width, let height):
            return "Anchor to \(corner) - width = \(width) height = \(height)"
        case .StretchToFillEdge(let sideDimension, let minimumSize):
            return "Stretch to fill edge - side dimension = \(sideDimension) minimumSize = \(minimumSize)"
        }
    }
}

private struct FRCustomViewGroup {
    var views : [UIView]
    var innerPadding: CGFloat
    var outterMargin : UIEdgeInsets
    var arrangementOptions: FRViewArrangementOptions
//    var sideDimension : CGFloat = 1.0
//    var minimumDimension: CGFloat = 1.0
}

class FRNotificationView: UIView {

    var position = FRViewPosition.Bottom
    
    var edgeMarginY : CGFloat = 16.0
    
    var messageMargin = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    var messageColor = UIColor.whiteColor()
    var messageAlignment = NSTextAlignment.Center
    var messageFont = UIFont.systemFontOfSize(16)
    
    private var title : String?
    var titleMargin = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    var titleColor = UIColor.whiteColor()
    var titleAlignment = NSTextAlignment.Center
    var titleFont = UIFont.boldSystemFontOfSize(16)
    
    // if display duration = 0, view will not be timely dismissed
    var displayDuration : UInt64 = 5
    var animationDuration: NSTimeInterval = 0.2
    
    var isShown = false
    var isDismissed = false
    var isAnimating = false
    
    // Dismiss view when view is tapped
    var dismissOnTap = true
    private var overlayView : UIView?
    var overlayStyle = FROverlayStyle.None
    
    var contentWidthMode = FRViewWidthConstraintMode.AutoAdjustToFitContent(minimumXMargin: 8, minimumHeight: 0)
    
    var transitionStyle = FRViewTransitionStyle.Default {
        didSet {
            switch (transitionStyle) {
                case .Default:
                    transitionStyle = defaultStyle()
                break
            default:
                break
            }
        }
    }
    
    var borderColor : UIColor? = UIColor.blackColor() {
        didSet {
            layer.borderColor = borderColor?.CGColor
        }
    }
    var borderWidth: CGFloat = 1.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    var cornerRadius: CGFloat = 4.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    private var message = ""
    private var customSubViews : [FRViewPosition: FRCustomViewGroup]?
    private var verticalConstraint: NSLayoutConstraint?
    private var horizontalConstraint: NSLayoutConstraint?
    
    private var messageLabel: UILabel!
    private var messageOutterMargin = UIEdgeInsetsZero
    private var titleLabel: UILabel?
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    init(message: String, title: String? = nil, position: FRViewPosition = FRViewPosition.Top) {
        super.init(frame: CGRectZero)
        self.message = message
        self.title = title
        let acceptedPostion = [FRViewPosition.Top, FRViewPosition.Bottom, FRViewPosition.Middle]
        if (acceptedPostion.contains(position)) {
            self.position = position
        }
        transitionStyle = defaultStyle()
        backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        clipsToBounds = true
    }
    
    func addSubviews(views:[UIView], position: FRViewPosition, innerPadding: CGFloat = 8.0, margin: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0), arrangementOptions: FRViewArrangementOptions = FRViewArrangementOptions.StretchToFillEdge(sideDimension: 40.0, minimumSize: 2.0)) {
        
        // Remove invalid positions
        if (position == .Middle) {
            return
        }
        switch arrangementOptions {
        case .StretchToFillEdge(_, _):
            break
        case .AnchorToCorner(let corner, _, _):
            if ( (corner == .Left || corner == .Right) && (position == .Left || position == .Right)) {
                return
            }
            if ( (corner == .Top || corner == .Bottom) && (position == .Top || position == .Bottom)) {
                return
            }
            break
        }
        
        if (customSubViews == nil) {
            customSubViews = [FRViewPosition: FRCustomViewGroup]()
        }
        if (customSubViews![position] == nil) {
            customSubViews![position] = FRCustomViewGroup(views: views, innerPadding: innerPadding, outterMargin: margin, arrangementOptions: arrangementOptions)
        }
        else {
            customSubViews![position]!.views.appendContentsOf(views)
            customSubViews![position]!.outterMargin = margin
            customSubViews![position]!.innerPadding = innerPadding
            customSubViews![position]!.arrangementOptions = arrangementOptions
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var showHandler : (() -> ())?
    private var sView: UIView?
    
    func show(transitionStyle: FRViewTransitionStyle? = nil, inView sview: UIView? = nil, completionBlock: (() -> ())? = nil) {
        if (isAnimating || isShown) {
            return
        }
        
        showHandler = completionBlock
        
        if let ts = transitionStyle {
            self.transitionStyle = ts
        }
        
        if sview == nil {
            self.sView = UIApplication.sharedApplication().keyWindow

//            self.sView = UIWindow(frame: UIScreen.mainScreen().bounds)
//            if let window = self.sView as? UIWindow {
//                window.backgroundColor = UIColor.clearColor()
//                window.windowLevel = UIWindowLevelAlert
//                window.makeKeyAndVisible()
//            }
        }
        else {
            self.sView = sview
        }
        
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.CGColor
        
        logInfo()
        setupSubviews()
        
        addOverlayView()
        
        switch self.transitionStyle{
        case .None:
            showAlertWithoutAnimation()
            break
        case .Default: //This should never be dropped in
            break
        case .Slide(let fromP):
            slideAlertIn(from: fromP, bounce: false)
            break
        case .Fade(_, let endAlpha):
            fadeAlert(true, endAlpha: endAlpha)
            break
        case .Bounce(let fromP):
            slideAlertIn(from: fromP, bounce: true)
            break
        }
    }
    
    var dismissHandler : (() -> ())?
    
    func dismiss(transitionStyle: FRViewTransitionStyle? = nil, completionBlock: (() -> ())? = nil) {
        if (!isShown || isDismissed || isAnimating) {
            return
        }
        
        guard let _ = superview else {
            print("⚠️ No superview")
            return
        }
        
        dismissHandler = completionBlock
        
        var tstyle = self.transitionStyle
        if let s = transitionStyle {
            switch s {
            case .Default:
                tstyle = defaultStyle()
                break
            default:
                tstyle = s
            }
        }
        
        switch (tstyle) {
        case .Fade(let startAlpha, _):
            fadeAlert(false, endAlpha: startAlpha)
            break
        case .Slide(let tposition):
            slideAlertOut(to: tposition, bounce: false)
            break
        case .Bounce(let tposition):
            slideAlertOut(to: tposition, bounce: true)
            break
        case .Default: // Shouldn't drop in here
            break
        case .None:
            didDismissView()
            break
        }
    }
    
    // MARK: - Subviews arragement
    private func addOverlayView() {
        switch overlayStyle {
        case .None:
            overlayView?.removeFromSuperview()
            return
            
        case .Blur(let style, let alpha):
            if overlayView == nil {
                overlayView = UIView()
            }
            overlayView!.backgroundColor = UIColor.clearColor()
            overlayView!.alpha = alpha

            if !UIAccessibilityIsReduceTransparencyEnabled() {
                let blurEffect = UIBlurEffect(style: style)
                var blurView: UIVisualEffectView?
                for subview in overlayView!.subviews {
                    if let ev = subview as? UIVisualEffectView {
                        blurView = ev
                        ev.effect = blurEffect
                        break
                    }
                }
                if (blurView == nil) {
                    blurView = UIVisualEffectView(effect: blurEffect)
                    blurView!.frame = UIScreen.mainScreen().bounds
                    blurView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                    overlayView!.addSubview(blurView!)
                }
            }
            else {
                switch style {
                case .Dark:
                    overlayView!.backgroundColor = UIColor(white: 0.0, alpha: alpha)
                    break
                case .ExtraLight:
                    overlayView!.backgroundColor = UIColor(white: 1.0, alpha: alpha)
                    break
                case .Light:
                    overlayView!.backgroundColor = UIColor(white: 0.5, alpha: alpha)
                    break
                }
            }
            break
        case .SolidColor(let color):
            if overlayView == nil {
                overlayView = UIView()
            }
            overlayView!.backgroundColor = color
            break
        }
        
        guard let oview = overlayView else {
            print("No overlay view")
            return
        }
        
        if let parent = sView {
            if oview.superview == nil {
                parent.addSubview(oview)
                oview.translatesAutoresizingMaskIntoConstraints = false
                let viewDict = ["overlay": oview]
                parent.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[overlay]-0-|", options: [], metrics: nil, views: viewDict))
                parent.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[overlay]-0-|", options: [], metrics: nil, views: viewDict))
            }
            parent.bringSubviewToFront(self)
        }
    }
    
    private func setupSubviews() {
        guard let topWindow = sView else {
            print("⚠️ No top window")
            return
        }
        
        messageOutterMargin = messageMargin
        var minimumViewWidth : CGFloat = 0
        var minimumViewHeight : CGFloat = 0
        
        // *** Title
        if let _ = title {
            minimumViewHeight = titleMargin.top + titleMargin.bottom
            minimumViewWidth = titleMargin.left + titleMargin.bottom
            messageOutterMargin.top = max(messageOutterMargin.top, titleMargin.bottom)
            titleLabel = UILabel()
            titleLabel!.text = title
            titleLabel!.textAlignment = titleAlignment
            titleLabel!.font = titleFont
            titleLabel!.textColor = titleColor
            titleLabel!.numberOfLines = 0
            addSubview(titleLabel!)
            titleLabel!.translatesAutoresizingMaskIntoConstraints = false
            
            let metrics = ["marginTop": titleMargin.top,
                "marginLeft": titleMargin.left,
                "marginRight": titleMargin.right]
            let viewDict = ["label": titleLabel!]
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-marginTop-[label]", options: [], metrics: metrics, views: viewDict))
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-marginLeft-[label]-marginRight-|", options: [], metrics: metrics, views: viewDict))
        }
        
        messageLabel = UILabel()
        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if let viewsArr = customSubViews {
            if let group = viewsArr[.Top] where group.views.count != 0 {
                var containerHeight : CGFloat = 0;
                let n = CGFloat(group.views.count)
                
                let container = UIView()
                addSubview(container)
                container.translatesAutoresizingMaskIntoConstraints = false
                var cviewDict = ["container": container]
                var metrics = ["marginLeft": group.outterMargin.left,
                                "marginRight": group.outterMargin.right]
                switch group.arrangementOptions {
                case .StretchToFillEdge(let height, let minSubviewWidth):
                    containerHeight = height
                    minimumViewWidth = max(minimumViewWidth, group.innerPadding * (n-1) + n * minSubviewWidth + group.outterMargin.left + group.outterMargin.right)
                    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-marginLeft-[container]-marginRight-|", options: [], metrics: metrics, views: cviewDict))
                    break
                case .AnchorToCorner(let corner, let subviewWidth, let height):
                    containerHeight = height
                    let containerWidth = group.innerPadding * (n-1) + n * subviewWidth
                    minimumViewWidth = containerWidth + group.outterMargin.left + group.outterMargin.right
                    metrics["width"] = containerWidth
                    switch (corner) {
                    case .Left:
                        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-marginLeft-[container(width)]", options: [], metrics: metrics, views: cviewDict))
                        break
                    case .Right:
                        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[container(width)]-marginRight-|", options: [], metrics: metrics, views: cviewDict))
                        break
                    case .Middle:
                        addConstraint(NSLayoutConstraint(item: container, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
                        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[container(width)]", options: [], metrics: metrics, views: cviewDict))
                        break
                    default:
                        break
                    }
                }
                var containerTopMargin = group.outterMargin.top
                metrics["height"] = containerHeight
                if let tlabel = titleLabel {
                    containerTopMargin = max(titleMargin.bottom, containerTopMargin)
                    metrics["marginTop"] = containerTopMargin
                    cviewDict["titleLabel"] = tlabel
                    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[titleLabel]-marginTop-[container(height)]", options: [], metrics: metrics, views: cviewDict))
                }
                else {
                    metrics["marginTop"] = containerTopMargin
                    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-marginTop-[container(height)]", options: [], metrics: metrics, views: cviewDict))
                }
                
                messageOutterMargin.top = max(messageOutterMargin.top, containerTopMargin + containerHeight + group.outterMargin.bottom)
                minimumViewHeight = max(minimumViewHeight, messageOutterMargin.top + messageOutterMargin.bottom)
                addVerticalSubview(group, container: container)
            }
            
            if let group = viewsArr[.Bottom] where group.views.count != 0 {
                var containerHeight : CGFloat = 0;
                let n = CGFloat(group.views.count)
                
                let container = UIView()
                addSubview(container)
                container.translatesAutoresizingMaskIntoConstraints = false
                let cviewDict = ["container": container]
                var metrics = ["marginBottom": group.outterMargin.bottom,
                    "marginLeft": group.outterMargin.left,
                    "marginRight": group.outterMargin.right]
                
                switch group.arrangementOptions {
                case .StretchToFillEdge(let height, let minSubviewWidth):
                    containerHeight = height
                    minimumViewWidth = max(minimumViewWidth, group.innerPadding * (n-1) + n * minSubviewWidth + group.outterMargin.left + group.outterMargin.right)
                    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-marginLeft-[container]-marginRight-|", options: [], metrics: metrics, views: cviewDict))
                    break
                case .AnchorToCorner(let corner, let subviewWidth, let height):
                    containerHeight = height
                    let containerWidth = group.innerPadding * (n-1) + n * subviewWidth
                    minimumViewWidth = max(minimumViewWidth, containerWidth + group.outterMargin.left + group.outterMargin.right)
                    metrics["width"] = containerWidth
                    switch (corner) {
                    case .Left:
                        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-marginLeft-[container(width)]", options: [], metrics: metrics, views: cviewDict))
                        break
                    case .Right:
                        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[container(width)]-marginRight-|", options: [], metrics: metrics, views: cviewDict))
                        break
                    case .Middle:
                        addConstraint(NSLayoutConstraint(item: container, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
                        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[container(width)]", options: [], metrics: metrics, views: cviewDict))
                        break
                    default:
                        break
                    }
                }
                
                messageOutterMargin.bottom = max(messageOutterMargin.bottom, group.outterMargin.top + containerHeight + group.outterMargin.bottom)
                
                minimumViewHeight = max(minimumViewHeight, messageMargin.top + messageMargin.bottom)
                metrics["height"] = containerHeight
                addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[container(height)]-marginBottom-|", options: [], metrics: metrics, views: cviewDict))
                addVerticalSubview(group, container: container)
            }
            
            if let group = viewsArr[.Left] where group.views.count != 0 {
                let n = CGFloat(group.views.count)
                let container = UIView()
                addSubview(container)
                container.translatesAutoresizingMaskIntoConstraints = false
                var containerWidth: CGFloat = 0
                var containerTopMargin = group.outterMargin.top
                var metrics = ["marginLeft": group.outterMargin.left,
                                "marginBottom": group.outterMargin.bottom]
                var cviewDict = ["container": container]
                var topLiner = "|"
                if let tLabel = titleLabel {
                    containerTopMargin = max(group.outterMargin.top, titleMargin.bottom)
                    cviewDict["titleLabel"] = tLabel
                    topLiner = "[titleLabel]"
                }
                metrics["marginTop"] = containerTopMargin
                
                switch (group.arrangementOptions) {
                case .StretchToFillEdge(let width, let minSubviewHeight):
                    minimumViewHeight = max(minimumViewHeight, group.innerPadding * (n-1) + n * minSubviewHeight + group.outterMargin.top + group.outterMargin.bottom)
                    containerWidth = width
                    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:" + topLiner + "-marginTop-[container]-marginBottom-|", options: [], metrics: metrics, views: cviewDict))
                    
                    break
                case .AnchorToCorner(let corner, let width, let height):
                    let containerHeight = group.innerPadding * (n-1) + n * height
                    minimumViewHeight = max(minimumViewHeight, containerHeight + group.outterMargin.top + group.outterMargin.bottom)
                    containerWidth = width
                    metrics["height"] = containerHeight
                    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[container(height)]", options: [], metrics: metrics, views: cviewDict))

                    switch (corner) {
                    case .Top:
                        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:" + topLiner + "-marginTop-[container]", options: [], metrics: metrics, views: cviewDict))
                        break
                    case .Bottom:
                        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[container]-marginBottom-|", options: [], metrics: metrics, views: cviewDict))
                        break
                    case .Middle:
                        addConstraint(NSLayoutConstraint(item: container, attribute: .CenterY, relatedBy: .Equal, toItem: messageLabel, attribute: .CenterY, multiplier: 1.0, constant: 0))
                        break
                    default:
                        break
                    }
                    break
                }
                
                messageOutterMargin.left = max(messageOutterMargin.left, group.outterMargin.left + containerWidth + group.outterMargin.right)

                minimumViewWidth = max(minimumViewWidth, messageOutterMargin.left + messageOutterMargin.right)
                metrics["width"] = containerWidth
                addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-marginLeft-[container(width)]", options: [], metrics: metrics, views: cviewDict))
                addHorizontalSubview(group, container: container)
            }
            
            if let group = viewsArr[.Right] where group.views.count != 0 {
                let n = CGFloat(group.views.count)
                let container = UIView()
                addSubview(container)
                container.translatesAutoresizingMaskIntoConstraints = false
                var containerWidth: CGFloat = 0
                var containerTopMargin = group.outterMargin.top
                var metrics = ["marginRight": group.outterMargin.right,
                    "marginBottom": group.outterMargin.bottom]
                var cviewDict = ["container": container]
                var topLiner = "|"
                if let tLabel = titleLabel {
                    containerTopMargin = max(group.outterMargin.top, titleMargin.bottom)
                    cviewDict["titleLabel"] = tLabel
                    topLiner = "[titleLabel]"
                }
                metrics["marginTop"] = containerTopMargin
                switch (group.arrangementOptions) {
                case .StretchToFillEdge(let width, let minSubviewHeight):
                    minimumViewHeight = max(minimumViewHeight, group.innerPadding * (n-1) + n * minSubviewHeight + group.outterMargin.top + group.outterMargin.bottom)
                    containerWidth = width
                    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:" + topLiner + "-marginTop-[container]-marginBottom-|", options: [], metrics: metrics, views: cviewDict))
                    break
                case .AnchorToCorner(let corner, let width, let height):
                    let containerHeight = group.innerPadding * (n-1) + n * height
                    minimumViewHeight = max(minimumViewHeight, containerHeight + group.outterMargin.top + group.outterMargin.bottom)
                    containerWidth = width
                    metrics["height"] = containerHeight
                    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[container(height)]", options: [], metrics: metrics, views: cviewDict))
                    
                    switch (corner) {
                    case .Top:
                        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:" + topLiner + "-marginTop-[container]", options: [], metrics: metrics, views: cviewDict))
                        break
                    case .Bottom:
                        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[container]-marginBottom-|", options: [], metrics: metrics, views: cviewDict))
                        break
                    case .Middle:
                        addConstraint(NSLayoutConstraint(item: container, attribute: .CenterY, relatedBy: .Equal, toItem: messageLabel, attribute: .CenterY, multiplier: 1.0, constant: 0))
                        break
                    default:
                        break
                    }
                    break
                }
                
                messageOutterMargin.right = max(messageOutterMargin.right, group.outterMargin.left + containerWidth + group.outterMargin.right)
                
                minimumViewWidth = max(minimumViewWidth, messageOutterMargin.left + messageOutterMargin.right)
                metrics["width"] = containerWidth
                addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[container(width)]-marginRight-|", options: [], metrics: metrics, views: cviewDict))
                addHorizontalSubview(group, container: container)
            }
        }
        
        // *** Message label
        
        messageLabel.text = message
        messageLabel.textColor = messageColor
        messageLabel.textAlignment = messageAlignment
        messageLabel.numberOfLines = 0
        messageLabel.font = messageFont
        
        
        let metrics = ["marginTop": messageOutterMargin.top,
            "marginBottom": messageOutterMargin.bottom,
            "marginLeft": messageOutterMargin.left,
            "marginRight": messageOutterMargin.right]
        var viewDict = ["messageLabel": messageLabel]
        if let tLabel = titleLabel {
            viewDict["titleLabel"] = tLabel
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[titleLabel]-marginTop-[messageLabel]-marginBottom-|", options: [], metrics: metrics, views: viewDict))
        }
        else {
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-marginTop-[messageLabel]-marginBottom-|", options: [], metrics: metrics, views: viewDict))
        }
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-marginLeft-[messageLabel]-marginRight-|", options: [], metrics: metrics, views: viewDict))
        
        updateConstraints()
        
        
        switch self.transitionStyle {
        case .Fade(let startAlpha, _):
            alpha = startAlpha
            break
        default:
            break
        }
        
        topWindow.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
 
    
        
        switch contentWidthMode {
        case .AutoAdjustToFitContent(let minimumXMargin, let minimumHeight):
//            let maxWidth = UIScreen.mainScreen().bounds.size.width - minimumXMargin*2
            
            minimumViewHeight = max(minimumHeight, minimumViewHeight)
            
//            messageLabel.preferredMaxLayoutWidth = maxWidth - messageOutterMargin.left - messageOutterMargin.right
            let maxWidthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: topWindow, attribute: .Width, multiplier: 1.0, constant: -minimumXMargin*2)
            topWindow.addConstraint(maxWidthConstraint)
            break
        case .HorizontalMargin(let left, right: let right):
            let widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: topWindow, attribute: .Width, multiplier: 1.0, constant: -left - right)
            widthConstraint.priority = 751
            topWindow.addConstraint(widthConstraint)
//            messageLabel.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.size.width + widthConstraint!.constant - messageOutterMargin.left - messageOutterMargin.right
            break
        case .FixedWidth(let width):
            let widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: width)
            widthConstraint.priority = 751
            topWindow.addConstraint(widthConstraint)
            break
        case .ProportionalToSuperView(let ratio, let minWidth, let maxWidth):
            let widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: topWindow, attribute: .Width, multiplier: ratio, constant: 0)
            widthConstraint.priority = 751
            topWindow.addConstraint(widthConstraint)
            
            minimumViewWidth = max(minimumViewWidth, minWidth)
            if (maxWidth > minimumViewWidth) {
                let maxWidthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: maxWidth)
                topWindow.addConstraint(maxWidthConstraint)
            }
            break
        }
        
        let minWidthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: minimumViewWidth)
        topWindow.addConstraint(minWidthConstraint)
        
        let minHeightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: minimumViewHeight)
        topWindow.addConstraint(minHeightConstraint)
    }
    
    private func addVerticalSubview(group: FRCustomViewGroup, container: UIView) {
        
        let firstView = group.views.first!
    
        let n = CGFloat(group.views.count)
        let offset = (1 - n) * group.innerPadding / n
        addVerticalSubviewsConstraints(firstView, container: container, sizeOffset: offset, sizeMultiplier: 1/n)
        container.addConstraint(NSLayoutConstraint(item: firstView,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: container,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1.0,
            constant: 0.0))
        
        if (group.views.count > 1) {
            var leftView = firstView
            for view in group.views[1..<group.views.count] {
                addVerticalSubviewsConstraints(view, container: container, sizeOffset: offset, sizeMultiplier: 1/n)
                container.addConstraint(NSLayoutConstraint(item: view,
                    attribute: NSLayoutAttribute.Leading,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: leftView,
                    attribute: NSLayoutAttribute.Trailing,
                    multiplier: 1.0,
                    constant: group.innerPadding))
                leftView = view
            }
           
        }
        container.updateConstraints()
    }
    
    private func addVerticalSubviewsConstraints(view: UIView, container: UIView, sizeOffset: CGFloat, sizeMultiplier: CGFloat) {
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addConstraint(NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: container,
            attribute: NSLayoutAttribute.Width,
            multiplier: sizeMultiplier,
            constant: sizeOffset))
        let views = ["childview": view]
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[childview]-0-|",
            options: [],
            metrics: nil,
            views: views))
    }
    
    private func addHorizontalSubview(group: FRCustomViewGroup, container: UIView) {
//        let metrics = ["marginTop": group.outterMargin.top,
//            "marginBottom": group.outterMargin.bottom,
//            "marginLeft":group.outterMargin.left,
//            "marginRight":group.outterMargin.right]
//        let cviewDict = ["container": container]
//        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-marginTop-[container]-marginBottom-|", options: [], metrics: metrics, views: cviewDict))
        
        let firstView = group.views.first!
        
        let n = CGFloat(group.views.count)
        let offset = (1 - n) * group.innerPadding / n
        addHorizontalSubviewsConstraints(firstView, container: container, sizeOffset: offset, sizeMultiplier: 1/n)
        container.addConstraint(NSLayoutConstraint(item: firstView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: container,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 0.0))
        
        if (group.views.count > 1) {
            var topView = firstView
            for view in group.views[1..<group.views.count] {
                addHorizontalSubviewsConstraints(view, container: container, sizeOffset: offset, sizeMultiplier: 1/n)
                container.addConstraint(NSLayoutConstraint(item: view,
                    attribute: NSLayoutAttribute.Top,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: topView,
                    attribute: NSLayoutAttribute.Bottom,
                    multiplier: 1.0,
                    constant: group.innerPadding))
                topView = view
            }
        }
        container.updateConstraints()
    }
    
    private func addHorizontalSubviewsConstraints(view: UIView, container: UIView, sizeOffset: CGFloat, sizeMultiplier: CGFloat) {
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addConstraint(NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: container,
            attribute: NSLayoutAttribute.Height,
            multiplier: sizeMultiplier,
            constant: sizeOffset))
        let views = ["childview": view]
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[childview]-0-|",
            options: [],
            metrics: nil,
            views: views))
    }

    
    private func placeAlertViewInFinalPosition() {
        (horizontalConstraint, verticalConstraint) = finalPositionConstraint()
        guard let topWindow = sView,
        let hC = horizontalConstraint,
        let vC = verticalConstraint else {
            print("⚠️ No top window")
            return
        }
        
        topWindow.addConstraints([hC, vC])
        topWindow.updateConstraints()
        topWindow.layoutIfNeeded()
    }
    
    private func showAlertWithoutAnimation() {
        placeAlertViewInFinalPosition()
        didShowAlertView()
    }
    
    private func finalPositionConstraint() -> (xConstraint: NSLayoutConstraint?, yConstraint: NSLayoutConstraint?) {
        guard let topWindow = sView else {
            print("⚠️ No top window")
            return (nil, nil)
        }
        
        var xConstraint: NSLayoutConstraint?
        
        switch (contentWidthMode) {
        case .AutoAdjustToFitContent(_, _), .FixedWidth(_), .ProportionalToSuperView(_):
            xConstraint = NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: topWindow, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            break
        case .HorizontalMargin(let left, _):
            xConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem:topWindow, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: left)
            break
        }
        
        var yConstraint: NSLayoutConstraint?
        
        switch position {
        case .Top:
            //            topWindow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-marginY-[alertview]", options: [], metrics: metrics, views: alertDict))
            yConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: topWindow, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: edgeMarginY)
            break
        case .Bottom:
            //                topWindow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[alertview]-marginY-|", options: [], metrics: metrics, views: alertDict))
            yConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: topWindow, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -edgeMarginY)
            break
        case .Middle:
            yConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: topWindow, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0)
            break
        default:
            break
        }
        return (xConstraint, yConstraint)
    }
    // MARK: - Transition
    private func fadeAlert(fadeIn: Bool, endAlpha: CGFloat) {
        if (verticalConstraint == nil || horizontalConstraint == nil) {
            placeAlertViewInFinalPosition()
        }
        isAnimating = true
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.alpha = endAlpha
            }, completion: { (finished) -> Void in
                if (finished) {
                    if (fadeIn) {
                        self.didShowAlertView()
                    }
                    else {
                        self.didDismissView()
                    }
                }
        })
    }
    
    private func slideAlertIn(from fposition: FRViewPosition, bounce: Bool) {
        guard let topWindow = sView else {
            print("⚠️ No top window")
            return
        }
//        let expectedSize = systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        
        var startXConstraint: NSLayoutConstraint?
        var startYConstraint: NSLayoutConstraint?
        
        (horizontalConstraint, verticalConstraint) = finalPositionConstraint()
        
        switch fposition {
        case .Top:
            (startXConstraint, _) = finalPositionConstraint()
            startYConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: topWindow, attribute: .Top, multiplier: 1.0, constant: 0)
            break
        case .Bottom:
            (startXConstraint, _) = finalPositionConstraint()
            startYConstraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: topWindow, attribute: .Bottom, multiplier: 1.0, constant: 0)
            break
        case .Left:
            startXConstraint = NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: topWindow, attribute: .Leading, multiplier: 1.0, constant: 0)
            (_, startYConstraint) = finalPositionConstraint()
            break
        case .Right:
            startXConstraint = NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: topWindow, attribute: .Trailing, multiplier: 1.0, constant: 0)
            (_, startYConstraint) = finalPositionConstraint()
            break
        case .Middle:
            startXConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: topWindow, attribute: .CenterX, multiplier: 1.0, constant: 0)
            startYConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: topWindow, attribute: .CenterX, multiplier: 1.0, constant: 0)
            break
        }
        
        topWindow.addConstraints([startXConstraint!, startYConstraint!])
        topWindow.updateConstraints()
        topWindow.layoutIfNeeded()
        
        isAnimating = true
        
        if (!bounce) {
            UIView .animateWithDuration(animationDuration, animations: { () -> Void in
                topWindow.removeConstraints([startXConstraint!, startYConstraint!])
                topWindow.addConstraints([self.horizontalConstraint!, self.verticalConstraint!])
                topWindow.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    if (finished) {
                        self.didShowAlertView()
                    }
            })
        }
        else {
            UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                topWindow.removeConstraints([startXConstraint!, startYConstraint!])
                topWindow.addConstraints([self.horizontalConstraint!, self.verticalConstraint!])
                topWindow.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    if (finished) {
                        self.didShowAlertView()
                    }
            })
        }
    }
    
    private func slideAlertOut(to tPosition: FRViewPosition, bounce: Bool) {
        guard let topWindow = sView else {
            print("⚠️ No top window")
            return
        }
        //        let expectedSize = systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        
        var endXConstraint: NSLayoutConstraint?
        var endYConstraint: NSLayoutConstraint?
        
        switch tPosition {
        case .Top:
            (endXConstraint, _) = finalPositionConstraint()
            endYConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: topWindow, attribute: .Top, multiplier: 1.0, constant: 0)
            break
        case .Bottom:
            (endXConstraint, _) = finalPositionConstraint()
            endYConstraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: topWindow, attribute: .Bottom, multiplier: 1.0, constant: 0)
            break
        case .Left:
            endXConstraint = NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: topWindow, attribute: .Leading, multiplier: 1.0, constant: 0)
            (_, endYConstraint) = finalPositionConstraint()
            break
        case .Right:
            endXConstraint = NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: topWindow, attribute: .Trailing, multiplier: 1.0, constant: 0)
            (_, endYConstraint) = finalPositionConstraint()
            break
        case .Middle:
            endXConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: topWindow, attribute: .CenterX, multiplier: 1.0, constant: 0)
            endYConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: topWindow, attribute: .CenterX, multiplier: 1.0, constant: 0)
            break
        }
        
        isAnimating = true
        
        UIView .animateWithDuration(animationDuration, animations: { () -> Void in
            topWindow.removeConstraints([self.horizontalConstraint!, self.verticalConstraint!])
            topWindow.addConstraints([endXConstraint!, endYConstraint!])
            topWindow.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                if (finished) {
                    self.didDismissView()
                }
        })
        
//        if (!bounce) {
//            UIView .animateWithDuration(animationDuration, animations: { () -> Void in
//                topWindow.removeConstraints([self.horizontalConstraint!, self.verticalConstraint!])
//                topWindow.addConstraints([endXConstraint!, endYConstraint!])
//                topWindow.layoutIfNeeded()
//                }, completion: { (finished) -> Void in
//                    if (finished) {
//                        self.didDismissView()
//                    }
//            })
//        }
//        else {
//            UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1.0, options: [], animations: { () -> Void in
//                topWindow.removeConstraints([self.horizontalConstraint!, self.verticalConstraint!])
//                topWindow.addConstraints([endXConstraint!, endYConstraint!])
//                topWindow.layoutIfNeeded()
//                }, completion: { (finished) -> Void in
//                    if (finished) {
//                        self.didDismissView()
//                    }
//            })
//        }
    }

    // MARK: -
    
    private func didShowAlertView() {
        isShown = true
        isAnimating = false
        if (dismissOnTap) {
            let gest = UITapGestureRecognizer(target: self, action: #selector(didTapOnAlertView))
            gest.numberOfTapsRequired = 1
            gest.cancelsTouchesInView = false
            addGestureRecognizer(gest)
        }
        setupDismissTimer()
        showHandler?()
    }
    
    private func setupDismissTimer() {
        if (displayDuration == 0) {
            return
        }
        
        Queue.Main.execute(after: displayDuration, closure: {
            [weak self] in
            if let a = self {
                if (a.isShown) {
                    a.dismiss(completionBlock: a.dismissHandler)
                }
            }
        })
    }
    
    @objc private func didTapOnAlertView() {
        Queue.Main.execute { () -> Void in
            self.dismiss(completionBlock: self.dismissHandler)
        }
    }
    
    
    private func didDismissView() {
        isAnimating = false
        isDismissed = true
        isShown = false
        overlayView?.removeFromSuperview()
        removeFromSuperview()
        self.verticalConstraint = nil
        self.horizontalConstraint = nil
        dismissHandler?()
    }
    
    private func defaultStyle() -> FRViewTransitionStyle {
        switch (position) {
        case .Top, .Bottom:
            return .Slide(from: position)
        default:
            return .Fade(startAlpha: 0.0, endAlpha: 1.0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch contentWidthMode {
        case .AutoAdjustToFitContent(let minimumXMargin, _):
            let maxWidth = UIScreen.mainScreen().bounds.size.width - minimumXMargin*2
            messageLabel.preferredMaxLayoutWidth = maxWidth - messageOutterMargin.left - messageOutterMargin.right
            titleLabel?.preferredMaxLayoutWidth = maxWidth - titleMargin.left - titleMargin.right
            break
        
        case .HorizontalMargin(let left, right: let right):
            let maxWidth = UIScreen.mainScreen().bounds.size.width - left - right
            messageLabel.preferredMaxLayoutWidth = maxWidth - messageOutterMargin.left - messageOutterMargin.right
            titleLabel?.preferredMaxLayoutWidth = maxWidth - titleMargin.left - titleMargin.right
        break
        case .FixedWidth(let width):
            messageLabel.preferredMaxLayoutWidth = width - messageOutterMargin.left - messageOutterMargin.right
            titleLabel?.preferredMaxLayoutWidth = width - titleMargin.left - titleMargin.right
            break
        case .ProportionalToSuperView(let ratio, _, let maxWidth):
            let maxWidth = min(UIScreen.mainScreen().bounds.size.width * ratio, maxWidth)
            messageLabel.preferredMaxLayoutWidth = maxWidth - messageOutterMargin.left - messageOutterMargin.right
            titleLabel?.preferredMaxLayoutWidth = maxWidth - titleMargin.left - titleMargin.right
            break
        }
        super.layoutSubviews()
    }
    
    // MARK: -
    
    func logInfo() {
        print("||====================================")
        print("* Notification: \(message)")
        print("* Position: \(position)")
        print("* Width mode: \(contentWidthMode)")
        print("* Transition style: \(transitionStyle)")
        if let viewsArr = customSubViews {
            for position in [FRViewPosition.Top, FRViewPosition.Bottom, FRViewPosition.Left, FRViewPosition.Right] {
                if let group = viewsArr[position] where group.views.count != 0 {
                    print("* Subview at \(position): \(group.views.count)")
                    print("** Arrangement: \(group.arrangementOptions)")
                }
            }
        }
        else {
            print("* No subview")
        }
        print("======================================||")
    }
    
    deinit {
        print("deinit notification view")
    }
}
