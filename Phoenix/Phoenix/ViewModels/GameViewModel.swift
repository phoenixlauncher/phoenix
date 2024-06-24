import Foundation
import AppKit

@MainActor
class GameViewModel: ObservableObject {
    @Published var isInitializing: Bool = false
    @Published var games: [Game] = []
    @Published var selectedGame: UUID
    @Published var selectedGameName: String
    var supabaseViewModel = SupabaseViewModel()
    var platformViewModel = PlatformViewModel()
    
    init() {
        logger.write("GameViewModel init starting.")
        // Initialize selectedGame and selectedGameName
        selectedGame = Defaults[.selectedGame]
        selectedGameName = ""
        
        // Load games and assign the value to the optional variable
        games = loadGames().sorted()
        
        // Update selectedGameName using the loaded games
        if let game = getGameFromID(id: Defaults[.selectedGame]) {
            selectedGameName = game.name
        }
        logger.write("GameViewModel init finished.")
    }
    
    func getGameFromName(name: String) -> Game? {
        return games.first { $0.name == name }
    }

    func getGameFromID(id: UUID) -> Game? {
        return games.first { $0.id == id }
    }

    func addGame(_ game: Game, save: Bool = true) {
        logger.write("Adding game \(game.name).")
        if let idx = games.firstIndex(where: { $0.id == game.id }) {
            games[idx] = game
        } else {
            if let index = games.firstIndex(where: { $0 > game }) {
                games.insert(game, at: index)
            } else {
                games.append(game)
            }
    }
        save ? saveGames() : ()
    }
    
    func addGames(_ addedGames: [Game], save: Bool = true) {
        for game in addedGames {
            logger.write("Adding game \(game.name).")
            if let idx = games.firstIndex(where: { $0.id == game.id }) {
                games[idx] = game
            } else {
                games.append(game)
            }
        }
        save ? saveGames() : ()
    }
    
    func toggleFavoriteFromID(_ id: UUID) {
        if let idx = games.firstIndex(where: { $0.id == id }) {
            games[idx].isFavorite.toggle()
        }
        saveGames()
    }
    
    func toggleHiddenFromID(_ id: UUID) {
        if let idx = games.firstIndex(where: { $0.id == id }) {
            games[idx].isHidden.toggle()
        }
        saveGames()
    }
    
    func deleteGameFromID(_ id: UUID) {
        if let idx = games.firstIndex(where: { $0.id == id }) {
            games.remove(at: idx)
        }
        saveGames()
    }

    func saveGames() {
        print("Saving games")
        games = games.sorted()
        saveJSONData(to: "games", with: convertGamesToJSONString(games))
    }
    
    /// If varying game detection settings are enabled, run methods to check for those games
    /// Save the games once the check is done, then parse the saved JSON to get a list of games
    func loadGames() -> [Game] {
        var platformGameSets: [Platform: Set<URL>] = [:]
        
        func scanGames(ofName platformName: String, at directoryURL: URL, withType type: String) -> Set<URL> {
            var gamePaths: Set<URL> = []
            do {
                let fileEnumerator = FileManager.default.enumerator(at: directoryURL, includingPropertiesForKeys: nil)
                if platformName != "Steam" {
                    while let fileURL = fileEnumerator?.nextObject() as? URL {
                        if fileURL.lastPathComponent.hasSuffix(type) {
                            gamePaths.insert(fileURL)
                        }
                        let resourceValues = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
                        if let isDirectory = resourceValues.isDirectory, isDirectory, fileURL.pathExtension == "app" {
                            fileEnumerator?.skipDescendants()
                        }
                    }
                } else {
                    while let fileURL = fileEnumerator?.nextObject() as? URL {
                        if fileURL.lastPathComponent.hasSuffix("acf") {
                            gamePaths.insert(fileURL)
                        }
                    }
                }
            }
            catch {
                logger.write(error.localizedDescription)
            }
            return gamePaths
        }
        
        for platform in platformViewModel.platforms.filter({ $0.commandTemplate != "" && $0.gameType != "" && $0.gameDirectories != [] }) {
            for directory in platform.gameDirectories {
                if let directoryURL = URL(string: directory), FileManager.default.fileExists(atPath: directory) {
                    platformGameSets[platform] = scanGames(ofName: platform.name, at: directoryURL, withType: platform.gameType)
                }
            }
        }
        
        Task {
            var (nonSteamGames, steamGames) = await compareGamePaths(platformGameSets: platformGameSets)
            await saveGamesFromScan(&nonSteamGames, &steamGames)
        }
        
        let res = loadGamesFromJSON()
        return res
    }
    
    struct NonSteamGame {
        var name: String
        var platform: Platform
        var urlPath: String
    }
    
    struct SteamGame {
        var steamID: String
        var name: String
    }
    
    func compareGamePaths(platformGameSets: [Platform: Set<URL>]) async -> ([NonSteamGame], [SteamGame]) {
        var nonSteamGames: [NonSteamGame] = [] // [NAME: PLATFORM] : URL.PATH
        var steamGames: [SteamGame] = [] // ID : NAME
        
        for (platform, gamePaths) in platformGameSets {
            if platform.name == "Steam" {
                for acfFile in gamePaths {
                    do {
                        let manifestDictionary = parseACFFile(data: try Data(contentsOf: acfFile))
                        if let name = manifestDictionary["name"], let id = manifestDictionary["appid"] {
                            steamGames.append(SteamGame(steamID: id, name: name))
                            logger.write("\(name) detected in Steam directories.")
                        }
                    }
                    catch {
                        logger.write(error.localizedDescription)
                    }
                }
            } else {
                for file in gamePaths {
                    let name = String(file.lastPathComponent.dropLast(platform.gameType.contains(".") ? platform.gameType.count : platform.gameType.count + 1))
                    nonSteamGames.append(NonSteamGame(name: name, platform: platform, urlPath: file.path))
                    logger.write("\(name) detected in \(platform.name) directories.")
                }
            }
        }
        return (nonSteamGames, steamGames)
    }
    
    func saveGamesFromScan(_ nonSteamGames: inout [NonSteamGame], _ steamGames: inout [SteamGame]) async {
        var doneGameNames: Set<String> = Set(loadGamesFromJSON().map({ $0.name })) // get the games that already are added to phoenix
        var newGames: [Game] = []
        
        var nonGamePaths: [String] = loadNonGamePathsFromJSON()
        
        logger.write("Starting fetch process. Currently done games are: \(doneGameNames.sorted())")
        
        // Filter the steamGames
        steamGames = steamGames.filter { steamGame in
            // Return true if the game name (key) is not in doneGames
            return !doneGameNames.contains(steamGame.name)
        }
        
        func saveSteamGames(_ games: [SteamGame]) async {
            print("saving steam games: \(games)")
            for steamGame in games {
                let name = steamGame.name
                let steamID = steamGame.steamID
                if !doneGameNames.contains(name), let launcherTemplate = platformViewModel.platforms.first(where: { "Steam" == $0.name})?.commandTemplate {
                    let game = await saveSupabaseGame(name, steamID: steamID, platform: "Steam", launcher: launcherTemplate)
                    if let game = game {
                        print("game found: " + game.name)
                        newGames.append(game)
                        addGame(game, save: false)
                        doneGameNames.insert(game.name)
                    }
                }
            }
        }
        
        // Filter the nonSteamGames
        nonSteamGames = nonSteamGames.filter { nonSteamGame in
            // Return true if the game name is not in doneGames
            return !doneGameNames.contains(nonSteamGame.name)
        }
        
        //Prioritize non-Mac games so Automator shortcuts and aliases aren't added but the actual games are.
        var macGames: [NonSteamGame] = []
        var otherGames: [NonSteamGame] = []
        
        for nonSteamGame in nonSteamGames {
            if nonSteamGame.platform.name == "Mac" {
                macGames.append(nonSteamGame)
            } else {
                otherGames.append(nonSteamGame)
            }
        }
        
        func saveNonSteamGames(_ games: [NonSteamGame]) async {
            print("saving non steam games: \(games)")
            for nonSteamGame in games {
                let name = nonSteamGame.name
                let platform = nonSteamGame.platform
                let urlPath = nonSteamGame.urlPath
                if !doneGameNames.contains(name), !nonGamePaths.contains(urlPath) {
                    let game = await saveSupabaseGame(name, platform: platform.name, launcher: String(format: platform.commandTemplate, urlPath))
                    if var game = game {
                        if platform.name == "Mac" && Defaults[.getIconFromApp], let appIcon = saveIconToFile(iconNSImage: NSWorkspace.shared.icon(forFile: urlPath), gameID: game.id) {
                            game.icon = appIcon
                        }
                        addGame(game, save: false)
                        doneGameNames.insert(name)
                    } else {
                        nonGamePaths.append(urlPath)
                    }
                }
            }
        }
        
        isInitializing = true
        await saveSteamGames(steamGames)
        await saveNonSteamGames(otherGames)
        await saveNonSteamGames(macGames)
        //save the names of the apps that didn't return anything from supabase
        saveJSONData(to: "nonGamePaths", with: convertnonGamePathsToJSONString(nonGamePaths))
        saveGames()
        isInitializing = false
    }

    
    func saveSupabaseGame(_ name: String, steamID: String? = nil, platform: String, launcher: String) async -> Game? {
        var fetchedGame: SupabaseGame?
        if let steamID = steamID {
            fetchedGame = await self.supabaseViewModel.fetchGameFromSteamID(steamID: steamID)
        } else {
            let fetchedIgdbIDs = await self.supabaseViewModel.fetchIgbdIDsFromName(name: name).map({ $0.igdb_id })
            if let firstIgdbID = fetchedIgdbIDs.sorted(by: { $0 < $1 }).first {
                print(firstIgdbID)
                fetchedGame = await self.supabaseViewModel.fetchGameFromIgdbID(firstIgdbID)
            } else {
                let fetchedGames = await self.supabaseViewModel.fetchIgbdIDsFromPatternName(name: name)
                if let firstIgdbID = fetchedGames.sorted(by: { $0.igdb_id < $1.igdb_id }).first(where: { $0.name?.localizedCaseInsensitiveContains(name) == true || name.localizedCaseInsensitiveContains($0.name ?? "") })?.igdb_id {
                    fetchedGame = await self.supabaseViewModel.fetchGameFromIgdbID(firstIgdbID)
                } else {
                    let fetchedGames = await self.supabaseViewModel.fetchIgbdIDsFromPatternNameWithSpaces(name: name)
                    if let firstIgdbID = fetchedGames.sorted(by: { $0.igdb_id < $1.igdb_id }).first?.igdb_id {
                        fetchedGame = await self.supabaseViewModel.fetchGameFromIgdbID(firstIgdbID)
                    }
                }
            }
        }
        if let fetchedGame = fetchedGame {
            var (game, headerData) = await self.supabaseViewModel.convertSupabaseGame(supabaseGame: fetchedGame, game: Game(id: UUID(), launcher: launcher, name: name, platformName: platform))
            if let headerData = headerData {
                game.metadata["header_img"] = saveImageToFile(data: headerData, gameID: game.id, type: "header")
            }
            return game
        }
        return nil
    }
}
