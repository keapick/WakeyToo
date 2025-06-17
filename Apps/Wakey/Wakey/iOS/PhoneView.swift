//
//  PhoneView.swift
//  Wakey
//
//  Created by echo on 8/19/24.
//

import SwiftUI
import SwiftData
import WakeyLib

// iOS main view
struct PhoneView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Server.lastUsed, order: .reverse) private var servers: [Server]

    @ObservedObject private var logWrapper = LoggerSwiftUI()
    
    var body: some View {
        NavigationStack {
            List {
                Section("Servers") {
                    if !servers.isEmpty {
                        ForEach(servers) { server in
                            Button {
                                WakeOnLAN.wakeServer(server)
                            } label: {
                                Text("\(server.name)")
                            }
                            .contextMenu {
                                NavigationLink {
                                    PhoneEditView(server: server)
                                } label: {
                                    Text("Edit")
                                }
                                Button(role: .destructive) {
                                    withAnimation {
                                        modelContext.delete(server)
                                    }
                                } label: {
                                    Text("Delete")
                                }
                            }
                        }
                    }
                    NavigationLink {
                        PhoneEditView(server: nil)
                    } label: {
                        Text("Add Server")
                    }
                }
                Section("Log") {
                    Text(logWrapper.text)
                    Button("Clear Log") {
                        logWrapper.removalAll()
                    }
                }
            }
            .toolbar {
                Link("Help", destination: URL(string: "https://ieesizaq.com/wakeytoo/")!)
            }
            .navigationTitle("WakeyToo")
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
    PhoneView()
        .modelContainer(for: Server.self, inMemory: true)
}
