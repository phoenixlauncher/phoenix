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
                platformViewModel.platforms.insert(Platform(name: String(localized: "platforms_NewPlatform")), at: selectedPlatform + 1)
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
            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
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
    @State var applicationsImporting = false
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
                                    }, minusDisabled: (platform.gameDirectories.count == 1))
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
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
                                        if selectedFileURL.path == "/Applications" {
                                            applicationsImporting = true
                                        } else {
                                            platform.gameDirectories.append(selectedFileURL.path)
                                        }
                                    }
                                }
                                catch {
                                    logger.write(error.localizedDescription)
                                    appViewModel.failureToastText = "\(String(localized: "toast_FileError")) \(error)"
                                    appViewModel.showFailureToast.toggle()
                                }
                            }
                            .onDrop(of: [.folder], isTargeted: nil) { selectedFile in
                                handleDrop(providers: selectedFile)
                                return true
                            }
                            .alert(isPresented: $applicationsImporting) {
                                Alert(
                                    title: Text(String(localized: "alert_Warning")),
                                    message: Text(String(localized: "alert_ApplicationsWarning")),
                                    primaryButton: .default(
                                        Text("Import"),
                                        action: { platform.gameDirectories.append("/Applications") }
                                    ),
                                    secondaryButton: .cancel()
                                )
                            }
                            Divider()
                                .padding(.horizontal)
                            Toggle(isOn: $platform.emulator) {
                                Text("Platform is an emulator")
                            }
                            .padding()
                            if platform.emulator {
                                ImportButton(type: .application, outputPath: $platform.emulatorExecutable, showOutput: true, title: String(localized: "platforms_SelectEmulator"), unselectedLabel: String(localized: "platforms_Select_Emulator_DragDrop"), selectedLabel: String(localized: "platforms_SelectedEmulator"), action: { url in
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
                                appViewModel.showSettingsSuccessToast(String(localized: "toast_PlatformSaved"))
                            } else {
                                appViewModel.showSettingsFailureToast(String(localized: "toast_PlatformSaveFailure"))
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
                        Text(String(localized: "platforms_NoPlatforms"))
                        HStack {
                            Text(String(localized: "platforms_ClickInstruction"))
                            Image(systemName: "plus")
                            Text(String(localized: "platforms_PlusInstruction"))
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
                    appViewModel.failureToastText = "\(String(localized: "toast_FileError")) \(error)"
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
