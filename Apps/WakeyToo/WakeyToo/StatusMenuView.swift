//
//  StatusView.swift
//  WakeyToo
//
//  Created by echo on 8/2/24.
//

import SwiftUI
import SwiftData
import WakeyLib

struct StatusMenuView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Server.lastUsed, order: .reverse) private var servers: [Server]
            
    var body: some View {
        
        ForEach(servers) { server in
            Button {
                WakeOnLAN.wakeServer(server)
            } label: {
                HStack {
                    Text("\(server.name)")
                }
            }
        }
        
        Divider()
        Button("Settings...") {
            
            // Focus existing window, the new version does not work reliably on macOS Sequoia
            NSApp.activate()
            NSApplication.shared.activate(ignoringOtherApps: true)
            
            // Prevent opening extra settings windows
            if !NSApplication.shared.windows.contains(where: { $0.title == SettingsView.titleString}) {
                openWindow(id: SettingsView.viewID)
            }
        }
        
        Link("Help", destination: URL(string: "https://ieesizaq.com/wakeytoo/")!)
        Divider()
        Button("Quit WakeyToo") {
            NSApplication.shared.terminate(nil)
        }
    }
}

#Preview {
    StatusMenuView()
        .modelContainer(for: Server.self, inMemory: true)
}
