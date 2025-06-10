import SwiftUI

/// App-wide theme options
enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark

    /// User-visible label
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    /// The SwiftUI `ColorScheme` that corresponds to the theme (nil = follow system)
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

/// Observable object that stores and persists the user's theme preference so it can be
/// updated at runtime and survive app relaunches.
final class ThemeManager: ObservableObject {
    // MARK: - Singleton
    static let shared = ThemeManager()

    // MARK: - Published state
    @Published var selectedTheme: AppTheme {
        didSet { persist() }
    }

    /// Convenience wrapper for SwiftUI's `.preferredColorScheme` modifier
    var colorScheme: ColorScheme? { selectedTheme.colorScheme }

    // MARK: - Storage Keys
    private let defaults = UserDefaults.standard
    private let key = "themePreference"

    // MARK: - Init
    private init() {
        // Read value from UserDefaults (falls back to .system)
        if let raw = defaults.string(forKey: key), let saved = AppTheme(rawValue: raw) {
            selectedTheme = saved
        } else {
            selectedTheme = .system
        }
    }

    // MARK: - Helpers
    private func persist() {
        defaults.set(selectedTheme.rawValue, forKey: key)
    }
} 