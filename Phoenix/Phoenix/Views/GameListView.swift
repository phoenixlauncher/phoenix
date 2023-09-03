//
//  GameListView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-28.
//
import SwiftUI

struct GameListView: View {
    
    @Binding var sortBy: PhoenixApp.SortBy
    @Binding var selectedGame: String?
    @Binding var refresh: Bool
    @Binding var searchText: String
    @State private var timer: Timer?
    @State private var iconSize: Double = 24
    @State private var minWidth: CGFloat = 296
    
    var body: some View {
        List(selection: $selectedGame) {
            let favoriteGames = games.filter {
                $0.is_deleted == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.is_favorite == true
            }
            if !favoriteGames.isEmpty {
                Section(header: Text("Favorites")) {
                    ForEach(favoriteGames, id: \.name) { game in
                        GameListItem(game: game, refresh: $refresh, iconSize: $iconSize)
                    }
                }
            }
            switch sortBy {
            case .platform:
                ForEach(Platform.allCases, id: \.self) { platform in
                    let gamesForPlatform = games.filter {
                        $0.platform == platform && $0.is_deleted == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.is_favorite == false
                    }
                    if !gamesForPlatform.isEmpty {
                        Section(header: Text(platform.displayName)) {
                            ForEach(gamesForPlatform, id: \.name) { game in
                                GameListItem(game: game, refresh: $refresh, iconSize: $iconSize)
                            }
                        }
                    }
                }
            case .status:
                ForEach(Status.allCases, id: \.self) { status in
                    let gamesForStatus = games.filter {
                        $0.status == status && $0.is_deleted == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.is_favorite == false
                    }
                    if !gamesForStatus.isEmpty {
                        Section(header: Text(status.displayName)) {
                            ForEach(gamesForStatus, id: \.name) { game in
                                GameListItem(game: game, refresh: $refresh, iconSize: $iconSize)
                            }
                        }
                        
                    }
                }
            case .name:
                let gamesForName = games.filter {
                    $0.is_deleted == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.is_favorite == false
                }
                if !gamesForName.isEmpty {
                    Section(header: Text("Name")) {
                        ForEach(gamesForName, id: \.name) { game in
                            GameListItem(game: game, refresh: $refresh, iconSize: $iconSize)
                        }
                    }
                }
            case .recency:
                ForEach(Recency.allCases, id: \.self) { recency in
                    let gamesForRecency = games.filter {
                        $0.recency == recency && $0.is_deleted == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.is_favorite == false
                    }
                    if !gamesForRecency.isEmpty {
                        Section(header: Text(recency.displayName)) {
                            ForEach(gamesForRecency, id: \.name) { game in
                                GameListItem(game: game, refresh: $refresh, iconSize: $iconSize)
                            }
                        }
                    }
                }
            }
            Text(String(refresh))
                .hidden()
        }
        .frame(minWidth: minWidth)
        .onAppear {
            if UserDefaults.standard.bool(forKey: "picker") {
                minWidth = 296
            } else {
                minWidth = 196
            }
            if UserDefaults.standard.double(forKey: "listIconSize") != 0 {
                iconSize = UserDefaults.standard.double(forKey: "listIconSize")
            }
            if UserDefaults.standard.bool(forKey: "listIconsHidden") {
                iconSize = 0
            } else {
                iconSize = UserDefaults.standard.double(forKey: "listIconSize")
            }
            if selectedGame == nil {
                selectedGame = games[0].name
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if UserDefaults.standard.bool(forKey: "picker") {
                    minWidth = 296
                } else {
                    minWidth = 196
                }
                if UserDefaults.standard.double(forKey: "listIconSize") != 0 {
                    iconSize = UserDefaults.standard.double(forKey: "listIconSize")
                }
                if UserDefaults.standard.bool(forKey: "listIconsHidden") {
                    iconSize = 0
                } else {
                    iconSize = UserDefaults.standard.double(forKey: "listIconSize")
                }
                refresh.toggle()
                // This code will be executed every 1 second
            }
        }
        .onDisappear {
            // Invalidate the timer when the view disappears
            timer?.invalidate()
            timer = nil
        }
    }
}

struct GameListItem: View {
    @State var game: Game
    @Binding var refresh: Bool
    @Binding var iconSize: Double
    
    var body: some View {
        HStack {
            Image(nsImage: loadImageFromFile(filePath: game.icon))
                .resizable()
                .frame(width: iconSize, height: iconSize)
            Text(game.name)
        }
        .contextMenu {
            Button(action: {
                favoriteGame(game, refresh: $refresh)
            }) {
                Text("\(game.is_favorite ? "Unfavorite" : "Favorite") game")
            }
            .accessibility(identifier: "Favorite Game")
            Button(action: {
                deleteGame(game, refresh: $refresh)
            }) {
                Text("Delete game")
            }
            .accessibility(identifier: "Favorite Game")
        }
    }
    
    /// Favorites a game from the games list by toggling its `is_favorite` property.
    ///
    /// - Parameters:
    ///   - game: The game to favorite / unfavorite.
    ///   - refresh: A binding to a Boolean value indicating whether the game list should be refreshed.
    func favoriteGame(_ game: Game, refresh: Binding<Bool>) {
        if let index = games.firstIndex(where: { $0.name == game.name }) {
            games[index].is_favorite.toggle()
            refresh.wrappedValue.toggle()
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            do {
                let gamesJSON = try encoder.encode(games)

                if var gamesJSONString = String(data: gamesJSON, encoding: .utf8) {
                    // Add the necessary JSON elements for the string to be recognized as type "Games" on next read
                    gamesJSONString = "{\"games\": \(gamesJSONString)}"
                    writeGamesToJSON(data: gamesJSONString)
                }
            } catch {
                logger.write(error.localizedDescription)
            }
        }
    }
    
    /// Deletes a game from the games list by setting its `is_deleted` property to `true`.
    ///
    /// - Parameters:
    ///   - game: The game to delete.
    ///   - refresh: A binding to a Boolean value indicating whether the game list should be refreshed.
    func deleteGame(_ game: Game, refresh: Binding<Bool>) {
        if let index = games.firstIndex(where: { $0.name == game.name }) {
            games[index].is_deleted = true
            refresh.wrappedValue.toggle()
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            do {
                let gamesJSON = try encoder.encode(games)

                if var gamesJSONString = String(data: gamesJSON, encoding: .utf8) {
                    // Add the necessary JSON elements for the string to be recognized as type "Games" on next read
                    gamesJSONString = "{\"games\": \(gamesJSONString)}"
                    writeGamesToJSON(data: gamesJSONString)
                }
            } catch {
                logger.write(error.localizedDescription)
            }
        }
    }
}
