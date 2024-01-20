//
//  JsonUtils.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import Foundation

/// Returns the URL for the application support directory for the current user.
///
/// - Returns: The URL for the application support directory.
func getApplicationSupportDirectory() -> URL {
    // find all possible Application Support directories for this user
    let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)

    // just send back the first one, which ought to be the only one
    return paths[0]
}

/// Returns the Phoenix application support directory
///
/// - Returns: The URL for the Application support directory/Phoenix.
func getPhoenixDirectory() -> URL? {
    let fileManager = FileManager.default
    let appSupportDirectory = fileManager.urls(
        for: .applicationSupportDirectory, in: .userDomainMask
    )
    .first
    let phoenixDirectory = appSupportDirectory?.appendingPathComponent("Phoenix")
    return phoenixDirectory
}

///  Parses the appmanifest_<steamID>.acf file and returns a dictionary of the key-value pairs.
///
///    - Parameters:
///      - data: The data from the appmanifest_<steamID>.acf file.
///
///    - Returns: A dictionary of the key-value pairs.
func parseACFFile(data: Data) -> [String: String] {
    let string = String(decoding: data, as: UTF8.self)

    // Use a regular expression to extract the key-value pairs
    let pattern = "(\"[^\"]+\"\\s*\"[^\"]*\")"
    let regex = try! NSRegularExpression(pattern: pattern)
    let matches = regex.matches(in: string, range: NSRange(location: 0, length: string.count))

    // Split the matches into key-value pairs and add them to the dictionary
    var dict = [String: String]()
    for match in matches {
        let keyValueString = (string as NSString).substring(with: match.range)
        let keyValueArray = keyValueString.components(separatedBy: "\"")
        let key = keyValueArray[1]
        let value = keyValueArray[3]
        dict[key] = value
    }
    return dict
}

/// Loads the games data from a JSON file named "games.json" in the "Phoenix"
/// directory under the application support directory.
///
/// - Returns: A `GamesList` object containing the games data (Empty if none can be
/// read from "games.json".
///
/// - Throws: An error if there was a problem reading from the JSON file or
/// decoding the data.
func loadGamesFromJSON() -> GamesList {
    let url = getApplicationSupportDirectory().appendingPathComponent("Phoenix/games.json")
    var games: GamesList?
    do {
        let jsonData = try Data(contentsOf: url)
        // Custom decoding strategy to convert "isDeleted" to "isHidden"
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .custom { keys -> CodingKey in
            let key = keys.last!
            if key.stringValue == "isDeleted" || key.stringValue == "is_deleted" {
                return AnyCodingKey(stringValue: "isHidden")!
            } else if key.stringValue == "appID" || key.stringValue == "steam_id" {
                return AnyCodingKey(stringValue: "steamID")!
            } else if key.stringValue == "is_favorite" {
                return AnyCodingKey(stringValue: "isFavorite")!
            } else {
                return key
            }
        }
        
        games = try decoder.decode(GamesList.self, from: jsonData)
        return games ?? GamesList(games: [])
    } catch {
        logger.write("[INFO]: Couldn't find games.json. Creating new one.")
        let jsonFileURL = Bundle.main.url(forResource: "games", withExtension: "json")
        do {
            if let jsonFileURL = jsonFileURL {
                let jsonData = try Data(contentsOf: jsonFileURL)
                let jsonString = String(decoding: jsonData, as: UTF8.self)
                writeGamesToJSON(data: jsonString)
            }
        } catch {
            logger.write(
                "[ERROR]: Something went wrong while trying to writeGamesToJSON() to 'games.json'"
            )
        }

        do {
            let jsonData = try Data(contentsOf: url)
            // Custom decoding strategy to convert "isDeleted" to "isHidden"
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .custom { keys -> CodingKey in
                let key = keys.last!
                if key.stringValue == "isDeleted" {
                    return AnyCodingKey(stringValue: "isHidden")!
                }
                return key
            }
            
            games = try decoder.decode(GamesList.self, from: jsonData)
            return games ?? GamesList(games: [])
        } catch {
            logger.write("[ERROR]: Couldn't read from new 'games.json'")
        }
    }

    return GamesList(games: [])
}

/// Writes the given data to a JSON file named "games.json" in the "Phoenix"
/// directory under the application support directory.
///
/// - Parameters:
///    - data: The data to write to the JSON file.
///
/// - Returns: Void.
///
/// - Throws: An error if there was a problem creating the directory or file, or
/// writing to the file.
func writeGamesToJSON(data: String) {
    let fileManager = FileManager.default
    let phoenixDirectory = getApplicationSupportDirectory().appendingPathComponent(
        "Phoenix", isDirectory: true)
    let gamesJSON = phoenixDirectory.appendingPathComponent("games.json", conformingTo: .json)
    let cachedImagesDirectory = phoenixDirectory.appendingPathComponent(
        "cachedImages", conformingTo: .directory)

    // If .../Application Support/Phoenix directory doesn't exist
    if !fileManager.fileExists(atPath: phoenixDirectory.path) {
        do {
            try fileManager.createDirectory(
                atPath: phoenixDirectory.path, withIntermediateDirectories: true)
            try fileManager.createDirectory(
                atPath: cachedImagesDirectory.path, withIntermediateDirectories: true)
        } catch {
            logger.write("[ERROR]: Could not create directory Application Support/Phoenix")
            return
        }
    }

    // If .../Application Support/Phoenix/games.json file exists
    if fileManager.fileExists(atPath: gamesJSON.path) {
        do {
            try data.write(to: gamesJSON, atomically: true, encoding: .utf8)
            logger.write("[INFO]: 'games.json' updated successfully.")
        } catch {
            logger.write("[ERROR]: Could not write data to 'games.json'")
        }
    } else {
        if fileManager.createFile(atPath: gamesJSON.path, contents: Data(data.utf8)) {
            logger.write("[INFO]: 'games.json' created successfully.")
        } else {
            logger.write("[ERROR]: 'games.json' not created.")
        }
    }
}

// Helper struct to handle custom coding key
struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}
