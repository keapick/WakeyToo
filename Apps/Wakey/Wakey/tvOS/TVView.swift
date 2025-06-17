//
//  TVView.swift
//  Wakey
//
//  Created by echo on 8/19/24.
//

import SwiftUI
import SwiftData
import WakeyLib

// tvOS main view
struct TVView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Server.lastUsed, order: .reverse) private var servers: [Server]
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var logWrapper = LoggerSwiftUI()
    
    var right: some View {
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
                    HStack {
                        if colorScheme == .light {
                            Image("LogoLight")
                        } else {
                            Image("LogoDark")
                        }
                        TVEditView()
                            .modelContext(modelContext)
                    }
                } label: {
                    Text("Add Server")
                }
            }
            
            Section("Log") {
                Text(logWrapper.text)
            }
            
            NavigationLink("Help") {
                HelpView()
            }
        }
        .navigationTitle("WakeyToo")
        .safeAreaPadding(.leading, 50)
    }
    
    var body: some View {
        NavigationStack {
            HStack {
                if colorScheme == .light {
                    Image("LogoLight")
                } else {
                    Image("LogoDark")
                }
                Spacer()
                right
            }
        }
    }
    
    private func debugServers() -> [Server] {
        return [
            Server(macAddress: "D8:BB:C1:8F:20:DB", name: "Squishy"),
            Server(macAddress: "44:8A:5B:5E:19:9B", name: "Variolite")
        ]
    }
}

#Preview {
    TVView()
        .modelContainer(for: Server.self, inMemory: true)
}
