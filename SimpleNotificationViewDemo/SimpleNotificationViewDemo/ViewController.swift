//
//  ViewController.swift
//  SimpleNotificationViewDemo
//
//  Created by Do Thi Hong Ha on 1/12/16.
//  Copyright © 2016 Yotel. All rights reserved.
//

import UIKit

enum OptionCells: Int {
    case SimpleTopSlide
    case SimpleBottomBounce
    case SimpleMiddleFade
    case LeftSubviews
    case BottomButtons
    case SimpleTitle
    case TitleAndRightSubviews
    case Random
    case Count
    
    var string : String {
        switch self {
        case .SimpleTopSlide:
            return "Simple notification sliding from top"
        case .SimpleBottomBounce:
            return "Simple notification bounce from bottom"
        case .SimpleMiddleFade:
            return "Simple notification fade in the middle"
        case .LeftSubviews:
            return "Notification with subviews on the left"
        case .BottomButtons:
            return "Notification with buttons"
        case .SimpleTitle:
            return "Notification with title"
        case .TitleAndRightSubviews:
            return "Title and subviews on the right"
        case .Random:
            return "Random"
        default:
            return ""
        }
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TABLE VIEW
    // MARK: - Table view datasource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? OptionCells.Count.rawValue : 6
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? "Samples" : "Custom views"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OptionCell")!
        let label = cell.viewWithTag(101) as? UILabel
        if (indexPath.section == 0) {
            let row = OptionCells(rawValue: indexPath.row)!
            label?.text = row.string
        }
        else {
            if let row = FRNotificationType(rawValue: indexPath.row) {
                switch row {
                case .Error:
                    label?.text = "Error"
                    break
                case .Info:
                    label?.text = "Information"
                    break
                case .Loading:
                    label?.text = "Loading view"
                    break
                case .Success:
                    label?.text = "Success"
                    break
                case .Warning:
                    label?.text = "Warning"
                    break
                }
            }
            else {
                label?.text = "Alert view"
            }
        }
        return cell
    }
    
    // MARK: - Table view delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            showSamples(OptionCells(rawValue: indexPath.row)!)
        }
        else if let type = FRNotificationType(rawValue: indexPath.row) {
            showCustomView(type)
        }
        else {
            showAlertView()
        }
    }
    
    func showSamples(row: OptionCells) {
        let messages = ["Lorem ipsum dolor sit amet", "Lorem ipsum dolor sit amet, consectetur adipiscing elit", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."]
        let message = messages[Int(arc4random_uniform(UInt32(messages.count)))]
        switch row {
        case .SimpleTopSlide:
            let notificationView = FRNotificationView(message: message)
            notificationView.show()
            break
        case .SimpleBottomBounce:
            let notificationView = FRNotificationView(message: message, position: .Bottom)
            notificationView.show(.Bounce(from: .Bottom))
            break
        case .SimpleMiddleFade:
            let notificationView = FRNotificationView(message: message, position: .Middle)
            notificationView.show()
            break
        case .LeftSubviews:
            let notificationView = FRNotificationView(message: message, position: .Middle)
            var views = [UIView]()
            let idx = messages.indexOf(message)!
            for _ in 0...idx {
                let view = UIView()
                let red = CGFloat(arc4random_uniform(255)) / 255
                let blue =  CGFloat(arc4random_uniform(255)) / 255
                let green =  CGFloat(arc4random_uniform(255)) / 255
                view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
                views.append(view)
            }
            notificationView.addSubviews(views, position: .Left)
            notificationView.show()
            break
        case .BottomButtons:
            let notificationView = FRNotificationView(message: message, position: .Middle)
            let leftButton = UIButton(type: .Custom)
            leftButton.setTitle("OK", forState: UIControlState.Normal)
            leftButton.backgroundColor = UIColor(red: 0.498, green: 0.6471, blue: 0, alpha: 1.0) /* #7fa500 */
            leftButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            leftButton.addTarget(self, action: #selector(didTapButton(_:)), forControlEvents: .TouchUpInside)
            leftButton.titleLabel!.font = UIFont.boldSystemFontOfSize(16)
            
            let rightButton = UIButton(type: .Custom)
            rightButton.setTitle("Dismiss", forState: UIControlState.Normal)
            rightButton.backgroundColor = UIColor(red: 0.1725, green: 0.3098, blue: 0.3765, alpha: 1.0) /* #2c4f60 */
            rightButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            rightButton.addTarget(self, action: #selector(didTapButton(_:)), forControlEvents: .TouchUpInside)
            rightButton.titleLabel!.font = UIFont.boldSystemFontOfSize(16)
            
            let arrangement = FRViewArrangementOptions.AnchorToCorner(corner: .Right, width: 80, height: 32)
            notificationView.addSubviews([leftButton, rightButton],
                position: .Bottom,
                innerPadding: 8.0,
                margin: UIEdgeInsetsMake(4, 4, 4, 4),
                arrangementOptions: arrangement)
            notificationView.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
            notificationView.show(.Bounce(from: .Left))
            break
            
        case .SimpleTitle:
            let notificationView = FRNotificationView(message: message, title: messages[Int(arc4random_uniform(UInt32(messages.count)))])
            notificationView.show()
            break
        case .TitleAndRightSubviews:
            let notificationView = FRNotificationView(message: message, title: messages[Int(arc4random_uniform(UInt32(messages.count)))], position: .Middle)
            var views = [UIView]()
            let idx = messages.indexOf(message)!
            for _ in 0...idx {
                let view = UIView()
                let red = CGFloat(arc4random_uniform(255)) / 255
                let blue =  CGFloat(arc4random_uniform(255)) / 255
                let green =  CGFloat(arc4random_uniform(255)) / 255
                view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
                views.append(view)
            }
            notificationView.addSubviews(views, position: .Right)
            notificationView.show()
            break
        case .Random:
            let position = FRViewPosition(rawValue: UInt(arc4random_uniform(3)))
            let randomIndex = Int(arc4random_uniform(UInt32(messages.count + 1)))
            var title: String?
            if (randomIndex < messages.count) {
                title = messages[randomIndex]
            }
            let notif = FRNotificationView(message: message, title: title, position: position!)
            notif.displayDuration = UInt64(arc4random_uniform(10)) + 5
            let numberOfSubViews = arc4random_uniform(5)
            if (numberOfSubViews != 0) {
                let pos = FRViewPosition(rawValue: UInt(arc4random_uniform(5)))!
                var views = [UIView]()
                for _ in 0...numberOfSubViews-1 {
                    let view = UIView()
                    let red = CGFloat(arc4random_uniform(255)) / 255
                    let blue =  CGFloat(arc4random_uniform(255)) / 255
                    let green =  CGFloat(arc4random_uniform(255)) / 255
                    view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
                    views.append(view)
                }
                notif.addSubviews(views, position: pos, arrangementOptions: FRViewArrangementOptions.randomOptions())
                print("Got \(numberOfSubViews) subviews at \(pos)")
            }
            notif.transitionStyle = FRViewTransitionStyle.randomStyle()
            notif.contentWidthMode = FRViewWidthConstraintMode.randomMode()
            let red = CGFloat(arc4random_uniform(255)) / 255
            let blue =  CGFloat(arc4random_uniform(255)) / 255
            let green =  CGFloat(arc4random_uniform(255)) / 255
            notif.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            notif.messageColor = UIColor(red: 1-red, green: 1-green, blue: 1-blue, alpha: 1.0)
            let textAlgnments = [NSTextAlignment.Left, NSTextAlignment.Right, NSTextAlignment.Center]
            notif.messageAlignment = textAlgnments[Int(arc4random_uniform(3))]
            notif.show()
            break
        default:
            break
        }

    }
    
    func showCustomView(type: FRNotificationType) {
        var message = "Loading... Please wait"
        if (type != .Loading) {
            let messages = ["Lorem ipsum dolor sit amet", "Lorem ipsum dolor sit amet, consectetur adipiscing elit", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."]
            message = messages[Int(arc4random_uniform(UInt32(messages.count)))]
        }
        let notificationView = FRNotificationView(message: message, type: type)
        notificationView.show()
    }
    
    func showAlertView() {
        let messages = ["Lorem ipsum dolor sit amet", "Lorem ipsum dolor sit amet, consectetur adipiscing elit", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."]
        let alert = FRAlertView(message:  messages[Int(arc4random_uniform(UInt32(messages.count)))],
            title:  messages[Int(arc4random_uniform(UInt32(messages.count)))],
                actionButtonsTitles: ["Looks good"], cancelButtonTitle: "Dismiss", buttonTapHandler: { (buttonIndex, isCanceled) -> () in
                FRNotificationView(message: "Did tap on button at index \(buttonIndex)").show()
            })
        alert.show()
    }
    
    func didTapButton(button: UIButton) {
        FRNotificationView(message: "Did tap on button \(button.titleLabel!.text!)").show()
    }
}

