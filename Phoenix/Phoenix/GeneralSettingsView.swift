//
//  GeneralSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("isGameDetectionEnabled")
    private var isGameDetectionEnabled: Bool = true
    
    var body: some View {
        Form {
            Toggle(isOn: $isGameDetectionEnabled) {
                Text("Game Detection")
            }
        }
    }
}
