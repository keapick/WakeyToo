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
    init() {
        // Keep the menu bar to a single "wake" icon: refuse to run while another
        // instance of this app is already live on this machine (e.g. a Login-Items
        // launch while an Xcode re-run starts, or a double-click). We filter out
        // ourselves so the check only counts *other* copies already registered with
        // LaunchServices — robust even if this new process isn't registered yet.
        if let bundleID = Bundle.main.bundleIdentifier {
            let others = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
                .filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
            if !others.isEmpty {
                exit(0)
            }
        }
    }

    var sharedModelContainer = WakeyDataStore.shared.container

    var body: some Scene {
        Settings {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
        
        MenuBarExtra("WakeyToo", systemImage: "wake") {
            StatusMenuView()
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.menu)
    }
}
