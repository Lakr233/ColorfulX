//
//  ColorfulAppApp.swift
//  ColorfulApp
//
//  Created by QAQ on 2023/12/1.
//

import ColorfulX
import SwiftUI

@main
struct ColorfulAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        #endif
    }
}
