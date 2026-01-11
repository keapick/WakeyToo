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
    
    // TODO: redesign this, don't even get a chance to match the server name
    @Parameter(title: "Server to Wake", description: "Server to Wake")
    var serverEntity: ServerEntity
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        // first try by id, then try best attempt phonetic spelling match
        if let server = try WakeyDataStore.shared.fetchServer(id: serverEntity.id) {
            WakeOnLAN.wakeServer(server)
        } else {
            
            let servers = try WakeyDataStore.shared.fetchAllServers()
            let serverNames = Array(servers.map(\.name))
            
            if let best = serverEntity.name.bestPhoneticMatch(in: serverNames) {
                if let server = try WakeyDataStore.shared.fetchServer(name: best) {
                    WakeOnLAN.wakeServer(server)
                }
            }
        }
        
        return .result(
            dialog: "Okay, sending a magic packet to \(serverEntity.name)."
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Wake \(\.$serverEntity)")
    }
    
    init() {}
    
    init(serverEntity: ServerEntity) {
        self.serverEntity = serverEntity
    }
}

