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
                //toggle favorite button
                ContextButton(action: {
                    gameViewModel.toggleFavoriteFromID(game.id)
                }, symbol: game.isFavorite ? "star.slash" : "star", text: "\(game.isFavorite ? String(localized: "context_Unfavorite") : String(localized: "context_Favorite")) \(String(localized: "context_Game"))")
                
                //toggle hidden button
                ContextButton(action: {
                    gameViewModel.toggleHiddenFromID(game.id)
                    if gameViewModel.games.indices.contains(0) {
                        gameViewModel.selectedGame = gameViewModel.games[0].id
                    }
                }, symbol: "eye.slash", text: String(localized: ("context_HideGame")))
                
                //delete game button
                ContextButton(action: {
                    gameViewModel.deleteGameFromID(game.id)
                    if gameViewModel.games.indices.contains(0) {
                        gameViewModel.selectedGame = gameViewModel.games[0].id
                    }
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
                ContextButtonMenu(forEachEnum: Platform.self, action: { editPlatform(thing: $0, id: game.id) }, symbol: "gamecontroller", text: String(localized: "context_EditPlatform"))
        
                //edit platform menu
                ContextButtonMenu(forEachEnum: Status.self, action: { editStatus(thing: $0, id: game.id) }, symbol: "trophy", text: String(localized: "context_EditStatus"))
                
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
    
    private func editIcon() {
        isImporting.toggle()
        importType = "icon"
    }
    
    private func editHeader() {
        isImporting.toggle()
        importType = "header"
    }
    
    func editPlatform(thing: any CaseIterableEnum, id: UUID) {
        if let idx = gameViewModel.games.firstIndex(where: { $0.id == id }), thing is Platform {
            gameViewModel.games[idx].platform = thing as! Platform
        }
        gameViewModel.saveGames()
    }
    
    func editStatus(thing: any CaseIterableEnum, id: UUID) {
        if let idx = gameViewModel.games.firstIndex(where: { $0.id == id }), thing is Status {
            gameViewModel.games[idx].status = thing as! Status
        }
        gameViewModel.saveGames()
    }
}

