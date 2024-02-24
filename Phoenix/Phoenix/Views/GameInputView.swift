//
//  GameInputView.swift
//  Phoenix
//
//  Created by James Hughes on 2022-12-27.
//
import Foundation
import SwiftUI
import AlertToast

struct GameInputView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var supabaseViewModel: SupabaseViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var isNewGame: Bool
    
    @State private var showChooseGameView: Bool = false
    @State var chooseGameViewDone = false
    
    @State var fetchedGames: [SupabaseGame] = []
    
    @State private var game: Game = Game()
    @State private var iconInput: String = ""
    @State private var headerInput: String = ""
    @State private var coverInput: String = ""
    @State private var dateInput: Date = .now

    @State private var iconIsImporting: Bool = false
    @State private var headIsImporting: Bool = false
    @State private var coverIsImporting: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    TextBox(textBoxName: String(localized: "editGame_Name"), placeholder: String(localized: "editGame_NameDesc"), input: $game.name) // Name input
                    
                    ImageImportButton(type: String(localized: "editGame_Icon"), isImporting: $iconIsImporting, input: $iconInput, output: $game.icon, gameID: gameViewModel.selectedGame)
        
                    SlotInput(contentName: String(localized: "editGame_Platform"), content: {
                        Picker("", selection: $game.platform) {
                            ForEach(Platform.allCases) { platform in
                                Text(platform.displayName)
                            }
                        }
                    })
                    
                    SlotInput(contentName: String(localized: "editGame_Status"), content: {
                        Picker("", selection: $game.status) {
                            ForEach(Status.allCases) { status in
                                Text(status.displayName)
                            }
                        }
                    })
                    
                    TextBox(textBoxName: String(localized: "editGame_Command"), placeholder: String(localized: "editGame_CommandDesc"), input: $game.launcher)
                }
                DisclosureGroup(String(localized: "editGame_Advanced")) {
                    VStack(alignment: .leading) {
                        LargeTextBox(textBoxName: String(localized: "editGame_Desc"), input: binding(for: "description"))
                        
                        LargeTextBox(textBoxName: String(localized: "editGame_Genres"), input: binding(for: "genre"))
                        
                        ImageImportButton(type: String(localized: "editGame_Header"), isImporting: $headIsImporting, input: $headerInput, output: binding(for: "header_img"), gameID: gameViewModel.selectedGame)
                        
                        ImageImportButton(type: String(localized: "editGame_Cover"), isImporting: $coverIsImporting, input: $coverInput, output: binding(for: "cover"), gameID: gameViewModel.selectedGame)
                        
                        if !Defaults[.showStarRating] {
                            TextBox(textBoxName: String(localized: "editGame_Rating"), placeholder: "X / 10", input: binding(for: "rating"))
                        }
                        
                        TextBox(textBoxName: String(localized: "editGame_Dev"), placeholder: String(localized: "editGame_DevDesc"), input: binding(for: "developer"))
                        
                        TextBox(textBoxName: String(localized: "editGame_Pub"), placeholder: String(localized: "editGame_PubDesc"), input: binding(for: "publisher"))
                        
                        DatePicker(String(localized: "editGame_Release"), selection: $dateInput, in: ...Date(), displayedComponents: .date)
                            .padding()
                    }
                }
            }
            .padding()
            HStack {
                Spacer().frame(maxWidth: .infinity)
                HStack {
                    if !isNewGame {
                        Button (
                            action: {
                                if let idx = gameViewModel.games.firstIndex(where: { $0.id == gameViewModel.selectedGame }) {
                                    game.recency = gameViewModel.games[idx].recency
                                    game.isFavorite = gameViewModel.games[idx].isFavorite
                                    gameViewModel.games[idx] = game
                                    gameViewModel.saveGames()
                                }
                                Task {
                                    await supabaseViewModel.fetchGamesFromName(name: game.name) { result in
                                        fetchedGames = result
                                        gameViewModel.saveGames()
                                        if fetchedGames.count != 0 {
                                            showChooseGameView.toggle()
                                        } else {
                                            appViewModel.showFailureToast(String(localized: "toast_NoGamesFailure"))
                                            dismiss()
                                        }
                                    }
                                }
                                gameViewModel.selectedGame = game.id
                            },
                            label: {
                                Text(LocalizedStringKey("editGame_Fetch"))
                            }
                        )
                    }
                    Button(
                        action: {
                            guard !game.name.isEmpty && !game.name.trimmingCharacters(in: .whitespaces).isEmpty else {
                                appViewModel.showFailureToast(String(localized: "toast_NoNameFailure"))
                                dismiss()
                                return
                            }
                            if isNewGame {
                                if Defaults[.isMetaDataFetchingEnabled] {
                                    Task {
                                        await supabaseViewModel.fetchGamesFromName(name: game.name) { result in
                                            fetchedGames = result
                                            if fetchedGames.count != 0 {
                                                showChooseGameView.toggle()
                                            } else {
                                                gameViewModel.games.append(game)
                                                gameViewModel.selectedGame = game.id
                                                appViewModel.showFailureToast(String(localized: "editGame_NoGamesFailure"))
                                                dismiss()
                                            }
                                        }
                                    }
                                }
                            } else {
                                if let idx = gameViewModel.games.firstIndex(where: { $0.id == gameViewModel.selectedGame }) {
                                    game.recency = gameViewModel.games[idx].recency
                                    game.isFavorite = gameViewModel.games[idx].isFavorite
                                    gameViewModel.games[idx] = game
                                    gameViewModel.selectedGame = game.id
                                    gameViewModel.saveGames()
                                    appViewModel.showSuccessToast(String(localized: "toast_GameSavedSuccess"))
                                } else {
                                    appViewModel.showFailureToast(String(localized: "toast_GameNotFoundFailure"))
                                }
                                dismiss()
                            }
                        },
                        label: {
                            Text(LocalizedStringKey("editGame_SaveGame"))
                        }
                    )
                    .accessibilityLabel(String(localized: "editGame_SaveGame"))
                    .padding()
                    .frame(maxWidth: .infinity)
                }

                HStack {
                    Spacer().frame(maxWidth: .infinity)
                    Spacer().frame(maxWidth: .infinity)
                    HelpButton()
                }
            }
        }
        .frame(minWidth: 768, maxWidth: 1024, maxHeight: 2000)
        .sheet(isPresented: $showChooseGameView, onDismiss: {
            if chooseGameViewDone {
                dismiss()
                appViewModel.showSuccessToast(String(localized: "toast_GameSavedSuccess"))
            }
        }, content: {
            ChooseGameView(supabaseGames: $fetchedGames, game: game, done: $chooseGameViewDone)
        })
        .onAppear() {
            if !isNewGame, let idx = gameViewModel.games.firstIndex(where: { $0.id == gameViewModel.selectedGame }) {
                let currentGame = gameViewModel.games[idx]
                game.id = currentGame.id
                game.name = currentGame.name
                game.icon = currentGame.icon
                game.platform = currentGame.platform
                game.status = currentGame.status
                game.launcher = currentGame.launcher
                game.metadata["description"] = currentGame.metadata["description"] ?? ""
                game.metadata["genre"] = currentGame.metadata["genre"] ?? ""
                game.metadata["header_img"] = currentGame.metadata["header_img"] ?? ""
                game.metadata["cover"] = currentGame.metadata["cover"] ?? ""
                game.metadata["rating"] = currentGame.metadata["rating"] ?? ""
                game.metadata["developer"] = currentGame.metadata["developer"] ?? ""
                game.metadata["publisher"] = currentGame.metadata["publisher"] ?? ""
                // Create Date Formatter
                dateInput = convertIntoDate(input: currentGame.metadata["release_date"] ?? "")
            } else {
                game.id = UUID()
            }
        }
    }
    
    private func binding(for key: String) -> Binding<String> {
        return Binding(get: {
            return self.game.metadata[key] ?? ""
        }, set: {
            self.game.metadata[key] = $0
        })
    }
}
