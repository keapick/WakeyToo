//
//  ConfigTests.swift
//  EchoTests
//
//  Created by echo on 11/16/24.
//

import Testing
import Foundation

@testable import WakeyLib

struct ConfigTests {
    
    // In unit tests, the bundle is the one associated with the module
    func urlForConfig(named: String = "echo_config") -> URL? {
        if let url = Bundle.module.url(forResource: named, withExtension: "json") {
            return url
        }
        return nil
    }
    
    @Test func testURLForConfig() async throws {
        let url = urlForConfig()
        #expect(url != nil)
    }
    
    @Test func testLoadConfig() async throws {
        if let url = urlForConfig() {
            let config = Config(version: "1.0.0")
            let loaded = Config.loadConfig(from: url)
            
            #expect(config == loaded)
        } else {
            Issue.record("Could not find config URL")
        }
    }
    
    @Test func testConfigLoggingVerbose() async throws {
        if let url = urlForConfig(named: "echo_config_log_level"), let config = Config.loadConfig(from: url) {
            #expect(config.logLevel == .verbose)
        } else {
            Issue.record("Could not find config URL")
        }
    }
    
    // MARK: - Error paths (not exercised by the happy-path fixtures)

    private func tempConfigURL(_ contents: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("wakey-config-\(UUID().uuidString).json")
        try contents.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    @Test func testLoadConfigMalformedJSONReturnsNil() throws {
        let url = try tempConfigURL("{ this is not valid json ")
        #expect(Config.loadConfig(from: url) == nil)
    }

    @Test func testLoadConfigEmptyFileReturnsNil() throws {
        let url = try tempConfigURL("")
        #expect(Config.loadConfig(from: url) == nil)
    }

    @Test func testLoadConfigMissingVersionReturnsNil() throws {
        // version is a non-optional `let String`; an object lacking it fails to decode.
        let url = try tempConfigURL(#"{"logLevel": 0}"#)
        #expect(Config.loadConfig(from: url) == nil)
    }

    @Test func testLoadConfigInvalidLogLevelTypeReturnsNil() throws {
        // logLevel is Int-backed, so a JSON string fails to decode.
        let url = try tempConfigURL(#"{"version": "1.0.0", "logLevel": "verbose"}"#)
        #expect(Config.loadConfig(from: url) == nil)
    }

    @Test func testLoadConfigMissingFileReturnsNil() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("wakey-config-absent-\(UUID().uuidString).json")
        #expect(Config.loadConfig(from: url) == nil)
    }

    @Test func testDefaultConfigFallsBackToVersionOne() throws {
        // Whether or not the resource is found, the observable result is the fallback.
        #expect(Config.defaultConfig() == Config(version: "1.0.0"))
    }

    @Test func testLoadConfigValidRoundTripMapsLogLevel() throws {
        // logLevel 3 is .error (rawValue), confirming the int-backed mapping.
        let url = try tempConfigURL(#"{"version": "2.1.3", "logLevel": 3}"#)
        let loaded = Config.loadConfig(from: url)
        var expected = Config(version: "2.1.3")
        expected.logLevel = .error
        #expect(loaded == expected)
    }

    @Test func testConfigExtraFields() async throws {
        if let url = urlForConfig(named: "echo_config_unsupported_fields") {
            let rules = Config(version: "1.0.0")
            let loaded = Config.loadConfig(from: url)
            
            #expect(loaded == rules)
        } else {
            Issue.record("Could not find config URL")
        }
    }
}
