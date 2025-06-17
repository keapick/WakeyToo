//
//  WakeOnLANTests.swift
//  WakeyLibTests
//
//  Created by echo on 7/6/24.
//

import XCTest
@testable import WakeyLib

final class WakeOnLANTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testValidMacAddress() throws {
        // valid formats
        XCTAssertTrue(WakeOnLAN.validate(macAddress: "44-8A-5B-5E-19-9B"))
        XCTAssertTrue(WakeOnLAN.validate(macAddress: "44:8A:5B:5E:19:9B"))
        XCTAssertTrue(WakeOnLAN.validate(macAddress: "448A5B5E199B"))

        // invalid formats
        XCTAssertFalse(WakeOnLAN.validate(macAddress: "44_8A_5B_5E_19_9B")) // wrong separator
        XCTAssertFalse(WakeOnLAN.validate(macAddress: "44:8A:5B:5E:19")) // not enough chars
        XCTAssertFalse(WakeOnLAN.validate(macAddress: "448A5B5E19")) // not enough cars
        XCTAssertFalse(WakeOnLAN.validate(macAddress: "44:8A:5B:5E:19:9G")) // overflow
    }
    
    func testReadMacAddressBlinky() throws {
        let expected: [UInt8] = [216, 187, 193, 143, 32, 219]
        let actual = try WakeOnLAN.readMacAddressFrom(hexString: "D8-BB-C1-8F-20-DB")
        
        XCTAssertTrue(expected.count == actual.count)
        XCTAssertTrue(expected.elementsEqual(actual))
    }
    
    func testReadMacAddressColon() throws {
        let expected: [UInt8] = [68, 138, 91, 94, 25, 155]
        // Linux uses : as a separator
        let actual = try WakeOnLAN.readMacAddressFrom(hexString: "44:8A:5B:5E:19:9B")

        XCTAssertTrue(expected.count == actual.count)
        XCTAssertTrue(expected.elementsEqual(actual))
    }
    
    func testReadMacAddressDash() throws {
        let expected: [UInt8] = [68, 138, 91, 94, 25, 155]
        // Windows uses - as a separator
        let actual = try WakeOnLAN.readMacAddressFrom(hexString: "44-8A-5B-5E-19-9B")

        XCTAssertTrue(expected.count == actual.count)
        XCTAssertTrue(expected.elementsEqual(actual))
    }
    
    // scanner ignores overflow! validator needs to block this!
    func testReadMacAddressIgnoresOverflow() throws {
        let expected: [UInt8] = [68, 138, 91, 94, 25, 9]
        let actual = try WakeOnLAN.readMacAddressFrom(hexString: "44-8A-5B-5E-19-9S")

        XCTAssertTrue(expected.count == actual.count)
        XCTAssertTrue(expected.elementsEqual(actual))
    }
    
    // User requested support for omitting the separator
    // This converts a string into a hexString.
    func testSanitizeMacAddressVariliteNoSeparator() throws {
        let expected = "44:8A:5B:5E:19:9B"
        let actual = WakeOnLAN.sanitizeMacAddress("448A5B5E199B")
        
        XCTAssertTrue(expected == actual)
    }
    
    func testInvalidMacAddressNonsense() throws {
        do {
            _ = try WakeOnLAN.readMacAddressFrom(hexString: "helloworld")
            XCTFail()
        } catch NetworkError.invalidMacAddress {
            // Pass if we get the expected error
        } catch {
            XCTFail()
        }
    }
    
    func testInvalidMacAddressTruncated() throws {
        do {
            _ = try WakeOnLAN.readMacAddressFrom(hexString: "44:8A:5B:5E:19")
            XCTFail()
        } catch NetworkError.invalidMacAddress {
            // Pass if we get the expected error
        } catch {
            XCTFail()
        }
    }

    func testMagicPacket() throws {
        let expected: [UInt8] = [
            255, 255, 255, 255, 255, 255,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155,
            68, 138, 91, 94, 25, 155
        ]
        let actual = try WakeOnLAN.createMagicPackageFor(macAddress: "44:8A:5B:5E:19:9B")

        XCTAssertTrue(expected.count == actual.count)
        XCTAssertTrue(expected.elementsEqual(actual))
    }
}
