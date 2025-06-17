//
//  ContentView.swift
//  Wakey
//
//  Created by echo on 7/3/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
    #if os(iOS)
        PhoneView()
    #elseif os(tvOS)
        TVView()
    #endif
    }
}

#Preview {
    ContentView()
}
