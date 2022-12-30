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
        } catch {
            print("Couldn't find games.json. Creating new one.")
            let jsonFileURL = Bundle.main.url(forResource: "games", withExtension: "json")
            do {
                let jsonData = try Data(contentsOf: jsonFileURL!)
                let jsonString = String(decoding: jsonData, as: UTF8.self)
                writeGamesToJSON(data: jsonString)
            } catch {
                print("Could not get data from 'games.json'")
            }
            
            do {
                let jsonData = try Data(contentsOf: url)
                games = try JSONDecoder().decode(GamesList.self, from: jsonData)
                
                return games ?? GamesList(games: [])
            } catch {
                print("Couldn't read from new 'games.json'")
            }
        }
    
        return GamesList(games: [])
}

func writeGamesToJSON(data: String) {
    // If .../Application Support/Phoenix directory exists
    if FileManager.default.fileExists(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix", isDirectory: true).path) {
        // If .../Application Support/Phoenix/games.json file exists
        if FileManager.default.fileExists(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix/games.json", conformingTo: .json).path) {
            let url = getApplicationSupportDirectory().appendingPathComponent("Phoenix/games.json")
            do {
                try data.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                print("Could not write data to 'games.json'")
            }
        // If .../Application Support/Phoenix/games.json file DOESN'T exist
        } else {
            if FileManager.default.createFile(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix/games.json", conformingTo: .json).path, contents: Data(data.utf8)) {
                print("'games.json' created successfully.")
            } else {
                print("'games.json' not created.")
            }
        }
        // If .../Application Support/Phoenix/cachedImages DOESN'T exist
        if FileManager.default.fileExists(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix/cachedImages", isDirectory: true).path) {
            do {
                try FileManager.default.createDirectory(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix", conformingTo: .directory).path, withIntermediateDirectories: true)
            } catch {
                print("Could not create directory")
            }
        }
    // If .../Application Support/Phoenix directory DOESN'T exist
    } else {
        do {
            try FileManager.default.createDirectory(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix", conformingTo: .directory).path, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix/cachedImages", conformingTo: .directory).path, withIntermediateDirectories: true)
            
            if FileManager.default.createFile(atPath: getApplicationSupportDirectory().appendingPathComponent("Phoenix/games.json", conformingTo: .json).path, contents: Data(data.utf8)) {
                print("'games.json' created successfully.")
            } else {
                print("'File' not created.")
            }
        } catch {
            print("Could not create directory")
        }
    }
    
    
}
