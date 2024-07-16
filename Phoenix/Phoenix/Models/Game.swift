//
//  Game.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import Foundation

struct Game: Codable, Comparable, Hashable, Sendable {
    var id: UUID = UUID()
    var steamID: String = ""
    var igdbID: String = ""
    var gameFile: String = ""
    var launcher: String = ""
    var metadata: [String: String] = [
        "rating": "",
        "release_date": "",
        "last_played": "",
        "developer": "",
        "header_img": "",
        "cover": "",
        "description": "",
        "genre": "",
        "publisher": "",
    ]
    var screenshots: [String?] = []
    var icon: String = ""
    var name: String = ""
    var platformName: String = "Other"
    var status: Status = Status.none
    var recency: Recency = Recency.never
    var isHidden: Bool = false
    var isFavorite: Bool = false
    
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
        return lhs.name.compareSpecial(rhs.name) == .orderedAscending
    }

    func changedFields() -> [String: Any] {
        let mirror = Mirror(reflecting: self)
        let defaultGame = Game()
        let defaultMirror = Mirror(reflecting: defaultGame)
        
        var changedFields: [String: Any] = [:]
        
        for (property, value) in mirror.children {
            guard let property = property else { continue }
            
            if let defaultValue = defaultMirror.children.first(where: { $0.label == property })?.value {
                if !isEqual(value, defaultValue) {
                    changedFields[property] = value
                }
            }
        }
        
        return changedFields
    }
    
    private func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        switch (lhs, rhs) {
        case (let lhs as UUID, let rhs as UUID):
            return lhs == rhs
        case (let lhs as String, let rhs as String):
            return lhs == rhs
        case (let lhs as [String: String], let rhs as [String: String]):
            return lhs == rhs
        case (let lhs as [String?], let rhs as [String?]):
            return lhs == rhs
        case (let lhs as Status, let rhs as Status):
            return lhs == rhs
        case (let lhs as Recency, let rhs as Recency):
            return lhs == rhs
        case (let lhs as Bool, let rhs as Bool):
            return lhs == rhs
        default:
            return false
        }
    }
    
    mutating func applyChanges(from changes: [String: Any]) {
        for (key, value) in changes {
            switch key {
            case "steamID":
                if let newValue = value as? String { self.steamID = newValue }
            case "igdbID":
                if let newValue = value as? String { self.igdbID = newValue }
            case "gameFile":
                if let newValue = value as? String { self.gameFile = newValue }
            case "launcher":
                if let newValue = value as? String { self.launcher = newValue }
            case "metadata":
                if let newValue = value as? [String: String] { self.metadata = newValue }
            case "screenshots":
                if let newValue = value as? [String?] { self.screenshots = newValue }
            case "icon":
                if let newValue = value as? String { self.icon = newValue }
            case "name":
                if let newValue = value as? String { self.name = newValue }
            case "platformName":
                if let newValue = value as? String { self.platformName = newValue }
            case "status":
                if let newValue = value as? Status { self.status = newValue }
            case "recency":
                if let newValue = value as? Recency { self.recency = newValue }
            case "isHidden":
                if let newValue = value as? Bool { self.isHidden = newValue }
            case "isFavorite":
                if let newValue = value as? Bool { self.isFavorite = newValue }
            default:
                break
            }
        }
    }
}

extension String {
    func compareSpecial(_ other: String) -> ComparisonResult {
        let lhsCharacters = Array(self.lowercased())
        let rhsCharacters = Array(other.lowercased())

        for (lhsChar, rhsChar) in zip(lhsCharacters, rhsCharacters) {
            if lhsChar.isNumber && rhsChar.isLetter {
                return .orderedDescending
            } else if lhsChar.isLetter && rhsChar.isNumber {
                return .orderedAscending
            } else if lhsChar != rhsChar {
                return lhsChar < rhsChar ? .orderedAscending : .orderedDescending
            }
        }

        return self.count < other.count ? .orderedAscending : (self.count > other.count ? .orderedDescending : .orderedSame)
    }
}

struct GamesList: Codable {
    var games: [Game]
}

