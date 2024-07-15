//
//  PhoenixApp.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-21.
//

import SwiftUI
import WhatsNewKit

@main
struct PhoenixApp: App {
    @Environment(\.openURL) var openURL
    @StateObject var gameViewModel = GameViewModel()
    @StateObject var appViewModel = AppViewModel()
    @StateObject var platformViewModel = PlatformViewModel()
    @StateObject var updaterViewModel = UpdaterViewModel()
    
    @State var sortBy: SortBy = Defaults[.sortBy]
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(sortBy: $sortBy)
                .frame(
                    minWidth: 750, idealWidth: 1900, maxWidth: .infinity,
                    minHeight: 445, idealHeight: 1080, maxHeight: .infinity
                )
                .environmentObject(gameViewModel)
                .environmentObject(appViewModel)
                .environmentObject(platformViewModel)
                .environment(
                    \.whatsNew,
                    WhatsNewEnvironment(
                        versionStore: UserDefaultsWhatsNewVersionStore(),
                        whatsNewCollection: WhatsNewConfiguration().whatsNewCollection
                    )
                )
        }.commands {
            CommandGroup(before: CommandGroupPlacement.newItem) {
                Button(String(localized: "file_AddGame")) {
                    appViewModel.isAddingGame.toggle()
                }
                .keyboardShortcut("n", modifiers: [.shift, .command])
                Button(String(localized: "file_EditGame")) {
                    gameViewModel.selectedGameIDs.count == 1 ? appViewModel.isEditingGame.toggle() : ()
                }
                .keyboardShortcut("e", modifiers: [.shift, .command])
                Button(String(localized: "file_PlayGame")) {
                    appViewModel.isPlayingGame.toggle()
                }
                .keyboardShortcut("p", modifiers: [.shift, .command])
            }
            CommandGroup(replacing: CommandGroupPlacement.importExport) {
                Button(String(localized: "file_PhoenixFolder")) {
                    if let phoenixDirectory = getPhoenixDirectory() {
                        NSWorkspace.shared.open(phoenixDirectory)
                        logger.write("[INFO]: Opened Application Support/Phoenix.")
                    }
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
            CommandGroup(replacing: CommandGroupPlacement.sidebar) {
                Button(String(localized: "view_Platform"), action: {
                    sortBy = SortBy.platform
                })
                .keyboardShortcut("1", modifiers: .command)
                Button(String(localized: "view_Status"), action: {
                    sortBy = SortBy.status
                })
                .keyboardShortcut("2", modifiers: .command)
                Button(String(localized: "view_Name"), action: {
                    sortBy = SortBy.name
                })
                .keyboardShortcut("3", modifiers: .command)
                Button(String(localized: "view_Recency"), action: {
                    sortBy = SortBy.recency
                })
                .keyboardShortcut("4", modifiers: .command)
            }
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(UpdaterViewModel: updaterViewModel)
            }
            CommandGroup(replacing: .help) {
                Button(String(localized: "help_Help"), action: {
                    openURL(URL(string: "https://github.com/phoenixlauncher/phoenix/wiki/0.-Home")!)
                })
                Button(String(localized: "help_Donate"), action: {
                    openURL(URL(string: "https://www.ko-fi.com/phoenixlauncher")!)
                })
            }
        }
        
        Settings {
            SettingsView()
                .environmentObject(gameViewModel)
                .environmentObject(appViewModel)
                .environmentObject(platformViewModel)
        }
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSSetUncaughtExceptionHandler { exception in
            // Log the stack trace to the console
            print("Uncaught exception: \(exception)")
            print("Stack trace: \(exception.callStackSymbols.joined(separator: "\n"))")
        }
        let processInfo = ProcessInfo.processInfo
        let operatingSystemVersion = processInfo.operatingSystemVersionString
        let hostName = processInfo.hostName
        let device = Host.current().localizedName!
        let userName = NSUserName()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        let dateString = dateFormatter.string(from: Date())
        let timeZone = TimeZone.current.identifier
        let numCores = ProcessInfo.processInfo.activeProcessorCount
        let memSize = ProcessInfo.processInfo.physicalMemory
        let appVersion =
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        logger.write("[OS]: Operating system version: \(operatingSystemVersion)")
        logger.write("[OS]: Host name: \(hostName)")
        logger.write("[OS]: Device: \(device)")
        logger.write("[OS]: User name: \(userName)")
        logger.write("[OS]: Date and time: \(dateString)")
        logger.write("[OS]: Time zone: \(timeZone)")
        logger.write("[OS]: Number of cores: \(numCores)")
        logger.write("[OS]: Total RAM available: \(memSize) bytes")
        logger.write("[OS]: App version: \(appVersion)")
        logger.write("[INFO]: Phoenix App Launched.")
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSSetUncaughtExceptionHandler { exception in
            // Log the stack trace to the console
            print("Uncaught exception: \(exception)")
            print("Stack trace: \(exception.callStackSymbols.joined(separator: "\n"))")
        }
        logger.write("[INFO]: Phoenix App finished launching.")
    }

    func applicationWillTerminate(_ notification: Notification) {
        // This method is called when the application is about to terminate. Save data if appropriate.
        logger.write("[INFO]: Phoenix App shutting down.")
    }
}
