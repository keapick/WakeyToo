//
//  ContentView.swift
//  WakeyToo
//
//  Created by echo on 8/1/24.
//

import SwiftUI
import SwiftData
import WakeyLib

struct SettingsView: View {
    static let viewID: String = "settings-view"
    static let titleString = "WakeyToo, a Wake-on-LAN Utility"

    @State private var showingDialog = false
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Server.lastUsed, order: .reverse) private var servers: [Server]

    @ObservedObject private var logWrapper = LoggerSwiftUI()
    
    var body: some View {
        // A native macOS settings pane — a grouped form of sections — replacing the
        // hand-styled iOS "card" rows (rounded-gray border overlay + per-row padding)
        // this view used to render.
        Form {
            Section("Servers") {
                ForEach(servers) { server in
                    // Native row: name as the primary label, MAC address as secondary
                    // detail, and a trailing destructive remove control.
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(server.name)
                            Text(server.macAddress)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(role: .destructive) {
                            modelContext.delete(server)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }

                HStack {
                    Spacer()
                    Button {
                        showingDialog.toggle()
                    } label: {
                        Label("Add Server", systemImage: "plus")
                    }
                    .alert("New Server", isPresented: $showingDialog) {
                        EditView()
                            .modelContext(modelContext)
                    }
                    .dialogIcon(Image(systemName: "network"))
                }
            }
            .listRowSeparator(.hidden)

            Section("Log") {
                Text(logWrapper.text)
                Button("Clear", role: .destructive) {
                    logWrapper.removalAll()
                }
            }
            .listRowSeparator(.hidden)
        }
        .formStyle(.grouped)
        .frame(minWidth: 400, minHeight: 200)
        .navigationTitle(SettingsView.titleString)
    }
    
    private func debugServers() -> [Server] {
        return [
            Server(macAddress: "D8:BB:C1:8F:20:DB", name: "Blinky"),
            Server(macAddress: "44:8A:5B:5E:19:9B", name: "Variolite")
        ]
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: Server.self, inMemory: true)
}
