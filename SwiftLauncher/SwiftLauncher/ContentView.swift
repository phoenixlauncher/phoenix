//
//  ContentView.swift
//  SwiftLauncher
//
//  Created by Kaleb Rosborough on 2022-12-21.
//

import SwiftUI

private let headerImageHeight: CGFloat = 500
private let collapsedImageHeight: CGFloat = 150

enum Platform {
    case NONE, MAC, STEAM, GOG, EPIC, EMUL
}

struct Game: Identifiable {
    let id = UUID().uuidString
    let name: String
    let icon: String
    let platform: Platform
    let launcher: String
    
    init(name: String, icon: String = "PlaceholderIcon", platform: Platform = Platform.NONE, launcher: String = "") {
        self.name = name
        self.icon = icon
        self.platform = platform
        self.launcher = launcher
    }
}

struct ContentView: View {
    @State private var games: [Game] = [
        Game(name: "AM2R", icon: "AM2R_Icon", platform: Platform.MAC, launcher: "open /Users/kalebrosborough/Applications/AM2R.app"),
        Game(name: "Minecraft", icon: "Minecraft_Icon", platform: Platform.MAC),
        
        Game(name: "Dead Cells", icon: "DeadCells_Icon", platform: Platform.STEAM),
        Game(name: "Hollow Knight", icon: "HollowKnight_Icon", platform: Platform.STEAM, launcher: "open steam://run/367520"),
        Game(name: "Muck", icon: "Muck_Icon", platform: Platform.STEAM),
        Game(name: "Terraria", icon: "Terraria_Icon", platform: Platform.STEAM),
        
        Game(name: "Metroid Dread", icon: "Ryujinx_Icon", platform: Platform.EMUL, launcher: "/Applications/Ryujinx.app/Contents/MacOS/Ryujinx /Users/kalebrosborough/Documents/Gaming.nosync/ROMs/Switch/Games/Metroid\\ Dread.nsp"),
        Game(name: "The Legend of Zelda: Breath of the Wild", icon: "Cemu_Icon", platform: Platform.EMUL),
        Game(name: "Castlevania: Symphony of the Night", icon: "OpenEmu_Icon", platform: Platform.EMUL),
    ]
    
    func checkForPlatform(arr: [Game], plat: Platform) -> Bool {
        for game in arr {
            if game.platform == plat {
                return true
            }
        }
        
        return false
    }
    
    @State private var selectedGame: String?
    
    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        
        // Image was pulled down
        if offset > 0 {
            return -offset
        }
        
        return 0
    }
    
    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height
        
        if offset > 0 {
            return imageHeight + offset
        }
        
        return imageHeight
    }
    
    private func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).maxY
        
        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height // Values will range from 0 - 1
        
        return blur * 10 // Values will range from 0 - 10
    }
    
    // The stuff that is actually on screen
    var body: some View {
        NavigationSplitView {
            // The sidebar
            List(selection: $selectedGame) {
                if checkForPlatform(arr: games, plat: Platform.MAC) {
                    Section(header: Text("Mac Games")) {
                        // The list of games that are installed as regular Mac apps
                        ForEach(games, id: \.name) { game in
                            if game.platform == Platform.MAC {
                                HStack {
                                    Image(game.icon)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text(game.name)
                                }
                            }
                        }
                    }.scrollDisabled(true)
                }
                    
                if checkForPlatform(arr: games, plat: Platform.STEAM) {
                    Section(header: Text("Steam Games")) {
                        // The list of games that are installed through Steam
                        ForEach(games, id: \.name) { game in
                            if game.platform == Platform.STEAM {
                                HStack {
                                    Image(game.icon)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text(game.name)
                                }
                            }
                        }
                    }.scrollDisabled(true)
                }
                    
                if checkForPlatform(arr: games, plat: Platform.GOG) {
                    Section(header: Text("GOG Games")) {
                        // The list of games that are installed through GOG Games
                        ForEach(games, id: \.name) { game in
                            if game.platform == Platform.GOG {
                                HStack {
                                    Image(game.icon)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text(game.name)
                                }
                            }
                        }
                    }.scrollDisabled(true)
                }
                    
                if checkForPlatform(arr: games, plat: Platform.EPIC) {
                    Section(header: Text("Epic Games")) {
                        // The list of games that are installed through the Epic Games Store
                        ForEach(games, id: \.name) { game in
                            if game.platform == Platform.EPIC {
                                HStack {
                                    Image(game.icon)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text(game.name)
                                }
                            }
                        }
                    }.scrollDisabled(true)
                }
                    
                if checkForPlatform(arr: games, plat: Platform.EMUL) {
                    Section(header: Text("Emulated Games")) {
                        // The list of games that are installed through Steam
                        ForEach(games, id: \.name) { game in
                            if game.platform == Platform.EMUL {
                                HStack {
                                    Image(game.icon)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text(game.name)
                                }
                            }
                        }
                    }.scrollDisabled(true)
                }
                    
                if checkForPlatform(arr: games, plat: Platform.NONE) {
                    Section(header: Text("Other")) {
                        // The list of games that aren't installed through any of the above stores
                        ForEach(games, id: \.name) { game in
                            if game.platform == Platform.NONE {
                                HStack {
                                    Image(game.icon)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text(game.name)
                                }
                            }
                        }
                    }.scrollDisabled(true)
                }
                
                Text(" ").frame(height: 300)
                
                Button(action: {
                    print("Adding game")
                }, label: {
                    Image(systemName: "plus.app")
                        .font(.system(size: 16))
                    Text("Add new game")
                        .foregroundColor(Color.white)
                        .font(.system(size: 15))
                })
                .buttonStyle(.plain)
                .frame(width: 200, height: 35)
                .background(LinearGradient(colors: [Color("mid_blue"), Color("light_blue")],
                                           startPoint: .bottom,
                                           endPoint: .top))
                .cornerRadius(10)
            }
        } detail: {
            // The detailed view of the selected game
            ScrollView {
                GeometryReader { geometry in
                    Image("PlaceholderHeader")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))
                        .blur(radius: self.getBlurRadiusForImage(geometry))
                        .clipped()
                        .offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
                }.frame(height: 400)
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {
                            if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
                                do {
                                    try shell(games[idx].launcher)
                                }
                                catch {
                                    print("\(error)") // handle or silence the error here
                                }
                            }
                        }, label: {
                            Text("Play")
                                .foregroundColor(Color.white)
                                .font(.system(size: 20))
                        })
                        .buttonStyle(.plain)
                        .frame(width: 125, height: 50)
                        .background(LinearGradient(colors: [Color("mid_green"), Color("light_green")],
                                                   startPoint: .bottom,
                                                   endPoint: .top))
                        .cornerRadius(10)
                        .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            print("Opening settings")
                        }, label: {
                            Image(systemName: "gear")
                                .foregroundColor(Color.white)
                                .font(.system(size: 24))
                        })
                        .buttonStyle(.plain)
                        .frame(width: 50, height: 50)
                        .background(LinearGradient(colors: [Color("mid_gray"), Color("light_gray")],
                                                   startPoint: .bottom,
                                                   endPoint: .top))
                        .cornerRadius(10)
                        .padding()
                    }
                    
                    HStack(alignment: .top, spacing: 100) {
                        VStack(alignment: .leading) {
                            // Game Description
                            Text("Forge your own path in Hollow Knight! An epic action adventure through a vast ruined kingdom of insects and heroes. Explore twisting caverns, battle tainted creatures and befriend bizarre bugs, all in a classic, hand-drawn 2D style.\n")
                            Text("A 2D metroidvania with an emphasis on close combat and exploration in which the player enters the once-prosperous now-bleak insect kingdom of Hallownest, travels through its various districts, meets friendly inhabitants, fights hostile ones and uncovers the kingdom's history while improving their combat abilities and movement arsenal by fighting bosses and accessing out-of-the-way areas.")
                            Image("HK")
                                .resizable()
                                .padding(.top)
                                .padding(.bottom)
                                .aspectRatio(contentMode: .fit)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                            
                        HStack {
                            // Game Info
                            VStack(alignment: .leading) {
                                Text("Time Played").padding(5)
                                Text("Last Played").padding(5)
                                Text("Platform").padding(5)
                                Text("Rating").padding(5)
                                Text("Genre\n\n\n").padding(5)
                                Text("Developer").padding(5)
                                Text("Publisher").padding(5)
                                Text("Release Date").padding(5)
                            }
                            VStack(alignment: .leading) {
                                Text("43 Hours").padding(5)
                                Text("Today").padding(5)
                                Text("Steam").padding(5)
                                Text("9.5 / 10").padding(5)
                                Text("Metroidvania\nSouls-Like\nAdventure\nPlatformer").padding(5)
                                Text("Team Cherry").padding(5)
                                Text("Team Cherry").padding(5)
                                Text("February 24, 2017").padding(5)
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
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle(selectedGame ?? "SwiftLauncher")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
