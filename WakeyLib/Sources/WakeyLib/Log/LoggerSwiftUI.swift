//
//  LoggerSwiftUI.swift
//  WakeyLib
//
//  Created by echo on 6/4/24.
//

import Foundation

/// Helper class to get Logger to conform to ObservableObject for SwiftUI
/// For debug views.
@MainActor
public final class LoggerSwiftUI: ObservableObject, LogDestination {
    
    // ideally, this would be readonly, but I can't seem to get that to work
    @Published public var text: String = ""
    
    // line limit, makes it easier to read than a character limit
    // this version trades data duplication for simplicity
    public var maxLines = 10
    private var textLines: [String] = []
    
    public init() {
        Logger.shared.destination = self
        Logger.shared.playbackBuffer()
    }
    
    // incoming log messages can be from any thread, just fire and forget them
    public nonisolated func handle(message: String) {
        Task {
            await self.eventuallyHandle(message: message)
        }
    }
    
    private func eventuallyHandle(message: String) {
        self.textLines.append(message)
        if self.textLines.count > self.maxLines {
            self.textLines.removeFirst()
        }
        
        self.text = ""
        for line in self.textLines.reversed() {
            self.text.append(line)
            self.text.append("\n")
        }
    }
    
    public func removalAll() {
        
        // UI elements are cleared immediately on main
        self.text.removeAll()
        self.textLines.removeAll()
        
        // The backing Logger is scheduled to be cleared on a background queue
        Logger.shared.clearBuffer()
    }
}
