//
//  PhoenixApp.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-21.
//

import SwiftUI

@main
struct PhoenixApp: App {
  init() {
    logger.write("[INFO]: Phoenix App Launched.")
  }
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
