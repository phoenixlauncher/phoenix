//
//  PlatformsSettingsView.swift
//  Phoenix
//
//  Created by jxhug on 5/10/24.
//

import SwiftUI
import CachedAsyncImage
import SwiftyJSON

struct PlatformsSettingsView: View {
    @State var selectedPlatform: Int = 0
    @State var searchingForIcon = false
    
    var body: some View {
        HStack(spacing: 20) {
            PlatformsSettingsSidebar(selectedPlatform: $selectedPlatform)
            PlatformsSettingsDetail(selectedPlatform: $selectedPlatform, searchingForIcon: $searchingForIcon)
        }
        .padding()
    }
}

struct PlatformsSettingsSidebar: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appViewModel: AppViewModel
    @Binding var selectedPlatform: Int
    
    var body: some View {
        VStack(spacing: 0) {
            List(selection: $selectedPlatform) {
                ForEach(Array(appViewModel.platforms.enumerated()), id: \.offset) { (index, element) in
                    HStack {
                        CachedAsyncImage(url: URL(string: element.iconURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                                    .if(colorScheme == .dark) { view in
                                        view.colorInvert()
                                    }
                            default:
                                ProgressView()
                                    .scaleEffect(0.5)
                            }
                        }
                        .frame(width: 20, height: 20)
                        Text(element.name)
                    }
                }
                .onMove { from, to in
                    appViewModel.platforms.move(fromOffsets: from, toOffset: to)
                }
            }
            SystemToolbar(selectedPlatform: $selectedPlatform, plusAction: {
                appViewModel.platforms.insert(Platform(name: "New Platform"), at: selectedPlatform + 1  )
                selectedPlatform += 1
                appViewModel.savePlatforms()
            }, minusAction: {
                if appViewModel.platforms.count > 1 {
                    appViewModel.platforms.remove(at: selectedPlatform)
                    if selectedPlatform != 0 {
                        selectedPlatform -= 1
                    } else {
                        selectedPlatform += 1
                    }
                    appViewModel.savePlatforms()
                }
            })
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .frame(width: 160)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(lineWidth: 1)
                .foregroundStyle(Color(NSColor.gridColor).opacity(0.5))
            )
    }
}

struct PlatformsSettingsDetail: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var gameViewModel: GameViewModel
    @Binding var selectedPlatform: Int
    @Binding var searchingForIcon: Bool
    @State var platform: Platform = Platform()
    
    var icon: String {
        URL(string: platform.iconURL)?.lastPathComponent.components(separatedBy: ".").first ?? ""
    }
    
    var body: some View {
        VStack {
            if appViewModel.platforms.count > 0 {
                VStack {
                    ScrollView {
                        TextBox(textBoxName: String(localized: "platforms_EditName"), input: $platform.name) // Name input
                        IconSearchButton(isSearching: $searchingForIcon, icon: icon)
                        TextBox(textBoxName: String(localized: "platforms_GameType"), caption: String(localized: "platforms_GameTypeDesc"), input: $platform.gameType) // Game type input
                        TextBox(textBoxName: String(localized: "platforms_CommandTemplate"), caption: String(localized: "platforms_CommandTemplateDesc"), input: $platform.commandTemplate) // Command template input
                    }
                    .frame(alignment: .leading)
                    Spacer()
                    HStack {
                        Button(action: {
                            if appViewModel.platforms[selectedPlatform].name != platform.name {
                                for index in gameViewModel.games.indices {
                                    if gameViewModel.games[index].platformName == appViewModel.platforms[selectedPlatform].name {
                                        gameViewModel.games[index].platformName = platform.name
                                    }
                                }
                            }
                            appViewModel.platforms[selectedPlatform] = platform
                            appViewModel.savePlatforms()
                            appViewModel.showSettingsSuccessToast("Platform saved!")
                        }) {
                            Text(LocalizedStringKey("platforms_SavePlatform"))
                        }
                        .padding()
                    }
                }
            } else {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Text("No platform selected.")
                        HStack {
                            Text("Click the")
                            Image(systemName: "plus")
                            Text("to create one.")
                        }
                        Spacer()
                    }
                    Spacer()
                } //
                .background(Color(
                    NSColor.unemphasizedSelectedContentBackgroundColor).opacity(0.5))
                .font(Font.system(size: 15))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color(NSColor.gridColor).opacity(0.5)))
                .frame(width: 400)
            }
        }
        .onAppear {
            platform = appViewModel.platforms[selectedPlatform]
        }
        .onChange(of: selectedPlatform) { _ in
            platform = appViewModel.platforms[selectedPlatform]
        }
        .sheet(isPresented: $searchingForIcon, onDismiss: {
            if platform.iconURL != "" {
                appViewModel.platforms[selectedPlatform].iconURL = platform.iconURL
            }
        }) {
            IconSearch(selectedIcon: $platform.iconURL)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
