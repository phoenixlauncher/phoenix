//
//  DragDropFilePicker.swift
//  Phoenix
//
//  Created by Benammi Swift on 02/03/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct DragDropFilePickerButton: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    @Binding var launcher: String;
    
    @State private var isImporting: Bool = false
    @State var appURL: URL?
    
    var body: some View {
        Button(action: {
            isImporting.toggle()
        }, label: {
            Text("Application goes here")
                .foregroundColor(.gray)
                .padding()
        })
        .background(Color(red: 0, green: 0, blue: 0.5))
        .fileImporter(isPresented: $isImporting , allowedContentTypes: [.application], allowsMultipleSelection: false)
        { result in
            do {
                let selectedAppURL: URL = try result.get().first ?? URL(fileURLWithPath: "")
                appURL = selectedAppURL
                if let appURL = appURL {
                    launcher = "open \"\(appURL.absoluteString)\""
                } else {
                    appViewModel.failureToastText = "Unable to create application launch command"
                    appViewModel.showFailureToast.toggle()
                }
            }
            catch {
                appViewModel.failureToastText = "Unable to create application launch command"
                appViewModel.showFailureToast.toggle()
            }
       }
        .onDrop(of: [.application], isTargeted: nil) { selectedApp in
            handleDrop(providers: selectedApp)
            return true
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            print(provider)
            // Check if the dropped item is a file URL
            provider.loadItem(forTypeIdentifier: UTType.application.identifier, options: nil) { item, error in
                if let url = (item as? URL) {
                    // Update the droppedURL state
                    self.appURL = url
                    if let appURL = appURL {
                        launcher = "open \"\(appURL.absoluteString)\""
                    } else {
                        appViewModel.failureToastText = "Unable to create application launch command"
                        appViewModel.showFailureToast.toggle()
                    }
                }
            }
        }
    }
}
