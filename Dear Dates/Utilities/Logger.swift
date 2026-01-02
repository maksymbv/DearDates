//
//  Logger.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import os.log
import Combine

enum LogLevel {
    case debug
    case info
    case warning
    case error
}

struct AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.deardates.app"
    
    static func log(_ message: String, level: LogLevel = .info, category: String = "App") {
        let log = OSLog(subsystem: subsystem, category: category)
        
        switch level {
        case .debug:
            os_log("%{public}@", log: log, type: .debug, message)
        case .info:
            os_log("%{public}@", log: log, type: .info, message)
        case .warning:
            os_log("%{public}@", log: log, type: .default, message)
        case .error:
            os_log("%{public}@", log: log, type: .error, message)
        }
        
        // Для отладки в консоли
        #if DEBUG
        print("[\(level)] \(category): \(message)")
        #endif
    }
}
