//
//  GeneralSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI

struct GeneralSettingsView: View {
    @Default(.steamDetection) var steamDetection
    @Default(.steamFolder) var steamFolder
    @Default(.crossOverDetection) var crossOverDetection
    @Default(.crossOverFolder) var crossOverFolder

    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 15) {
                Defaults.Toggle(String(format: String(localized: "general_Detect"), "Steam"), key: .steamDetection)
                if steamDetection {
                    FolderImportButton(type: "Steam", folder: $steamFolder, endPath: "steamapps")
                }
                Defaults.Toggle(String(format: String(localized: "general_Detect"), "CrossOver"), key: .crossOverDetection)
                if crossOverDetection {
                    FolderImportButton(type: "CrossOver", folder: $crossOverFolder, endPath: nil)
                }
                Divider()
                Defaults.Toggle(String(localized: "general_FetchMeta"), key: .isMetaDataFetchingEnabled)
                Defaults.Toggle(String(localized: "general_GetIconFromApp"), key: .getIconFromApp)
            }
            .padding()
        }
        .frame(alignment: .topLeading)
    }
}
