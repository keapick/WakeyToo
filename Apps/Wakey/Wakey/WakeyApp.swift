//
//  WakeyApp.swift
//  Wakey
//
//  Created by echo on 7/3/24.
//

import SwiftUI
import SwiftData
import WakeyLib

@main
struct WakeyApp: App {
    var dataStore = WakeyDataStore.shared
    
    // used to enable quick actions
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
                case .background:
                    updateQuickActions()
                case .inactive:
                    break
                case .active:
                    break
                @unknown default:
                    break
            }
        }
        .modelContainer(dataStore.container)
    }
    
    // Quick Actions trades two touches for a long press. Basically a wash UX wise.
    // At least the logs show that a Magic Packet is sent.
    private func updateQuickActions() {
        #if !os(tvOS)
        var shortcutItems = [UIApplicationShortcutItem]()
        do {
            let servers = try dataStore.fetchRecentServers()
            for server in servers {
                shortcutItems.append(UIApplicationShortcutItem(type: "Wake", localizedTitle: "\(server.name)", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(systemImageName: "wake")))
            }
            UIApplication.shared.shortcutItems = shortcutItems
        } catch { }
        #endif
    }
}
