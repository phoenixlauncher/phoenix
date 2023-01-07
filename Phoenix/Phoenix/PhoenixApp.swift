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
