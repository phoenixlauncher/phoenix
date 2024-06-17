import Foundation
import AppKit

@MainActor
class GameViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var selectedGame: UUID
    @Published var selectedGameName: String
    var supabaseViewModel = SupabaseViewModel()
    var platformViewModel = PlatformViewModel()
    
    init() {
        // Initialize selectedGame and selectedGameName
        selectedGame = Defaults[.selectedGame]
        selectedGameName = ""
        
        // Load games and assign the value to the optional variable
        games = loadGames().sorted()
        
        // Update selectedGameName using the loaded games
        if let game = getGameFromID(id: Defaults[.selectedGame]) {
            selectedGameName = game.name
        }
    }
    
    func getGameFromName(name: String) -> Game? {
        return games.first { $0.name == name }
    }

    func getGameFromID(id: UUID) -> Game? {
        return games.first { $0.id == id }
    }

    func addGame(_ game: Game) {
        logger.write("Adding game \(game.name).")
        if let idx = games.firstIndex(where: { $0.id == game.id }) {
            games[idx] = game
        } else {
            games.append(game)
        }
        saveGames()
    }
    
    func addGames(_ addedGames: [Game]) {
        for game in addedGames {
            logger.write("Adding game \(game.name).")
            if let idx = games.firstIndex(where: { $0.id == game.id }) {
                games[idx] = game
            } else {
                games.append(game)
            }
        }
        saveGames()
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
        Task {
            for platform in platformViewModel.platforms {
                for directory in platform.gameDirectories {
                    if let directoryURL = URL(string: directory), FileManager.default.fileExists(atPath: directory) {
                        platformGameSets[platform] = scanGames(ofName: platform.name, at: directoryURL, withType: platform.gameType)
                    }
                }
            }
            await compareGamePaths(platformGameSets: platformGameSets)
        }
        
        let res = loadGamesFromJSON()
        return res
    }
    
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
    
    func compareGamePaths(platformGameSets: [Platform: Set<URL>]) async {
        let startGameNames = Set(loadGamesFromJSON().map({ $0.name }))
        
        var nonSteamGames: [[String: Platform]: String] = [:] // [NAME: PLATFORM] : URL.PATH
        var steamGames: [String: String] = [:] // ID : NAME
        
        for (platform, gamePaths) in platformGameSets {
            if platform.name == "Steam" {
                for acfFile in gamePaths {
                    do {
                        let manifestDictionary = parseACFFile(data: try Data(contentsOf: acfFile))
                        if let name = manifestDictionary["name"], let id = manifestDictionary["appid"] {
                            steamGames[id] = name
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
                    logger.write("\(name) detected in \(platform.name) directories.")
                    nonSteamGames[[name: platform]] = file.path
                }
            }
        }
        
        var doneGames: Set<String> = startGameNames
        var newGames: [Game] = []
        
        logger.write("Starting fetch process. Currently done games are: \(doneGames.sorted())")

        for (id, name) in steamGames {
            if !doneGames.contains(name), let launcherTemplate = platformViewModel.platforms.first(where: { "Steam" == $0.name})?.commandTemplate {
                await saveSupabaseGame(name, steamID: id, platform: "Steam", launcher: launcherTemplate) { gameFound, game in
                    if gameFound {
                        newGames.append(game)
                        doneGames.insert(name)
                    }
                }
            }
        }
        
        //Prioritize non-Mac games so Automator shortcuts and aliases aren't added but the actual games are.
        
        var macGames: [(namePlatform: [String: Platform], urlPath: String)] = []
        var otherGames: [(namePlatform: [String: Platform], urlPath: String)] = []

        for (namePlatform, urlPath) in nonSteamGames {
            var isMacGame = false
            for (_, platform) in namePlatform {
                if platform.name == "Mac" {
                    isMacGame = true
                    break
                }
            }
            if isMacGame {
                macGames.append((namePlatform: namePlatform, urlPath: urlPath))
            } else {
                otherGames.append((namePlatform: namePlatform, urlPath: urlPath))
            }
        }

        func saveGames(_ games: [(namePlatform: [String: Platform], urlPath: String)]) async {
            for (namePlatform, urlPath) in games {
                for (name, platform) in namePlatform {
                    if !doneGames.contains(name) {
                        await saveSupabaseGame(name, platform: platform.name, launcher: String(format: platform.commandTemplate, urlPath)) { gameFound, game in
                            if gameFound {
                                var icon: String?
                                if platform.name == "Mac" {
                                    if Defaults[.getIconFromApp] {
                                        if let appIcon = saveIconToFile(iconNSImage: NSWorkspace.shared.icon(forFile: urlPath), gameID: game.id) {
                                            icon = appIcon
                                        }
                                    }
                                }
                                var newGame = game
                                newGame.icon = icon ?? ""
                                newGames.append(newGame)
                                doneGames.insert(name)
                            }
                        }
                    }
                }
            }
        }
        await saveGames(otherGames)
        await saveGames(macGames)
        
        
        addGames(newGames)
    }

    
    func saveSupabaseGame(_ name: String, steamID: String? = nil, platform: String, launcher: String, completion: @escaping (Bool, Game) -> Void) async {
        var fetchedGames: [SupabaseGame] = []
        if let steamID = steamID {
            fetchedGames = await self.supabaseViewModel.fetchGamesFromSteamID(steamID: steamID)
        } else {
            fetchedGames = await self.supabaseViewModel.fetchGamesFromName(name: name)
        }
        let supabaseGame = fetchedGames.sorted(by: { $0.igdb_id < $1.igdb_id }).first(where: { game in
            if let gameName = game.name {
                if gameName.lowercased() == name.lowercased() {
                    return true
                }
            }
            return false
        }) ?? fetchedGames.sorted(by: { $0.igdb_id < $1.igdb_id }).first(where: { game in
            if let gameName = game.name {
                if gameName.lowercased().contains(name.lowercased()) || name.lowercased().contains(gameName.lowercased()) {
                    return true
                }
            }
            return false
        })
        if let supabaseGame = supabaseGame {
            self.supabaseViewModel.convertSupabaseGame(supabaseGame: supabaseGame, game: Game(id: UUID(), launcher: launcher, name: name, platformName: platform)) { game in
                completion(true, game)
            }
        }
    }
}
