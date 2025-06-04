//
//  MelodyPin.swift
//  MelodyMap
//
//  Created by Anant Dhokia on 6/3/25.
//

import Foundation
import CoreLocation

struct MelodyPin: Identifiable, Codable {
    var id: UUID = UUID()
    var song: DeezerSong
    var latitude: Double
    var longitude: Double
    var note: String?
    var timestamp: Date
    var photoFilename: String?

    init(song: DeezerSong, coordinate: CLLocationCoordinate2D, note: String? = nil, photoFilename: String? = nil) {
        self.song = song
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.note = note
        self.timestamp = Date()
        self.photoFilename = photoFilename
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}


