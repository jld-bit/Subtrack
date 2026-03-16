import Foundation

enum SubscriptionCategory: String, CaseIterable, Identifiable {
    case entertainment
    case productivity
    case music
    case fitness
    case cloud
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .entertainment: return "Entertainment"
        case .productivity: return "Productivity"
        case .music: return "Music"
        case .fitness: return "Fitness"
        case .cloud: return "Cloud"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .entertainment: return "play.tv.fill"
        case .productivity: return "briefcase.fill"
        case .music: return "music.note"
        case .fitness: return "figure.run"
        case .cloud: return "icloud.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}
