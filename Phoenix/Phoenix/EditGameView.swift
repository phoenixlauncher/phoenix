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
                HStack {
                    Text("Name")
                        .frame(width: 70, alignment: .leading)
                    if currentGame.name == "" {
                        TextField("Enter game name", text: $nameInput)
                            .padding()
                            .accessibility(label: Text("NameInput"))
                    } else {
                        TextField(currentGame.name, text: $nameInput)
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
                            iconIsImporting = true

                        },
                        label: {
                            Text("Browse")
                        })
                    Text(iconInput)
                }
                .padding()
                .fileImporter(
                    isPresented: $iconIsImporting,
                    allowedContentTypes: [.image],
                    allowsMultipleSelection: false
                ) { result in
                    do {
                        let selectedFile: URL = try result.get().first ?? URL(fileURLWithPath: "")
                        iconInput = selectedFile.relativeString
                        
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
                            destinationURL = cachedImagesDirectoryPath.appendingPathComponent("\(currentGame.name)icon.jpg")
                        } else {
                            destinationURL = cachedImagesDirectoryPath.appendingPathComponent("\(currentGame.name)icon.png")
                        }
                        
                        do {
                            try iconData.write(to: destinationURL)
                            iconOutput = destinationURL.relativeString
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
                    Picker("", selection: $platInput) {
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
                    if currentGame.launcher == "" {
                        TextField("Enter terminal command to launch game", text: $cmdInput)
                            .padding()
                            .accessibility(label: Text("NameInput"))
                    } else {
                        TextField(currentGame.launcher, text: $cmdInput)
                            .padding()
                            .accessibility(label: Text("NameInput"))
                    }
                }

                HStack {
                    Text("Description")
                        .frame(width: 70, alignment: .leading)
                    TextEditor(text: $descInput)
                        .scrollContentBackground(.hidden)
                        .border(Color.gray.opacity(0.1), width: 1)
                        .background(Color.gray.opacity(0.05))
                        .frame(minHeight: 50)
                        .padding()
                }
                HStack {
                    Text("Genres")
                        .frame(width: 70, alignment: .leading)
                    TextEditor(text: $genreInput)
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
                            headIsImporting = true

                        },
                        label: {
                            Text("Browse")
                        })
                    Text(headInput)
                }
                .padding()
                .fileImporter(
                    isPresented: $headIsImporting,
                    allowedContentTypes: [.image],
                    allowsMultipleSelection: false
                ) { result in
                    do {
                        let selectedFile: URL = try result.get().first ?? URL(fileURLWithPath: "")
                        headInput = selectedFile.relativeString
                        
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
                            destinationURL = cachedImagesDirectoryPath.appendingPathComponent("\(currentGame.name)_header.jpg")
                        } else {
                            destinationURL = cachedImagesDirectoryPath.appendingPathComponent("\(currentGame.name)_header.png")
                        }
                        
                        do {
                            try headerData.write(to: destinationURL)
                            headOutput = destinationURL.relativeString
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
                    if currentGame.metadata["rating"] == "" {
                        TextField("X / 10", text: $rateInput)
                            .padding()
                            .accessibility(label: Text("RatingInput"))
                    } else {
                        TextField(currentGame.metadata["rating"] ?? "X / 10", text: $rateInput)
                            .padding()
                            .accessibility(label: Text("RatingInput"))
                    }
                    
                }
                HStack {
                    Text("Developer")
                        .frame(width: 70, alignment: .leading)
                    if currentGame.metadata["developer"] == "" {
                        TextField("Enter game developer", text: $devInput)
                            .padding()
                            .accessibility(label: Text("devInput"))
                    } else {
                        TextField(currentGame.metadata["developer"] ?? "Enter game developer", text: $devInput)
                            .padding()
                            .accessibility(label: Text("devInput"))
                    }
                    
                }
                HStack {
                    Text("Publisher")
                        .frame(width: 70, alignment: .leading)
                    if currentGame.metadata["publisher"] == "" {
                        TextField("Enter game publisher", text: $pubInput)
                            .padding()
                            .accessibility(label: Text("pubInput"))
                    } else {
                        TextField(currentGame.metadata["publisher"] ?? "Enter game publisher", text: $pubInput)
                            .padding()
                            .accessibility(label: Text("pubInput"))
                    }
                }
                HStack {
                    Text("Release Date")
                        .frame(width: 87, alignment: .leading)
                    DatePicker("", selection: $dateInput, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                }
            }
            .padding()
            Button(
                action: {
                    var dateInputStr = ""

                    if nameInput == "" {
                        nameInput = currentGame.name
                    }
                    if iconOutput == "" {
                        iconOutput = currentGame.icon
                    }
                    if platInput == .NONE {
                        platInput = currentGame.platform
                    }
                    if cmdInput == "" {
                        cmdInput = currentGame.launcher
                    }
                    if descInput == "" {
                        descInput = currentGame.metadata["description"] ?? ""
                    }
                    if headOutput == "" {
                        headOutput = currentGame.metadata["header_img"] ?? ""
                    }
                    if rateInput == "" {
                        rateInput = currentGame.metadata["rating"] ?? ""
                    }
                    if genreInput == "" {
                        genreInput = currentGame.metadata["genre"] ?? ""
                    }
                    if devInput == "" {
                        devInput = currentGame.metadata["developer"] ?? ""
                    }
                    if pubInput == "" {
                        pubInput = currentGame.metadata["publisher"] ?? ""
                    }
                    // check if the date is today, if yes then change it to the previous release date
                    if dateInput.formatted(date: .complete, time: .omitted) == Date().formatted(date: .complete, time: .omitted) {
                        dateInputStr = currentGame.metadata["release_date"] ?? ""
                    } else {
                        let dateFormatter: DateFormatter = {
                            let formatter = DateFormatter()
                            formatter.dateStyle = .long
                            return formatter
                        }()

                        dateInputStr = dateFormatter.string(from: dateInput)
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

                    let idx = games.firstIndex(where: { $0.name == currentGame.name })
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

                    dismiss()
                },
                label: {
                    Text("Save Changes")
                }
            )
            .padding()
        }
        .font(.system(size: 13))
        .frame(minWidth: 768, maxWidth: 1024, maxHeight: 2000)
        .onAppear() {
            nameInput = currentGame.name
            platInput = currentGame.platform
            cmdInput = currentGame.launcher
            descInput = currentGame.metadata["description"] ?? ""
            genreInput = currentGame.metadata["genre"] ?? ""
            rateInput = currentGame.metadata["rating"] ?? ""
            devInput = currentGame.metadata["developer"] ?? ""
            pubInput = currentGame.metadata["publisher"] ?? ""
            // Create Date Formatter
            let dateFormatter = DateFormatter()

            // Set Date Format
            dateFormatter.dateFormat = "MMM dd, yyyy"
            // Convert String to Date
            dateInput = dateFormatter.date(from: currentGame.metadata["release_date"] ?? "") ?? Date()
        }
    }
}
