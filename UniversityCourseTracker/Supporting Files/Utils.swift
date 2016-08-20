//
//  Utils.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/27/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation

import UIKit


var GlobalMainQueue: dispatch_queue_t {
    return dispatch_get_main_queue()
}

var GlobalUserInteractiveQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
}

var GlobalUserInitiatedQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
}

var GlobalUtilityQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
}

var GlobalBackgroundQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
}

var GlobalHighPriorityQueue: dispatch_queue_t {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
}



extension UIColor {
    convenience init(hexString:String) {
        self.init(hexString:hexString, alpha:1)
    }
    
    convenience init(hexString:String, alpha: CGFloat) {
        let hexString:NSString = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let scanner = NSScanner(string: hexString as String)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
    
    func viewFromColor() -> UIView {
        let bgColorView = UIView()
        bgColorView.backgroundColor = self
        return bgColorView
    }
}

extension UITableView {
    func scrollToTop(animated: Bool) {
        setContentOffset(CGPointZero, animated: animated)
    }
}

extension UIImage {
    func filledImage(fillColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.mainScreen().scale)
        
        let context = UIGraphicsGetCurrentContext()
        fillColor.setFill()
        
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        CGContextSetBlendMode(context, CGBlendMode.ColorBurn)
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        CGContextDrawImage(context, rect, self.CGImage)
        
        CGContextSetBlendMode(context, CGBlendMode.SourceIn)
        CGContextAddRect(context, rect)
        CGContextDrawPath(context,CGPathDrawingMode.Fill)
        
        let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return coloredImg
    }
}


extension UITableViewController {
    
    func showRefreshing()  {
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl!.frame.size.height)
        self.refreshControl?.beginRefreshing()
    }
    
    func emptyMessage(message:String) {
        let messageLabel = UILabel(frame: CGRectMake(0,0,90, self.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = AppConstants.Colors.primary
        messageLabel.numberOfLines = 2;
        messageLabel.textAlignment = .Center;
        //messageLabel.sizeToFit()
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = .None;
    }
    
    func showRefreshing(closure: () -> Bool)  {
        delay(1.5, closure: {
            if closure() {
                self.showRefreshing()
            } else {
                self.hideRefreshing()
            }
        })
    }
    
    func hideRefreshing() {
        self.refreshControl?.endRefreshing()
    }
}

func delay(delay: Double, closure: ()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(),
        closure
    )
}

extension UIViewController {
    var appDelegate:AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    var coreData:CoreDataManager {
        return appDelegate.coreDataManager!
    }
    
    var datarepo:DataRepos {
        return appDelegate.dataRepo!
    }
    
    var reporting:Reporting {
        return appDelegate.reporting!
    }

    func popToRoot(button: UIBarButtonItem) {
        for vc in navigationController!.viewControllers {
            if vc is TrackedSectionViewController {
                navigationController?.popToViewController(vc, animated: true)
            }
        }
        reporting.logPopHome(self)
    }

    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
    
    func makeActivityIndicator(view: UIView) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = view.center
        view.addSubview(indicator)
        return indicator
    }
    
    func startIndicator(indicator: UIActivityIndicatorView?) {
        indicator?.startAnimating()
        indicator?.backgroundColor = UIColor.clearColor()
    }
    
    func stopIndicator(indicator: UIActivityIndicatorView?) {
        indicator?.stopAnimating()
        indicator?.hidesWhenStopped = true
    }

    func alertNoInternet(onOk: ()->()) {
        let alert = UIAlertController(title: "No internet connection", message: "Please make sure you are connected to the internet", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
            uiAction in onOk()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
        
    func alertYouFuckedUp(onOk: ()->()) {
        let alert = UIAlertController(title: "You fucked up somewhere here", message: "Pleease refrain from future fuck ups.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "I'll try", style: UIAlertActionStyle.Default, handler: {
            uiAction in onOk()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func makeTitleViewWithSubtitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRectMake(0, -5, 0, 0))
        
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRectMake(0, 18, 0, 0))
        subtitleLabel.backgroundColor = UIColor.clearColor()
        subtitleLabel.textColor = UIColor.whiteColor()
        subtitleLabel.font = UIFont.systemFontOfSize(12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRectMake(0, 0, max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff > 0 {
            var frame = titleLabel.frame
            frame.origin.x = widthDiff / 2
            titleLabel.frame = CGRectIntegral(frame)
        } else {
            var frame = subtitleLabel.frame
            frame.origin.x = abs(widthDiff) / 2
            subtitleLabel.frame = CGRectIntegral(frame)
        }
        
        titleView.sizeToFit()
        
        return titleView
    }
}

public extension NSObject{
    public class var nameOfClass: String{
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public var nameOfClass: String{
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
    }
}