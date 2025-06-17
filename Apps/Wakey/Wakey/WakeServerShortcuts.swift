//
//  WakeServerShortcuts.swift
//  Wakey
//
//  Created by echo on 12/12/24.
//

import AppIntents

struct WakeServerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        
        // All the phrases need applicationName
        // Although these can be parameterized, I found it unreliable and I'm a native english speaker...
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
