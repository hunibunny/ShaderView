//
//  Logger.swift
//  
//
//  Created by Pirita Minkkinen on 11/8/23.
//


import os.log


public enum LogLevel: Int {
    case none = 0
    case error = 1
    case debug = 2
    
}


//TODO: improve this
public class Logger {
    private static var currentLevel: LogLevel = .error // Default log level

    static func error(_ message: String) {
        if(currentLevel.rawValue >= 1){
            os_log(.error, "%{public}@", message)
            //os_log(.error, log: OSLog(subsystem: category, category: "Error"), "%{public}@", message)
        }
    }
    
    static func debug(_ message: String) {
        if(currentLevel.rawValue >= 2){
            os_log(.error, "%{public}@", message)
            //os_log(.debug, log: OSLog(subsystem: category, category: "Debug"), "%{public}@", message)
        }
    }
    
    // os_log(.info, log: OSLog(subsystem: category, category: "Info"), "%{public}@", message)
    
    public static func setLogLevel(level: LogLevel){
        currentLevel = level
    }
}
    
