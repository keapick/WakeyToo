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
