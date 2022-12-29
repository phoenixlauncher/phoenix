//
//  JsonUtils.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import Foundation

private func getApplicationSupportDirectory() -> URL {
    // find all possible Application Support directories for this user
    let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    
    // just send back the first one, which ought to be the only one
    return paths[0]
}

func loadGamesFromJSON() -> GamesList {
    let url = getApplicationSupportDirectory().appendingPathComponent("Phoenix/games.json")
    
    var games: GamesList?
        do {
            let jsonData = try Data(contentsOf: url)
            games = try JSONDecoder().decode(GamesList.self, from: jsonData)
    
            return games ?? GamesList(games: [])
//            if let games = games {
//                return games
//            } else {
//                print("Failed to parse")
//            }
        } catch {
            print("\(error)")
        }
    
        return GamesList(games: [])
}

func writeGamesToJSON(data: String) {
    let url = getApplicationSupportDirectory().appendingPathComponent("Phoenix/games.json")
    
    do {
        try data.write(to: url, atomically: true, encoding: .utf8)
    } catch {
        print("Could not write data to file")
    }
}
