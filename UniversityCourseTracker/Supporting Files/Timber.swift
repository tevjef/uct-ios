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

class NSLogger: NSObject, DDLogger {
    func logMessage(logMessage: DDLogMessage!) {
        let message = logFormatter.formatLogMessage(logMessage)
        NSLog(message)
    }
    
    var logFormatter: DDLogFormatter! = TimberFormatter()
}

class FirebaseLogger: NSObject, DDLogger {
    func logMessage(logMessage: DDLogMessage!) {
        let message = logFormatter.formatLogMessage(logMessage)

        FIRCrashLogv("%@", getVaList([message]))
    }
    
    var logFormatter: DDLogFormatter! = TimberFormatter()
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
    
    var logFormatter: DDLogFormatter! = TimberFormatter()
}

class TimberFormatter: NSObject, DDLogFormatter {
    
    @objc func formatLogMessage(logMessage: DDLogMessage!) -> String! {
        let tag = logMessage.fileName.componentsSeparatedByString(".swift").first!
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