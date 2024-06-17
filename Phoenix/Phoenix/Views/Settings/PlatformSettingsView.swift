//
//  PlatformSettingsView.swift
//  Phoenix
//
//  Created by jxhug on 5/10/24.
//

import SwiftUI
import CachedAsyncImage
import SwiftyJSON
import UniformTypeIdentifiers

struct PlatformSettingsView: View {
    @State var selectedPlatform: Int = 0
    @State var searchingForIcon = false
    
    var body: some View {
        HStack(spacing: 20) {
            PlatformSettingsSidebar(selectedPlatform: $selectedPlatform)
            PlatformSettingsDetail(selectedPlatform: $selectedPlatform, searchingForIcon: $searchingForIcon)
        }
        .padding()
    }
}

struct PlatformSettingsSidebar: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var platformViewModel: PlatformViewModel
    @Binding var selectedPlatform: Int
    
    var body: some View {
        VStack(spacing: 0) {
            List(selection: $selectedPlatform) {
                ForEach(Array(platformViewModel.platforms.enumerated()), id: \.offset) { (index, element) in
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
                    platformViewModel.platforms.move(fromOffsets: from, toOffset: to)
                }
            }
            SystemToolbar(plusAction: {
                platformViewModel.platforms.insert(Platform(name: "New Platform"), at: selectedPlatform + 1  )
                selectedPlatform += 1
                platformViewModel.savePlatforms()
            }, plusDisabled: false, minusAction: {
                if platformViewModel.platforms.count > 1 {
                    platformViewModel.platforms.remove(at: selectedPlatform)
                    if selectedPlatform != 0 {
                        selectedPlatform -= 1
                    } else {
                        selectedPlatform += 1
                    }
                    platformViewModel.savePlatforms()
                }
            }, minusDisabled: (platformViewModel.platforms[selectedPlatform].deletable == false))
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

struct PlatformSettingsDetail: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var platformViewModel: PlatformViewModel
    @EnvironmentObject var gameViewModel: GameViewModel
    @Binding var selectedPlatform: Int
    @State var selectedGameDir: Int = 0
    @State var importingGameDir = false
    @Binding var searchingForIcon: Bool
    @State var platform: Platform = Platform()
    
    var icon: String {
        URL(string: platform.iconURL)?.lastPathComponent.components(separatedBy: ".").first ?? ""
    }
    
    var body: some View {
        VStack {
            if platformViewModel.platforms.count > 0 {
                VStack {
                    ScrollView {
                        VStack(alignment: .leading) {
                            TextBox(textBoxName: String(localized: "platforms_EditName"), input: $platform.name) // Name input
                            IconSearchButton(isSearching: $searchingForIcon, icon: icon) // Icon search
                            TextBox(textBoxName: String(localized: "platforms_GameType"), caption: String(localized: "platforms_GameTypeDesc"), input: $platform.gameType) // Game type input
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text(String(localized: "platforms_GameDirectories"))
                                    Text(String(localized: "platforms_GameDirectoriesDesc"))
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }.frame(width: 150, alignment: .leading)
                                Spacer()
                                VStack {
                                    List(selection: $selectedGameDir) {
                                        ForEach(Array(platform.gameDirectories.enumerated()), id: \.offset) { (index, gameDirectory) in
                                            Text(gameDirectory)
                                        }.onAppear {
                                            print(platform.gameDirectories)
                                        }
                                    }
                                    .frame(height: 75)
                                    SystemToolbar(plusAction: {
                                        importingGameDir = true
                                    }, plusDisabled: false, minusAction: {
                                        if platform.gameDirectories.count > 1 {
                                            platform.gameDirectories.remove(at: selectedGameDir)
                                            if selectedGameDir != 0 {
                                                selectedGameDir -= 1
                                            } else {
                                                selectedGameDir += 1
                                            }
                                        }
                                    }, minusDisabled: false)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(lineWidth: 1)
                                        .foregroundStyle(Color(NSColor.gridColor).opacity(0.5))
                                )
                            }
                            .padding()
                            .fileImporter(
                                isPresented: $importingGameDir,
                                allowedContentTypes: [.folder],
                                allowsMultipleSelection: false
                            ) { result in
                                do {
                                    let selectedFileURL: URL? = try result.get().first
                                    if let selectedFileURL = selectedFileURL {
                                        platform.gameDirectories.append(selectedFileURL.path)
                                    }
                                }
                                catch {
                                    logger.write(error.localizedDescription)
                                    appViewModel.failureToastText = "Unable to get file: \(error)"
                                    appViewModel.showFailureToast.toggle()
                                }
                            }
                            .onDrop(of: [.folder], isTargeted: nil) { selectedFile in
                                handleDrop(providers: selectedFile)
                                return true
                            }
//                            FileImportButton(type: .folder, outputPath: $platform.gameDirectory, showOutput: true, title: String(localized: "platforms_GameDirectory"), unselectedLabel: String(localized: "platforms_Select_GameDirectory"), selectedLabel: String(localized: "platforms_SelectedGameDirectory"), action: { url in
//                                return url.path
//                            })
                            Divider()
                                .padding(.horizontal)
                            Toggle(isOn: $platform.emulator) {
                                Text("Platform is an emulator")
                            }
                            .padding()
                            if platform.emulator {
                                FileImportButton(type: .application, outputPath: $platform.emulatorExecutable, showOutput: true, title: String(localized: "platforms_SelectEmulator"), unselectedLabel: String(localized: "platforms_Select_Emulator_DragDrop"), selectedLabel: String(localized: "platforms_SelectedEmulator"), action: { url in
                                    return "\(url.path)/Contents/MacOS/\(url.deletingPathExtension().lastPathComponent)"
                                })
                                TextBox(textBoxName: String(localized: "platforms_EmulatorArgs"), caption: String(localized: "platforms_EmulatorArgsDesc"), input: $platform.commandArgs) // Args input
                            } else {
                                TextBox(textBoxName: String(localized: "platforms_CommandTemplate"), caption: String(localized: "platforms_CommandTemplateDesc"), input: $platform.commandTemplate) // Command template input
                            }
                        }
                    }
                    .frame(alignment: .leading)
                    Spacer()
                    HStack {
                        Button(action: {
                            if platformViewModel.platforms[selectedPlatform].name != platform.name {
                                for index in gameViewModel.games.indices {
                                    if gameViewModel.games[index].platformName == platformViewModel.platforms[selectedPlatform].name {
                                        gameViewModel.games[index].platformName = platform.name
                                    }
                                }
                            }
                            if platformViewModel.platforms.filter({ platform.name == $0.name }).count <= 1 {
                                if platform.emulatorExecutable != "" && platform.emulator {
                                    platform.commandTemplate = "\"\(platform.emulatorExecutable)\" %@ \(platform.commandArgs)"
                                }
                                platformViewModel.platforms[selectedPlatform] = platform
                                platformViewModel.savePlatforms()
                                appViewModel.showSettingsSuccessToast("Platform saved!")
                            } else {
                                appViewModel.showSettingsFailureToast("Platform cannot be named the same as another platform.")
                            }
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
            platform = platformViewModel.platforms[selectedPlatform]
        }
        .onChange(of: selectedPlatform) { _ in
            print(platformViewModel.platforms[selectedPlatform])
            platform = platformViewModel.platforms[selectedPlatform]
        }
        .sheet(isPresented: $searchingForIcon, onDismiss: {
            if platform.iconURL != "" {
                platformViewModel.platforms[selectedPlatform].iconURL = platform.iconURL
            }
        }) {
            IconSearch(selectedIcon: $platform.iconURL)
        }
        .frame(height: 600, alignment: .bottom)
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: provider.registeredTypeIdentifiers.first!, options: nil) { item, error in
                if let error = error {
                    logger.write(error.localizedDescription)
                    appViewModel.failureToastText = "Unable to create application launch command: \(error)"
                    appViewModel.showFailureToast.toggle()
                    return
                }
                if let selectedFileURL = (item as? URL) {
                    platform.gameDirectories.append(selectedFileURL.path)
                }
            }
        }
    }
}
