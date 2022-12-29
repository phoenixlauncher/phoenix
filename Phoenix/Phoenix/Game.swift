//
//  Game.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import Foundation

enum Platform: String, Codable, CaseIterable, Identifiable {
    case MAC, STEAM, GOG, EPIC, EMUL, NONE

    var id: Platform { self }
    
    var displayName: String {
        switch self {
            case .MAC: return "Mac"
            case .STEAM: return "Steam"
            case .GOG: return "GOG"
            case .EPIC: return "Epic"
            case .EMUL: return "Emulated"
            case .NONE: return "Other"
        }
    }
}

struct Game: Codable, Comparable {
    var launcher: String
    var metadata: [String: String]
    var icon: String
    var name: String
    var platform: Platform

    init(launcher: String = "", metadata: [String: String] = [:], icon: String = "PlaceholderIcon", name: String, platform: Platform = Platform.NONE) {
        self.launcher = launcher
        self.metadata = metadata
        self.icon = icon
        self.name = name
        self.platform = platform
    }

    static func < (lhs: Game, rhs: Game) -> Bool {
        lhs.name < rhs.name
    }
}

struct GamesList: Codable {
    var games: [Game]
}

func checkForPlatform(arr: [Game], plat: Platform) -> Bool {
    for game in arr {
        if game.platform == plat {
            return true
        }
    }

    return false
}
