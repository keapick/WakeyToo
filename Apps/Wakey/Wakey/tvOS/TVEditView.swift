//
//  TVEditView.swift
//  Wakey
//
//  Created by echo on 12/11/24.
//

import SwiftUI
import WakeyLib

struct TVEditView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var macAddress = ""
    @State private var name = ""
    @State private var validMacAddress = false
    @State private var validName = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            HStack {
                TextField("Name", text: $name)
                if !validName {
                    Spacer()
                    Text("Name cannot be empty")
                        .foregroundColor(.red)
                }
            }
            HStack {
                TextField("Hardware or MAC Address", text: $macAddress)
                if !validMacAddress {
                    Spacer()
                    Text("Invalid MAC Address")
                        .foregroundColor(.red)
                }
            }
            
            Button("Save", action: save)
                .disabled(!validName || !validMacAddress)
        }
        .onChange(of: name) { oldValue, newValue in
            validName = WakeOnLAN.validate(name: name)
        }
        .onChange(of: macAddress) { oldValue, newValue in
            validMacAddress = WakeOnLAN.validate(macAddress: newValue)
        }
        .navigationTitle("Add Server")
        .safeAreaPadding(.leading, 50)
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
        
        WakeServerShortcuts.updateAppShortcutParameters()
        
        dismiss()
    }
}
