//
//  ServerEntity.swift
//  Wakey
//
//  Created by echo on 12/12/24.
//

import AppIntents
import WakeyLib

// Merging the AppEntity with SwiftData seems ugly, lets just shadow the min data necessary for shortcuts.
struct ServerEntity: AppEntity, Identifiable {
    var id: UUID
    var name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Server"
    static let defaultQuery = ServerQuery()
}

struct ServerQuery: EntityQuery {
        
    func entities(for identifiers: [ServerEntity.ID]) async throws -> [ServerEntity] {
        var result = [ServerEntity]()
        for identifier in identifiers {
            if let server = try WakeyDataStore.shared.fetchServer(id: identifier) {
                result.append(ServerEntity(id: server.appEntityID, name: server.name))
            }
        }
        return result
    }
    
    func suggestedEntities() async throws -> [ServerEntity] {
        var result = [ServerEntity]()
        let servers = try WakeyDataStore.shared.fetchRecentServers()
        for server in servers {
            result.append(ServerEntity(id: server.appEntityID, name: server.name))
        }
        return result
    }
}
