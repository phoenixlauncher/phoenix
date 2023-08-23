//
//  Game.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import Foundation

enum Platform: String, Codable, CaseIterable, Identifiable {
    case MAC, STEAM, GOG, EPIC, PC, PS, NIN, XBOX, NONE

    var id: Platform { self }

    var displayName: String {
        switch self {
        case .MAC: return "Mac"
        case .STEAM: return "Steam"
        case .GOG: return "GOG"
        case .EPIC: return "Epic"
        case .PC: return "PC"
        case .PS: return "Playstation"
        case .NIN: return "Nintendo"
        case .XBOX: return "Xbox"
        case .NONE: return "Other"
        }
    }
}

struct Game: Codable, Comparable, Hashable {
    var appID: String
    var launcher: String
    var metadata: [String: String]
    var icon: String
    var name: String
    var platform: Platform
    var is_deleted: Bool // New property to indicate if the game has been deleted

    init(
        appID: String = "",
        launcher: String = "",
        metadata: [String: String] = [
            "rating": "",
            "release_date": "",
            "last_played": "",
            "developer": "",
            "header_img": "PlaceholderHeader",
            "description": "",
            "genre": "",
            "publisher": "",
        ],
        icon: String = "PlaceholderImage",
        name: String,
        platform: Platform = Platform.NONE,
        is_deleted: Bool
    ) {
        self.appID = appID
        self.launcher = launcher
        self.metadata = metadata
        self.icon = icon
        self.name = name
        self.platform = platform
        self.is_deleted = is_deleted
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

