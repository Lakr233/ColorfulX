//
//  ColorfulAppApp.swift
//  ColorfulApp
//
//  Created by QAQ on 2023/12/1.
//

import SwiftUI

@main
struct ColorfulAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        #if os(macOS)
            .windowToolbarStyle(.unifiedCompact)
        #endif
    }
}
