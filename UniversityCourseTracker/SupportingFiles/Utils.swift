//
//  Utils.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/27/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation

import UIKit


var GlobalMainQueue: DispatchQueue {
    return DispatchQueue.main
}

var GlobalUserInteractiveQueue: DispatchQueue {
    return DispatchQueue(label: "io.coursetrakr", qos: DispatchQoS.userInteractive)
}

var GlobalUserInitiatedQueue: DispatchQueue {
    return DispatchQueue(label: "io.coursetrakr", qos: DispatchQoS.userInitiated)
}

var GlobalUtilityQueue: DispatchQueue {
    return DispatchQueue(label: "io.coursetrakr", qos: DispatchQoS.utility)
}

var GlobalBackgroundQueue: DispatchQueue {
    return DispatchQueue(label: "io.coursetrakr", qos: DispatchQoS.background)
}

var GlobalHighPriorityQueue: DispatchQueue {
    return DispatchQueue(label: "io.coursetrakr", qos: DispatchQoS.default)
}



extension UIColor {
    convenience init(hexString:String) {
        self.init(hexString:hexString, alpha:1)
    }
    
    convenience init(hexString:String, alpha: CGFloat) {
        let hexString:NSString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        let scanner = Scanner(string: hexString as String)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
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
    func scrollToTop(_ animated: Bool) {
        setContentOffset(CGPoint.zero, animated: animated)
    }
}

extension UIImage {
    func filledImage(_ fillColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        
        let context = UIGraphicsGetCurrentContext()
        fillColor.setFill()
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        context?.setBlendMode(CGBlendMode.colorBurn)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context?.draw(self.cgImage!, in: rect)
        
        context?.setBlendMode(CGBlendMode.sourceIn)
        context?.addRect(rect)
        context?.drawPath(using: CGPathDrawingMode.fill)
        
        let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return coloredImg
    }
}


extension UITableViewController {
    
    func showRefreshing()  {
        self.tableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl!.frame.size.height)
        self.refreshControl?.beginRefreshing()
    }
    
    func emptyMessage(_ message:String) {
        let messageLabel = UILabel(frame: CGRect(x: 0,y: 0,width: 90, height: self.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = AppConstants.Colors.primary
        messageLabel.numberOfLines = 2;
        messageLabel.textAlignment = .center;
        //messageLabel.sizeToFit()
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = .none;
    }
    
    func showRefreshing(_ closure: @escaping () -> Bool)  {
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

func delay(_ delay: Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
        execute: closure
    )
}

extension UIViewController {
    var appDelegate:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
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

    func popToRoot(_ button: UIBarButtonItem) {
        for vc in navigationController!.viewControllers {
            if vc is TrackedSectionViewController {
                navigationController?.popToViewController(vc, animated: true)
            }
        }
        reporting.logPopHome(self)
    }

    func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
    
    func makeActivityIndicator(_ view: UIView) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.color = UIColor.white
        indicator.center = view.center
        indicator.backgroundColor = AppConstants.Colors.primaryDark.withAlphaComponent(0.7)
        indicator.layer.cornerRadius = 5
        indicator.isOpaque = false
        
        view.addSubview(indicator)
        return indicator
    }
    
    func startIndicator(_ indicator: UIActivityIndicatorView?, _ condition: (() -> Bool)? = nil) {
        delay(1, closure: {
            if condition != nil && condition!() {
                indicator?.startAnimating()
            }
        })
    }
    
    func stopIndicator(_ indicator: UIActivityIndicatorView?) {
        indicator?.stopAnimating()
        indicator?.hidesWhenStopped = true
    }

    func alertNoInternet(_ onOk: @escaping ()->()) {
        let alert = UIAlertController(title: "No internet connection", message: "Please make sure you are connected to the internet", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
            uiAction in onOk()
        }))
        self.present(alert, animated: true, completion: nil)
    }
        
    func alertYouFuckedUp(_ onOk: @escaping ()->()) {
        let alert = UIAlertController(title: "You fucked up somewhere here", message: "Pleease refrain from future fuck ups.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "I'll try", style: UIAlertActionStyle.default, handler: {
            uiAction in onOk()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func makeTitleViewWithSubtitle(_ title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -5, width: 0, height: 0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff > 0 {
            var frame = titleLabel.frame
            frame.origin.x = widthDiff / 2
            titleLabel.frame = frame.integral
        } else {
            var frame = subtitleLabel.frame
            frame.origin.x = abs(widthDiff) / 2
            subtitleLabel.frame = frame.integral
        }
        
        titleView.sizeToFit()
        
        return titleView
    }
}

public extension NSObject{
    public class var nameOfClass: String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public var nameOfClass: String{
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}
