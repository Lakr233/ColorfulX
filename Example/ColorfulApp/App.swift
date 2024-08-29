//
//  App.swift
//  ColorfulApp
//
//  Created by QAQ on 2023/12/1.
//

import ColorfulX
import SwiftUI

struct App: SwiftUI.App {
    #if targetEnvironment(macCatalyst)
        @Environment(\.scenePhase) var scenePhase
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView().background(Color.white)
        }
        #if targetEnvironment(macCatalyst)
        .onChange(of: scenePhase) { _ in
            removeTitleBarFromWindow()
        }
        #endif
        #if os(macOS)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        #endif
    }

    #if targetEnvironment(macCatalyst)
        func removeTitleBarFromWindow() {
            let scenes = UIApplication.shared.connectedScenes.map { $0 as? UIWindowScene }
            for scene in scenes {
                if let titlebar = scene?.titlebar {
                    titlebar.titleVisibility = .hidden
                    titlebar.toolbar = nil
                }
            }
        }
    #endif
}
