//
//  GameDetailView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-28.
//

import SwiftUI

struct GameDetailView: View {
    private func loadImageFromFile(filePath: String) -> NSImage? {
        do {
            if filePath != "" {
                let imageData = try Data(contentsOf: URL(string: filePath)!)
                return NSImage(data: imageData)
            } else {
                return nil
            }
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    @State var editingGame: Bool = false
    @State var showingAlert: Bool = false
    @Binding var selectedGame: String?
    @Binding var refresh: Bool
    
    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
                    let game = games[idx]
//                    Image(try String(contentsOfFile: game.metadata["header_img"]!))
                    Image(nsImage: loadImageFromFile(filePath: game.metadata["header_img"]!) ?? NSImage(imageLiteralResourceName: "PlaceholderHeader"))
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: getHeightForHeaderImage(geometry))
                        .blur(radius: getBlurRadiusForImage(geometry))
                        .clipped()
                        .offset(x: 0, y: getOffsetForHeaderImage(geometry))
                }
            }.frame(height: 400)
            
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
                            do {
                                let game = games[idx]
                                if game.launcher != "" {
                                    try shell(game.launcher)
                                } else {
                                    showingAlert = true
                                }
                            } catch {
                                print("\(error)") // handle or silence the error here
                            }
                        }
                    }, label: {
                        Text("Play")
                            .foregroundColor(Color.white)
                            .font(.system(size: 20))
                    })
                    .alert("No launcher configured. Please configure a launch command to run \(selectedGame ?? "this game")", isPresented: $showingAlert) {}
                    .buttonStyle(.plain)
                    .frame(width: 125, height: 50)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        editingGame.toggle()
                    }, label: {
                        Image(systemName: "gear")
                            .foregroundColor(Color.white)
                            .font(.system(size: 24))
                    })
                    .sheet(isPresented: $editingGame, onDismiss: {
                        // Refresh game list
                        refresh.toggle()
                    }, content: {
                        let idx = games.firstIndex(where: { $0.name == selectedGame })
                        let game = games[idx!]
                        EditGameView(currentGame: .constant(game))
                    })
                    .buttonStyle(.plain)
                    .frame(width: 50, height: 50)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()
                }
                
                HStack(alignment: .top, spacing: 100) {
                    VStack(alignment: .leading) {
                        // Game Description
                        if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
                            let game = games[idx]
                            Text(game.metadata["description"] ?? "No game selected")
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    
                    HStack {
                        // Game Info
                        VStack(alignment: .leading) {
                            Text("Time Played").padding(5)
                            Text("Last Played").padding(5)
                            Text("Platform").padding(5)
                            Text("Rating").padding(5)
                            Text("Genre\n\n").padding(5)
                            Text("Developer").padding(5)
                            Text("Publisher").padding(5)
                            Text("Release Date").padding(5)
                        }
                        VStack(alignment: .leading) {
                            if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
                                let game = games[idx]
                                Text(game.metadata["time_played"] ?? "").padding(5)
                                Text(game.metadata["last_played"] ?? "").padding(5)
                                switch game.platform {
                                    case Platform.MAC:
                                        Text("MacOS").padding(5)
                                    case Platform.STEAM:
                                        Text("Steam").padding(5)
                                    case Platform.GOG:
                                        Text("GOG").padding(5)
                                    case Platform.EPIC:
                                        Text("Epic Games").padding(5)
                                    case Platform.EMUL:
                                        Text("Emulated").padding(5)
                                    case Platform.NONE:
                                        Text("Other").padding(5)
                                }
                                Text(game.metadata["rating"] ?? "").padding(5)
                                Text(game.metadata["genre"] ?? "").padding(5)
                                Text(game.metadata["developer"] ?? "").padding(5)
                                Text(game.metadata["publisher"] ?? "").padding(5)
                                Text(game.metadata["release_date"] ?? "").padding(5)
                            }
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
                .padding(.horizontal)
                .padding(.top, 16.0)
            }
            .font(.system(size: 15))
            .lineSpacing(5)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle(selectedGame ?? "Phoenix")
    }
}
