//
//  AddGameView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-27.
//
import Foundation
import SwiftUI
import IGDB_SWIFT_API
import AlertToast

struct GameInputView: View {
    @Environment(\.dismiss) private var dismiss
    
    var isNewGame: Bool
    var gameName: String
    
    @Binding var showSuccessToast: Bool
    @State private var showDupeGameToast = false
    
    @State private var showChooseGameView: Bool = false
    
    @State var fetchedGames: [Proto_Game] = []
    @State var fetchedGame: Game?
    
    @State private var nameInput: String = ""
    @State private var iconOutput: String = ""
    @State private var platInput: Platform = .none
    @State private var statusInput: Status = .none
    @State private var cmdInput: String = ""
    @State private var descInput: String = ""
    @State private var headOutput: String = ""
    @State private var rateInput: String = ""
    @State private var genreInput: String = ""
    @State private var devInput: String = ""
    @State private var pubInput: String = ""
    @State private var dateInput: Date = .now

    @State private var iconIsImporting: Bool = false
    @State private var headIsImporting: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    TextBox(textBoxName: "Name", placeholder: "Enter game name", input: $nameInput) // Name input
                    
                    ImageImportButton(type: "Icon", isImporting: $iconIsImporting, output: $iconOutput, gameName: nameInput) 
        
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
                        
                        ImageImportButton(type: "Header", isImporting: $headIsImporting, output: $headOutput, gameName: nameInput)
                        
                        TextBox(textBoxName: "Rating", placeholder: "X / 10", input: $rateInput)
                        
                        TextBox(textBoxName: "Developer", placeholder: "Enter game developer", input: $devInput)
                        
                        TextBox(textBoxName: "Publisher", placeholder: "Enter game publisher", input: $pubInput)
                        
                        SlotInput(contentName: "Release Date", content: {
                            DatePicker("", selection: $dateInput, in: ...Date(), displayedComponents: .date)
                        })
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
                                FetchGameData().fetchGamesFromName(name: nameInput) { gamesWithName in
                                    fetchedGames = gamesWithName
                                    showChooseGameView.toggle()
                                }
                            },
                            label: {
                                Text("Fetch Metadata")
                            }
                        )
                    }
                    Button(
                        action: {
                            let game: Game = .init(
                                launcher: cmdInput, metadata: ["description": descInput, "header_img": headOutput, "rating": rateInput, "genre": genreInput, "developer": devInput, "publisher": pubInput, "release_date": convertIntoString(input: dateInput)], icon: iconOutput, name: nameInput, platform: platInput, status: statusInput
                            )
                            if isNewGame {
                                let dispatchGroup = DispatchGroup()
                                for i in games {
                                    dispatchGroup.enter()
                                    defer {
                                        dispatchGroup.leave()
                                    }
                                    if i.name == game.name {
                                        showDupeGameToast = true
                                    }
                                }
                                
                                dispatchGroup.notify(queue: .main) { // once for loop is over
                                    if !showDupeGameToast { // if no games are dupes
                                        games.append(game)
                                        games = games.sorted()
                                        saveGame()
                                        if UserDefaults.standard.bool(forKey: "isMetadataFetchingEnabled") {
                                            FetchGameData().fetchGamesFromName(name: nameInput) { gamesWithName in
                                                fetchedGames = gamesWithName
                                                showChooseGameView.toggle()
                                            }
                                        }
//                                                                        showSuccessToast = true
//                                                                        dismiss()
                                    }                                }

                            } else {
                                let idx = games.firstIndex(where: { $0.name == nameInput })
                                games[idx!] = game
                                saveGame()
                                showSuccessToast = true
                                dismiss()
                            }
                        },
                        label: {
                            Text("Save Game")
                        }
                    )
                    .padding()
                    .frame(maxWidth: .infinity)
                }

                HStack {
                    Spacer().frame(maxWidth: .infinity)
                    Spacer().frame(maxWidth: .infinity)
                    HelpButton(url: "https://github.com/PhoenixLauncher/Phoenix/blob/main/setup.md")
                }
            }
        }
        .frame(minWidth: 768, maxWidth: 1024, maxHeight: 2000)
        .toast(isPresenting: $showDupeGameToast, tapToDismiss: true) { // Alert if game already exists with name
            AlertToast(type: .error(Color.red), title: "Game already exists with this name!")
        }
        .sheet(isPresented: $showChooseGameView, onDismiss: {
            if let fetchedGame = fetchedGame {
                games.append(fetchedGame)
                games = games.sorted()
                saveGame()
                dismiss()
            }
        }, content: {
            ChooseGameView(games: $fetchedGames, fetchedGame: $fetchedGame)
        })
        .onAppear() {
            if !isNewGame {
                let idx = games.firstIndex(where: { $0.name == gameName })
                let currentGame = games[idx!]
                nameInput = currentGame.name
                iconOutput = currentGame.icon
                platInput = currentGame.platform
                statusInput = currentGame.status
                cmdInput = currentGame.launcher
                descInput = currentGame.metadata["description"] ?? ""
                genreInput = currentGame.metadata["genre"] ?? ""
                headOutput = currentGame.metadata["header_img"] ?? ""
                rateInput = currentGame.metadata["rating"] ?? ""
                devInput = currentGame.metadata["developer"] ?? ""
                pubInput = currentGame.metadata["publisher"] ?? ""
                // Create Date Formatter
                dateInput = convertIntoDate(input: currentGame.metadata["release_date"] ?? "")
            }
        }
    }
}
