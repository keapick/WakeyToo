//
//  WakeyDataStore.swift
//  WakeyLib
//
//  Created by echo on 12/1/24.
//

import Foundation
import SwiftData

/// Shared access to SwiftData from app and extensions
/// SwiftUI views can directly use the ModelContainer to get access to Query.
/// Other code can use the helper methods to handle CRUD operations.
public struct WakeyDataStore: Sendable {
    
    public static let shared = WakeyDataStore()
        
    // For direct access to the ModelContainer, allows SwiftUI Views to use Query
    public let container: ModelContainer
    
    public init() {
        self.container = WakeyDataStore.initModelContainer()
    }
    
    static func initModelContainer() -> ModelContainer {
        let schema = Schema([
            Server.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, migrationPlan: ServerMigrationPlan.self, configurations: [modelConfiguration])
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    public func create(_ server: Server) throws {
        // ModelContext is not Sendable, it is tied to the thread that created it.
        let context = ModelContext(container)
        context.insert(server)
        try context.save()
    }
    
    public func delete(_ server: Server) throws {
        let context = ModelContext(container)
        let id = server.persistentModelID
        try context.delete(model: Server.self, where: #Predicate<Server> { server in
            server.persistentModelID == id
        })
        try context.save()
    }
    
    // for app intents, suggested list
    public func fetchAllServers() throws -> [Server] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Server>(
            sortBy: [
                SortDescriptor(\.lastUsed, order: .reverse)
            ]
         )
        return try context.fetch(descriptor)
    }
    
    // for app intents
    public func fetchServer(id: UUID) throws -> Server? {
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<Server>(
            predicate: #Predicate<Server> { server in
                server.appEntityID == id
            }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
    
    // for quick actions
    public func fetchRecentServers() throws -> [Server] {
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<Server>(
            sortBy: [
                SortDescriptor(\.lastUsed, order: .reverse)
            ]
         )
        descriptor.fetchLimit = 3
        return try context.fetch(descriptor)
    }
    
    // for quick actions, it only provides the quick item title
    public func fetchServer(name: String) throws -> Server? {
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<Server>(
            predicate: #Predicate<Server> { server in
                server.name == name
            }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
    
}
