//
//  Game.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import Foundation

struct Game: Codable, Comparable, Hashable {
    var id: UUID
    var steamID: String
    var igdbID: String
    var launcher: String
    var metadata: [String: String]
    var screenshots: [String?]
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
        screenshots: [String] = [],
        icon: String = "",
        name: String = "",
        platform: Platform = .none,
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
        self.screenshots = screenshots
        self.icon = icon
        self.name = name
        self.platform = platform
        self.status = status
        self.recency = recency
        self.isHidden = isHidden
        self.isFavorite = isFavorite
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

