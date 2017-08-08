//
//  Log.swift
//  NaptimeDevice
//
//  Created by PointerFLY on 04/05/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit

public class Log: NSObject {

    /// If true, log will be printed on the console, the default value is true.
    public static var shouldPrintLog = true

    /// You can access log, and do you own stuffs with logs, either record them to a file or display them.
    public static var customLogAction: ((_ message: String, _ level: Level) -> Void)?

    public enum Level: Int {
        case verbose = 0
        case debug = 1
        case info = 2
        case warn = 3
        case error = 4
    }

    /// Prefix of each log message.
    public static var prefix = "[NaptimeLog]: "

    /// Current log level, note that logs' level lower than current level will not be printed.
    /// For instance, if current level is warn, log with a level of verbose, debug and info will not be 
    /// printed.
    /// However, customLogAction ignore this setting and always works.
    ///
    /// - Note: For partner corporations, for privacy matters, verbose and debug logs are not available.
    ///   Verbose and debug log will not be printed or appear on customLogAction despite of current log
    ///   level, and it won't do anything when you invoke Log.verbose(#message) or Log.debug(#message)
    static open var level = Level.info

    public static func verbose(_ message: String) {
        #if !OPEN_PRODUCT
        customLogAction?(message, Level.verbose);
        guard level.rawValue <= Level.verbose.rawValue else  { return }
        if shouldPrintLog {
            print(prefix + message)
        }
        #endif
    }

    public static func debug(_ message: String) {
        #if !OPEN_PRODUCT
            customLogAction?(message, Level.debug);
            guard level.rawValue <= Level.debug.rawValue else  { return }
            if shouldPrintLog {
                print(prefix + message)
            }
        #endif
    }

    public static func info(_ message: String) {
        customLogAction?(message, Level.info);
        guard level.rawValue <= Level.info.rawValue else  { return }
        if shouldPrintLog {
            print(prefix + message)
        }
    }

    public static func warn(_ message: String) {
        customLogAction?(message, Level.warn);
        guard level.rawValue <= Level.warn.rawValue else  { return }
        if shouldPrintLog {
            print(prefix + message)
        }
    }

    public static func error(_ message: String) {
        customLogAction?(message, Level.error);
        guard level.rawValue <= Level.error.rawValue else  { return }
        if shouldPrintLog {
            print(prefix + message)
        }
    }
}
