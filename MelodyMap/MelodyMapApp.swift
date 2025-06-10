//
//  MelodyMapApp.swift
//  MelodyMap
//
//  Created by Anant Dhokia on 6/3/25.
//

import SwiftUI
import Foundation

/// The main entry point for the MelodyMap application. Injects a global `ThemeManager`
/// so any view can adjust the app appearance, and applies the chosen `ColorScheme` via
/// `.preferredColorScheme(_:)`.
@main
struct MelodyMapApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(themeManager.colorScheme)
                .environmentObject(themeManager)
        }
    }
}
