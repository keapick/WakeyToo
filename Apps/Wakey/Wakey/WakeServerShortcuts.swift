//
//  WakeServerShortcuts.swift
//  Wakey
//
//  Created by echo on 12/12/24.
//

import AppIntents

struct WakeServerShortcuts: AppShortcutsProvider {
    
    static var appShortcuts: [AppShortcut] {
        
        AppShortcut(
            intent: WakeServer(),
            phrases: [
                "Wake Server with \(.applicationName)",
                "Wake a Server with \(.applicationName)"
            ],
            shortTitle: "Wake a Server",
            systemImageName: "wake")
    }
}
