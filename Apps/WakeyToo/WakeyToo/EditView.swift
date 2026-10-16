//
//  EditView.swift
//  WakeyToo
//
//  Created by echo on 12/7/24.
//

import SwiftUI
import SwiftData
import WakeyLib

// Editor for a server entry. With `server == nil` it adds a new server; with a
// `server` supplied it edits that one in place (pre-filled on open).
struct EditView: View {
    let server: Server?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var macAddress = ""
    @State private var name = ""
    @State private var validMacAddress = false
    @State private var validName = false
    @State private var errorMessage: String?

    private var editorTitle: String {
        server == nil ? "Add Server" : "Edit Server"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Server") {
                    TextField("Name", text: $name)
                    TextField("Hardware or MAC Address", text: $macAddress)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Button("Save", action: save)
                            .disabled(!validName || !validMacAddress)
                            .keyboardShortcut(.defaultAction)
                        Button("Cancel", role: .cancel) {
                            dismiss()
                        }
                        .keyboardShortcut(.cancelAction)
                    }
                }
            }
            .frame(width: 340)
            .navigationTitle(editorTitle)
            .onAppear {
                // When editing, pre-fill the fields from the server. Those values
                // were validated when created/saved, so mark them valid too so
                // Save is enabled immediately.
                if let server {
                    name = server.name
                    macAddress = server.macAddress
                    validName = true
                    validMacAddress = true
                }
            }
            .onChange(of: name) { oldValue, newValue in
                validName = WakeOnLAN.validate(name: newValue)
            }
            .onChange(of: macAddress) { oldValue, newValue in
                validMacAddress = WakeOnLAN.validate(macAddress: newValue)
            }
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

        // macAddress is @Attribute(.unique), so a clash would make save() throw
        // (the old `try?` swallowed it). Detect it up front so the user learned
        // why it failed instead of it failing silently. For an edit, only a
        // *different* server counts as a clash — the one being edited is allowed
        // to keep its own address.
        let allServers = try? modelContext.fetch(FetchDescriptor<Server>())
        var clash = false
        if let allServers {
            if let server {
                clash = allServers.contains { $0 !== server && $0.macAddress == macAddress }
            } else {
                clash = allServers.contains { $0.macAddress == macAddress }
            }
        }
        if clash {
            errorMessage = "A server with that MAC address already exists."
            return
        }

        do {
            if let server {
                // Update the existing server in place.
                server.name = name
                server.macAddress = macAddress
            } else {
                // Insert a new server.
                let newServer = Server(macAddress: macAddress, name: name)
                modelContext.insert(newServer)
            }
            try modelContext.save()
            dismiss()
        } catch let error {
            // Backstop for any other save failure: the real reason is logged so it
            // isn't lost, while the UI shows a generic, recoverable message.
            Logger.shared.logWarning(message: "Save failed: \(error)")
            errorMessage = "Couldn't save the server. Please try again."
        }
    }
}


#Preview {
    // Add mode: no server to pre-fill from.
    EditView(server: nil)
        .modelContainer(for: Server.self, inMemory: true)
}
