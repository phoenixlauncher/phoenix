//
//  Game.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import Foundation

enum Platform: String, Codable, CaseIterable, Identifiable {
    case mac, steam, gog, epic, pc, ps, nin, sega, xbox, none

    var id: Platform { self }

    var displayName: String {
        switch self {
        case .mac: return String(localized: "platforms_Mac")
        case .steam: return String(localized: "platforms_Steam")
        case .gog: return String(localized: "platforms_GOG")
        case .epic: return String(localized: "platforms_Epic")
        case .pc: return String(localized: "platforms_PC")
        case .ps: return String(localized: "platforms_Playstation")
        case .nin: return String(localized: "platforms_Nintendo")
        case .sega: return String(localized: "platforms_Sega")
        case .xbox: return String(localized: "platforms_Xbox")
        case .none: return String(localized: "platforms_Other")
        }
    }
}

enum Status: String, Codable, CaseIterable, Identifiable {
    case playing, shelved, occasional, backlog, beaten, completed, abandoned, none

    var id: Status { self }

    var displayName: String {
        switch self {
        case .playing: return String(localized: "status_Playing")
        case .shelved: return String(localized: "status_Shelved")
        case .occasional: return String(localized: "status_Occasional")
        case .backlog: return String(localized: "status_Backlog")
        case .beaten: return String(localized: "status_Beaten")
        case .completed: return String(localized: "status_Completed")
        case .abandoned: return String(localized: "status_Abandoned")
        case .none: return String(localized: "status_Other")
        }
    }
}

enum Recency: String, Codable, CaseIterable, Identifiable {
    case day, week, month, three_months, six_months, year, never

    var id: Recency { self }

    var displayName: String {
        switch self {
        case .day: return String(localized: "recency_Today")
        case .week: return String(localized: "recency_ThisWeek")
        case .month: return String(localized: "recency_ThisMonth")
        case .three_months: return String(localized: "recency_Last3Months")
        case .six_months: return String(localized: "recency_Last6Months")
        case .year: return String(localized: "recency_ThisYear")
        case .never: return String(localized: "recency_Never")
        }
    }
}

struct Game: Codable, Comparable, Hashable {
    var id: UUID
    var steamID: String
    var igdbID: String
    var launcher: String
    var metadata: [String: String]
    var icon: String
    var name: String
    var platform: Platform
    var status: Status
    var recency: Recency
    var isHidden: Bool
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        steamID: String = "",
        igdbID: String = "",
        launcher: String = "",
        metadata: [String: String] = [
            "rating": "",
            "release_date": "",
            "last_played": "",
            "developer": "",
            "header_img": "",
            "cover": "",
            "description": "",
            "genre": "",
            "publisher": "",
        ],
        icon: String = "",
        name: String = "",
        platform: Platform = Platform.none,
        status: Status = Status.none,
        recency: Recency = Recency.never,
        isHidden: Bool = false,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.steamID = steamID
        self.igdbID = igdbID
        self.launcher = launcher
        self.metadata = metadata
        self.icon = icon
        self.name = name
        self.platform = platform
        self.status = status
        self.recency = recency
        self.isHidden = isHidden
        self.isFavorite = isFavorite
    }

    enum CodingKeys: String, CodingKey {
        case id, steamID, igdbID, launcher, metadata, icon, name, platform, status, recency, isHidden, isFavorite
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.launcher = (try? container.decode(String.self, forKey: .launcher)) ?? ""
        self.metadata = (try? container.decode([String: String].self, forKey: .metadata)) ?? ["": ""]
        self.icon = (try? container.decode(String.self, forKey: .icon)) ?? ""
        self.name = (try? container.decode(String.self, forKey: .name)) ?? ""

        var platformRawValue = try container.decode(String.self, forKey: .platform)
        platformRawValue = platformRawValue.lowercased()
        self.platform = Platform(rawValue: platformRawValue) ?? .none

        var statusRawValue = try container.decode(String.self, forKey: .status)
        statusRawValue = statusRawValue.lowercased()
        self.status = Status(rawValue: statusRawValue) ?? .none

        // Decode recency, or derive it from last_played
        let dateString = metadata["last_played"] ?? ""
        if dateString == "" || dateString == "Never" {
            self.recency = .never
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            let lastPlayedDate = dateFormatter.date(from: dateString)
            let timeInterval = lastPlayedDate?.timeIntervalSinceNow ?? 0
            let dayInSecs: TimeInterval = 24 * 60 * 60
            switch abs(timeInterval) {
            case 0...dayInSecs:
                self.recency = .day
            case 0...7 * dayInSecs:
                self.recency = .week
            case 0...30 * dayInSecs:
                self.recency = .month
            case 0...90 * dayInSecs:
                self.recency = .three_months
            case 0...180 * dayInSecs:
                self.recency = .six_months
            case 0...365 * dayInSecs:
                self.recency = .year
            default:
                self.recency = .never
            }
        }

        self.steamID = (try? container.decode(String.self, forKey: .steamID)) ?? ""
        self.igdbID = (try? container.decode(String.self, forKey: .igdbID)) ?? ""

        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.isHidden = (try? container.decode(Bool.self, forKey: .isHidden)) ?? false
        self.isFavorite = (try? container.decode(Bool.self, forKey: .isFavorite)) ?? false
    }

    /**
     Compares two `Game` objects based on their `name` property.

     - Parameters:
        - lhs: The left-hand side of the comparison.
        - rhs: The right-hand side of the comparison.

     - Returns: `true` if the `name` property of the left-hand side is
                lexicographically less than the `name` property of the
                right-hand side, `false` otherwise.
     */
    static func < (lhs: Game, rhs: Game) -> Bool {
        lhs.name < rhs.name
    }
}

struct GamesList: Codable {
    var games: [Game]
}

/// Check if the given array of games contains any games for the given platform
///
/// - Parameters:
///    - arr: the array of games to search
///    - plat: the platform to search for
///
/// - Returns: A boolean for whether plat was found
func checkForPlatform(arr: [Game], plat: Platform) -> Bool {
    // Check if arr has any games in it for plat
    for game in arr {
        if game.platform == plat {
            return true
        }
    }

    return false
}
