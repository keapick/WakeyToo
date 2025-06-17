//
//  Server.swift
//  WakeyLib
//
//  Created by echo on 7/3/24.
//

import Foundation
import SwiftData

// Apple hasn't made this Swift 6 compatible yet
// https://developer.apple.com/forums/thread/756802
extension MigrationStage: @unchecked @retroactive Sendable { }
extension Schema.Version: @unchecked @retroactive Sendable { }

public typealias Server = ServerVersionSchemaV2.Server

enum ServerMigrationPlan: SchemaMigrationPlan {
    
    static var schemas: [any VersionedSchema.Type] {
        [ServerVersionSchemaV1.self, ServerVersionSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: ServerVersionSchemaV1.self,
        toVersion: ServerVersionSchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            let servers = try context.fetch(FetchDescriptor<ServerVersionSchemaV2.Server>())
            for server in servers {
                //print("Before: \(server.appEntityID)")
                server.appEntityID = UUID()
                //print("After: \(server.appEntityID)")
            }
            try? context.save()
        }
    )
}

public enum ServerVersionSchemaV1: VersionedSchema {
    public static var versionIdentifier: Schema.Version {
        return Schema.Version(1, 0, 0)
    }
    
    public static var models: [any PersistentModel.Type] {
        [Server.self]
    }
    
    @Model
    public final class Server {
        @Attribute(.unique) public var macAddress: String
        public var name: String
        
        // sort by most recently accessed
        public var lastUsed: Date?
        
        public init(macAddress: String, name: String) {
            self.macAddress = macAddress
            self.name = name
        }
    }
}

// App Intents require a UUID and lightweight migration does NOT populate them correctly
public enum ServerVersionSchemaV2: VersionedSchema {
    public static var versionIdentifier: Schema.Version {
        return Schema.Version(2, 0, 0)
    }
    
    public static var models: [any PersistentModel.Type] {
        [Server.self]
    }
    
    @Model
    public final class Server {
        @Attribute(.unique) public var macAddress: String
        public var name: String
        
        // App Intents require a UUID
        public var appEntityID: UUID = UUID()
        
        // sort by most recently accessed
        public var lastUsed: Date?
        
        public init(macAddress: String, name: String) {
            self.macAddress = macAddress
            self.name = name
        }
    }
}
