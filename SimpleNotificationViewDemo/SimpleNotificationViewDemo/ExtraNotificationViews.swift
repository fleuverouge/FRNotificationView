//
//  ExtraNotificationViews.swift
//  SimpleNotificationViewDemo
//
//  Created by Do Thi Hong Ha on 1/12/16.
//  Copyright © 2016 Yotel. All rights reserved.
//

import Foundation
import FontAwesome_swift

enum FRNotificationType: Int {
    case Info
    case Success
    case Error
    case Warning
    case Loading
}

extension FRNotificationView {
    
    convenience init(message: String, type: FRNotificationType) {
       
        self.init(message: message)
        position = .Top
        messageColor = UIColor.whiteColor()
        var subviewPosition = FRViewPosition.Left
        var subviewSize = CGSize(width: 30, height: 30)
        overlayStyle = .None
        var subView: UIView!
        switch type {
        case .Loading:
            subviewPosition = .Top
            overlayStyle = .SolidColor(UIColor(white: 0.0, alpha: 0.7))
            position = .Middle
            subviewSize = CGSize(width: 40, height: 40)
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            indicator.startAnimating()
            subView = indicator
            backgroundColor = UIColor(white: 0.0, alpha: 0.7)
            borderColor = UIColor.blackColor()
            transitionStyle = FRViewTransitionStyle.Fade(startAlpha: 0.0, endAlpha: 1.0)
            break
        case .Info:
            backgroundColor = UIColor(red: 0.2039, green: 0.5961, blue: 0.8588, alpha: 1.0) /* #3498db */
            borderColor = UIColor(red: 0.1608, green: 0.502, blue: 0.7255, alpha: 1.0) /* #2980b9 */
//            tabBarItem.image = UIImage.fontAwesomeIconWithName(.Github, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30))
            subView = UIImageView(image: UIImage.fontAwesomeIconWithName(.InfoCircle, textColor: messageColor, size: subviewSize))
            break
        case .Error:
            backgroundColor = UIColor(red: 0.9059, green: 0.298, blue: 0.2353, alpha: 1.0) /* #e74c3c */
            borderColor = UIColor(red: 0.7529, green: 0.2235, blue: 0.1686, alpha: 1.0) /* #c0392b */
            subView = UIImageView(image: UIImage.fontAwesomeIconWithName(.TimesCircle, textColor: messageColor, size: subviewSize))
            transitionStyle = FRViewTransitionStyle.Bounce(from: .Top)
            break
        case .Warning:
            backgroundColor = UIColor(red: 0.949, green: 0.7922, blue: 0.1529, alpha: 1.0) /* #f2ca27 */
            borderColor = UIColor(red: 0.9529, green: 0.6118, blue: 0.0706, alpha: 1.0) /* #f39c12 */
            subView = UIImageView(image: UIImage.fontAwesomeIconWithName(.ExclamationTriangle, textColor: messageColor, size: subviewSize))
            break
        case .Success:
            backgroundColor = UIColor(red: 0.1804, green: 0.8, blue: 0.4431, alpha: 1.0) /* #2ecc71 */
            borderColor = UIColor(red: 0.1529, green: 0.6824, blue: 0.3765, alpha: 1.0) /* #27ae60 */
            subView = UIImageView(image: UIImage.fontAwesomeIconWithName(.CheckCircle, textColor: messageColor, size: subviewSize))
            break
        }
        let arrangement = FRViewArrangementOptions.AnchorToCorner(corner: .Middle, width: subviewSize.width, height: subviewSize.height)
        addSubviews([subView], position: subviewPosition, arrangementOptions: arrangement)
    }
}

class FRAlertView: FRNotificationView {
    var actionButtonBackgroundColor = UIColor(red: 0.6078, green: 0.349, blue: 0.7137, alpha: 1.0) /* #9b59b6 */
    var actionButtonTitleColor = UIColor.whiteColor()
    var cancelButtonBackgroundColor = UIColor.whiteColor()
    var cancelButtonTitleColor = UIColor.blackColor()
    var actionButtonsTitles : [String]?
    var cancelButtonTitle: String = "Dismiss"
    var buttonTapHandler: ((Int, Bool) -> ())!
    var buttonFont = UIFont.boldSystemFontOfSize(15)
    
    init(message: String, title: String?, actionButtonsTitles:[String]? = nil, cancelButtonTitle: String, buttonTapHandler: (Int, Bool) -> ()) {
        super.init(message: message, title: title, position: .Middle)
        backgroundColor = UIColor.whiteColor()
        titleColor = UIColor.blackColor()
        messageColor = UIColor.blackColor()
        borderColor = nil
        borderWidth = 0.0
        self.actionButtonsTitles = actionButtonsTitles
        self.cancelButtonTitle = cancelButtonTitle
        self.buttonTapHandler = buttonTapHandler
        overlayStyle = .Blur(style: .Dark, alpha: 0.7)
        dismissOnTap = false
        displayDuration = 0
        contentWidthMode = FRViewWidthConstraintMode.ProportionalToSuperView(ratio: 0.8, minWidth: 0, maxWidth: 400)
        titleMargin = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    override func show(transitionStyle: FRViewTransitionStyle? = nil, inView sview: UIView? = nil, completionBlock: (() -> ())? = nil) {
        addButtons()
        super.show(transitionStyle, inView: sview, completionBlock: completionBlock)
    }
    
    private let FR_BUTTON_TAG_INDEX = 101
    
    private func addButtons() {
        var buttons = [UIButton]()
        if let arr = actionButtonsTitles {
            var index = FR_BUTTON_TAG_INDEX
            for buttonTitle in arr {
                let button = UIButton()
                button.setTitleColor(actionButtonTitleColor, forState: .Normal)
                button.setTitle(buttonTitle, forState: .Normal)
                button.backgroundColor = actionButtonBackgroundColor
                button.titleLabel!.adjustsFontSizeToFitWidth = true
                button.titleLabel!.minimumScaleFactor = 0.5
                button.titleLabel!.font = buttonFont
                buttons.append(button)
                button.tag = index
                index += 1
                button.addTarget(self, action: #selector(didTapOnButton(_:)), forControlEvents: .TouchUpInside)
                let topBorder = UIView()
                topBorder.backgroundColor = UIColor.lightGrayColor()
                button.addSubview(topBorder)
                topBorder.translatesAutoresizingMaskIntoConstraints = false
                
                let rightBorder = UIView()
                rightBorder.backgroundColor = UIColor.lightGrayColor()
                button.addSubview(rightBorder)
                rightBorder.translatesAutoresizingMaskIntoConstraints = false
                
                let viewDict = ["topBorder": topBorder,
                                "rightBorder": rightBorder]
                button.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[topBorder(1)]", options: [], metrics: nil, views: viewDict))
                button.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[topBorder]-0-|", options: [], metrics: nil, views: viewDict))
                button.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[rightBorder]-0-|", options: [], metrics: nil, views: viewDict))
                button.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[rightBorder(1)]-0-|", options: [], metrics: nil, views: viewDict))
            }
        }
        
        let button = UIButton()
        button.setTitleColor(cancelButtonTitleColor, forState: .Normal)
        button.setTitle(cancelButtonTitle, forState: .Normal)
        button.backgroundColor = cancelButtonBackgroundColor
        button.titleLabel!.adjustsFontSizeToFitWidth = true
        button.titleLabel!.minimumScaleFactor = 0.5
        button.titleLabel!.font = buttonFont
        buttons.append(button)
        button.addTarget(self, action: #selector(didTapCancelButton), forControlEvents: .TouchUpInside)
        let topBorder = UIView()
        topBorder.backgroundColor = UIColor.lightGrayColor()
        button.addSubview(topBorder)
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        let viewDict = ["border": topBorder]
        button.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[border(1)]", options: [], metrics: nil, views: viewDict))
        button.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[border]-0-|", options: [], metrics: nil, views: viewDict))
        
        let arrangement = FRViewArrangementOptions.StretchToFillEdge(sideDimension: 36, minimumSize: 1.0)
        addSubviews(buttons, position: .Bottom, innerPadding: 0.0, margin: UIEdgeInsetsMake(8.0, 0, 0, 0), arrangementOptions: arrangement)
    }
    
    func didTapOnButton(button: UIButton) {
        let index = FR_BUTTON_TAG_INDEX - button.tag
        dismiss(nil) { () -> () in
            self.buttonTapHandler(index, false)
        }
    }
    
    func didTapCancelButton() {
        dismiss(nil) { () -> () in
            self.buttonTapHandler(-1, true)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}