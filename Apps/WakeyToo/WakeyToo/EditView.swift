//
//  EditView.swift
//  WakeyToo
//
//  Created by echo on 12/7/24.
//

import SwiftUI
import WakeyLib

struct EditView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var macAddress = ""
    @State private var name = ""
    @State private var validMacAddress = false
    @State private var validName = false
    
    var body: some View {
        Form {
            Section() {
                TextField("Name", text: $name)
                TextField("Hardware or MAC Address", text: $macAddress)
            }
            
            Button("Save", action: save)
                .disabled(!validName || !validMacAddress)
            
            Button("Cancel", role: .cancel) {
                validName = false
                validMacAddress = false
            }
        }
        .onChange(of: name) { oldValue, newValue in
            validName = WakeOnLAN.validate(name: newValue)
        }
        .onChange(of: macAddress) { oldValue, newValue in
            validMacAddress = WakeOnLAN.validate(macAddress: newValue)
        }
    }
    
    private func save() {
        guard WakeOnLAN.validate(name: name) else {
            Logger.shared.logWarning(message: "Invalid server name, ignoring")
            return
        }
        guard WakeOnLAN.validate(macAddress: macAddress) else {
            Logger.shared.logWarning(message: "Invalid MAC address, ignoring")
            return
        }
        
        let newServer = Server(macAddress: macAddress, name: name)
        modelContext.insert(newServer)
        try? modelContext.save()
    }
}


#Preview {
    EditView()
        .modelContainer(for: Server.self, inMemory: true)
}
