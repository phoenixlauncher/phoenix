//
//  GameListItem.swift
//  Phoenix
//
//  Created by jxhug on 11/20/23.
//

import SwiftUI

struct GameListItem: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var platformViewModel: PlatformViewModel

    @State var gameID: UUID
    let filteredGames: [Game]
    
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
                //toggle favorite button
                ContextButton(action: {
                    gameViewModel.toggleFavoriteFromID(game.id)
                }, symbol: game.isFavorite ? "star.slash" : "star", text: "\(game.isFavorite ? String(localized: "context_Unfavorite") : String(localized: "context_Favorite")) \(String(localized: "context_Game"))")
                
                //toggle hidden button
                ContextButton(action: {
                    hide(id: game.id)
                }, symbol: "eye.slash", text: String(localized: ("context_HideGame")))
                
                //delete game button
                ContextButton(action: {
                    delete(id: game.id)
                }, symbol: "trash", text: String(localized: "context_DeleteGame"))

                Divider()
                
                //edit name button
                ContextButton(action: { changeName.toggle() }, symbol: "character.cursor.ibeam", text: String(localized: "context_EditName"))
                
                //edit icon button
                ContextButton(action: editIcon, symbol: "app.dashed", text: String(localized: "context_EditIcon"))

                //edit header button
                ContextButton(action: editHeader, symbol: "photo", text: String(localized: "context_EditHeader"))
                
                Divider()
                
                //edit platform menu
                PlatformContextButtonMenu(platforms: platformViewModel.platforms, action: { editPlatform(platform: $0, id: game.id) }, symbol: "gamecontroller", text: String(localized: "context_EditPlatform"))
        
                //edit platform menu
                EnumContextButtonMenu(forEachEnum: Status.self, action: { editStatus(status: $0, id: game.id) }, symbol: "trophy", text: String(localized: "context_EditStatus"))
                
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
                do {
                    if let path = try result.get().first {
                        if let data = pathIntoData(path: path) {
                            if importType == "icon" {
                                if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }), let icon = saveIconToFile(iconData: data, gameID: game.id) {
                                    gameViewModel.games[idx].icon = icon
                                    gameViewModel.saveGames()
                                }
                            } else {
                                if let idx = gameViewModel.games.firstIndex(where: { $0.id == game.id }), let image = saveImageToFile(data: data, gameID: game.id, type: importType) {
                                    gameViewModel.games[idx].metadata["header_img"] = image
                                    gameViewModel.saveGames()
                                }
                            }
                        }
                    }
                }
                catch {
                    logger.write(error.localizedDescription)
                }
            }
            .onAppear {
                name = game.name
            }
        }
    }
    
    private func editIcon() {
        isImporting.toggle()
        importType = "icon"
    }
    
    private func editHeader() {
        isImporting.toggle()
        importType = "header"
    }
    
    func editPlatform(platform: Platform, id: UUID) {
        if gameViewModel.selectedGameIDs.count > 1 {
            for id in gameViewModel.selectedGameIDs {
                if let idx = gameViewModel.games.firstIndex(where: { $0.id == id }) {
                    gameViewModel.games[idx].platformName = platform.name
                }
            }
        } else {
            if let idx = gameViewModel.games.firstIndex(where: { $0.id == id }) {
                gameViewModel.games[idx].platformName = platform.name
            }
        }
        gameViewModel.selectedGameIDs = []
        gameViewModel.saveGames()
    }
    
    func editStatus(status: Status, id: UUID) {
        if gameViewModel.selectedGameIDs.count > 1 {
            for id in gameViewModel.selectedGameIDs {
                if let idx = gameViewModel.games.firstIndex(where: { $0.id == id }) {
                    gameViewModel.games[idx].status = status
                }
            }
        } else {
            if let idx = gameViewModel.games.firstIndex(where: { $0.id == id }) {
                gameViewModel.games[idx].status = status
            }
        }
        gameViewModel.selectedGameIDs = []
        gameViewModel.saveGames()
    }
    
    func hide(id: UUID) {
        if gameViewModel.selectedGameIDs.count > 1 {
            for id in gameViewModel.selectedGameIDs {
                gameViewModel.toggleHiddenFromID(id)
            }
        } else {
            gameViewModel.toggleHiddenFromID(id)
        }
        gameViewModel.selectedGameIDs = []
        if let firstID = filteredGames.first?.id {
            gameViewModel.selectedGameIDs.insert(firstID)
        }
        gameViewModel.saveGames()
    }
    
    func delete(id: UUID) {
        if gameViewModel.selectedGameIDs.count > 1 {
            for id in gameViewModel.selectedGameIDs {
                gameViewModel.deleteGameFromID(id)
            }
        } else {
            gameViewModel.deleteGameFromID(id)
        }
        gameViewModel.selectedGameIDs = []
        if let firstID = filteredGames.first?.id {
            gameViewModel.selectedGameIDs.insert(firstID)
        }
        gameViewModel.saveGames()
    }
}

