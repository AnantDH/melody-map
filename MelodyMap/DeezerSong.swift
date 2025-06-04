//
//  DeezerSong.swift
//  MelodyMap
//
//  Created by Anant Dhokia on 6/3/25.
//

import Foundation

struct DeezerSearchResponse: Codable {
    let data: [DeezerSong]
}

struct DeezerSong: Identifiable, Codable {
    var id: Int
    let title: String
    let artist: DeezerArtist
    let album: DeezerAlbum
    let preview: String?
}

struct DeezerArtist: Codable {
    let name: String
}

struct DeezerAlbum: Codable {
    let cover_medium: String
}

