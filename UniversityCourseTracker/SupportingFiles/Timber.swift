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
    func log(message logMessage: DDLogMessage) {
        let message = logFormatter.format(message: logMessage)
        NSLog(message!)
    }
    
    var logFormatter: DDLogFormatter = TimberFormatter()
}

class FirebaseLogger: NSObject, DDLogger {
    func log(message logMessage: DDLogMessage) {
        let message = logFormatter.format(message: logMessage)

        FirebaseCrashMessage(message!)
    }
    
    var logFormatter: DDLogFormatter = TimberFormatter()
}

class CrashlyicsLogger: NSObject, DDLogger {
    func log(message logMessage: DDLogMessage) {
        let message = logFormatter.format(message: logMessage)
        
        if logMessage.level == .error {
            Crashlytics.sharedInstance().recordError(NSError(domain: message!, code: -1, userInfo: [:]))
            return
        }
        CLSLogv("%@", getVaList([message!]))
    }
    
    var logFormatter: DDLogFormatter = TimberFormatter()
}

class TimberFormatter: NSObject, DDLogFormatter {
    
    @objc func format(message logMessage: DDLogMessage) -> String? {
        let tag = logMessage.fileName.components(separatedBy: ".swift").first!
        var prefix: String = ""
        switch logMessage.level {
        case .debug:
            prefix = "D/"
        case .verbose:
            prefix = "V/"
        case .info:
            prefix = "I/"
        case .error:
            prefix = "E/"
        case .warning:
            prefix = "W/"
        default:
            prefix = "WTF/"
        }
        
        return "\(prefix)\(tag): \(logMessage.message)"
    }
}
