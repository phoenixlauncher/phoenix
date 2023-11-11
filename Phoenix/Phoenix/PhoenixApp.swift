//
//  PhoenixApp.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-21.
//

import SwiftUI

@main
struct PhoenixApp: App {
    @StateObject var updaterViewModel = UpdaterViewModel()
    
    enum SortBy: String, Codable, CaseIterable, Identifiable, Defaults.Serializable {
        case platform, status, name, recency

        var id: SortBy { self }
        
        var displayName: String {
            switch self {
            case .platform: return "Platform"
            case .status: return "Status"
            case .name: return "Name"
            case .recency: return "Recency"
            }
        }
        
        var spaces: String {
            switch self {
            case .platform: return "        Platform"
            case .status: return "       Status"
            case .name: return "         Name"
            case .recency: return "      Recency"
            }
        }
        
        var spacedName: String {
            switch self {
            case .platform: return "       "
            case .status: return "     "
            case .name: return "       "
            case .recency: return "    "
            }
        }
        
        var symbol: String {
            switch self {
            case .platform: return "gamecontroller"
            case .status: return "trophy"
            case .name: return "textformat.abc.dottedunderline"
            case .recency: return "clock"
            }
        }
    }
    
    @State var sortBy: SortBy = Defaults[.sortBy]
    
    @State var isAddingGame: Bool = false
    @State var isEditingGame: Bool = false
    @State var isPlayingGame: Bool = false
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(sortBy: $sortBy, isAddingGame: $isAddingGame, isEditingGame: $isEditingGame, isPlayingGame: $isPlayingGame)
                .frame(
                    minWidth: 750, idealWidth: 1900, maxWidth: .infinity,
                    minHeight: 445, idealHeight: 1080, maxHeight: .infinity
                )
        }.commands {
            CommandGroup(before: CommandGroupPlacement.newItem) {
                Button("Add Game") {
                    self.isAddingGame.toggle()
                }
                .keyboardShortcut("n", modifiers: [.shift, .command])
                Button("Edit Game") {
                    self.isEditingGame.toggle()
                }
                .keyboardShortcut("e", modifiers: [.shift, .command])
                Button("Play Game") {
                    self.isPlayingGame.toggle()
                }
                .keyboardShortcut("p", modifiers: [.shift, .command])
            }
            CommandGroup(replacing: CommandGroupPlacement.importExport) {
                Button("Open Phoenix Data Folder") {
                    if let phoenixDirectory = getPhoenixDirectory() {
                        print(phoenixDirectory)
                        NSWorkspace.shared.open(phoenixDirectory)
                        logger.write("[INFO]: Opened Application Support/Phoenix.")
                    }
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
            CommandGroup(replacing: CommandGroupPlacement.sidebar) {                                                                               
                Button("Sort Sidebar by Platform", action: {
                    sortBy = SortBy.platform
                })
                .keyboardShortcut("1", modifiers: .command)
                Button("Sort Sidebar by Status", action: {
                    sortBy = SortBy.status
                })
                .keyboardShortcut("2", modifiers: .command)
                Button("Sort Sidebar by Name", action: {
                    sortBy = SortBy.name
                })
                .keyboardShortcut("3", modifiers: .command)
                Button("Sort Sidebar by Recency", action: {
                    sortBy = SortBy.recency
                })
                .keyboardShortcut("4", modifiers: .command)
            }
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(UpdaterViewModel: updaterViewModel)
            }
        }
        
        Settings {
            SettingsView()
        }
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

    func applicationWillTerminate(_ aNotification: Notification) {
        // This method is called when the application is about to terminate. Save data if appropriate.
        logger.write("[INFO]: Phoenix App shutting down.")
    }
}
