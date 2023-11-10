//
//  GameListView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-28.
//
import SwiftUI

struct GameListView: View {
    
    @Binding var sortBy: PhoenixApp.SortBy
    @Binding var selectedGame: UUID
    @Binding var refresh: Bool
    @Binding var searchText: String
    @Binding var isAddingGame: Bool
    @State private var timer: Timer?
    @State private var minWidth: CGFloat = 296
    
    @Default(.showSortByNumber) var showSortByNumber
    @Default(.showSidebarAddGameButton) var showSidebarAddGameButton
    @Default(.accentColorUI) var accentColorUI
    @Default(.gradientUI) var gradientUI
    
    var body: some View {
        VStack {
            List(selection: $selectedGame) {
                let favoriteGames = games.filter {
                    $0.isHidden == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.isFavorite == true
                }
                if !favoriteGames.isEmpty {
                    Section(header: Text("Favorites \(showSortByNumber ? "(\(favoriteGames.count))" : "")")) {
                        ForEach(favoriteGames, id: \.id) { game in
                            GameListItem(selectedGame: $selectedGame, game: game, refresh: $refresh)
                        }
                    }
                }
                switch sortBy {
                case .platform:
                    ForEach(Platform.allCases, id: \.self) { platform in
                        let gamesForPlatform = games.filter {
                            $0.platform == platform && $0.isHidden == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.isFavorite == false
                        }
                        if !gamesForPlatform.isEmpty {
                            Section(header: Text("\(platform.displayName) \(showSortByNumber ? "(\(gamesForPlatform.count))" : "")")) {
                                ForEach(gamesForPlatform, id: \.id) { game in
                                    GameListItem(selectedGame: $selectedGame, game: game, refresh: $refresh)
                                }
                            }
                        }
                    }
                case .status:
                    ForEach(Status.allCases, id: \.self) { status in
                        let gamesForStatus = games.filter {
                            $0.status == status && $0.isHidden == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.isFavorite == false
                        }
                        if !gamesForStatus.isEmpty {
                            Section(header: Text("\(status.displayName) \(showSortByNumber ? "(\(gamesForStatus.count))" : "")")) {
                                ForEach(gamesForStatus, id: \.id) { game in
                                    GameListItem(selectedGame: $selectedGame, game: game, refresh: $refresh)
                                }
                            }
                        }
                    }
                case .name:
                    let gamesForName = games.filter {
                        $0.isHidden == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.isFavorite == false
                    }
                    if !gamesForName.isEmpty {
                        Section(header: Text("Name")) {
                            ForEach(gamesForName, id: \.id) { game in
                                GameListItem(selectedGame: $selectedGame, game: game, refresh: $refresh)
                            }
                        }
                    }
                case .recency:
                    ForEach(Recency.allCases, id: \.self) { recency in
                        let gamesForRecency = games.filter {
                            $0.recency == recency && $0.isHidden == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.isFavorite == false
                        }
                        if !gamesForRecency.isEmpty {
                            Section(header: Text("\(recency.displayName) \(showSortByNumber ? "(\(gamesForRecency.count))" : "")")) {
                                ForEach(gamesForRecency, id: \.id) { game in
                                    GameListItem(selectedGame: $selectedGame, game: game, refresh: $refresh)
                                }
                            }
                        }
                    }
                }
            }
            
            if showSidebarAddGameButton {
                Button(action: {
                    isAddingGame.toggle()
                }, label: {
                    Image(systemName: "plus.app")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white)
                    Text("Add new game")
                        .foregroundColor(Color.white)
                        .font(.system(size: 15))
                })
                .buttonStyle(.plain)
                .frame(minWidth: 200, maxWidth: .infinity, maxHeight: 35)
                .background(
                    Group {
                        if gradientUI {
                            LinearGradient(
                                colors: [accentColorUI ? Color.accentColor : Color.blue,
                                         accentColorUI ? Color.accentColor.opacity(0.7) : Color.blue.opacity(0.7)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                            .cornerRadius(7.5) // Adjust the corner radius value as needed
                        } else {
                            (accentColorUI ? Color.accentColor : Color.blue)
                                .cornerRadius(7.5) // Adjust the corner radius value as needed
                        }
                    }
                )
                .padding()
            }
        }
        .frame(minWidth: Defaults[.showPickerText] ? 296 : 245)
    }
}

struct GameListItem: View {
    @Binding var selectedGame: UUID
    @State var game: Game
    @Binding var refresh: Bool
    @State var iconSize: Double = Defaults[.listIconSize]
    @State var iconsHidden: Bool = Defaults[.listIconsHidden]
    
    var body: some View {
        HStack {
            if !iconsHidden {
                Image(nsImage: loadImageFromFile(filePath: game.icon))
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
            }
            Text(game.name)
        }
        .contextMenu {
            Button(action: {
                if let idx = games.firstIndex(where: { $0.id == game.id }) {
                    games[idx].isFavorite.toggle()
                }
                saveGames()
            }) {
                Text("\(game.isFavorite ? "Unfavorite" : "Favorite") game")
            }
            .accessibility(identifier: "Favorite Game")
            Button(action: {
                if let idx = games.firstIndex(where: { $0.id == game.id }) {
                    games[idx].isHidden = true
                }
                selectedGame = games[0].id
                saveGames()
            }) {
                Text("Hide game")
            }
            .accessibility(identifier: "Hide Game")
            Button(action: {
                if let idx = games.firstIndex(where: { $0.id == game.id }) {
                    games.remove(at: idx)
                }
                selectedGame = games[0].id
                saveGames()
            }) {
                Text("Delete game")
            }
            .accessibility(identifier: "Delete Game")
        }
        .onChange(of: Defaults[.listIconSize]) { value in
            iconSize = value
        }
        .onChange(of: Defaults[.listIconsHidden]) { value in
            iconsHidden = value
        }
    }
}
