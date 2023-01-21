//
//  PhoenixApp.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-21.
//

import SwiftUI

@main
struct PhoenixApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(
                    minWidth: 800, idealWidth: 1900, maxWidth: .infinity,
                    minHeight: 445, idealHeight: 1080, maxHeight: .infinity)
        }.commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                Button("Open Phoenix Data Folder") {
                    if let phoenixDirectory = getPhoenixDirectory() {
                        print(phoenixDirectory)
                        NSWorkspace.shared.open(phoenixDirectory)
                        logger.write("[INFO]: Opened Application Support/Phoenix.")
                    }
                }
            }
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
