//
//  Platform.swift
//  Phoenix
//
//  Created by jxhug on 1/21/24.
//

import Foundation

struct Platform: Identifiable, Encodable, Decodable, Hashable {
    var id: UUID = UUID() // Identifier for platform
    var iconURL: String = "" // Iconify icon URL
    var name: String = "" // Name of game
    var gameType: String = "" // Type of game (app, bin, exe, z64)
    var gameDirectories: [String] = []
    var emulator: Bool = false
    var emulatorExecutable: String = ""
    var commandArgs: String = ""
    var commandTemplate: String = "" // Command template for launching ("open %@")
    var deletable: Bool = true
}
