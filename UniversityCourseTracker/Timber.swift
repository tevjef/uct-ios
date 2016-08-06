//
//  Timber.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/6/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation

class Timber {

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

class DebugTree: Tree {
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