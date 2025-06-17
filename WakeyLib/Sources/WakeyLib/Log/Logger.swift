//
//  Logger.swift
//  WakeyLib
//
//  Created by Ernest Cho on 4/20/24.
//

import Foundation

public enum LogLevel: Int, Codable {
    case verbose = 0
    case debug
    case warning
    case error
}

public protocol LogDestination {
    func handle(message: String)
}

// by default, messages are just printed to standard out
struct DefaultDestination: LogDestination {
    func handle(message: String) {
        print(message)
    }
}

/// Many apps have their own existing logging system.
/// This SDK logger allows redirecting log messages to whatever system the App dev chooses.
public class Logger: NSObject {
    
    // This is using an internal isolation queue.
    nonisolated(unsafe) public static let shared: Logger = Logger()

    var currentLogLevel = Config.defaultConfig().logLevel
    var destination : LogDestination = DefaultDestination()
    var queue = DispatchQueue(label: "com.ieesizaq.echologqueue")
    
    public func setDestination(destination: LogDestination) {
        self.queue.sync {
            self.destination = destination
        }
    }
    
    public func setLogLevel(logLevel: LogLevel) {
        self.queue.sync {
            self.currentLogLevel = logLevel
        }
    }
    
    public func logVerbose(message: String) {
        self.logMessage(message: message, level: .verbose)
    }
    
    public func logDebug(message: String) {
        self.logMessage(message: message, level: .debug)
    }
    
    public func logWarning(message: String) {
        self.logMessage(message: message, level: .warning)
    }
    
    public func logError(message: String) {
        self.logMessage(message: message, level: .error)
    }
    
    func logMessage(message: String, level: LogLevel) {
        self.queue.sync {
            if (currentLogLevel.rawValue <= level.rawValue) {
                self.buffer(message: message)
                self.destination.handle(message: message)
            }
        }
    }
    
    let maxBufferSize = 10
    var messageBuffer: [String] = []
    
    func buffer(message: String) {
        if self.messageBuffer.count > self.maxBufferSize {
            self.messageBuffer.removeFirst()
        }
        self.messageBuffer.append(message)
    }
    
    // replays the most recent log messages
    // This is to capture early lifecycle messages that occur prior to the app rerouting messages.
    public func playbackBuffer() {
        self.queue.sync {
            for string in self.messageBuffer {
                self.destination.handle(message: string)
            }
        }
    }
    
    public func clearBuffer() {
        self.queue.sync {
            self.messageBuffer.removeAll()
        }
    }
}
