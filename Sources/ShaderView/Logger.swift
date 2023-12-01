//
//  Logger.swift
//  
//
//  Created by Pirita Minkkinen on 11/8/23.
//


import os.log


///Is used to set the loglevel of the Logger class
public enum LogLevel: Int {
    case none = 0
    case error = 1
    case debug = 2
    
}


//TODO: improve this
///Logger for the package.
public class Logger {
    private static var currentLevel: LogLevel = .error // Default log level
    
    private static func shouldLog(_ level: LogLevel) -> Bool {
        return currentLevel.rawValue >= level.rawValue
    }
    
    static func debug(_ message: String) {
        if shouldLog(.debug) {
            os_log(.debug, "%{public}@", message)
        }}
    
    
    static func error(_ message: String) {
        if shouldLog(.error){
            os_log(.error, "%{public}@", message)
            //os_log(.error, log: OSLog(subsystem: category, category: "Error"), "%{public}@", message)
        }
    }
    
    
    
    // os_log(.info, log: OSLog(subsystem: category, category: "Info"), "%{public}@", message)
    
    ///Can be used to set the Log level of the ShaderView pakcage
    public static func setLogLevel(level: LogLevel){
        currentLevel = level
    }
}

