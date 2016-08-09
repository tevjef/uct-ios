//
//  Utils.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/27/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation

import UIKit

extension UIColor {
    convenience init(hexString:String) {
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
        
        self.init(red:red, green:green, blue:blue, alpha:1)
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
}

extension UITableView {
    func scrollToTop(animated: Bool) {
        setContentOffset(CGPointZero, animated: animated)
    }
}


extension UITableViewController {
    
    func showRefreshing()  {
        self.refreshControl?.beginRefreshing()
    }
    
    
    func showRefreshing(closure: () -> Bool)  {
        delay(0.3, closure: {
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

    func popToRoot(button: UIBarButtonItem) {
        for vc in navigationController!.viewControllers {
            if vc is TrackedSectionViewController {
                navigationController?.popToViewController(vc, animated: true)
            }
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
    
    func makeActivityIndicator(view: UIView) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = view.center
        view.addSubview(indicator)
        return indicator
    }
    
    func startIndicator(indicator: UIActivityIndicatorView?) {
        indicator?.startAnimating()
        indicator?.backgroundColor = UIColor.whiteColor()
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