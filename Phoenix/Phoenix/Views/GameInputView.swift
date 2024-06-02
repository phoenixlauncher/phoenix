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
    @EnvironmentObject var platformViewModel: PlatformViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var isNewGame: Bool
    
    @State private var showChooseGameView: Bool = false
    @State var chooseGameViewDone = false
    
    @State var fetchedGames: [SupabaseGame] = []
    
    @State private var game: Game = Game()
    @State private var dateInput: Date = .now

    @State private var screenshotIsImporting: Bool = false
    var newScreenshot: String?
    
    @State private var hoveredScreenshot: String?
    
    var currentPlatform: Platform? {
        platformViewModel.platforms.first(where: {game.platformName == $0.name})
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Group {
                        TextBox(textBoxName: String(localized: "editGame_Name"), input: $game.name) // Name input
                        
                        FileImportButton(type: .image, outputPath: $game.icon, showOutput: false, title: String(localized: "editGame_Icon"), unselectedLabel: String(localized: "editGame_File_DragDrop"), selectedLabel: String(localized: "editGame_SelectedImage"), action: { path in
                            return saveIconToFile(iconData: pathIntoData(path: path), gameID: game.id)
                        })
                        
                        SlotInput(contentName: String(localized: "editGame_Platform"), content: {
                            Picker("Platform", selection: $game.platformName) {
                                ForEach(platformViewModel.platforms.map({ $0.name }), id: \.self) { platformName in
                                    Text(platformName)
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
                        
                        if let currentPlatform = currentPlatform, currentPlatform.commandTemplate != "", currentPlatform.gameType != "" {
                            GameFilePickerButton(currentPlatform: currentPlatform, game: $game, extraAction: { url in
                                if let icon = saveIconToFile(iconNSImage: NSWorkspace.shared.icon(forFile: url.path), gameID: game.id) {
                                    game.icon = icon
                                }
                            })
                        }
                    }
                    DisclosureGroup(String(localized: "editGame_Advanced")) {
                        VStack(alignment: .leading) {
                            TextBox(textBoxName: String(localized: "editGame_Command"), caption: String(localized: "editGame_CommandOverride"), input: $game.launcher)
                            
                            TextBox(textBoxName: String(localized: "editGame_Desc"), input: binding(for: "description"))
                            
                            TextBox(textBoxName: String(localized: "editGame_Genres"), input: binding(for: "genre"))
                            
                            FileImportButton(type: .image, outputPath: binding(for: "header_img"), showOutput: false, title: String(localized: "editGame_Header"), unselectedLabel: String(localized: "editGame_File_DragDrop"), selectedLabel: String(localized: "editGame_SelectedImage"), action: { path in
                                if let data = pathIntoData(path: path) {
                                    return saveImageToFile(data: data, gameID: game.id, type: "header")
                                }
                                return nil
                            })
                            
                            FileImportButton(type: .image, outputPath: binding(for: "cover"), showOutput: false, title: String(localized: "editGame_Cover"), unselectedLabel: String(localized: "editGame_File_DragDrop"), selectedLabel: String(localized: "editGame_SelectedImage"), action: { path in
                                if let data = pathIntoData(path: path) {
                                    return saveImageToFile(data: data, gameID: game.id, type: "cover")
                                }
                                return nil
                            })
                            
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
                                                do {
                                                    if let path = try result.get().first {
                                                        if let data = pathIntoData(path: path) {
                                                            game.screenshots.insert(saveImageToFile(data: data, gameID: game.id, type: "screenshot_\(UUID())"), at: 0)
                                                        }
                                                    }
                                                }
                                                catch {
                                                    logger.write(error.localizedDescription)
                                                    appViewModel.failureToastText = "Unable to get file: \(error)"
                                                    appViewModel.showFailureToast.toggle()
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
                                TextBox(textBoxName: String(localized: "editGame_Rating"), caption: "X / 10", input: binding(for: "rating"))
                            }
                            
                            TextBox(textBoxName: String(localized: "editGame_Dev"), input: binding(for: "developer"))
                            
                            TextBox(textBoxName: String(localized: "editGame_Pub"), input: binding(for: "publisher"))
                            
                            DatePicker(String(localized: "editGame_Release"), selection: $dateInput, in: ...Date(), displayedComponents: .date)
                                .padding()
                            
                            TextBox(textBoxName: String(localized: "editGame_igdbID"), caption: String(localized: "editGame_igdbIDDesc"), input: $game.igdbID)
                        }
                    }
                }
                .padding()
            }
            Spacer()
            HStack {
                Spacer()
                HStack(spacing: 20) {
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
                }
                Spacer()
                HelpButton()
//                    .padding()
            }.frame(maxWidth: .infinity, alignment: .trailing).padding()
        }
        .frame(minWidth: 800, maxWidth: 1024, minHeight: 350, maxHeight: 2000)
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
                game = currentGame
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
