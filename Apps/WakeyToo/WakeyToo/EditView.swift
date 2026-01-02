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
    @Environment(\.dismiss) private var dismiss
    
    var serverToEdit: Server?
    
    @State private var macAddress = ""
    @State private var name = ""
    @State private var validMacAddress = false
    @State private var validName = false
    
    init(serverToEdit: Server? = nil) {
        self.serverToEdit = serverToEdit
        _macAddress = State(initialValue: serverToEdit?.macAddress ?? "")
        _name = State(initialValue: serverToEdit?.name ?? "")
        _validMacAddress = State(initialValue: serverToEdit.map { WakeOnLAN.validate(macAddress: $0.macAddress) } ?? false)
        _validName = State(initialValue: serverToEdit.map { WakeOnLAN.validate(name: $0.name) } ?? false)
    }
    
    private func populateFromServer() {
        if let server = serverToEdit {
            name = server.name
            macAddress = server.macAddress
            validName = WakeOnLAN.validate(name: server.name)
            validMacAddress = WakeOnLAN.validate(macAddress: server.macAddress)
        } else {
            name = ""
            macAddress = ""
            validName = false
            validMacAddress = false
        }
    }
    
    var body: some View {
        Form {
            Section() {
                TextField("Name", text: $name)
                TextField("Hardware or MAC Address", text: $macAddress)
            }
            
            Button("Save", action: save)
                .disabled(!validName || !validMacAddress)
            
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        }
        .onChange(of: name) { oldValue, newValue in
            validName = WakeOnLAN.validate(name: newValue)
        }
        .onChange(of: macAddress) { oldValue, newValue in
            validMacAddress = WakeOnLAN.validate(macAddress: newValue)
        }
        .onAppear {
            populateFromServer()
        }
        .onChange(of: serverToEdit?.appEntityID) { _, _ in
            populateFromServer()
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
        
        if let server = serverToEdit {
            server.name = name
            server.macAddress = macAddress
        } else {
            let newServer = Server(macAddress: macAddress, name: name)
            modelContext.insert(newServer)
        }
        
        try? modelContext.save()
        dismiss()
    }
}


#Preview {
    EditView()
        .modelContainer(for: Server.self, inMemory: true)
}

