//
//  TVHelpView.swift
//  Wakey
//
//  Created by echo on 12/11/24.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack() {
            HStack() {
                Spacer()
                Text("https://ieesizaq.com/wakeytoo/")
                Spacer()
            }
            HStack() {
                Spacer()
                Image("QRCode")
                Spacer()
            }
        }
        .navigationTitle("Help")
    }
}
