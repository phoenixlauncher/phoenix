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
        case .mac: return "Mac"
        case .steam: return "Steam"
        case .gog: return "GOG"
        case .epic: return "Epic"
        case .pc: return "PC"
        case .ps: return "Playstation"
        case .nin: return "Nintendo"
        case .sega: return "Sega"
        case .xbox: return "Xbox"
        case .none: return "Other"
        }
    }
}

enum Status: String, Codable, CaseIterable, Identifiable {
    case playing, shelved, occasional, backlog, beaten, completed, abandoned, none

    var id: Status { self }

    var displayName: String {
        switch self {
        case .playing: return "Playing"
        case .shelved: return "Shelved"
        case .occasional: return "Occasional"
        case .backlog: return "Backlog"
        case .beaten: return "Beaten"
        case .completed: return "Completed"
        case .abandoned: return "Abandoned"
        case .none: return "Other"
        }
    }
}

enum Recency: String, Codable, CaseIterable, Identifiable {
    case day, week, month, three_months, six_months, year, never

    var id: Recency { self }

    var displayName: String {
        switch self {
        case .day: return "Today"
        case .week: return "This Week"
        case .month: return "This Month"
        case .three_months: return "Last 3 Months"
        case .six_months: return "Last 6 Months"
        case .year: return "This Year"
        case .never: return "Never"
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
    var is_deleted: Bool
    var is_favorite: Bool

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
            "description": "",
            "genre": "",
            "publisher": "",
        ],
        icon: String = "",
        name: String = "",
        platform: Platform = Platform.none,
        status: Status = Status.none,
        recency: Recency = Recency.never,
        is_deleted: Bool = false,
        is_favorite: Bool = false
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
        self.is_deleted = is_deleted
        self.is_favorite = is_favorite
    }
    
    enum CodingKeys: String, CodingKey {
        case id, steamID, igdbID, launcher, metadata, icon, name, platform, status, recency, is_deleted, is_favorite
    }
        
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        launcher = try container.decode(String.self, forKey: .launcher)
        metadata = try container.decode([String: String].self, forKey: .metadata)
        icon = try container.decode(String.self, forKey: .icon)
        name = try container.decode(String.self, forKey: .name)
        
        var platformRawValue = try container.decode(String.self, forKey: .platform)
        platformRawValue = platformRawValue.lowercased()
        
        if let platform = Platform(rawValue: platformRawValue) {
            self.platform = platform
        } else {
            self.platform = .none
        }
        
        var statusRawValue = try container.decode(String.self, forKey: .status)
        statusRawValue = statusRawValue.lowercased()

        if let status = Status(rawValue: statusRawValue) {
            self.status = status
        } else {
            self.status = .none
        }
        
        // Decode recency, or derive it from last_played
        let dateString = metadata["last_played"] ?? ""
        if dateString == "" || dateString == "Never" {
            self.recency = .never
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            let lastPlayedDate = dateFormatter.date(from: dateString)
            let timeInterval = lastPlayedDate?.timeIntervalSinceNow ?? 0
            if abs(timeInterval) <= 24 * 60 * 60 {
                self.recency = .day
            } else if abs(timeInterval) <= 7 * 24 * 60 * 60 {
                self.recency = .week
            } else if abs(timeInterval) <= 30 * 24 * 60 * 60 {
                self.recency = .month
            } else if abs(timeInterval) <= 90 * 24 * 60 * 60 {
                self.recency = .three_months
            } else if abs(timeInterval) <= 180 * 24 * 60 * 60 {
                self.recency = .six_months
            } else if abs(timeInterval) <= 365 * 24 * 60 * 60 {
                self.recency = .year
            } else {
                self.recency = .never
            }
        }
        
        // Handle steamID conversion with default to ""
        if let steamID = try? container.decode(String.self, forKey: .steamID) {
            self.steamID = steamID
        } else {
            self.steamID = ""
        }
        
        // Handle igdbID conversion with default to ""
        if let igdbID = try? container.decode(String.self, forKey: .igdbID) {
            self.igdbID = igdbID
        } else {
            self.igdbID = ""
        }
        
        // Handle id conversion
        if let id = try? container.decode(UUID.self, forKey: .id) {
            self.id = id
        } else {
            self.id = UUID()
        }
        
        // Handle is_deleted conversion with default to ""
        if let is_deleted = try? container.decode(Bool.self, forKey: .is_deleted) {
            self.is_deleted = is_deleted
        } else {
            self.is_deleted = false
        }
        
        // Handle is_favorite conversion with default to ""
        if let is_favorite = try? container.decode(Bool.self, forKey: .is_favorite) {
            self.is_favorite = is_favorite
        } else {
            self.is_favorite = false
        }
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

func loadGames() -> GamesList {
    if UserDefaults.standard.bool(forKey: "isGameDetectionEnabled") {
        detectSteamGamesAndWriteToJSON()
    }
    
    let res = loadGamesFromJSON()
    return res
}

