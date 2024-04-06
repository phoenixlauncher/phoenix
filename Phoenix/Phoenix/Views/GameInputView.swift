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
    @State private var screenshotIsImporting: Bool = false
    var newScreenshot: String?
    
    @State private var hoveredScreenshot: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    TextBox(textBoxName: String(localized: "editGame_Name"), placeholder: String(localized: "editGame_NameDesc"), input: $game.name) // Name input
                    
                    ImageImportButton(type: String(localized: "editGame_Icon"), isImporting: $iconIsImporting, input: $iconInput, output: $game.icon, gameID: game.id)
        
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
                    
                    
                    if game.platform != .mac && game.platform != .pc {
                        TextBox(textBoxName: String(localized: "editGame_Command"), placeholder: String(localized: "editGame_CommandDesc"), input: $game.launcher)
                    } else {
                        DragDropFilePickerButton(launcher: $game.launcher)
                    }
                
                }
                DisclosureGroup(String(localized: "editGame_Advanced")) {
                    VStack(alignment: .leading) {
                        TextBox(textBoxName: String(localized: "editGame_Desc"), placeholder: String(localized: "editGame_DescDesc"), input: binding(for: "description"))
                        
                        TextBox(textBoxName: String(localized: "editGame_Genres"), placeholder: String(localized: "editGame_GenresDesc"), input: binding(for: "genre"))
                        
                        ImageImportButton(type: String(localized: "editGame_Header"), isImporting: $headIsImporting, input: $headerInput, output: binding(for: "header_img"), gameID: game.id)
                        
                        ImageImportButton(type: String(localized: "editGame_Cover"), isImporting: $coverIsImporting, input: $coverInput, output: binding(for: "cover"), gameID: game.id)
                        
                        DisclosureGroup(String(localized: "editGame_Screenshots")) {
                            ScrollView([.horizontal]) {
                                HStack {
                                    Rectangle()
                                        .background(.gray)
                                        .opacity(0.15)
                                        .overlay {
                                            Button(action: {
                                                screenshotIsImporting.toggle()
                                            }) {
                                                Image(systemName: "plus")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 27))
                                                    .frame(width: 50, height: 50)
                                                    .contentShape(RoundedRectangle(cornerRadius: 25))
                                            }
                                            .buttonStyle(.plain)
                                            .background(.white.opacity(0.5))
                                            .cornerRadius(25)
                                        }
                                        .frame(width: 300, height: 175)
                                        .cornerRadius(7.5)
                                        .fileImporter(isPresented: $screenshotIsImporting, allowedContentTypes: [.image], allowsMultipleSelection: false) { result in
                                            resultIntoData(result: result) { data in
                                                saveImageToFile(data: data, gameID: game.id, type: "screenshot_\(UUID())") { image in
                                                    game.screenshots.insert(image, at: 0)
                                                }
                                            }
                                        }
                                    ForEach(game.screenshots, id: \.self) { screenshot in
                                        if let screenshot = screenshot, let screenshotURL = URL(string: screenshot) {
                                            AsyncImage(url: screenshotURL) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image.resizable()
                                                default:
                                                    EmptyView()
                                                }
                                            }
                                            .opacity((hoveredScreenshot == screenshot) ? 0.5 : 1)
                                            .cornerRadius(7.5)
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 175)
                                            .overlay {
                                                if hoveredScreenshot == screenshot {
                                                    Button(action: {
                                                        if let idx = game.screenshots.firstIndex(where: { $0 == screenshot }) {
                                                            game.screenshots.remove(at: idx)
                                                        }
                                                    }) {
                                                        Image(systemName: "xmark")
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 27))
                                                            .frame(width: 50, height: 50)
                                                            .contentShape(RoundedRectangle(cornerRadius: 25))
                                                    }
                                                    .buttonStyle(.plain)
                                                    .background(.red)
                                                    .cornerRadius(25)
                                                }
                                            }
                                            .animation(.easeInOut(duration: 0.1), value: (hoveredScreenshot == screenshot))
                                            .onHover { hover in
                                                if hover {
                                                    hoveredScreenshot = screenshot
                                                } else {
                                                    hoveredScreenshot = nil
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .cornerRadius(7.5)
                        }
                        .padding()
                        
                        if !Defaults[.showStarRating] {
                            TextBox(textBoxName: String(localized: "editGame_Rating"), placeholder: "X / 10", input: binding(for: "rating"))
                        }
                        
                        TextBox(textBoxName: String(localized: "editGame_Dev"), placeholder: String(localized: "editGame_DevDesc"), input: binding(for: "developer"))
                        
                        TextBox(textBoxName: String(localized: "editGame_Pub"), placeholder: String(localized: "editGame_PubDesc"), input: binding(for: "publisher"))
                        
                        DatePicker(String(localized: "editGame_Release"), selection: $dateInput, in: ...Date(), displayedComponents: .date)
                            .padding()
                        
                        TextBox(textBoxName: String(localized: "editGame_igdbID"), placeholder: String(localized: "editGame_igdbIDDesc"), input: $game.igdbID)
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
                                    if game.igdbID != gameViewModel.games[idx].igdbID, let igdbID = Int(game.igdbID) {
                                        Task {
                                            await supabaseViewModel.fetchGameFromIgdbID(igdbID) { response in
                                                supabaseViewModel.convertSupabaseGame(supabaseGame: response, game: game) { newGame in
                                                    gameViewModel.games[idx] = newGame
                                                    gameViewModel.selectedGame = newGame.id
                                                    gameViewModel.saveGames()
                                                    appViewModel.showSuccessToast(String(localized: "toast_GameSavedSuccess"))
                                                }
                                            }
                                        }
                                    } else {
                                        gameViewModel.games[idx] = game
                                        gameViewModel.selectedGame = game.id
                                        gameViewModel.saveGames()
                                        appViewModel.showSuccessToast(String(localized: "toast_GameSavedSuccess"))
                                    }   
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
                game.igdbID = currentGame.igdbID
                game.steamID = currentGame.steamID
                game.name = currentGame.name
                game.icon = currentGame.icon
                game.platform = currentGame.platform
                game.status = currentGame.status
                game.recency = currentGame.recency
                game.isFavorite = currentGame.isFavorite
                game.launcher = currentGame.launcher
                game.screenshots = currentGame.screenshots
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
