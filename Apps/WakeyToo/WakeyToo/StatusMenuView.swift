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
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openSettings) private var openSettings
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
        Button("Settings…") {
            // The agent (LSUIElement) app isn't the active app, so without an
            // explicit nudge its window opens behind the frontmost window.
            // Activate first, then present; the single-instance Settings scene
            // means openSettings() can't spawn a duplicate window.
            NSApp.activate(ignoringOtherApps: true)
            openSettings()
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
