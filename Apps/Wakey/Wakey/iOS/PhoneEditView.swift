//
//  PhoneEditView.swift
//  Wakey
//
//  Created by echo on 12/11/24.
//

import SwiftUI
import WakeyLib

// iOS edit view
struct PhoneEditView: View {
    
    let server: Server?
    private var editorTitle: String {
        server == nil ? "Add Server" : "Edit Server"
    }
        
    @State private var macAddress = ""
    @State private var name = ""
    
    @State private var validMacAddress = false
    @State private var validName = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                    
                    TextField("Hardware or MAC Address", text: $macAddress)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }
                
                Section() {
                    if !validName {
                        Text("Name cannot be empty")
                            .foregroundColor(.red)
                    }
                    if !validMacAddress {
                        Text("Invalid MAC Address")
                            .foregroundColor(.red)
                    }
                }
            }
            .onChange(of: name) { oldValue, newValue in
                validName = WakeOnLAN.validate(name: newValue)
            }
            .onChange(of: macAddress) { oldValue, newValue in
                validMacAddress = WakeOnLAN.validate(macAddress: newValue)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        withAnimation {
                            save()
                            dismiss()
                        }
                    }
                    .disabled(!validName || !validMacAddress)
                }
            }
            .onAppear {
                if let server {
                    name = server.name
                    macAddress = server.macAddress
                }
            }
            .navigationTitle(editorTitle)
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
        
        if let server {
            server.name = name
            server.macAddress = macAddress
        } else {
            let newServer = Server(macAddress: macAddress, name: name)
            modelContext.insert(newServer)
            try? modelContext.save()
        }
        
        WakeServerShortcuts.updateAppShortcutParameters()
    }
}
