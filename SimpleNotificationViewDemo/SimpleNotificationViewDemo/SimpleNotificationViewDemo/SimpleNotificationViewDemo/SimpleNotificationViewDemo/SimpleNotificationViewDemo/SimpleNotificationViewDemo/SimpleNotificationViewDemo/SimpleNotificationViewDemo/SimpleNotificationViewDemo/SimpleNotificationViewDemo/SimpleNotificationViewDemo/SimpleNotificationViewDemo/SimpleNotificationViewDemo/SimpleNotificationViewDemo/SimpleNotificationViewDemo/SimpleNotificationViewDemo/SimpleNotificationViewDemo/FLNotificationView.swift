//
//  NotificationView.swift
//  StreamBitrate
//
//  Created by Do Thi Hong Ha on 1/8/16.
//  Copyright © 2016 Yotel. All rights reserved.
//

import UIKit

enum FLViewPosition: UInt, CustomDebugStringConvertible {
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

enum FLViewTransitionStyle: CustomDebugStringConvertible {
    case None
    case Default
    case Slide(from: FLViewPosition)
    case Fade(startAlpha: CGFloat, endAlpha : CGFloat )
    case Bounce(from: FLViewPosition)
    
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
    
    static func randomStyle() -> FLViewTransitionStyle {
        let num = arc4random_uniform(5)
        switch num {
        case 1:
            return .Default
        case 2:
            let position = FLViewPosition(rawValue: UInt(arc4random_uniform(5)))!
            return .Slide(from: position)
        case 3:
            let startAlpha = CGFloat(arc4random_uniform(5)) / 10
            let endAlpha = (CGFloat(arc4random_uniform(4) + 7)) / 10
            return .Fade(startAlpha: startAlpha, endAlpha: endAlpha)
        case 4:
            let position = FLViewPosition(rawValue: UInt(arc4random_uniform(5)))!
            return .Bounce(from: position)
        default:
            return .None
        }
    }
}

enum FLViewWidthConstraintMode: CustomDebugStringConvertible {
    case HorizontalMargin(left: CGFloat, right: CGFloat)
    case AutoAdjustToFitContent(minimumXMargin: CGFloat, minimumHeight: CGFloat)
    
    static func randomMode() -> FLViewWidthConstraintMode {
        let mode = arc4random_uniform(2)
        if (mode == 0) {
            let left = CGFloat(arc4random_uniform(8) + 9)
            let right = CGFloat(arc4random_uniform(8) + 9)
            return .HorizontalMargin(left: left, right: right)
        }
        else {
            let minimumXMargin = CGFloat(arc4random_uniform(4) + 5)
            let minimumHeight = CGFloat(arc4random_uniform(10) + 21)
            return .AutoAdjustToFitContent(minimumXMargin: minimumXMargin, minimumHeight: minimumHeight)
        }
    }
    
    var debugDescription: String {
        switch self {
        case .HorizontalMargin(let left, let right):
            return "Horizontal margin left = \(left) right = \(right)"
        case .AutoAdjustToFitContent(let minimumXMargin, let minimumHeight):
            return "Auto adjust to fit content with minimum X margin = \(minimumXMargin) minimum height = \(minimumHeight)"
        }
    }
}

enum FLViewArrangementOptions: CustomDebugStringConvertible {
    case StretchToFillEdge(sideDimension: CGFloat, minimumSize: CGFloat)
    case AnchorToCorner(corner: FLViewPosition, width: CGFloat, height: CGFloat)
    
    static func randomOptions() -> FLViewArrangementOptions {
        let opt = arc4random_uniform(2)
        if (opt == 0) {
            let sideDimension = CGFloat(arc4random_uniform(20) + 21)
            let minimunSize = CGFloat(arc4random_uniform(10)) + 11
            return .StretchToFillEdge(sideDimension: sideDimension, minimumSize: minimunSize)
        }
        else {
            let corner = FLViewPosition(rawValue: UInt(arc4random_uniform(5)))!
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

private struct FLCustomViewGroup {
    var views : [UIView]
    var innerPadding: CGFloat
    var outterMargin : UIEdgeInsets
    var arrangementOptions: FLViewArrangementOptions
//    var sideDimension : CGFloat = 1.0
//    var minimumDimension: CGFloat = 1.0
}

class FLNotificationView: UIView {

    var position = FLViewPosition.Bottom
    
    var edgeMarginY : CGFloat = 16.0
    
    var messageMargin = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    var textColor = UIColor.whiteColor()
    var textAlignment = NSTextAlignment.Center
    
    var displayDuration : UInt64 = 5
    var animationDuration: NSTimeInterval = 0.2
    
    var isShown = false
    var isDismissed = false
    var isAnimating = false
    
    var contentWidthMode = FLViewWidthConstraintMode.AutoAdjustToFitContent(minimumXMargin: 8, minimumHeight: 0)
    
    var transitionStyle = FLViewTransitionStyle.Default {
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
    private var customSubViews : [FLViewPosition: FLCustomViewGroup]?
    private var heightConstraint : NSLayoutConstraint?
    private var verticalConstraint: NSLayoutConstraint?
    private var horizontalConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    
    private var label: UILabel!
    private var messageOutterMargin = UIEdgeInsetsZero
//    private var finalConstraints = [NSLayoutConstraint]()
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    init(message: String, position: FLViewPosition = FLViewPosition.Top) {
        super.init(frame: CGRectZero)
        self.message = message
        let acceptedPostion = [FLViewPosition.Top, FLViewPosition.Bottom, FLViewPosition.Middle]
        if (acceptedPostion.contains(position)) {
            self.position = position
        }
        transitionStyle = defaultStyle()
        backgroundColor = UIColor(white: 0, alpha: 0.7)
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.CGColor
        let gest = UITapGestureRecognizer(target: self, action: "didTapOnAlertView")
        gest.numberOfTapsRequired = 1
        gest.cancelsTouchesInView = false
        addGestureRecognizer(gest)
    }
    
//    func addSubviews(views:[UIView], position: ViewPosition, sideDimension : CGFloat, minimumDimension : CGFloat = 1.0, margin: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0), innerPadding : CGFloat = 8.0) {
//        if (customSubViews == nil) {
//            customSubViews = [ViewPosition: CustomViewGroup]()
//        }
//        if (customSubViews![position] == nil) {
//            customSubViews![position] = CustomViewGroup(views: views, innerPadding: innerPadding, outterMargin: margin, sideDimension: sideDimension, minimumDimension: minimumDimension)
//        }
//        else {
//            customSubViews![position]!.views.appendContentsOf(views)
//            customSubViews![position]!.sideDimension = sideDimension
//            customSubViews![position]!.outterMargin = margin
//            customSubViews![position]!.innerPadding = innerPadding
//        }
//    }
    func addSubviews(views:[UIView], position: FLViewPosition, innerPadding: CGFloat = 8.0, margin: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0), arrangementOptions: FLViewArrangementOptions = FLViewArrangementOptions.StretchToFillEdge(sideDimension: 40.0, minimumSize: 2.0)) {
        
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
            customSubViews = [FLViewPosition: FLCustomViewGroup]()
        }
        if (customSubViews![position] == nil) {
            customSubViews![position] = FLCustomViewGroup(views: views, innerPadding: innerPadding, outterMargin: margin, arrangementOptions: arrangementOptions)
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
    
    func show(transitionStyle: FLViewTransitionStyle? = nil) {
        if (isAnimating || isShown) {
            return
        }
        
        if let ts = transitionStyle {
            self.transitionStyle = ts
        }
        
        logInfo()
        setupSubviews()
        
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
    
    // MARK: - Subviews arragement
    private func setupSubviews() {
        guard let topWindow = UIApplication.sharedApplication().keyWindow else {
            print("⚠️ No top window")
            return
        }
        
        messageOutterMargin = messageMargin
        var minimumViewWidth : CGFloat = 0
        var minimumViewHeight : CGFloat = 0
        
        if let viewsArr = customSubViews {
            if let group = viewsArr[.Top] where group.views.count != 0 {
                var containerHeight : CGFloat = 0;
                let n = CGFloat(group.views.count)
                
                let container = UIView()
                addSubview(container)
                container.translatesAutoresizingMaskIntoConstraints = false
                let cviewDict = ["container": container]
                var metrics = ["marginTop": group.outterMargin.top,
                    "marginLeft": group.outterMargin.left,
                    "marginRight": group.outterMargin.right]

                switch group.arrangementOptions {
                case .StretchToFillEdge(let height, let minSubviewWidth):
                    containerHeight = height
                    minimumViewWidth = group.innerPadding * (n-1) + n * minSubviewWidth + group.outterMargin.left + group.outterMargin.right
                    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-marginLeft-[container]-marginRight-|", options: [], metrics: metrics, views: cviewDict))
                    break
                case .AnchorToCorner(let corner, let subviewWidth, let height):
                    containerHeight = height
                    let containerWidth = group.innerPadding * (n-1) + n * subviewWidth
                    minimumViewWidth = containerWidth + group.outterMargin.left + group.outterMargin.right
                    metrics["width"] = minimumViewWidth
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
                messageOutterMargin.top = max(messageOutterMargin.top, group.outterMargin.top + containerHeight + group.outterMargin.bottom)
                minimumViewHeight = containerHeight + group.outterMargin.top + group.outterMargin.bottom
                metrics["height"] = containerHeight
                addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-marginTop-[container(height)]", options: [], metrics: metrics, views: cviewDict))
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
                    minimumViewWidth = group.innerPadding * (n-1) + n * minSubviewWidth + group.outterMargin.left + group.outterMargin.right
                    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-marginLeft-[container]-marginRight-|", options: [], metrics: metrics, views: cviewDict))
                    break
                case .AnchorToCorner(let corner, let subviewWidth, let height):
                    containerHeight = height
                    let containerWidth = group.innerPadding * (n-1) + n * subviewWidth
                    minimumViewWidth = containerWidth + group.outterMargin.left + group.outterMargin.right
                    metrics["width"] = minimumViewWidth
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
                
                minimumViewHeight = containerHeight + group.outterMargin.top + group.outterMargin.bottom
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
                var metrics = ["marginLeft": group.outterMargin.left,
                "marginTop": group.outterMargin.top,
                "marginBottom": group.outterMargin.bottom]
                let cviewDict = ["container": container]
                switch (group.arrangementOptions) {
                case .StretchToFillEdge(let width, let minSubviewHeight):
                    minimumViewHeight = group.innerPadding * (n-1) + n * minSubviewHeight + group.outterMargin.top + group.outterMargin.bottom
                    containerWidth = width
                    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-marginTop-[container]-marginBottom-|", options: [], metrics: metrics, views: cviewDict))
                    break
                case .AnchorToCorner(let corner, let width, let height):
                    let containerHeight = group.innerPadding * (n-1) + n * height
                    minimumViewHeight = containerHeight + group.outterMargin.top + group.outterMargin.bottom
                    containerWidth = width
                    metrics["height"] = containerHeight
                    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[container(height)]", options: [], metrics: metrics, views: cviewDict))

                    switch (corner) {
                    case .Top:
                        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-marginTop-[container]", options: [], metrics: metrics, views: cviewDict))
                        break
                    case .Bottom:
                        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[container]-marginBottom-|", options: [], metrics: metrics, views: cviewDict))
                        break
                    case .Middle:
                        addConstraint(NSLayoutConstraint(item: container, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
                        break
                    default:
                        break
                    }
                    break
                }
                
                messageOutterMargin.left = max(messageOutterMargin.left, group.outterMargin.left + containerWidth + group.outterMargin.right)

                minimumViewWidth = containerWidth + group.outterMargin.left + group.outterMargin.right
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
                var metrics = ["marginRight": group.outterMargin.right,
                    "marginTop": group.outterMargin.top,
                    "marginBottom": group.outterMargin.bottom]
                let cviewDict = ["container": container]
                switch (group.arrangementOptions) {
                case .StretchToFillEdge(let width, let minSubviewHeight):
                    minimumViewHeight = group.innerPadding * (n-1) + n * minSubviewHeight + group.outterMargin.top + group.outterMargin.bottom
                    containerWidth = width
                    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-marginTop-[container]-marginBottom-|", options: [], metrics: metrics, views: cviewDict))
                    break
                case .AnchorToCorner(let corner, let width, let height):
                    let containerHeight = group.innerPadding * (n-1) + n * height
                    minimumViewHeight = containerHeight + group.outterMargin.top + group.outterMargin.bottom
                    containerWidth = width
                    metrics["height"] = containerHeight
                    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[container(height)]", options: [], metrics: metrics, views: cviewDict))
                    
                    switch (corner) {
                    case .Top:
                        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-marginTop-[container]", options: [], metrics: metrics, views: cviewDict))
                        break
                    case .Bottom:
                        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[container]-marginBottom-|", options: [], metrics: metrics, views: cviewDict))
                        break
                    case .Middle:
                        addConstraint(NSLayoutConstraint(item: container, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
                        break
                    default:
                        break
                    }
                    break
                }
                
                messageOutterMargin.right = max(messageOutterMargin.right, group.outterMargin.left + containerWidth + group.outterMargin.right)
                
                minimumViewWidth = containerWidth + group.outterMargin.left + group.outterMargin.right
                metrics["width"] = containerWidth
                addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[container(width)]-marginRight-|", options: [], metrics: metrics, views: cviewDict))
                addHorizontalSubview(group, container: container)
            }
        }
        
        label = UILabel()
        label.text = message
        label.textColor = textColor
        label.textAlignment = textAlignment
        label.numberOfLines = 0
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let metrics = ["marginTop": messageOutterMargin.top,
            "marginBottom": messageOutterMargin.bottom,
            "marginLeft": messageOutterMargin.left,
            "marginRight": messageOutterMargin.right]
        let viewDict = ["label": label]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-marginTop-[label]-marginBottom-|", options: [], metrics: metrics, views: viewDict))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-marginLeft-[label]-marginRight-|", options: [], metrics: metrics, views: viewDict))
        
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
 
        let minWidthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: minimumViewWidth)
        topWindow.addConstraint(minWidthConstraint)
        
        switch contentWidthMode {
        case .AutoAdjustToFitContent(let minimumXMargin, let minimumHeight):
            let maxWidth = UIScreen.mainScreen().bounds.size.width - minimumXMargin*2
            
            let minHeightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: max(minimumViewHeight, minimumHeight))
            topWindow.addConstraint(minHeightConstraint)
            
            label.preferredMaxLayoutWidth = maxWidth - messageOutterMargin.left - messageOutterMargin.right
            let maxWidthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: topWindow, attribute: .Width, multiplier: 1.0, constant: -minimumXMargin*2)
            topWindow.addConstraint(maxWidthConstraint)
            break
        case .HorizontalMargin(let left, right: let right):
            let minHeightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: minimumViewHeight)
            topWindow.addConstraint(minHeightConstraint)
            
            widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: topWindow, attribute: .Width, multiplier: 1.0, constant: -left - right)
            widthConstraint!.priority = 751
            topWindow.addConstraint(widthConstraint!)
            label.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.size.width + widthConstraint!.constant - messageOutterMargin.left - messageOutterMargin.right
            break
        }
    }
    
    private func addVerticalSubview(group: FLCustomViewGroup, container: UIView) {
        
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
    
    private func addHorizontalSubview(group: FLCustomViewGroup, container: UIView) {
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
        guard let topWindow = UIApplication.sharedApplication().keyWindow,
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
        guard let topWindow = UIApplication.sharedApplication().keyWindow else {
            print("⚠️ No top window")
            return (nil, nil)
        }
        
        var xConstraint: NSLayoutConstraint?
        
        switch (contentWidthMode) {
        case .AutoAdjustToFitContent(_, _):
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
    
    private func slideAlertIn(from fposition: FLViewPosition, bounce: Bool) {
        guard let topWindow = UIApplication.sharedApplication().keyWindow else {
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
            UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
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
    
    private func slideAlertOut(to tPosition: FLViewPosition, bounce: Bool) {
        guard let topWindow = UIApplication.sharedApplication().keyWindow else {
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
        setupDismissTimer()
    }
    
    private func setupDismissTimer() {
        if (displayDuration == 0) {
            return
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(displayDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), {[weak self] () -> Void in
            if let a = self {
                if (a.isShown) {
                    a.dismiss()
                }
            }
        })
    }
    
    @objc private func didTapOnAlertView() {
        Queue.Main.execute { () -> Void in
            self.dismiss()
        }
    }
    
    func dismiss(transitionStyle: FLViewTransitionStyle? = nil) {
        if (!isShown || isDismissed || isAnimating) {
            return
        }
        
        guard let _ = superview else {
            print("⚠️ No superview")
            return
        }
        
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
    
    private func didDismissView() {
        isAnimating = false
        isDismissed = true
        isShown = false
        removeFromSuperview()
        self.verticalConstraint = nil
        self.horizontalConstraint = nil
    }
    
    
    private func defaultStyle() -> FLViewTransitionStyle {
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
            label.preferredMaxLayoutWidth = maxWidth - messageOutterMargin.left - messageOutterMargin.right
            break
        
        case .HorizontalMargin(let left, right: let right):
            let maxWidth = UIScreen.mainScreen().bounds.size.width - left - right
            label.preferredMaxLayoutWidth = maxWidth - messageOutterMargin.left - messageOutterMargin.right
        break
        }
        super.layoutSubviews()
    }
    
    func logInfo() {
        print("||====================================")
        print("* Notification: \(message)")
        print("* Position: \(position)")
        print("* Width mode: \(contentWidthMode)")
        print("* Transition style: \(transitionStyle)")
        if let viewsArr = customSubViews {
            for position in [FLViewPosition.Top, FLViewPosition.Bottom, FLViewPosition.Left, FLViewPosition.Right] {
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
