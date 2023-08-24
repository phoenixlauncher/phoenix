//
//  EditGameView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-28.
//
import Foundation
import SwiftUI

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(self.prefix(1)).uppercased()
        let other = String(self.dropFirst())
        return first + other
    }
}

struct EditGameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @Binding var currentGame: Game

    @State private var nameInput: String = ""
    @State private var iconInput: String = ""
    @State private var iconOutput: String = ""
    @State private var platInput: Platform = .NONE
    @State private var cmdInput: String = ""
    @State private var descInput: String = ""
    @State private var headInput: String = ""
    @State private var headOutput: String = ""
    @State private var rateInput: String = ""
    @State private var genreInput: String = ""
    @State private var devInput: String = ""
    @State private var pubInput: String = ""
    @State private var dateInput: Date = .now
    @State private var iconIsImporting: Bool = false
    @State private var headIsImporting: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    HStack {
                        Text("Name")
                            .frame(width: 70, alignment: .leading)
                        if self.currentGame.name == "" {
                            TextField("Enter game name", text: self.$nameInput)
                                .padding()
                                .accessibility(label: Text("NameInput"))
                        } else {
                            TextField(self.currentGame.name, text: self.$nameInput)
                                .padding()
                                .accessibility(label: Text("NameInput"))
                        }
                    }
                    
                    HStack {
                        Text("Icon")
                            .frame(width: 70, alignment: .leading)
                            .offset(x: -15)
                        Button(
                            action: {
                                self.iconIsImporting = true
                                
                            },
                            label: {
                                Text("Browse")
                            }
                        )
                        Text(self.iconInput)
                    }
                    .padding()
                    .fileImporter(
                        isPresented: self.$iconIsImporting,
                        allowedContentTypes: [.image],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            let selectedFile: URL = try result.get().first ?? URL(fileURLWithPath: "")
                            self.iconInput = selectedFile.relativeString
                            
                            let iconData = try Data(contentsOf: selectedFile)
                            
                            let fileManager = FileManager.default
                            guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                                fatalError("Unable to retrieve application support directory URL")
                            }
                            
                            let cachedImagesDirectoryPath = appSupportURL.appendingPathComponent("Phoenix/cachedImages", isDirectory: true)
                            
                            if !fileManager.fileExists(atPath: cachedImagesDirectoryPath.path) {
                                do {
                                    try fileManager.createDirectory(at: cachedImagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
                                    print("Created 'Phoenix/cachedImages' directory")
                                } catch {
                                    fatalError("Failed to create 'Phoenix/cachedImages' directory: \(error.localizedDescription)")
                                }
                            }
                            
                            var destinationURL: URL
                            
                            if selectedFile.pathExtension.lowercased() == "jpg" || selectedFile.pathExtension.lowercased() == "jpeg" {
                                destinationURL = cachedImagesDirectoryPath.appendingPathComponent("\(self.currentGame.name)icon.jpg")
                            } else {
                                destinationURL = cachedImagesDirectoryPath.appendingPathComponent("\(self.currentGame.name)icon.png")
                            }
                            
                            do {
                                try iconData.write(to: destinationURL)
                                self.iconOutput = destinationURL.relativeString
                                print("Saved image to: \(destinationURL.path)")
                            } catch {
                                print("Failed to save image: \(error.localizedDescription)")
                            }
                        } catch {
                            // Handle failure.
                            print("Unable to write to file")
                            print(error.localizedDescription)
                        }
                    }
                    
                    HStack {
                        Text("Platform")
                            .frame(width: 70, alignment: .leading)
                        Picker("", selection: self.$platInput) {
                            ForEach(Platform.allCases) { platform in
                                Text(platform.displayName)
                            }
                        }
                        .labelsHidden()
                        .padding()
                    }
                    
                    HStack {
                        Text("Command")
                            .frame(width: 70, alignment: .leading)
                        if self.currentGame.launcher == "" {
                            TextField("Enter terminal command to launch game", text: self.$cmdInput)
                                .padding()
                                .accessibility(label: Text("NameInput"))
                        } else {
                            TextField(self.currentGame.launcher, text: self.$cmdInput)
                                .padding()
                                .accessibility(label: Text("NameInput"))
                        }
                    }
                    
                    HStack {
                        Text("Description")
                            .frame(width: 70, alignment: .leading)
                        TextEditor(text: self.$descInput)
                            .scrollContentBackground(.hidden)
                            .border(Color.gray.opacity(0.1), width: 1)
                            .background(Color.gray.opacity(0.05))
                            .frame(minHeight: 50)
                            .padding()
                    }
                }
                Group {
                    HStack {
                        Text("Genres")
                            .frame(width: 70, alignment: .leading)
                        TextEditor(text: self.$genreInput)
                            .scrollContentBackground(.hidden)
                            .border(Color.gray.opacity(0.1), width: 1)
                            .background(Color.gray.opacity(0.05))
                            .frame(minHeight: 50)
                            .padding()
                    }
                    HStack {
                        Text("Header")
                            .frame(width: 70, alignment: .leading)
                            .offset(x: -15)
                        Button(
                            action: {
                                self.headIsImporting = true
                                
                            },
                            label: {
                                Text("Browse")
                            }
                        )
                        Text(self.headInput)
                    }
                    .padding()
                    .fileImporter(
                        isPresented: self.$headIsImporting,
                        allowedContentTypes: [.image],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            let selectedFile: URL = try result.get().first ?? URL(fileURLWithPath: "")
                            self.headInput = selectedFile.relativeString
                            
                            let headerData = try Data(contentsOf: selectedFile)
                            
                            let fileManager = FileManager.default
                            guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                                fatalError("Unable to retrieve application support directory URL")
                            }
                            
                            let cachedImagesDirectoryPath = appSupportURL.appendingPathComponent("Phoenix/cachedImages", isDirectory: true)
                            
                            if !fileManager.fileExists(atPath: cachedImagesDirectoryPath.path) {
                                do {
                                    try fileManager.createDirectory(at: cachedImagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
                                    print("Created 'Phoenix/cachedImages' directory")
                                } catch {
                                    fatalError("Failed to create 'Phoenix/cachedImages' directory: \(error.localizedDescription)")
                                }
                            }
                            
                            var destinationURL: URL
                            
                            if selectedFile.pathExtension.lowercased() == "jpg" || selectedFile.pathExtension.lowercased() == "jpeg" {
                                destinationURL = cachedImagesDirectoryPath.appendingPathComponent("\(self.currentGame.name)_header.jpg")
                            } else {
                                destinationURL = cachedImagesDirectoryPath.appendingPathComponent("\(self.currentGame.name)_header.png")
                            }
                            
                            do {
                                try headerData.write(to: destinationURL)
                                self.headOutput = destinationURL.relativeString
                                print("Saved image to: \(destinationURL.path)")
                            } catch {
                                print("Failed to save image: \(error.localizedDescription)")
                            }
                        } catch {
                            // Handle failure.
                            print("Unable to write to file")
                            print(error.localizedDescription)
                        }
                    }
                    HStack {
                        Text("Rating")
                            .frame(width: 70, alignment: .leading)
                        if self.currentGame.metadata["rating"] == "" {
                            TextField("X / 10", text: self.$rateInput)
                                .padding()
                                .accessibility(label: Text("RatingInput"))
                        } else {
                            TextField(self.currentGame.metadata["rating"] ?? "X / 10", text: self.$rateInput)
                                .padding()
                                .accessibility(label: Text("RatingInput"))
                        }
                    }
                    HStack {
                        Text("Developer")
                            .frame(width: 70, alignment: .leading)
                        if self.currentGame.metadata["developer"] == "" {
                            TextField("Enter game developer", text: self.$devInput)
                                .padding()
                                .accessibility(label: Text("devInput"))
                        } else {
                            TextField(self.currentGame.metadata["developer"] ?? "Enter game developer", text: self.$devInput)
                                .padding()
                                .accessibility(label: Text("devInput"))
                        }
                    }
                    HStack {
                        Text("Publisher")
                            .frame(width: 70, alignment: .leading)
                        if self.currentGame.metadata["publisher"] == "" {
                            TextField("Enter game publisher", text: self.$pubInput)
                                .padding()
                                .accessibility(label: Text("pubInput"))
                        } else {
                            TextField(self.currentGame.metadata["publisher"] ?? "Enter game publisher", text: self.$pubInput)
                                .padding()
                                .accessibility(label: Text("pubInput"))
                        }
                    }
                    HStack {
                        Text("Release Date")
                            .frame(width: 87, alignment: .leading)
                        DatePicker("", selection: self.$dateInput, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                    }
                }
            }
            .padding()
            HStack {
                Spacer().frame(maxWidth: .infinity)

                Button(
                    action: {
                        var dateInputStr = ""

                        if self.nameInput == "" {
                            self.nameInput = self.currentGame.name
                        }
                        if self.iconOutput == "" {
                            self.iconOutput = self.currentGame.icon
                        }
                        if self.platInput == .NONE {
                            self.platInput = self.currentGame.platform
                        }
                        if self.cmdInput == "" {
                            self.cmdInput = self.currentGame.launcher
                        }
                        if self.descInput == "" {
                            self.descInput = self.currentGame.metadata["description"] ?? ""
                        }
                        if self.headOutput == "" {
                            self.headOutput = self.currentGame.metadata["header_img"] ?? ""
                        }
                        if self.rateInput == "" {
                            self.rateInput = self.currentGame.metadata["rating"] ?? ""
                        }
                        if self.genreInput == "" {
                            self.genreInput = self.currentGame.metadata["genre"] ?? ""
                        }
                        if self.devInput == "" {
                            self.devInput = self.currentGame.metadata["developer"] ?? ""
                        }
                        if self.pubInput == "" {
                            self.pubInput = self.currentGame.metadata["publisher"] ?? ""
                        }
                        // check if the date is today, if yes then change it to the previous release date
                        if self.dateInput.formatted(date: .complete, time: .omitted) == Date().formatted(date: .complete, time: .omitted) {
                            dateInputStr = self.currentGame.metadata["release_date"] ?? ""
                        } else {
                            let dateFormatter: DateFormatter = {
                                let formatter = DateFormatter()
                                formatter.dateStyle = .long
                                return formatter
                            }()

                            dateInputStr = dateFormatter.string(from: self.dateInput)
                        }

                        let editedGame: Game = .init(
                            launcher: cmdInput,
                            metadata: [
                                "description": descInput,
                                "header_img": headOutput,
                                "rating": rateInput,
                                "genre": genreInput,
                                "developer": devInput,
                                "publisher": pubInput,
                                "release_date": dateInputStr,
                            ],
                            icon: iconOutput,
                            name: nameInput,
                            platform: platInput,
                            is_deleted: false
                        )

                        let idx = games.firstIndex(where: { $0.name == self.currentGame.name })
                        games[idx!] = editedGame

                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted

                        do {
                            let gamesJSON = try JSONEncoder().encode(games)

                            if var gamesJSONString = String(data: gamesJSON, encoding: .utf8) {
                                // Add the necessary JSON elements for the string to be recognized as type "Games" on next read
                                gamesJSONString = "{\"games\": \(gamesJSONString)}"
                                writeGamesToJSON(data: gamesJSONString)
                            }
                        } catch {
                            logger.write(error.localizedDescription)
                        }

                        self.dismiss()
                    },
                    label: {
                        Text("Save Changes")
                    }
                )
                .padding()
                .frame(maxWidth: .infinity)

                HStack {
                    Spacer()
                        .frame(maxWidth: .infinity)
                    Spacer()
                        .frame(maxWidth: .infinity)

                    Button (
                        action: {
                            openURL(URL(string: "https://github.com/PhoenixLauncher/Phoenix/blob/main/setup.md")!)
                        }, label: {
                            ZStack {
                                Circle()
                                    .strokeBorder(Color(NSColor.separatorColor), lineWidth: 0.5)
                                    .background(Circle().foregroundColor(Color(NSColor.controlColor)))
                                    .shadow(color: Color(NSColor.separatorColor).opacity(0.3), radius: 1)
                                    .frame(width: 20, height: 20)
                                Text("?").font(.system(size: 15, weight: .medium))
                            }
                        }
                    )
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity)

                }
            }
        }
        .font(.system(size: 13))
        .frame(idealWidth: 800)
        .onAppear {
            self.nameInput = self.currentGame.name
            self.platInput = self.currentGame.platform
            self.cmdInput = self.currentGame.launcher
            self.descInput = self.currentGame.metadata["description"] ?? ""
            self.genreInput = self.currentGame.metadata["genre"] ?? ""
            self.rateInput = self.currentGame.metadata["rating"] ?? ""
            self.devInput = self.currentGame.metadata["developer"] ?? ""
            self.pubInput = self.currentGame.metadata["publisher"] ?? ""
            // Create Date Formatter
            let dateFormatter = DateFormatter()

            // Set Date Format
            dateFormatter.dateFormat = "MMM dd, yyyy"
            // Convert String to Date
            self.dateInput = dateFormatter.date(from: self.currentGame.metadata["release_date"] ?? "") ?? Date()
        }
    }
}
