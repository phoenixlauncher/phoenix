//
//  AppearanceSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI
import AppKit

struct AppearanceSettingsView: View {
    
    @AppStorage("accentColorUI")
    private var accentColorUI: Bool = true
    
    var body: some View {
        Form {
            Toggle(isOn: $accentColorUI) {
                Text("Adaptive Color UI)")
            }
        }
    }
}
