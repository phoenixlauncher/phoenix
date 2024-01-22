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
    @State var name: String = ""
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
                    Text("\(game.isFavorite ? String(localized: "context_Unfavorite") : String(localized: "context_Favorite")) \(String(localized: "context_Game"))")
                }
                .accessibility(identifier: String(localized: "context_FavoriteGame"))
                Button(action: {
                    if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                        gameViewModel.games[idx].isHidden = true
                    }
                    gameViewModel.selectedGame = gameViewModel.games[0].id
                    gameViewModel.saveGames()
                }) {
                    Image(systemName: "eye.slash")
                    Text(LocalizedStringKey("context_HideGame"))
                }
                .accessibility(identifier: String(localized: "context_HideGame"))
                Button(action: {
                    if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                        gameViewModel.games.remove(at: idx)
                    }
                    if gameViewModel.games.indices.contains(0) {
                        gameViewModel.selectedGame = gameViewModel.games[0].id
                    }
                    gameViewModel.saveGames()
                }) {
                    Image(systemName: "trash")
                    Text(LocalizedStringKey("context_DeleteGame"))
                }
                .accessibility(identifier: String(localized: "context_DeleteGame"))
                //edit name button
                Divider()
                Button(action: {
                    changeName.toggle()
                }) {
                    HStack {
                        Image(systemName: "character.cursor.ibeam")
                        Text(LocalizedStringKey("context_EditName"))
                    }
                }
                .accessibility(identifier: String(localized: "context_EditName"))
                .padding()
                //edit icon button
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
                //edit header button
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
                Divider()
                //edit platform menu
                Menu(content: {
                    ForEach(Platform.allCases) { platform in
                        Button(action: {
                            if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                                gameViewModel.games[idx].platform = platform
                            }
                            gameViewModel.saveGames()
                        }) {
                            Text(platform.displayName)
                        }
                        .accessibility(identifier: String(platform.displayName))
                        .padding()
                    }
                },
                label: {
                    HStack {
                        Image(systemName: "gamecontroller")
                        Text(LocalizedStringKey("context_EditPlatform"))
                    }
                })
                .accessibility(identifier: String(localized: "context_EditPlatform"))
                .padding()
                //edit status menu
                Menu(content: {
                    ForEach(Status.allCases) { status in
                        Button(action: {
                            if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }) {
                                gameViewModel.games[idx].status = status
                            }
                            gameViewModel.saveGames()
                        }) {
                            Text(status.displayName)
                        }
                        .accessibility(identifier: String(status.displayName))
                        .padding()
                    }
                },
                label: {
                    HStack {
                        Image(systemName: "trophy")
                        Text(LocalizedStringKey("context_EditStatus"))
                    }
                })
                .accessibility(identifier: String(localized: "context_EditStatus"))
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
