import Foundation
import Observation

enum Language: String, CaseIterable, Identifiable {
    case system       = "system"
    case english      = "en"
    case japanese     = "ja"
    case chinese      = "zh-Hans"
    case vietnamese   = "vi"
    case thai         = "th"

    var id: String { rawValue }

    // Always shown in the native language so any user can find their language
    var nativeName: String {
        switch self {
        case .system:     return "System Default"
        case .english:    return "English"
        case .japanese:   return "日本語"
        case .chinese:    return "中文（简体）"
        case .vietnamese: return "Tiếng Việt"
        case .thai:       return "ภาษาไทย"
        }
    }

    var flagEmoji: String {
        switch self {
        case .system:     return "🌐"
        case .english:    return "🇺🇸"
        case .japanese:   return "🇯🇵"
        case .chinese:    return "🇨🇳"
        case .vietnamese: return "🇻🇳"
        case .thai:       return "🇹🇭"
        }
    }

    // Resolve bundle for this language (or .main for system)
    var bundle: Bundle {
        guard self != .system,
              let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
              let b    = Bundle(path: path) else { return .main }
        return b
    }
}

@Observable
final class LanguageManager {
    private static let key = "app_language"

    private(set) var currentLanguage: Language
    // `bundle` is a tracked stored property — accessing it inside l() registers observation
    private(set) var bundle: Bundle

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.key)
        let lang  = Language(rawValue: saved ?? "system") ?? .system
        currentLanguage = lang
        bundle          = lang.bundle
    }

    func setLanguage(_ language: Language) {
        currentLanguage = language
        bundle          = language.bundle
        UserDefaults.standard.set(language.rawValue, forKey: Self.key)
    }

    // Localize a key using the current bundle
    func l(_ key: String) -> String {
        NSLocalizedString(key, bundle: bundle, comment: "")
    }

    // Localize a format key then substitute arguments
    func lf(_ key: String, _ args: CVarArg...) -> String {
        String(format: l(key), arguments: args)
    }
}
