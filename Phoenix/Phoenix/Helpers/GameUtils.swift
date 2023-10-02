//
//  GameInputUtils.swift
//  Phoenix
//
//  Created by James Hughes on 9/24/23.
//

import Foundation

func getGameFromName(name: String) -> Game? {
    if let idx = games.firstIndex(where: { $0.name == name }) {
        return games[idx]
    } else {
        return nil
    }
}

func saveGames() {
    games = games.sorted()
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    do {
        let gamesJSON = try JSONEncoder().encode(games)
        
        if var gamesJSONString = String(data: gamesJSON, encoding: .utf8) {
            // Add the necessary JSON elements for the string to be recognized as type "Games" on next read
            gamesJSONString = "{\"games\": \(gamesJSONString)}"
            writeGamesToJSON(data: gamesJSONString)
        }
    } catch {
        logger.write(error.localizedDescription)
    }
}
