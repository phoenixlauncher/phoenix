//
//  PhoenixApp.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-21.
//

import SwiftUI

@main
struct PhoenixApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
            .frame(minWidth: 800, idealWidth: 1900, maxWidth: .infinity,
                   minHeight: 445, idealHeight: 1080, maxHeight: .infinity)
    }
  }
}
