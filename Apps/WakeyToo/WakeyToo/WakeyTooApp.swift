//
//  WakeyTooApp.swift
//  WakeyToo
//
//  Created by echo on 8/1/24.
//

import SwiftUI
import SwiftData
import WakeyLib

@main
struct WakeyTooApp: App {
    var sharedModelContainer = WakeyDataStore.shared.container

    var body: some Scene {
        WindowGroup(id: SettingsView.viewID) {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
        .windowResizability(.contentSize)
        
        MenuBarExtra("WakeyToo", systemImage: "wake") {
            StatusMenuView()
                .modelContainer(sharedModelContainer)
        }
    }
}
