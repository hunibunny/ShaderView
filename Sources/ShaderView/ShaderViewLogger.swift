//
//  ShaderViewLogger.swift
//  A logging utility for ShaderView package.
//
//  Created by Pirita Minkkinen on 11/8/23.
//


import os.log


/// Defines log levels for the Logger class.
/// - Levels:
///   - none: No logging.
///   - error: Logs only error messages.
///   - debug: Logs error and debug messages.

public enum ShaderViewLogLevel: Int {
    case none = 0
    case error = 1
    case debug = 2
    
}


/// `ShaderViewLogger` provides a simple logging mechanism for the package.
/// It supports different log levels and uses `os.log` for output.
///
/// Usage:
/// `ShaderViewLogger.setLogLevel(level: .debug)` to set the log level.
/// `ShaderViewLogger.debug("Debug message")` to log a debug message.
public class ShaderViewLogger {
    private static var currentLevel: ShaderViewLogLevel = .debug // Default log level
    
    /// Determines if a message of the given log level should be logged.
    private static func shouldLog(_ level: ShaderViewLogLevel) -> Bool {
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
    
    
    
    /// Sets the current log level of the ShaderViewLogger.
       /// - Parameter level: The `LogLevel` to set for logging.
    public static func setLogLevel(level: ShaderViewLogLevel){
        currentLevel = level
    }
}

