//
//  GeneralSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI

struct GeneralSettingsView: View {
    @State var steamIsImporting: Bool = false
    @State var invalidFolder: Bool = false
    @State var lastPathComponent: String?

    @Default(.steamDetection) var steamDetection
    @Default(.steamFolder) var steamFolder
    @Default(.crossOverDetection) var crossOverDetection
    @Default(.crossOverFolder) var crossOverFolder

    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 15) {
                Defaults.Toggle(String(format: String(localized: "general_Detect"), "Steam"), key: .steamDetection)
                if steamDetection {
                    FolderImportButton(type: "Steam", folder: $steamFolder, lastPathComponent: $lastPathComponent, endPath: "steamapps", invalidFolder: $invalidFolder)
                }
                Defaults.Toggle(String(format: String(localized: "general_Detect"), "CrossOver"), key: .crossOverDetection)
                if crossOverDetection {
                    FolderImportButton(type: "CrossOver", folder: $crossOverFolder, lastPathComponent: $lastPathComponent, endPath: nil, invalidFolder: $invalidFolder)
                }
                Divider()
                Defaults.Toggle(String(localized: "general_FetchMeta"), key: .isMetaDataFetchingEnabled)
                Defaults.Toggle(String(localized: "general_GetIconFromApp"), key: .getIconFromApp)
            }
            .alert(String(localized: "alert_InvalidFolder"), isPresented: $invalidFolder) {
                VStack {
                    Button("Close", role: .cancel) {}
                }
            } message: {
                Text("\(String(localized: "alert_InvalidFolderMsg")) \(lastPathComponent ?? "")")
            }
            .padding(20)
        }
    }
}
