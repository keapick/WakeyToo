//
//  WakeServer.swift
//  Wakey
//
//  Created by echo on 12/12/24.
//

import SwiftUI
import AppIntents
import WakeyLib

// AppIntent for Shortcuts support
struct WakeServer: AppIntent {
    static var openAppWhenRun: Bool = false
    
    static var title: LocalizedStringResource = "Wake server"
    static var description = IntentDescription("Wakes a server with a Magic Packet")
    
    @Parameter(title: "Server to Wake", description: "Server to Wake")
    var serverEntity: ServerEntity
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        var wokenServerName: String? = nil
        
        // first try by id (Exact match/Existing Shortcut)
        if let server = try WakeyDataStore.shared.fetchServer(id: serverEntity.id) {
            WakeOnLAN.wakeServer(server)
            wokenServerName = server.name
        } else {
            // Fallback: Fuzzy match on the name Siri passed (Synthetic Entity)
            let servers = try WakeyDataStore.shared.fetchAllServers()
            let serverNames = servers.map(\.name)
            
            if let bestMatchName = serverEntity.name.bestPhoneticMatch(in: serverNames),
               let server = try WakeyDataStore.shared.fetchServer(name: bestMatchName) {
                WakeOnLAN.wakeServer(server)
                wokenServerName = server.name
            }
        }
        
        if let name = wokenServerName {
            return .result(
                dialog: "Okay, sending a magic packet to \(name)."
            )
        } else {
            return .result(
                dialog: "I couldn't find a server matching \(serverEntity.name)."
            )
        }
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Wake \(\.$serverEntity)")
    }
    
    init() {}
    
    init(serverEntity: ServerEntity) {
        self.serverEntity = serverEntity
    }
}
