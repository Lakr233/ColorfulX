//
//  App.swift
//  ColorfulApp
//
//  Created by QAQ on 2023/12/1.
//

import ColorfulX
import SwiftUI

struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView().background(Color.white)
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        #endif
    }
}
