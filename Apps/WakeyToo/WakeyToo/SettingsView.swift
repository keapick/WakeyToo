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
    @State private var editingServer: Server? = nil
    @State private var deletingServer: Server? = nil

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
                    // detail, and a trailing edit / remove control for that server.
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(server.name)
                            Text(server.macAddress)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            editingServer = server
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .help("Edit this server")
                        Button(role: .destructive) {
                            deletingServer = server
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                        .help("Remove this server")
                    }
                }

                HStack {
                    Spacer()
                    Button {
                        showingDialog.toggle()
                    } label: {
                        Label("Add Server", systemImage: "plus")
                    }
                    .help("Add a new server")
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
        // Add a new server (server == nil) in a native sheet.
        .sheet(isPresented: $showingDialog) {
            EditView(server: nil)
                .modelContext(modelContext)
        }
        // Edit an existing server in place.
        .sheet(item: $editingServer) { server in
            EditView(server: server)
                .modelContext(modelContext)
        }
        // Confirm before a destructive remove so a one-tap delete can't nuke a
        // server on a typo.
        .confirmationDialog(
            Text("Remove \(deletingServer?.name ?? "this server")? This can't be undone."),
            isPresented: Binding(
                get: { deletingServer != nil },
                set: { active in
                    if !active { deletingServer = nil }
                }
            ),
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                if let server = deletingServer {
                    modelContext.delete(server)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
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
