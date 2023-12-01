//
//  ColofulAppApp.swift
//  ColofulApp
//
//  Created by QAQ on 2023/12/1.
//

import SwiftUI

@main
struct ColofulAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        #if os(macOS)
            .windowStyle(.hiddenTitleBar)
        #endif
    }
}
