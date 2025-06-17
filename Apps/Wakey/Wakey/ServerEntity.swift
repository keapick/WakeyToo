//
//  ServerEntity.swift
//  Wakey
//
//  Created by echo on 12/12/24.
//

import AppIntents
import WakeyLib

struct ServerEntity: AppEntity, Identifiable {
    var id: UUID
    var name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Server"
    static var defaultQuery = ServerQuery()
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
