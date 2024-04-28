//
//  SupabaseGame.swift
//  Phoenix
//
//  Created by jxhug on 12/29/23.
//

struct SupabaseGame: Decodable, Hashable {
    var igdb_id: Int
    var steam_id: String?
    var release_date: Int?
    var developer: String?
    var header_img: String?
    var cover: String?
    var screenshots: [String]?
    var storyline: String?
    var summary: String?
    var genre: String?
    var publisher: String?
    var icon: String?
    var name: String?
}

struct SupabaseHeader: Decodable, Hashable {
    var header_img: String?
}

struct SupabaseScreenshots: Decodable, Hashable {
    var screenshots: [String]?
}

struct SupabaseIgdbID: Decodable, Hashable {
    var igdb_id: Int
}

