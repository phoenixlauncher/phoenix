//
//  GeneralSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("isGameDetectionEnabled")
    private var isGameDetectionEnabled: Bool = false

    var body: some View {
        Form {
            VStack(alignment: .leading) {
                Toggle(isOn: $isGameDetectionEnabled) {
                    Text("Game Detection")
                }
            }
        }
    }
}
