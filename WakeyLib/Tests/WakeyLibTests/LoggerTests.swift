//
//  LoggerTests.swift
//  EchoTests
//
//  Created by Ernest Cho on 4/20/24.
//

import XCTest
@testable import WakeyLib

// A deterministic destination that records everything it is handed.
// Logger routes through a serial queue via `sync`, so the recorded array is
// observable immediately after a logging call returns.
final class RecordingDestination: LogDestination {
    private(set) var messages: [String] = []
    func handle(message: String) {
        messages.append(message)
    }
    func clear() {
        messages.removeAll()
    }
}

final class LoggerTests: XCTestCase {

    // A fresh, hermetic Logger. Attaching a recorder keeps stdout quiet;
    // tests that assert on delivery re-point the destination to their own recorder.
    private func newLogger(level: LogLevel = .verbose) -> Logger {
        let logger = Logger()
        logger.setDestination(destination: RecordingDestination())
        logger.setLogLevel(logLevel: level)
        return logger
    }

    // MARK: - Level thresholding
    // A message is kept when `currentLogLevel.rawValue <= messageLevel.rawValue`
    // (verbose = 0, debug = 1, warning = 2, error = 3).

    func testAtVerboseEveryLevelIsRecorded() throws {
        let recorder = RecordingDestination()
        let logger = newLogger(level: .verbose)
        logger.setDestination(destination: recorder)

        logger.logVerbose(message: "verbose")
        logger.logDebug(message: "debug")
        logger.logWarning(message: "warning")
        logger.logError(message: "error")

        XCTAssertEqual(recorder.messages, ["verbose", "debug", "warning", "error"])
    }

    func testAtDebugVerboseIsSuppressed() throws {
        let recorder = RecordingDestination()
        let logger = newLogger(level: .debug)
        logger.setDestination(destination: recorder)

        logger.logVerbose(message: "verbose") // 0 filtered under debug (1)
        logger.logDebug(message: "debug")

        XCTAssertEqual(recorder.messages, ["debug"])
    }

    func testAtWarningVerboseAndDebugAreSuppressed() throws {
        let recorder = RecordingDestination()
        let logger = newLogger(level: .warning)
        logger.setDestination(destination: recorder)

        logger.logVerbose(message: "verbose")
        logger.logDebug(message: "debug")
        logger.logWarning(message: "warning")
        logger.logError(message: "error")

        XCTAssertEqual(recorder.messages, ["warning", "error"])
    }

    func testAtErrorOnlyErrorsAreRecorded() throws {
        let recorder = RecordingDestination()
        let logger = newLogger(level: .error)
        logger.setDestination(destination: recorder)

        logger.logWarning(message: "warning")
        logger.logError(message: "error")

        XCTAssertEqual(recorder.messages, ["error"])
    }

    func testSetLogLevelReclassesOnTheFly() throws {
        let recorder = RecordingDestination()
        let logger = newLogger(level: .error)
        logger.setDestination(destination: recorder)

        logger.logDebug(message: "debug") // filtered at .error
        XCTAssertEqual(recorder.messages, [])

        logger.setLogLevel(logLevel: .debug)
        logger.logDebug(message: "debug-2") // now passed through
        XCTAssertEqual(recorder.messages, ["debug-2"])
    }

    // MARK: - Ring buffer
    // The ring buffer caps at `maxBufferSize` (10): the oldest message is dropped
    // before a new one is appended, so it never holds more than the cap.
    func testRingBufferCapsAtMaxBufferSize() throws {
        let logger = newLogger(level: .verbose)
        for i in 0..<15 {
            logger.logVerbose(message: "m\(i)")
        }
        // Steady-state holds the last `maxBufferSize` messages, oldest first.
        XCTAssertEqual(logger.messageBuffer.count, 10)
        XCTAssertEqual(logger.messageBuffer,
                       ["m5", "m6", "m7", "m8", "m9", "m10", "m11", "m12", "m13", "m14"])
    }

    func testPlaybackReplaysOldestFirst() throws {
        let logger = newLogger(level: .verbose)
        logger.logVerbose(message: "first")
        logger.logVerbose(message: "second")
        logger.logVerbose(message: "third")

        let recorder = RecordingDestination()
        logger.setDestination(destination: recorder)
        logger.playbackBuffer()

        XCTAssertEqual(recorder.messages, ["first", "second", "third"])
    }

    func testClearBufferEmptiesAndStopsPlayback() throws {
        let logger = newLogger(level: .verbose)
        logger.logVerbose(message: "one")
        logger.logVerbose(message: "two")

        logger.clearBuffer()
        XCTAssertTrue(logger.messageBuffer.isEmpty)

        let recorder = RecordingDestination()
        logger.setDestination(destination: recorder)
        logger.playbackBuffer()
        XCTAssertTrue(recorder.messages.isEmpty)
    }
}
