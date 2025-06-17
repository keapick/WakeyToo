//
//  WakeOnLAN.swift
//  WakeyLib
//
//  Created by echo on 7/5/24.
//

import Foundation

public enum NetworkError: Error {
    case invalidMacAddress // fallure to read mac address
    
    // sendto errno codes
    case noRouteToHost // on iOS, this indicates a lack of network permission or entitlement
    case networkUnreachable // no connections found
    case cannotAssignRequestedAddress // no LAN connections found. Likely cell or public IP only
    case noSuchFileOrDirectory // on macOS 15+, this indicates a lack of network permission
    case socketFailue // catch all for any socket related error
}

public struct WakeOnLAN {
    
    // Wake on LAN is a fire and forget API, this just makes sure to update the last used timestamp
    public static func wakeServer(_ server: Server) {
        let address = server.macAddress
        DispatchQueue.global().async {
            WakeOnLAN.sendWakeOnLAN(macAddress: address, maxAttempts: 3)
        }
        server.lastUsed = Date.now
    }
    
    // quick actions helper method
    public static func wakeServerByName(_ name: String) {
        do {
            if let server = try WakeyDataStore.shared.fetchServer(name: name) {
                WakeOnLAN.wakeServer(server)
            } else {
                Logger.shared.logWarning(message: "Failed to find server with name: \(name)")
            }
        } catch { }
    }
    
    public static func validate(name: String) -> Bool {
        return (name.count > 0)
    }

    public static func validate(macAddress: String) -> Bool {
        guard macAddress.count == 17 || (macAddress.count == 12 && !containsSeparators(macAddress)) else {
            return false
        }
        
        // scanner.scanHexInt64 ignores overflow...
        let charset = "0123456789abcdefABCDEF:-"
        for char in macAddress {
            if !charset.contains(char) {
                return false
            }
        }
        
        let cleanMacAddress = sanitizeMacAddress(macAddress)
        do {
            let works = try WakeOnLAN.readMacAddressFrom(hexString: cleanMacAddress)
            if works.count == 6 {
                return true
            }
        } catch { }
        
        Logger.shared.logWarning(message: "Invalid MAC address, ignoring")
        return false
    }
    
    static func containsSeparators(_ string: String) -> Bool {
        return string.contains("-") || string.contains(":")
    }
    
    /// Adds separators to strings that lack them, improves usability
    static func sanitizeMacAddress(_ string: String) -> String {
        if string.count == 17 {
            return string
        }
        
        var sanitized = ""
        for (index, character) in string.enumerated() {
            sanitized.append(character)
            if (index+1) % 2 == 0 && index != string.count-1 {
                sanitized.append(":")
            }
        }
        
        return sanitized
    }
    
    /// Converts a mac address hex string to a UInt8 buffer. Assumes hexString is properly formatted with separators!
    /// Similar to C's sscanf
    static func readMacAddressFrom(hexString: String) throws -> [UInt8] {
        
        // Copy hexString into [UInt64]
        let scanner = Scanner(string: hexString)
        scanner.caseSensitive = false
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: ":-")
        
        let macAddressSize = 6
        let macAddress = UnsafeMutablePointer<UInt64>.allocate(capacity: macAddressSize)
        defer {
            macAddress.deallocate()
        }
        
        for i in 0...5 {
            let offsetPointer = macAddress + i
            let status = scanner.scanHexInt64(offsetPointer)
            
            if (!status) {
                throw NetworkError.invalidMacAddress
            }
        }
        
        // Copy from [UInt64] to [UInt8]
        let uInt64Array = Array(UnsafeBufferPointer(start:macAddress, count:macAddressSize))
        let uInt8Array: [UInt8] = uInt64Array.map { uInt64 in
            UInt8(truncatingIfNeeded: uInt64)
        }
        
        return uInt8Array
    }
    
    // macOS Sequoia's Local network permission handler does not initialize very quickly, I need to retry errors
    // This method blocks the thread! Only call from a background threads and treat as fire and forget!
    // https://developer.apple.com/forums/thread/765513
    // TODO: migrate this to Swift Concurrency?
    static func sendWakeOnLAN(macAddress: String, maxAttempts: Int) {
        var success = false
        var attemptCount = 0
        
        while attemptCount < maxAttempts, !success {
            
            // only sleep if this isn't the first attempt
            if attemptCount > 0 {
                Logger.shared.logWarning(message: "Will retry in 2 seconds")
                Thread.sleep(forTimeInterval: 2)
            }
            
            // attempt wake on lan
            do {
                try sendWakeOnLAN(macAddress: macAddress)
                success = true
            } catch {
                attemptCount += 1
            }
        }
        
        if !success {
            Logger.shared.logError(message: "Failed to send magic packet to \(macAddress) after \(maxAttempts) attempts.")
        }
    }
    
    static func sendWakeOnLAN(macAddress: String) throws {
        let udpSocket = try self.setupSocket()
        
        // rebind sockaddr_in to sockaddr, then call bind
        var udpClient = self.setupUDPClient()
        let clientBindStatus = withUnsafePointer(to: &udpClient) { sockAddressIn in
            sockAddressIn.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockAddress in
                bind(udpSocket, sockAddress, socklen_t(MemoryLayout<sockaddr_in>.stride))
            }
        }
        guard clientBindStatus != -1 else {
            throw NetworkError.socketFailue
        }
        
        let magicPacket = try self.createMagicPackageFor(macAddress: macAddress)
        let packetSize = magicPacket.count
        
        // rebind sockaddr_in to sockaddr, then call sendto
        var udpServer = self.setupUDPServer()
        let sendStatus = withUnsafePointer(to: &udpServer) { sockAddressIn in
            sockAddressIn.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockAddress in
                sendto(udpSocket, magicPacket, packetSize, 0, sockAddress, socklen_t(MemoryLayout<sockaddr_in>.stride))
            }
        }
        
        if sendStatus == 102 {
            Logger.shared.logVerbose(message: "Wake \(macAddress) at \(Date.now.formatted(date: .omitted, time: .standard)). status: OK")
        } else {
            Logger.shared.logVerbose(message: "Wake \(macAddress) at \(Date.now.formatted(date: .omitted, time: .standard)). status: \(sendStatus) errno:\(errno)")
        }
        
        guard sendStatus != -1 else {
            if errno == 65 {
                // 65 no route to host.
                // The app probably does NOT have multicasting entitlement, which is required on iOS.
                Logger.shared.logVerbose(message: "No route to host. Have you granted network permission?")
                throw NetworkError.noRouteToHost
            } else if errno == 51 {
                // 51 network unreachable
                // The app has no active network connection.
                Logger.shared.logVerbose(message: "Nework Unreachable. Are you offline?")
                throw NetworkError.networkUnreachable
            } else if errno == 49 {
                // 49 can't assign requested address.
                Logger.shared.logVerbose(message: "Can't assign requested address. Are you on cellular only?")
                throw NetworkError.cannotAssignRequestedAddress
            } else if errno == 2 {
                // 2 no such file or directory
                // macOS 15+ will report this until network permission is granted
                Logger.shared.logVerbose(message: "No such file or directory. Have you granted network permission?")
                throw NetworkError.noSuchFileOrDirectory
            } else {
                // errno is global, so there's a chance it was overwritten by a different system call failure
                // https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20161031/028627.html
                Logger.shared.logVerbose(message: "Unexpected errno: \(errno). There is a known issue with Swift and errno, so this could be misleading.")
                throw NetworkError.socketFailue
            }
        }
    }
    
    static func setupSocket() throws -> Int32 {
        let udpSocket = socket(AF_INET, SOCK_DGRAM, 0)
        guard udpSocket != -1 else {
            throw NetworkError.socketFailue
        }
        
        // In C it's just "int broadcast = 1;"
        let broadcast = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        defer {
            broadcast.deallocate()
        }
        broadcast.pointee = 1
        
        // SO_BROADCAST works on both IPv4 and IPv6
        let broadcastSetupStatus = setsockopt(udpSocket, SOL_SOCKET, SO_BROADCAST, broadcast, socklen_t(MemoryLayout<Int32>.size))
        guard broadcastSetupStatus != -1 else {
            throw NetworkError.socketFailue
        }
        
        return udpSocket
    }
    
    static func setupUDPClient() -> sockaddr_in {
        var socketAddressIn = sockaddr_in()
        socketAddressIn.sin_family = UInt8(truncatingIfNeeded: AF_INET)
        socketAddressIn.sin_addr.s_addr = INADDR_ANY
        socketAddressIn.sin_port = 0
        return socketAddressIn
    }
    
    static func setupUDPServer() -> sockaddr_in {
        var socketAddressIn = sockaddr_in()
        socketAddressIn.sin_family = UInt8(truncatingIfNeeded: AF_INET)
        socketAddressIn.sin_addr.s_addr = INADDR_BROADCAST
        socketAddressIn.sin_port = UInt16(truncatingIfNeeded: 9).bigEndian
        return socketAddressIn
    }
    
    // create magic packet for wake on lan
    static func createMagicPackageFor(macAddress: String) throws -> [UInt8] {
        let macAddress: [UInt8] = try self.readMacAddressFrom(hexString: sanitizeMacAddress(macAddress))
        let magicPacketSize = 102
        let magicPacket = UnsafeMutablePointer<UInt8>.allocate(capacity: magicPacketSize)
        defer {
            magicPacket.deallocate()
        }
        
        // 6 copies of 0xFF
        for i in 0...5 {
            let offsetPointer = magicPacket + i
            offsetPointer.pointee = UInt8(truncatingIfNeeded: 0xFF)
        }

        // 16 copies of the mac address
        let macAddressStart = magicPacket + 6
        for i in 0...15 {
            for j in 0...5 {
                let offsetPointer = macAddressStart + (i * 6) + j
                offsetPointer.pointee = macAddress[j]
            }
        }
        
        // I believe this does NOT copy the actual buffer, but should probably confirm
        let uInt8Array = Array(UnsafeBufferPointer(start:magicPacket, count:magicPacketSize))
        return uInt8Array
    }
}
