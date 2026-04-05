import SwiftUI

enum DeadlineCategory: String, Codable, CaseIterable, Identifiable {
    case none
    case work
    case personal
    case study
    case travel
    case finance
    case health
    case hobby
    case family
    case event
    case other

    var id: String { rawValue }

    var localizedKey: String { "category_\(rawValue)" }

    var icon: String {
        switch self {
        case .none:     return "minus.circle"
        case .work:     return "briefcase.fill"
        case .personal: return "person.fill"
        case .study:    return "book.fill"
        case .travel:   return "airplane"
        case .finance:  return "yensign.circle.fill"
        case .health:   return "heart.fill"
        case .hobby:    return "gamecontroller.fill"
        case .family:   return "house.fill"
        case .event:    return "party.popper.fill"
        case .other:    return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .none:     return Color(.systemGray)
        case .work:     return .blue
        case .personal: return .purple
        case .study:    return .orange
        case .travel:   return .teal
        case .finance:  return .green
        case .health:   return .red
        case .hobby:    return .pink
        case .family:   return .brown
        case .event:    return .indigo
        case .other:    return .gray
        }
    }
}
