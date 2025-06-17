//
//  Config.swift
//  WakeyLib
//
//  Created by echo on 11/16/24.
//

import Foundation

/*
 * JSONEncoder and JSONDecoder do not honor the default values in a Codable.
 * If fields are required, then they must be present in the JSON. This leads to unnecessarily strict and verbose JSON.
 * If fields are optional, then there will be extraneous boilerplate code to deal with nullable fields.
 *
 * Workaround using a DTO with all optional fields. Another option is to implement your own Decodable methods.
 */
struct ConfigDTO: Codable, Equatable {
    let version: String
    var logLevel: LogLevel?
}

// JSON config file to control behavior of this library
// Helpful when supporting platforms such as React Native, Unity or handling early lifecycle events
public struct Config: Equatable {
        
    public let version: String
    public var logLevel: LogLevel = .debug
    
    init(version: String) {
        self.version = version
    }
    
    init(from dto: ConfigDTO) {
        self.version = dto.version
        if let logLevel = dto.logLevel {
            self.logLevel = logLevel
        }
    }

    // unit tests do not store resources in the main bundle, use the module bundle instead
    public static func defaultConfig() -> Config {
        if let url = Bundle.main.url(forResource: "echo_config", withExtension: "json") {
            if let config = loadConfig(from: url) {
                return config
            }
        }
        return Config(version: "1.0.0")
    }
    
    static func loadConfig(from fileURL: URL) -> Config? {
        do {
            let data = try Data(contentsOf: fileURL)
            let dto = try JSONDecoder().decode(ConfigDTO.self, from: data)
            return Config(from: dto)
        } catch {
            Logger.shared.logError(message:"Failed to load config: \(error)")
        }
        return nil
    }
}
