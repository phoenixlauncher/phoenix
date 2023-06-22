//
//  AppearanceSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI
import AppKit

class AppearanceDelegateObject: ObservableObject {
    var refreshGameDetailView: (() -> Void)?
}

struct AppearanceSettingsView: View {
    
    @EnvironmentObject private var appearanceDelegateObject: AppearanceDelegateObject
    
    @AppStorage("accentColorUI")
    private var accentColorUI: Bool = true
    
    var body: some View {
        Form {
            Toggle(isOn: $accentColorUI) {
                Text("Accent Color UI (Requires restart)")
            }
            .onChange(of: accentColorUI) { newValue in
                updateAccentColorUI()
            }
            Button(action: {
                restartApp()
            }) {
                Text("Restart App")
            }
        }
    }
    
    func updateAccentColorUI() {
        appearanceDelegateObject.refreshGameDetailView?()
    }
    
    func restartApp() {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["sh", "-c", "sleep 1 && open -a '\(Bundle.main.bundlePath)'"]
        task.launch()
        NSApp.terminate(nil)
    }

}
