//
//  Logger.swift
//  
//
//  Created by Pirita Minkkinen on 11/8/23.
//


import os.log

//TODO: improve this
class Logger {
    static func error(_ message: String, category: String = "Default") {
        os_log(.error, "%{public}@", message)
    }
    
    static func debug(_ message: String, category: String = "Default") {
        os_log(.error, "%{public}@", message)
    }
}
    