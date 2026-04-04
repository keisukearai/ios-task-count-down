import SwiftUI

enum DeadlineCategory: String, Codable, CaseIterable, Identifiable {
    case work
    case personal
    case study
    case travel
    case finance
    case health
    case other

    var id: String { rawValue }

    var localizedKey: String { "category_\(rawValue)" }

    var icon: String {
        switch self {
        case .work:     return "briefcase.fill"
        case .personal: return "person.fill"
        case .study:    return "book.fill"
        case .travel:   return "airplane"
        case .finance:  return "yensign.circle.fill"
        case .health:   return "heart.fill"
        case .other:    return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .work:     return .blue
        case .personal: return .purple
        case .study:    return .orange
        case .travel:   return .teal
        case .finance:  return .green
        case .health:   return .red
        case .other:    return .gray
        }
    }
}
