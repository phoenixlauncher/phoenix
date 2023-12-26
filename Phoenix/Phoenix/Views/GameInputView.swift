//
//  GameInputView.swift
//  Phoenix
//
//  Created by James Hughes onon 2022-12-27.
//
import Foundation
import SwiftUI
import AlertToast

struct GameInputView: View {
    @Environment(\.dismiss) private var dismiss
    
    var isNewGame: Bool
    @Binding var selectedGame: UUID
    @Binding var refresh: Bool
    
    @Binding var showSuccessToast: Bool
    @Binding var successToastText: String
    
    @Binding var showFailureToast: Bool
    @Binding var failureToastText: String
    
    @State private var showChooseGameView: Bool = false
    @State var chooseGameViewDone = false
    
    @State var fetchedGames: [SupabaseGame] = []
    
    @State private var id: UUID?
    
    @State private var nameInput: String = ""
    @State private var iconInput: String = ""
    @State private var platInput: Platform = .none
    @State private var statusInput: Status = .none
    @State private var cmdInput: String = ""
    @State private var descInput: String = ""
    @State private var headerInput: String = ""
    @State private var coverInput: String = ""
    @State private var rateInput: String = ""
    @State private var genreInput: String = ""
    @State private var devInput: String = ""
    @State private var pubInput: String = ""
    @State private var dateInput: Date = .now

    @State private var iconIsImporting: Bool = false
    @State private var headIsImporting: Bool = false
    @State private var coverIsImporting: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    TextBox(textBoxName: "Name", placeholder: "Enter game name", input: $nameInput) // Name input
                    
                    ImageImportButton(type: "Icon", isImporting: $iconIsImporting, output: $iconInput, gameID: selectedGame)
        
                    SlotInput(contentName: "Platform", content: {
                        Picker("", selection: $platInput) {
                            ForEach(Platform.allCases) { platform in
                                Text(platform.displayName)
                            }
                        }
                    })
                    
                    SlotInput(contentName: "Status", content: {
                        Picker("", selection: $statusInput) {
                            ForEach(Status.allCases) { status in
                                Text(status.displayName)
                            }
                        }
                    })
                    
                    TextBox(textBoxName: "Command", placeholder: "Enter terminal command to launch game", input: $cmdInput)
                }
                DisclosureGroup("Advanced") {
                    VStack(alignment: .leading) {
                        LargeTextBox(textBoxName: "Description", input: $descInput)
                        
                        LargeTextBox(textBoxName: "Genres", input: $genreInput)
                        
                        ImageImportButton(type: "Header", isImporting: $headIsImporting, output: $headerInput, gameID: selectedGame)
                        
                        ImageImportButton(type: "Cover", isImporting: $coverIsImporting, output: $coverInput, gameID: selectedGame)
                        
                        if !Defaults[.showStarRating] {
                            TextBox(textBoxName: "Rating", placeholder: "X / 10", input: $rateInput)
                        }
                        
                        TextBox(textBoxName: "Developer", placeholder: "Enter game developer", input: $devInput)
                        
                        TextBox(textBoxName: "Publisher", placeholder: "Enter game publisher", input: $pubInput)
                        
                        DatePicker("Release Date", selection: $dateInput, in: ...Date(), displayedComponents: .date)
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
                                var game: Game = .init(
                                    id: id ?? UUID(), launcher: cmdInput, metadata: ["description": descInput, "header_img": headerInput, "cover": coverInput, "rating": rateInput, "genre": genreInput, "developer": devInput, "publisher": pubInput, "release_date": convertIntoString(input: dateInput)], icon: iconInput, name: nameInput, platform: platInput, status: statusInput
                                )
                                if let idx = games.firstIndex(where: { $0.id == selectedGame }) {
                                    game.recency = games[idx].recency
                                    game.isFavorite = games[idx].isFavorite
                                    games[idx] = game
                                    saveGames()
                                }
                                Task {
                                    await FetchSupabaseData().fetchGamesFromName(name: game.name) { result in
                                        fetchedGames = result
                                        saveGames()
                                        if fetchedGames.count != 0 {
                                            successToastText  = "Game saved!"
                                            showChooseGameView.toggle()
                                        } else {
                                            failureToastText = "No games found."
                                            showFailureToast = true
                                            dismiss()
                                        }
                                    }
                                }
                                selectedGame = game.id
                            },
                            label: {
                                Text("Fetch Metadata")
                            }
                        )
                    }
                    Button(
                        action: {
                            guard !nameInput.isEmpty && !nameInput.trimmingCharacters(in: .whitespaces).isEmpty else {
                                failureToastText = "Game must have a name."
                                showFailureToast = true
                                dismiss()
                                return
                            }
                            var game: Game = .init(
                                id: id ?? UUID(), launcher: cmdInput, metadata: ["description": descInput, "header_img": headerInput, "cover": coverInput, "rating": rateInput, "genre": genreInput, "developer": devInput, "publisher": pubInput, "release_date": convertIntoString(input: dateInput)], icon: iconInput, name: nameInput, platform: platInput, status: statusInput
                            )
                            if isNewGame {
                                games.append(game)
                                saveGames()
                                refresh.toggle()
                                if Defaults[.isMetaDataFetchingEnabled] {
                                    Task {
                                        await FetchSupabaseData().fetchGamesFromName(name: game.name) { result in
                                            fetchedGames = result
                                            if fetchedGames.count != 0 {
                                                successToastText = "Game created!"
                                                showChooseGameView.toggle()
                                            } else {
                                                failureToastText = "No games found."
                                                showFailureToast = true
                                                dismiss()
                                            }
                                        }
                                    }
                                }
                            } else {
                                if let idx = games.firstIndex(where: { $0.id == selectedGame }) {
                                    game.recency = games[idx].recency
                                    game.isFavorite = games[idx].isFavorite
                                    games[idx] = game
                                    saveGames()
                                    successToastText = "Game saved!"
                                    showSuccessToast = true
                                } else {
                                    failureToastText = "Game couldn't be found."
                                    showFailureToast = true
                                }
                                dismiss()
                            }
                        },
                        label: {
                            Text("Save Game")
                        }
                    )
                    .accessibilityLabel("Save Game")
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
                showSuccessToast = true
            }
        }, content: {
            ChooseGameView(games: $fetchedGames, gameID: selectedGame, done: $chooseGameViewDone)
        })
        .onAppear() {
            if !isNewGame, let idx = games.firstIndex(where: { $0.id == selectedGame }) {
                let currentGame = games[idx]
                id = currentGame.id
                nameInput = currentGame.name
                iconInput = currentGame.icon
                platInput = currentGame.platform
                statusInput = currentGame.status
                cmdInput = currentGame.launcher
                descInput = currentGame.metadata["description"] ?? ""
                genreInput = currentGame.metadata["genre"] ?? ""
                headerInput = currentGame.metadata["header_img"] ?? ""
                rateInput = currentGame.metadata["rating"] ?? ""
                devInput = currentGame.metadata["developer"] ?? ""
                pubInput = currentGame.metadata["publisher"] ?? ""
                // Create Date Formatter
                dateInput = convertIntoDate(input: currentGame.metadata["release_date"] ?? "")
            }
        }
    }
}
