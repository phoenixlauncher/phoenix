//
//  GameListItem.swift
//  Phoenix
//
//  Created by jxhug on 11/20/23.
//

import SwiftUI

struct GameListItem: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel

    @State var gameID: UUID
    
    var game: Game? {
        gameViewModel.getGameFromID(id: gameID) ?? nil
     }
    
    @Default(.listIconSize) var iconSize
    @Default(.listIconsHidden) var iconsHidden
    
    @State var changeName: Bool = false
    @State var name: String = "uwuwuwu"
    @State var isImporting: Bool = false
    @State var importType: String = "icon"
    
    var body: some View {
        if let game = game {
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
                    gameViewModel.selectedGame = gameViewModel.games[0].id
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
                    gameViewModel.selectedGame = gameViewModel.games[0].id
                    gameViewModel.saveGames()
                }) {
                    Image(systemName: "trash")
                    Text("Delete game")
                }
                .accessibility(identifier: "Delete game")
                Divider()
                Button(action: {
                    changeName.toggle()
                }) {
                    HStack {
                        Image(systemName: "character.cursor.ibeam")
                        Text("Edit name")
                    }
                }
                .accessibility(identifier: "Edit name")
                .padding()
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
            .sheet(isPresented: $changeName) {
                TextBoxAlert(text: $name, saveAction: {
                    if let idx = gameViewModel.games.firstIndex(where: { $0.name == game.name }) {
                        gameViewModel.games[idx].name = name
                        gameViewModel.saveGames()
                    }
                }) 
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.image],
                allowsMultipleSelection: false
            ) { result in
                resultIntoData(result: result) { data in
                    if importType == "icon" {
                        saveIconToFile(iconData: data, gameID: game.id) { image in
                            if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                                gameViewModel.games[idx].icon = image
                                gameViewModel.saveGames()
                            }
                        }
                    } else {
                        saveImageToFile(data: data, gameID: game.id, type: importType) { image in
                            if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                                gameViewModel.games[idx].metadata["header_img"] = image
                                gameViewModel.saveGames()
                            }
                        }
                    }
                }
            }
            .onAppear {
                name = game.name
            }
        }
    }
}
