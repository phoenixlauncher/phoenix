//
//  GameListItem.swift
//  Phoenix
//
//  Created by jxhug on 11/20/23.
//

import SwiftUI

struct GameListItem: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel

    @State var gameIndex: Int
    
    @Default(.listIconSize) var iconSize
    @Default(.listIconsHidden) var iconsHidden
    
    @State var isImporting: Bool = false
    @State var importType: String = "icon"
    
    var body: some View {
        HStack {
            if !iconsHidden && gameViewModel.games[gameIndex].icon != "" {
                Image(nsImage: loadImageFromFile(filePath: gameViewModel.games[gameIndex].icon))
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
            }
            Text(gameViewModel.games[gameIndex].name)
        }
        .contextMenu {
            Button(action: {
                gameViewModel.games[gameIndex].isFavorite.toggle()
                gameViewModel.saveGames()
            }) {
                Image(systemName: gameViewModel.games[gameIndex].isFavorite ? "star.slash" : "star")
                Text("\(gameViewModel.games[gameIndex].isFavorite ? String(localized: "context_Unfavorite") : String(localized: "context_Favorite")) \(String(localized: "context_Game"))")
            }
            .accessibility(identifier: String(localized: "context_FavoriteGame"))
            Button(action: {
                gameViewModel.games[gameIndex].isHidden = true
                gameViewModel.selectedGame = gameViewModel.games[0].id
                gameViewModel.saveGames()
            }) {
                Image(systemName: "eye.slash")
                Text(LocalizedStringKey("context_HideGame"))
            }
            .accessibility(identifier: String(localized: "context_HideGame"))
            Button(action: {
                gameViewModel.games.remove(at: gameIndex)
                gameViewModel.selectedGame = gameViewModel.games[0].id
                gameViewModel.saveGames()
            }) {
                Image(systemName: "trash")
                Text(LocalizedStringKey("context_DeleteGame"))
            }
            .accessibility(identifier: String(localized: "context_DeleteGame"))
            Divider()
            Button(action: {
                isImporting.toggle()
                importType = "icon"
            }) {
                HStack {
                    Image(systemName: "app.dashed")
                    Text(LocalizedStringKey("context_EditIcon"))
                }
            }
            .accessibility(identifier: String(localized: "context_EditIcon"))
            .padding()
            Button(action: {
                isImporting.toggle()
                importType = "header"
            }) {
                HStack {
                    Image(systemName: "photo")
                    Text(LocalizedStringKey("context_EditHeader"))
                }
            }
            .accessibility(identifier: String(localized: "context_EditHeader"))
            .padding()
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            resultIntoData(result: result) { data in
                if importType == "icon" {
                    saveIconToFile(iconData: data, gameID: gameViewModel.games[gameIndex].id) { image in
                        gameViewModel.games[gameIndex].icon = image
                        gameViewModel.saveGames()
                    }
                } else {
                    saveImageToFile(data: data, gameID: gameViewModel.games[gameIndex].id, type: importType) { image in
                        gameViewModel.games[gameIndex].metadata["header_img"] = image
                        gameViewModel.saveGames()
                    }
                }
            }
        }
    }
}
