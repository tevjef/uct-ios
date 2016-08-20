//
//  Timber.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/6/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Firebase
import Crashlytics

class Timber: NSObject {

    enum Priority {
        case VERBOSE
        case DEBUG
        case INFO
        case WARN
        case ERROR
    }

    static var TREE_OF_SOULS: Array<Tree> = Array<Tree>()
    
    class func v(str: String, file: String = #file) {
        let tag = prepareTag(Priority.VERBOSE, file: file)
        for tree in TREE_OF_SOULS {
            tree.v("\(tag)\(str)")
        }
    }
    
    class func d(str: String, file: String = #file) {
        let tag = prepareTag(Priority.DEBUG, file: file)
        for tree in TREE_OF_SOULS {
            tree.d("\(tag)\(str)")
        }
    }
    
    class func i(str: String, file: String = #file) {
        let tag = prepareTag(Priority.INFO, file: file)
        for tree in TREE_OF_SOULS {
            tree.i("\(tag)\(str)")
        }
    }
    
    class func w(str: String, file: String = #file) {
        let tag = prepareTag(Priority.WARN, file: file)
        for tree in TREE_OF_SOULS {
            tree.w("\(tag)\(str)")
        }
    }
    
    class func e(str: String, file: String = #file) {
        let tag = prepareTag(Priority.ERROR, file: file)
        for tree in TREE_OF_SOULS {
            tree.e("\(tag)\(str)")
        }
    }
    
    class func prepareTag(priority: Priority, file: String) -> String {
        var tag = file.componentsSeparatedByString("/").last!
        tag = tag.componentsSeparatedByString(".swift").first!
        var prefix: String = ""
        switch priority {
        case .DEBUG:
            prefix = "D/"
        case .VERBOSE:
            prefix = "V/"
        case .INFO:
            prefix = "I/"
        case .ERROR:
            prefix = "E/"
        case .WARN:
            prefix = "W/"
        }
        return prefix + tag + ": "
    }
    
    class func plant(tree: Tree) {
        TREE_OF_SOULS.append(tree)
    }
}

protocol Tree {
    func v(message: String)
    func d(message: String)
    func i(message: String)
    func w(message: String)
    func e(message: String)
}

class DebugTree: NSObject, Tree {
    func v(message: String) {
        NSLog(message)
    }
    func d(message: String) {
        NSLog(message)
    }
    func i(message: String) {
        NSLog(message)
    }
    func w(message: String) {
        NSLog(message)
    }
    func e(message: String) {
        NSLog(message)
    }
}

class FirebaseLogger: NSObject, DDLogger {
    func logMessage(logMessage: DDLogMessage!) {
        let message = logFormatter.formatLogMessage(logMessage)

        FIRCrashLogv("%@", getVaList([message]))
    }
    
    var logFormatter: DDLogFormatter! = TimberFormatter.sharedInstance
}

class CrashlyicsLogger: NSObject, DDLogger {
    func logMessage(logMessage: DDLogMessage!) {
        let message = logFormatter.formatLogMessage(logMessage)
        
        if logMessage.level == .Error {
            Crashlytics.sharedInstance().recordError(NSError(domain: message, code: -1, userInfo: [:]))
            return
        }
        CLSLogv("%@", getVaList([message]))
    }
    
    var logFormatter: DDLogFormatter! = TimberFormatter.sharedInstance
}

class TimberFormatter: NSObject, DDLogFormatter {
    
    static let sharedInstance = TimberFormatter()
    
    private override init() {}
    
    @objc func formatLogMessage(logMessage: DDLogMessage!) -> String! {
        let tag = logMessage.fileName.componentsSeparatedByString(".swift").first!
        print(tag)
        var prefix: String = ""
        switch logMessage.level {
        case .Debug:
            prefix = "D/"
        case .Verbose:
            prefix = "V/"
        case .Info:
            prefix = "I/"
        case .Error:
            prefix = "E/"
        case .Warning:
            prefix = "W/"
        default:
            prefix = "WTF/"
        }
        
        return "\(prefix)\(tag): \(logMessage.message)"
    }
}