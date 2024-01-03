//
//  GameListItem.swift
//  Phoenix
//
//  Created by jxhug on 11/20/23.
//

import SwiftUI

struct GameListItem: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    
    @Binding var selectedGame: UUID
    @State var game: Game
    @Binding var refresh: Bool
    @State var iconSize: Double = Defaults[.listIconSize]
    @State var iconsHidden: Bool = Defaults[.listIconsHidden]
    
    @State var isImporting: Bool = false
    @State var importType: String = "icon"
    
    var body: some View {
        HStack {
            if !iconsHidden && game.icon != "" {
                Image(nsImage: loadImageFromFile(filePath: game.icon))
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
            }
            Text(game.name)
        }
        .contextMenu {
            Button(action: {
                if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                    gameViewModel.games[idx].isFavorite.toggle()
                }
                gameViewModel.saveGames()
            }) {
                Image(systemName: game.isFavorite ? "star.slash" : "star")
                Text("\(game.isFavorite ? "Unfavorite" : "Favorite") game")
            }
            .accessibility(identifier: "Favorite game")
            Button(action: {
                if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                    gameViewModel.games[idx].isHidden = true
                }
                selectedGame = gameViewModel.games[0].id
                gameViewModel.saveGames()
            }) {
                Image(systemName: "eye.slash")
                Text("Hide game")
            }
            .accessibility(identifier: "Hide game")
            Button(action: {
                if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                    gameViewModel.games.remove(at: idx)
                }
                selectedGame = gameViewModel.games[0].id
                gameViewModel.saveGames()
            }) {
                Image(systemName: "trash")
                Text("Delete game")
            }
            .accessibility(identifier: "Delete game")
            Divider()
            Button(action: {
                isImporting.toggle()
                importType = "icon"
            }) {
                HStack {
                    Image(systemName: "app.dashed")
                    Text("Edit icon")
                }
            }
            .accessibility(identifier: "Edit icon")
            .padding()
            Button(action: {
                isImporting.toggle()
                importType = "header"
            }) {
                HStack {
                    Image(systemName: "photo")
                    Text("Edit header")
                }
            }
            .accessibility(identifier: "Edit header")
            .padding()
        }
        .onChange(of: Defaults[.listIconSize]) { value in
            iconSize = value
        }
        .onChange(of: Defaults[.listIconsHidden]) { value in
            iconsHidden = value
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            resultIntoData(result: result) { data in
                if importType == "icon" {
<<<<<<< HEAD
                    saveIconToFile(iconData: data, gameID: selectedGame) { image in
                        if let idx = games.firstIndex(where: { $0.id == selectedGame }) {
                            games[idx].icon = image
=======
                    saveIconToFile(iconData: data, gameID: game.id) { image in
                        if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                            gameViewModel.games[idx].icon = image
>>>>>>> 2e1e90c (mvvm basics)
                            game.icon = image
                            refresh.toggle()
                            gameViewModel.saveGames()
                        }
                    }
                } else {
<<<<<<< HEAD
                    saveImageToFile(data: data, gameID: selectedGame, type: importType) { image in
                        if let idx = games.firstIndex(where: { $0.id == selectedGame }) {
                            games[idx].metadata["header_img"] = image
                            saveGames()
=======
                    saveImageToFile(data: data, gameID: game.id, type: importType) { image in
                        if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                            gameViewModel.games[idx].metadata["header_img"] = image
                            gameViewModel.saveGames()
>>>>>>> 2e1e90c (mvvm basics)
                        }
                    }
                }
            }
        }
    }
}
