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
    @State private var serverBeingEdited: Server? = nil
    @State private var editSessionID = UUID()
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Server.lastUsed, order: .reverse) private var servers: [Server]

    @ObservedObject private var logWrapper = LoggerSwiftUI()
    
    var body: some View {
        VStack {
            List {
                Section("Servers") {
                    ForEach(servers) { server in
                        VStack {
                            HStack {
                                Text(server.name)
                                Spacer()
                            }
                            HStack {
                                Text(server.macAddress)
                                Spacer()
                                Button("Edit") {
                                    serverBeingEdited = server
                                    editSessionID = UUID()
                                    showingDialog = true
                                }
                                Button("Remove", role: .destructive) {
                                    modelContext.delete(server)
                                }
                            }
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    Button("Add Server") {
                        serverBeingEdited = nil
                        editSessionID = UUID()
                        showingDialog = true
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
            .alert(serverBeingEdited == nil ? "New Server" : "Edit Server", isPresented: $showingDialog) {
                EditView(serverToEdit: serverBeingEdited)
                    .id(editSessionID)
                    .modelContext(modelContext)
            }
            .dialogIcon(Image(systemName: "network"))
        }
        .frame(minWidth: 400, maxWidth: 400, minHeight: 200, maxHeight: .infinity)
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
