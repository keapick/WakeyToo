//
//  WakeOnLANIntegrationTests.swift
//  EchoUtilityTests
//
//  Created by echo on 7/6/24.
//

import XCTest
@testable import Echo

// These tests only work when hosted in an app with Multicasting permission
final class WakeOnLANIntegrationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // This will send the magic packet to Squishy
    func testWakeSquishy() throws {
        do {
            try NetworkTools.sendWakeOnLAN(macAddress: "D8:BB:C1:8F:20:DB")
        } catch {
            XCTFail()
        }
    }
    
    // This will send the magic packet to Variolite
    func testWakeVariolite() throws {
        do {
            try NetworkTools.sendWakeOnLAN(macAddress: "44:8A:5B:5E:19:9B")
        } catch {
            XCTFail()
        }
    }
    
    // TODO: Tests for different device and environment configurations. I don't have access to an IPv6 LAN
    // 1. No connectivity
    // 2. Cellular only - does not support Broadcast
    // 3. IPv4 LAN - this is my home LAN
    // 4. IPv6 LAN
    // 5. IPv4 and IPv6 LAN
}
