//
//  AddGameView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-27.
//
import Foundation
import SwiftUI

struct AddGameView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var nameInput: String = ""
    @State private var iconInput: String = ""
    @State private var iconOutput: String = ""
    @State private var platInput: Platform = .none
    @State private var statusInput: Status = .none
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
                    TextField("Enter game name", text: $nameInput)
                        .padding()
                        .accessibility(label: Text("NameInput"))
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

                        // Resize the image to 48x48 pixels
                        if let image = NSImage(data: iconData) {
                            let newSize = NSSize(width: 48, height: 48)
                            let newImage = NSImage(size: newSize)

                            newImage.lockFocus()
                            image.draw(in: NSRect(origin: .zero, size: newSize),
                                       from: NSRect(origin: .zero, size: image.size),
                                       operation: .sourceOver,
                                       fraction: 1.0)
                            newImage.unlockFocus()

                            // Convert the resized image to data
                            if let resizedImageData = newImage.tiffRepresentation {
                                let fileManager = FileManager.default
                                let cachedImagesDirectoryURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                                    .appendingPathComponent("Phoenix/cachedImages", isDirectory: true)

                                if !fileManager.fileExists(atPath: cachedImagesDirectoryURL.path) {
                                    do {
                                        try fileManager.createDirectory(at: cachedImagesDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                                        print("Created 'Phoenix/cachedImages' directory")
                                    } catch {
                                        fatalError("Failed to create 'Phoenix/cachedImages' directory: \(error.localizedDescription)")
                                    }
                                }

                                var destinationURL: URL

                                if selectedFile.pathExtension.lowercased() == "jpg" || selectedFile.pathExtension.lowercased() == "jpeg" {
                                    destinationURL = cachedImagesDirectoryURL.appendingPathComponent("\(nameInput)_icon.jpg")
                                } else {
                                    destinationURL = cachedImagesDirectoryURL.appendingPathComponent("\(nameInput)_icon.png")
                                }

                                do {
                                    try resizedImageData.write(to: destinationURL)
                                    iconOutput = destinationURL.relativeString
                                    print("Resized and saved image to: \(destinationURL.path)")
                                } catch {
                                    print("Failed to save resized image: \(error.localizedDescription)")
                                }
                            }
                        }
                    } catch {
                        // Handle failure.
                        print("Unable to process selected file")
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
                    Text("Status")
                        .frame(width: 70, alignment: .leading)
                    Picker("", selection: $statusInput) {
                        ForEach(Status.allCases) { status in
                            Text(status.displayName)
                        }
                    }
                    .labelsHidden()
                    .padding()
                }

                HStack {
                    Text("Command")
                        .frame(width: 70, alignment: .leading)
                    TextField("Enter terminal command to launch game", text: $cmdInput)
                        .padding()
                        .accessibility(label: Text("NameInput"))
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
                }
                Group {
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
                                destinationURL = cachedImagesDirectoryPath.appendingPathComponent("\(nameInput)_header.jpg")
                            } else {
                                destinationURL = cachedImagesDirectoryPath.appendingPathComponent("\(nameInput)_header.png")
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
                        TextField("X / 10", text: $rateInput)
                            .padding()
                            .accessibility(label: Text("RatingInput"))
                        
                    }
                    HStack {
                        Text("Developer")
                            .frame(width: 70, alignment: .leading)
                        TextField("Enter game developer", text: $devInput)
                            .padding()
                            .accessibility(label: Text("devInput"))
                        
                    }
                    HStack {
                        Text("Publisher")
                            .frame(width: 70, alignment: .leading)
                        TextField("Enter game publisher", text: $pubInput)
                            .padding()
                            .accessibility(label: Text("pubInput"))
                    }
                    HStack {
                        Text("Release Date")
                            .frame(width: 87, alignment: .leading)
                        DatePicker("", selection: $dateInput, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                    }
                }
            }
            .padding()

            Button(
                action: {
                    let dateFormatter: DateFormatter = {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .long
                        return formatter
                    }()

                    let newGame: Game = .init(
                        launcher: cmdInput,
                        metadata: [
                            "description": descInput,
                            "header_img": headOutput,
                            "last_played": "Never",
                            "rating": rateInput,
                            "genre": genreInput,
                            "developer": devInput,
                            "publisher": pubInput,
                            "release_date": dateFormatter.string(from: dateInput),
                        ],
                        icon: iconOutput,
                        name: nameInput,
                        platform: platInput,
                        status: statusInput,
                        is_deleted: false
                    )

                    games.append(newGame)
                    games = games.sorted()

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
                    Text("Save Game")
                }
            )
            .padding()
        }
        .frame(minWidth: 768, maxWidth: 1024, maxHeight: 2000)
    }
}
